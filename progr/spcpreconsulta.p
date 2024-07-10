{admcab.i}

def input  parameter par-rec-plani as recid.
def input  parameter par-rec-clien as recid.
def output parameter par-consultar as log init no. /*** Yes = Consultar ***/
def output parameter par-liberar   as log init yes.

def var vdevval     as dec format ">>>,>>9.99" label "Devolucao".
def var vfincod     like finan.fincod.
def var vprotot     like plani.platot.
def var vbonus      like plani.numero init 0.
def var vliqui      as dec. 
def var ventra      as dec. 
def var vparce      as dec.
def var vct         as int.
def var vtitdtven   as date.
def var ult-compra  as date.
def var v-acum      like clien.limcrd.
def var ventrefcom  as date format "99/99/9999".

def buffer bcpclien for cpclien.

/* Parametros */
def var vnroultimoscontratos as int init 0.

def shared temp-table tp-titulo like fin.titulo
    index dt-ven titdtven
    index titnum /*is primary unique*/ empcod
                 titnat 
                 modcod 
                 etbcod 
                 clifor 
                 titnum 
                 titpar.

def shared temp-table tp-contrato like fin.contrato.

def workfile wacum
    field mes  as int format "99"
    field ano  as int format "9999"
    field acum like plani.platot.

def temp-table tt-contrato
    field etbcod    like titulo.etbcod
    field titnum    like titulo.titnum

    field titdtemi  like titulo.titdtemi
    field atraso    as   int
    field vltotal as dec
    index contrato is primary unique etbcod titnum.

def var v-consultas as int init 0.
find clien where recid(clien) = par-rec-clien no-lock.

find first bcpclien where bcpclien.clicod = clien.clicod
                    exclusive-lock no-error.
                                    
if not avail bcpclien
then do:
    
    create bcpclien.
    assign bcpclien.clicod = clien.clicod.
    
end.

assign bcpclien.var-char11 = ""
       bcpclien.datexp     = today.

if clien.entrefcom[1] <> ?
then ventrefcom = date(clien.entrefcom[1]).
if clien.entrefcom[2] <> ?
then v-consultas = int(acha("Consultas", clien.entrefcom[2])).
if v-consultas = ?
then v-consultas = 0.

def var varquivo as char.
varquivo = "./logspc" + string(clien.clicod) + ".txt".

output to value(varquivo) append.
put "FASE 1 - INICIO" skip.
put clien.entrefcom[1] skip.
put clien.entrefcom[2] skip.
output close.

assign bcpclien.var-char11 = bcpclien.var-char11
                              + "# DATA DA ULTIMA PRE CONSULTA: "
                              + string(today,"99/99/9999")
                              + "|".

if acha("Ok", clien.entrefcom[2]) = "Sim"
    and (clien.dtcad = today or ventrefcom = today)
then do:

    assign bcpclien.var-char11 = bcpclien.var-char11
                           + "# NAO CONSULTAR E LIBERAR - CLIENTE JA FOI "
                           + "CONSULTADO NESTA DATA"
                           + "|  E NAO POSSUI REGISTROS.|".

    output to value(varquivo) append.
    put "FASE 2 - NAO CONSULTAR E LIBERAR " skip.
    output close.
    par-consultar = no.
    par-liberar = yes.
    leave. /* Procedure */
end.  

if acha("Ok", clien.entrefcom[2]) = "Nao" /* or
    clien.entrefcom[2] = ? or
    clien.entrefcom[2] = ""               */
then do.
    output to value(varquivo) append.
    put "FASE 3 - CONSULTAR" skip.
    output close.

    if ventrefcom <> ? and
       ventrefcom = today and
       v-consultas >= 3
    then do:
        output to value(varquivo) append.
        put "FASE 4 - NAO CONSULTAR E NAO LIBERAR " skip.
        output close.

        assign bcpclien.var-char11 = bcpclien.var-char11
                        + "# NAO CONSULTAR E NAO LIBERAR - CLIENTE JA FOI "
                        + "|  CONSULTADO 3 VEZES NESTA DATA E POSSUI REGISTROS."
                        + "|".
                           
        assign
        par-consultar = no
        par-liberar = no.
        leave. /* Procedure */
    end.    
    
    assign bcpclien.var-char11 = bcpclien.var-char11
                           + "# REALIZAR CONSULTA - CLIENTE FOI "
                           + "CONSULTADO EM " + string(ventrefcom,"99/99/9999") 
                           + " E POSSUI REGISTROS.|"
                           
    par-consultar = yes.
    leave. /* Procedure */

end.

assign
    par-consultar = no
    par-liberar = yes.
    
    vct = 0.
    for each tp-titulo where tp-titulo.modcod = "CRE" 
                         and tp-titulo.titpar > 0
                         and tp-titulo.titnat = no
                       no-lock
                       break by tp-titulo.titdtemi desc.

        if tp-titulo.titsit = "LIB" and
            today - tp-titulo.titdtven >= 45
        then do:
            output to value(varquivo) append.
            put "FASE 5 - NAO CONSULTAR E NAOLIBERAR" skip.
            output close.
            
            assign bcpclien.var-char11 = bcpclien.var-char11
                           + "# NAO CONSULTAR E NAO LIBERAR - "
                           + "CLIENTE POSSUI AO MENOS UMA PARCELA NAO PAGA "
                           + "|  COM MAIS DE 45 DIAS DE ATRASO.|".
                           
            assign
                par-liberar = no
                par-consultar = no.
            leave.
        end.
        
 
        /* Maior emissao e vencimento */
        assign
            vtitdtven    = if vtitdtven = ?
                           then tp-titulo.titdtven
                           else max(vtitdtven, tp-titulo.titdtven)
            ult-compra   = if ult-compra = ?
                           then tp-titulo.titdtemi
                           else max(ult-compra, tp-titulo.titdtemi).

        find tt-contrato where tt-contrato.etbcod = tp-titulo.etbcod
                           and tt-contrato.titnum = tp-titulo.titnum
                         no-error.
        if not avail tt-contrato
        then do.
            create tt-contrato.
            assign
                tt-contrato.etbcod   = tp-titulo.etbcod
                tt-contrato.titnum   = tp-titulo.titnum
                tt-contrato.titdtemi = tp-titulo.titdtemi.
        end.

        tt-contrato.vltotal = tt-contrato.vltotal + tp-titulo.titvlcob.
        
        if tp-titulo.titsit = "LIB"    
        then do.
            if today - tp-titulo.titdtven > tt-contrato.atraso
            then do.
                tt-contrato.atraso = today - tp-titulo.titdtven.
            end.
        end.
        else 
            if tp-titulo.titdtpag - tp-titulo.titdtven > tt-contrato.atraso
            then tt-contrato.atraso = tp-titulo.titdtpag - tp-titulo.titdtven.

        if tp-titulo.titpar <> 0 and tp-titulo.titdtpag <> ?
        then do:
 
            find first wacum where wacum.mes = month(tp-titulo.titdtpag) and
                                   wacum.ano = year(tp-titulo.titdtpag) 
                         no-error.
            if not avail wacum
            then do:
                create wacum.
                assign wacum.mes = month(tp-titulo.titdtpag)
                       wacum.ano = year(tp-titulo.titdtpag).
            end.
            wacum.acum = wacum.acum + tp-titulo.titvlcob.
        end.
        if substr(tp-titulo.titnum,1,1) <> "v"
        then do:
            find first tp-contrato where
                       tp-contrato.etbcod = tp-titulo.etbcod and
                       tp-contrato.contnum = int(tp-titulo.titnum)
                        no-error.
            if not avail tp-contrato
            then do:
                create tp-contrato.
                tp-contrato.etbcod = tp-titulo.etbcod.
                tp-contrato.contnum = int(tp-titulo.titnum).
                tp-contrato.dtinicial = tp-titulo.titdtemi.
            end.
            tp-contrato.vltotal = tp-contrato.vltotal + tp-titulo.titvlcob.    
        end.
    end.      
    if par-liberar = no
    then leave. /* Procedure */

    vct = 0.
    vnroultimoscontratos = 30.
    def var vvalmaiorcontrato as dec init 0.
    for each tp-contrato no-lock
            by tp-contrato.dtinicial descending:
        vct = vct + 1.
        if vct > vnroultimoscontratos
        then leave.
        if vvalmaiorcontrato < tp-contrato.vltotal
        then vvalmaiorcontrato = tp-contrato.vltotal.
    end.  
          
    vct = 0.
    vnroultimoscontratos = 3.
    for each tt-contrato 
            break by tt-contrato.titdtemi desc.
        
        if tt-contrato.atraso >= 60
        then DO:
    
            assign bcpclien.var-char11 = bcpclien.var-char11
                           + "# REALIZAR CONSULTA - "
                           + "CLIENTE POSSUI AO MENOS UM CONTRATO  "
                           + "|  COM MAIS DE 60 DIAS DE ATRASO.|".
                           
            
            output to value(varquivo) append.
            put "FASE 6 - ATRASO >= 60 CONSULTAR " skip.
            output close.
            par-consultar = yes.
        END.

        vct = vct + 1.
        if vct > vnroultimoscontratos
        then leave.

    end.
    if par-consultar = yes
    then leave. /* Procedure */

    if (ult-compra = ? and vtitdtven = ?) or
       (ult-compra <> ? and ult-compra < today - (365 * 2)) or
       (vtitdtven <> ? and vtitdtven < today - 365)
    then do.
                
        if ult-compra = ? or vtitdtven = ?
        then assign bcpclien.var-char11 = bcpclien.var-char11
                          + "# REALIZAR CONSULTA - "
                          + "CLIENTE AINDA NAO REALIZOU COMPRA OU "
                          + "NUNCA TEVE CONTRATO.|".
                          
        else                  
        assign bcpclien.var-char11 = bcpclien.var-char11
                          + "# REALIZAR CONSULTA - "
                          + "CLIENTE REALIZOU A ULTIMA COMPRA EM "
                          + string(ult-compra,"99/99/9999")
                          + "|  E SEU ULTIMO VENCIMENTO DE PARCELA FOI EM "
                          + string(vtitdtven,"99/99/9999")
                          + ".|".

        output to value(varquivo) append.
        put "FASE 7 - CONSULTAR " skip.
        PUT "ULTIMA COMPRA " ult-compra skip.
        put "ULTIMO VENCIMENTO " vtitdtven SKIP.
        output close.

        par-consultar = yes.
        leave. /* Procedure */
    end.

    for each wacum by wacum.acum:
        v-acum = wacum.acum.
    end.

    /*******************SOMA CREDSCOR******************/
    if par-rec-plani <> ?
    then do.
        find plani where recid(plani) = par-rec-plani no-lock.
        /* bloqueado em 25/02/2010
        find first credscor where credscor.clicod = plani.desti
                            no-lock no-error.
        if avail credscor
        then do:
    
            if credscor.dtultc > ult-compra
            then ult-compra = credscor.dtultc.        

            if credscor.valacu > v-acum
            then do:
                v-acum = credscor.valacu.
            end.    
        end.    
        */

        /*****************************************/

        /*
            Valor da prestacao - Habito de Consumo
        */
        
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:
            vprotot = (movim.movqtm * movim.movpc).
        end.
        
        if vprotot > 0 and
           plani.pedcod > 0
        then do.
            run gercpg1.p(input plani.pedcod, 
                          input vprotot, 
                          input vdevval, 
                          input vbonus, 
                          output vliqui, 
                          output ventra,
                          output vparce). 

            if vvalmaiorcontrato > 0 and
               vliqui > 0 and
               vliqui > vvalmaiorcontrato * 3
            then do.
            
                assign bcpclien.var-char11 = bcpclien.var-char11
                          + "# REALIZAR CONSULTA - "
                          + "CLIENTE ESTA MUDANDO HABITO DE COMPRA "
                          + "|  MAIOR CONTRATO "
                          + string(vvalmaiorcontrato,">>>,>>>,>>9.99")
                          + " E O VALOR ATUAL E DE "
                          + string(vliqui,">>>,>>>,>>9.99")
                          + ".|".

            
                output to value(varquivo) append.
                put "FASE 8 - CONSULTAR " skip.
                PUT "MAIOR CONTRATO " vvalmaiorcontrato skip.
                put "VALOR ATUAL " vliqui skip.
                output close.

                par-consultar = yes.
                leave. /* Procedure */
            end.
   
        end.
    end.



