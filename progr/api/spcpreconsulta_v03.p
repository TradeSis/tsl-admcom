/*#1 07.08.18 Parametro desativacao consulta SPC
  #2 03.10.18 Felipe - tabela para registro de log SPC
*/
{acha.i} /***WS {admcab.i}***/

/*** spcpreconsulta.p ***/
def input  parameter par-rec-plani as recid.
def input  parameter par-rec-clien as recid.
def output parameter par-consultar as log init no. /*** Yes = Consultar ***/
def output parameter par-liberar   as log init yes.

def var vdevval     as dec format ">>>,>>9.99" label "Devolucao".
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

/*#2*/
def var vResposta   as char.  
def var vCPF        as char.
def var vok as log.
def buffer bcpclien for cpclien.

/* Parametros */
def var vnroultimoscontratos as int init 0.

def shared temp-table tp-titulo like titulo
    field vliof as dec
    field vlcet as dec
    field vltfc as dec
    index dt-ven titdtven
    index titnum /*is primary unique*/ empcod
                 titnat 
                 modcod 
                 etbcod 
                 clifor 
                 titnum 
                 titpar.

def shared temp-table tp-contrato /***like contrato***/
    field contnum   like contrato.contnum
    field etbcod    like contrato.etbcod
    field dtinicial like contrato.dtinicial
    field vltotal   like contrato.vltotal
    index contrato is primary unique etbcod contnum.

def workfile wacum
    field mes  as int format "99"
    field ano  as int format "9999"
    field acum like plani.platot.

def temp-table tt-contrato
    field etbcod    like titulo.etbcod
    field titnum    like titulo.titnum

    field titdtemi  like titulo.titdtemi
    field atraso    as int
    field vltotal   as dec
    index contrato is primary unique etbcod titnum.

def var varqlog as char.
def var vlog    as log.
def var vconsultas as int init 0.
def var vhora   as int.
def var vparam  as char.

/* #1 */
run le_tabini.p (0, 0, "ConectaSPC", OUTPUT vparam).
if vparam = "Nao" /* today = 07/21/2018 */
then do.
    par-consultar = no.
    return.
end.

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

/*#2*/
vCPF = fill("0",11 - length(clien.ciccgc)) + clien.ciccgc.

find last ConsSPC where ConsSPC.CPF = vCPF no-lock no-error.
if avail ConsSPC 
then do:
    assign
        ventrefcom = ConsSPC.Data
        vhora      = ConsSPC.Hora.
    
    if ConsSPC.Resposta <> ?
    then assign
            vResposta  = ConsSPC.Resposta
            vconsultas = int(acha("Consultas", ConsSPC.Resposta)).
end.
else do:
    if clien.entrefcom[1] <> ?
    then ventrefcom = date(clien.entrefcom[1]) no-error.
    if clien.entrefcom[2] <> ?
    then assign
            vResposta  = clien.entrefcom[2]
            vconsultas = int(acha("Consultas", clien.entrefcom[2]))
            vhora      = int(acha("Hora", clien.entrefcom[2])).
end.

if vconsultas = ?
then vconsultas = 0.
if vhora = ?
then vhora = 0.

if vlog
then do.
    varqlog = "/ws/log/pre-spc_" + string(today,"999999") + "_" +
              string(clien.clicod) + ".log".
    unix silent rm -f value(varqlog).
    run gera-log ("FASE 1 - INICIO", 
                  ventrefcom /*clien.entrefcom[1]*/, 
                  vResposta /*clien.entrefcom[2]*/).
end.

assign bcpclien.var-char11 = bcpclien.var-char11
                              + "# DATA DA ULTIMA PRE CONSULTA: "
                              + string(today,"99/99/9999")
                              + "|".

if acha("Ok", vResposta /*clien.entrefcom[2]*/ ) = "Sim"
   and (clien.dtcad = today or ventrefcom = today)
then do:
    assign bcpclien.var-char11 = bcpclien.var-char11
                           + "# NAO CONSULTAR E LIBERAR - CLIENTE JA FOI "
                           + "CONSULTADO NESTA DATA"
                           + "|  E NAO POSSUI REGISTROS.|".
    if vlog
    then run gera-log ("FASE 2 - NAO CONSULTAR E LIBERAR", "", "").
    par-consultar = no.
    par-liberar = yes.
    return.
end.  

if acha("Ok", vResposta /*clien.entrefcom[2]*/) = "Nao" /* or
    clien.entrefcom[2] = ? or
    clien.entrefcom[2] = ""               */
then do.
    if vlog
    then run gera-log ("FASE 3 - CONSULTAR", "", "").

    /* #1 */
    if ventrefcom = today and
       vhora > 0 and
       time - vhora <= 5400 /* 1 hora */
    then do:
        if vlog
        then run gera-log ("FASE 4 - NAO CONSULTAR E NAO LIBERAR", "", "").

        assign bcpclien.var-char11 = bcpclien.var-char11
                        + "# NAO CONSULTAR E NAO LIBERAR - CLIENTE JA FOI "
                        + "|  CONSULTADO A MENOS DE 1 HORA."
                        + "|".
        assign
            par-consultar = no
            par-liberar = no.
        return.
    end.

    if ventrefcom <> ? and
       ventrefcom = today and
       vconsultas >= 2 /* 05/06/2012 */
    then do:
        if vlog
        then run gera-log ("FASE 4 - NAO CONSULTAR E NAO LIBERAR", "", "").

        assign bcpclien.var-char11 = bcpclien.var-char11
                        + "# NAO CONSULTAR E NAO LIBERAR - CLIENTE JA FOI "
                        + "|  CONSULTADO 2 VEZES NESTA DATA E POSSUI REGISTROS."
                        + "|".
        assign
            par-consultar = no
            par-liberar = no.
        return.
    end.    
    
    assign bcpclien.var-char11 = bcpclien.var-char11
                      + "# REALIZAR NOVA CONSULTA - A ULTIMA"
                      + "CONSULTA FOI EM " + string(ventrefcom,"99/99/9999") 
                      + " E O CLIENTE JA POSSUIA REGISTROS.|"
                           
    par-consultar = yes.
    return.
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
            if vlog
            then run gera-log ("FASE 5 - NAO CONSULTAR E NAOLIBERAR", "", "").

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
            then tt-contrato.atraso = today - tp-titulo.titdtven.
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
    then return.

    vct = 0.
    vnroultimoscontratos = 20. /* 05/06/2012 */
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
            if vlog
            then run gera-log("FASE 6 - ATRASO >= 60 CONSULTAR", "", "").
            par-consultar = yes.
        END.

        vct = vct + 1.
        if vct > vnroultimoscontratos
        then leave.

    end.
    if par-consultar = yes
    then return.

    if (ult-compra = ? and vtitdtven = ?) or
       (ult-compra <> ? and ult-compra < today - (365 * 2)) or
       (vtitdtven <> ? and vtitdtven < today - 365)
    then do.

        if ult-compra <> ? and vtitdtven <> ?
        then assign bcpclien.var-char11 = bcpclien.var-char11
                          + "# REALIZAR CONSULTA - "
                          + "CLIENTE REALIZOU A ULTIMA COMPRA EM "
                          + string(ult-compra,"99/99/9999")
                          + "|  E SEU ULTIMO VENCIMENTO DE PARCELA FOI EM "
                          + string(vtitdtven,"99/99/9999")
                          + ".|".
        
        else assign bcpclien.var-char11 = bcpclien.var-char11
                          + "# REALIZAR CONSULTA - "
                          + "CLIENTE AINDA NAO REALIZOU COMPRA "
                          + "OU NUNCA TEVE CONTRATO"
                          + ".|".
        if vlog
        then run gera-log("FASE 7 - CONSULTAR",
                          "ULTIMA COMPRA " + string(ult-compra),
                          "ULTIMO VENCIMENTO " + string(vtitdtven)).
        par-consultar = yes.
        return.
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
               vliqui > vvalmaiorcontrato * 4 /* 05/06/2012 */
            then do.
                assign bcpclien.var-char11 = bcpclien.var-char11
                          + "# REALIZAR CONSULTA - "
                          + "CLIENTE ESTA MUDANDO HABITO DE COMPRA "
                          + "|  MAIOR CONTRATO "
                          + string(vvalmaiorcontrato,">>>,>>>,>>9.99")
                          + " E O VALOR ATUAL E DE "
                          + string(vliqui,">>>,>>>,>>9.99")
                          + ".|".
                if vlog
                then run gera-log("FASE 8 - CONSULTAR",
                                 "MAIOR CONTRATO " + string(vvalmaiorcontrato),
                                 "VALOR ATUAL " + string(vliqui)).
                par-consultar = yes.
                return.
            end.
        end.
    end.

procedure gera-log.
    def input parameter par-linha1 as char.
    def input parameter par-linha2 as char.
    def input parameter par-linha3 as char.
            
    output to value(varqlog) append.
    put unformatted string(time, "hh:mm:ss") " " par-linha1 skip.
    if par-linha2 <> ""
    then put unformatted par-linha2 skip.
    if par-linha3 <> ""
    then put unformatted par-linha3 skip.
    output close.

end procedure.
                    
    
