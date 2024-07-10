{admcab.i}
/*
pause 0 before-hide.
*/

/*
message "Programa atual 04/01/2016  ". pause.
*/

def var p-seguro as dec.
def var p-principal as dec.
def var p-acrescimo as dec.
def var p-juros as dec.
def var p-crepes as dec.

def var vi as int.
def var vb as int.

def var p-sitlan as char.
def var p-tiplan as char.

def buffer btitulo for fin.titulo.

def temp-table tt-tabdac like tabdac.

def temp-table tt-rec-moe
    field etbcod like estab.etbcod
    field datref as date
    field moecod like fin.moeda.moecod
    field valor as dec
    index i1 etbcod moecod.

def buffer moeda for fin.moeda.

def shared var vdti as date.
def shared var vdtf as date.
def temp-table t-titulo like fin.titulo.
def buffer btitulosal for titulosal. 
def var vcfinacr as dec.
def var vcfinan as dec.
def var vrecrng as dec.
def var vjurorng as dec.

def var vcontratodd as dec.
def var vtp as char format "x(20)" extent 3
init["GERAL","EMISSAO","RECEBIMENTO"].
def var v-index as int.
/*
disp vtp with frame f1 no-label.
choose field vtp with frame f1.
v-index = frame-index.
*/
v-index = 1.
def var vnov as log.
def var vetb-pag like estab.etbcod.

DEF VAR VRENEG AS DEC.

def temp-table tt-recmoeda
    field etbcod like estab.etbcod
    field datref as date
    field moecod like fin.moeda.moecod
    field valor  as dec
    index i1 etbcod datref moecod.

def temp-table tt-contnov like fin.contrato.
def temp-table tt-contdat like fin.contrato.
    
def temp-table tt-venda like tabdicem.
def temp-table tt-receb like tabdicre.

def var vest as dec.
def var vrec1 as dec.
def var vrec2 as dec.

def var vemissao as dec.
def var vrecebimento as dec.
def var vjuro as dec.
def var vtitvlcob as dec.

def var v-devol as dec.
def var v-estorno as dec.
def var vacrescimo as dec.
def var vemiacre as dec.
def temp-table tt-estab
    field etbcod like estab.etbcod
    .
for each estab.
create tt-estab.
tt-estab.etbcod = estab.etbcod .
end.
def var vdia as int.
def var vmes as int.
def var vano as int.

def var varqexp as char.
def stream tl .
def var vdata1 as date. 
def var vhist as char.
def var varquivo as char.
def var vetbcod like estab.etbcod.
    if opsys = "unix"
        then varqexp = 
            "/admcom/relat/titdc_" + 
                trim(string(vetbcod,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
        else varqexp = 
            "l:\audit\titdc_" + trim(string(vetbcod,"999")) + "_" + 
                string(day(vdti),"99") +   
                string(month(vdti),"99") +   
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +   
                string(month(vdtf),"99") +   
                string(year(vdtf),"9999") + ".txt".
      
def var vrecebe-ant as dec.

def var vclifor as char.

def temp-table tt-contrato 
    field dtinicial like fin.contrato.dtinicial
    field contnum like fin.contrato.contnum
    field vltotal like fin.contrato.vltotal
    field vlacres as dec
    .

def temp-table n-contrato like fin.contrato.
def temp-table n-titulo like fin.titulo.
def temp-table fc-contrato like fin.contrato.
def temp-table d-contrato like fin.contrato.
def temp-table e-contrato like fin.contrato.
def temp-table tit-vista like fin.titulo.
 
def var val-novacao as dec.
def var vtitnum like fin.titulo.titnum.
output to value(varqexp).
output stream tl to terminal.

def var v-principal as dec.
def var v-acrescimo as dec.
def var v-novacao as log format "Sim/Nao".
def var v-financiado as dec.
def var v-clientes as dec.
def var v-seguro as dec.
def var v-crepes as dec.

def new shared temp-table tit-novado like fin.titulo.

for each tt-tabdac: delete tt-tabdac. end.
/*update vdti label "Periodo" vdtf label "a" with frame f2 side-label.
*/
sresp = no.
Message "Confirma iniciar processamento?" update sresp.
if not sresp then return.

for each tt-estab  no-lock:       
    if tt-estab.etbcod >= 900 and
       tt-estab.etbcod <> 993
    then vetb-pag = 996.
    else vetb-pag = tt-estab.etbcod.

    for each tt-contdat: delete tt-contdat. end.
        
    do vdata1 = vdti to vdtf:
        disp stream tl "Processando ... " tt-estab.etbcod vdata1 
                with frame fxy1 no-label 1 down centered no-box
                color message .
        pause 0.

        vdia = day(vdata1).
        vmes = month(vdata1).
        vano = year(vdata1).
            
        create tt-venda.
        assign
            tt-venda.etbcod = tt-estab.etbcod
            tt-venda.datref = vdata1.

        create tt-receb.
        assign
            tt-receb.etbcod = tt-estab.etbcod
            tt-receb.datref = vdata1.
        
        for each n-contrato: delete n-contrato. end.
        for each n-titulo: delete n-titulo. end.    
        for each fc-contrato: delete fc-contrato. end.
        for each d-contrato: delete d-contrato. end.
        for each e-contrato: delete e-contrato. end.
        for each tit-novado: delete tit-novado. end.
        for each tit-vista: delete tit-vista. end.

        assign
            p-principal = 0
            p-acrescimo = 0
            p-juros = 0.
            
        /**** EMISSÕES ****/      

        if v-index = 1 or v-index = 2 or v-index = 3
        then do:
            for each fin.contrato where contrato.etbcod = tt-estab.etbcod and
                                    contrato.dtinicial = vdata1
                                    no-lock:
                if contrato.vltotal <= 0
                then next.

                find first envfinan where 
                           envfinan.empcod = 19
                       and envfinan.titnat = no
                       and envfinan.modcod = "CRE"
                       and envfinan.etbcod = contrato.etbcod
                       and envfinan.clifor = contrato.clicod
                       and envfinan.titnum = string(contrato.contnum)
                           no-lock no-error.

                assign
                    v-principal = 0
                    v-acrescimo = 0
                    v-novacao = no
                    v-financiado = 0
                    v-clientes = 0
                    vtitvlcob = 0
                    vacrescimo = 0
                    v-seguro = 0
                    v-crepes = 0
                    .
                
                run retorna-principal-acrescimo-contrato.p
                        (input recid(contrato), 
                         output v-novacao,
                         output v-financiado,
                         output v-clientes,
                         output v-principal, 
                         output v-acrescimo,
                         output v-seguro,
                         output v-crepes).


                if v-seguro > 0
                then do:
                    assign
                        tt-venda.define_venda_seguro[1] = "SEG - SEGURO"
                        tt-venda.venda_seguro[1] = 
                        tt-venda.venda_seguro[1] + v-seguro.
                    if v-novacao
                    then tt-venda.venda_seguro_novacao =
                                tt-venda.venda_seguro_novacao + v-seguro.
                    else if v-financiado > 0 
                    then tt-venda.venda_seguro_fdrebes =
                                tt-venda.venda_seguro_fdrebes + v-seguro.
                    else tt-venda.venda_seguro_lebes =
                                tt-venda.venda_seguro_lebes + v-seguro.
                end.
                if v-crepes > 0
                then do:
                    assign
                        tt-venda.define_venda_cpess[1] = "CP - CREDITO PESSOAL"
                        tt-venda.venda_cpess[1] = 
                        tt-venda.venda_cpess[1] + v-crepes
                        tt-venda.venda_seguro_fdrebes =
                            tt-venda.venda_seguro_fdrebes + v-crepes.
                        .
                end.
                if v-index = 1 or v-index = 2
                then do:
                if v-principal > 0 and not v-novacao
                then do:
                    assign
                        vtitvlcob = v-principal
                        vacrescimo = v-acrescimo .
                        
                    find first fin.contnf where 
                         contnf.etbcod = contrato.etbcod and
                         contnf.contnum = contrato.contnum
                         no-lock no-error.
                    if avail contnf
                    then do:
                        find first com.plani where 
                                plani.etbcod = contnf.etbcod and
                                plani.placod = contnf.placod and
                                plani.movtdc = 5 and
                                plani.pladat = contrato.dtinicial
                                no-lock no-error.
                        if avail plani and
                                substr(plani.notped,1,1) = "C" and
                                (plani.ufemi <> "" or
                                 (plani.ufdes <> "" and
                                  plani.ufdes <> "C"))
                        then do: 
                    
                            if avail envfinan and envfinan.envsit <> "EXC"
                            then p-sitlan = "FINANCEIRA".
                            else p-sitlan = "LEBES".
                            run put-contrato.
                        end.
                        else do:
                            p-sitlan = "SEMCUPOM".
                            run put-contrato.        
                        end.            
                    end.
                    else do:
                        find first com.plani where 
                                plani.etbcod = contrato.etbcod and
                                plani.emite  = contrato.etbcod and
                                plani.desti  = contrato.clicod and
                                plani.movtdc = 5 and
                                plani.pladat = contrato.dtinicial
                                no-lock no-error.
                        if avail plani and
                                substr(plani.notped,1,1) = "C" and
                                (plani.ufemi <> "" or
                                 (plani.ufdes <> "" and
                                  plani.ufdes <> "C"))
                        then do: 
                            if avail envfinan and envfinan.envsit <> "EXC"
                            then p-sitlan = "FINANCEIRA".
                            else p-sitlan = "LEBES".
                            run put-contrato.
                        end.
                        else do:
                            p-sitlan = "SEMCUPOM".
                            run put-contrato.        
                        end. 
                        /*p-sitlan = "OUTROS".
                        run put-contrato.
                        */
                    end.               
                end.
                else if v-principal > 0
                then do:
                    
                    if v-financiado > 0
                    then  assign
                                tt-venda.novacao_fdrebes =
                                tt-venda.novacao_fdrebes + v-financiado
                                tt-venda.acrescimo_novacao_fdrebes =
                                tt-venda.acrescimo_novacao_fdrebes + 
                                    (v-acrescimo * (v-financiado / v-principal))
                                    .
                    if v-clientes > 0
                    then assign
                            tt-venda.novacao_lebes =
                            tt-venda.novacao_lebes + v-clientes
                            tt-venda.acrescimo_novacao_lebes =
                            tt-venda.acrescimo_novacao_lebes +
                            (v-acrescimo * (v-clientes / v-principal))
                            .
            
                    create n-contrato.
                    buffer-copy fin.contrato to n-contrato.
                    n-contrato.vlfrete = v-principal.
                
                
                
                end.
                else do:

                    assign
                        vtitvlcob  = contrato.vltotal
                        vacrescimo = 0
                        p-sitlan = "OUTROS"
                        .
                    run put-contrato.    
 
                end.
                end.
            end.
                
            if v-index = 1 or v-index = 2
            then do:
            /*** Adicional ***/

            for each contratodd where contratodd.etbcod = tt-estab.etbcod and
                                    contratodd.dtinicial = vdata1
                                    no-lock:

                if contratodd.crecod = 999
                then next.
          
                vtitvlcob = contratodd.vltotal.
                
                if vtitvlcob <= 0
                then next.
                p-sitlan = "LEBES".
                run put-contratodd.
            end.    
            
            /*** Novacao ***/           
            for each n-contrato no-lock.
                vtitvlcob = n-contrato.vlfrete.
                vacrescimo = n-contrato.vltotal - n-contrato.vlfrete.
                if n-contrato.banco = 10
                then p-sitlan = "FINANCEIRA".
                else p-sitlan = "LEBES".
                run put-contratonov.
            end.           
        
            /*** Cancelamento financeira ****/
            
            for each envfinan where 
                     envfinan.etbcod = tt-estab.etbcod and
                     envfinan.envsit = "CAN" and
                     envfinan.dt1 = vdata1
                     no-lock.
                     
                find first fin.titulo where
                           titulo.empcod = envfinan.empcod and
                           titulo.titnat = envfinan.titnat and
                           titulo.modcod = envfinan.modcod and
                           titulo.etbcod = envfinan.etbcod and
                           titulo.clifor = envfinan.clifor and
                           titulo.titnum = envfinan.titnum and
                           titulo.titpar = envfinan.titpar
                           no-lock no-error.
                if not avail titulo then next.
                           
                find first fc-contrato where
                          fc-contrato.contnum = int(envfinan.titnum)
                          no-error.
                if not avail fc-contrato
                then do:
                    create fc-contrato.
                    assign
                        fc-contrato.contnum   = int(envfinan.titnum)
                        fc-contrato.etbcod    = envfinan.etbcod 
                        fc-contrato.clicod    = envfinan.clifor 
                        fc-contrato.dtinicial = envfinan.dt1 
                        .
                end.
                fc-contrato.vltotal = 
                    fc-contrato.vltotal + titulo.titvlcob.
            end.

            /*** Estorno financeira ****/
            for each envfinan where 
                     envfinan.etbcod = tt-estab.etbcod and
                     envfinan.envsit = "EST" and
                     envfinan.dt1 = vdata1
                     no-lock.
                     
                find first fin.titulo where
                           titulo.empcod = envfinan.empcod and
                           titulo.titnat = envfinan.titnat and
                           titulo.modcod = envfinan.modcod and
                           titulo.etbcod = envfinan.etbcod and
                           titulo.clifor = envfinan.clifor and
                           titulo.titnum = envfinan.titnum and
                           titulo.titpar = envfinan.titpar
                           no-lock no-error.
                if not avail titulo then next.
                           
                find first fc-contrato where
                          fc-contrato.contnum = int(envfinan.titnum)
                          no-error.
                if not avail fc-contrato
                then do:
                    create fc-contrato.
                    assign
                        fc-contrato.contnum   = int(envfinan.titnum)
                        fc-contrato.etbcod    = envfinan.etbcod 
                        fc-contrato.clicod    = envfinan.clifor 
                        fc-contrato.dtinicial = envfinan.dt1 
                        .
                end.
                fc-contrato.vltotal = 
                    fc-contrato.vltotal + titulo.titvlcob.
                
            end.
            for each fc-contrato no-lock:
     
                find fin.contrato where contrato.contnum =
                            fc-contrato.contnum no-lock no-error.
                if not avail contrato then next.            
                
                assign
                    v-principal = 0
                    v-acrescimo = 0
                    v-novacao = no
                    v-financiado = 0
                    v-clientes = 0
                    vtitvlcob = 0
                    vacrescimo = 0
                    v-seguro = 0
                    v-crepes = 0
                    .
                
                run retorna-principal-acrescimo-contrato.p
                        (input recid(contrato), 
                         output v-novacao,
                         output v-financiado,
                         output v-clientes,
                         output v-principal, 
                         output v-acrescimo,
                         output v-seguro,
                         output v-crepes).
                
                vtitvlcob  = v-principal.
                vacrescimo = v-acrescimo.
                
                p-sitlan = "LEBES".
                run put-fccontrato.
                
            end.
            end.
        end.

        /***** RECEBIMENTO ****/
        
        if v-index = 1 or v-index = 3

        then do:
            for each titulo where 
                     titulo.etbcobra = tt-estab.etbcod and
                     titulo.titdtpag = vdata1 /*and
                     titulo.modcod = "CRE"*/ no-lock:
                     
                if titulo.modcod <> "CRE" then next.
                if titulo.titvlcob <= 0 then next.
                if titulo.clifor = 1 then next.
                if titulo.titnat = yes then next.
                
                find first tit-novado of titulo no-error.
                if avail tit-novado
                then next.
                
                p-juros = 0.
                p-principal = 0.
                p-acrescimo = 0.
                p-seguro.
                
                find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = titulo.etbcod
                                    and envfinan.clifor = titulo.clifor
                                    and envfinan.titnum = titulo.titnum
                                    /*and envfinan.titpar = titulo.titpar
                                    */
                                    no-lock no-error.

                if titulo.titpar = 0 and
                   avail envfinan and envfinan.envsit <> "EXC"
                then do:
                    tt-receb.recebimento_entrada = 
                        tt-receb.recebimento_entrada + titulo.titvlcob.
                    if titulo.moecod = "PDM"
                    then 
                    for each titpag where
                          titpag.empcod = titulo.empcod and
                          titpag.titnat = titulo.titnat and
                          titpag.modcod = titulo.modcod and
                          titpag.etbcod = titulo.etbcod and
                          titpag.clifor = titulo.clifor and
                          titpag.titnum = titulo.titnum and
                          titpag.titpar = titulo.titpar
                          no-lock:
                        find first fin.moeda where 
                               moeda.moecod = titpag.moecod
                               no-lock no-error.
                        if not avail moeda
                        then find first fin.moeda where
                                moeda.moecod = "REA"
                                no-lock no-error.
                        vi = 0.
                        do vi = 1 to 15:
                            if tt-receb.define_recebimento_entrada_moeda[vi] 
                                            = ""
                            then tt-receb.define_recebimento_entrada_moeda[vi]
                                    =  moeda.moecod + " - " + moeda.moenom.
                            if tt-receb.define_recebimento_entrada_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom
                            then do:
                                tt-receb.recebimento_entrada_moeda[vi] =
                                 tt-receb.recebimento_entrada_moeda[vi] + 
                                 titpag.titvlpag.
                                leave.
                            end.    
                        end.         
                    end.               
                    else do:
                         find first fin.moeda where 
                               moeda.moecod = titulo.moecod
                               no-lock no-error.
                         if not avail moeda
                         then find first fin.moeda where
                                moeda.moecod = "REA"
                                no-lock no-error.
                         vi = 0.
                         do vi = 1 to 15:
                            if tt-receb.define_recebimento_entrada_moeda[vi]
                                                   = ""
                            then tt-receb.define_recebimento_entrada_moeda[vi]
                                =  moeda.moecod + " - " + moeda.moenom.
                            if tt-receb.define_recebimento_entrada_moeda[vi] 
                                =  moeda.moecod + " - " + moeda.moenom
                            then do:
                                tt-receb.recebimento_entrada_moeda[vi] =
                                 tt-receb.recebimento_entrada_moeda[vi] 
                                        + titulo.titvlcob.
                                leave.
                            end.    
                        end.         
                    end.   
                    next.
                end.
                
                if  avail envfinan and envfinan.envsit <> "EXC"
                then do:
                    
                    p-principal = 0.
                    p-acrescimo = 0.
                    p-seguro = 0.
                    p-juros = titulo.titjuro.
                    p-crepes = 0.
                    run retorna-principal-acrescimo-titulo.p
                                        (input recid(titulo),
                                            output p-principal, 
                                            output p-acrescimo,
                                            output p-seguro,
                                            output p-crepes).

                    if p-crepes > 0
                    then do:
                        p-tiplan = "RECCREPES".
                        p-sitlan = "FINANCEIRA".
                        p-principal = p-crepes.
                        run put-recebimento.
                    end. 
                    else do:
                    if p-principal + p-acrescimo + p-seguro <> titulo.titvlcob
                    then do:
                        if p-principal + p-acrescimo + p-seguro 
                                                > titulo.titvlcob
                        then p-acrescimo = p-acrescimo -
                            ((p-principal + p-acrescimo + p-seguro) 
                                        - titulo.titvlcob).
                        else if p-principal + p-acrescimo + p-seguro
                                            < titulo.titvlcob
                            then p-principal = p-principal +
                                (titulo.titvlcob - 
                                (p-principal + p-acrescimo + p-seguro)).

                    end.    
                    if p-principal <= 0 
                    then assign
                        p-principal = titulo.titvlcob - titulo.titdes
                        p-seguro = titulo.titdes
                         p-acrescimo = 0.
                    
                    p-tiplan = "RECEBIMENTO".
                    p-sitlan = "FINANCEIRA".
                    run put-recebimento.
                    end.
                end.
                else  do:
                    find first titulodd of fin.titulo no-lock no-error.
                    if avail titulodd
                    then do:
                        tt-receb.recebimento_incobraveis = 
                        tt-receb.recebimento_incobraveis
                            + titulodd.titvlcob.
                        next.    
                    end.
                    
                    if not can-find(first tabdac where
                                       tabdac.etbcod = fin.titulo.etbcod and
                                       tabdac.clicod = fin.titulo.clifor and
                                       tabdac.numlan = fin.titulo.titnum and
                                       tabdac.parlan = ? and
                                       tabdac.datemi = fin.titulo.titdtemi and
                                       tabdac.tiplan begins "EMI" and
                                       tabdac.sitlan = "LEBES")
                                       
                    then do:
                        tt-receb.recebimento_forasaldo =
                            tt-receb.recebimento_forasaldo +
                                        fin.titulo.titvlcob.
                        next.    
                    end.     
                    find first tabdac where
                                       tabdac.etbcod = fin.titulo.etbcod and
                                       tabdac.clicod = fin.titulo.clifor and
                                       tabdac.numlan = fin.titulo.titnum and
                                       tabdac.parlan = ? and
                                       tabdac.datemi = fin.titulo.titdtemi and
                                       tabdac.tiplan begins "EMI" and
                                       tabdac.sitlan = "INCOBRAVEL" 
                                       no-lock no-error.
                    if avail tabdac 
                    then next.                        
                  
                    find first contratodd where
                           contratodd.cont-num = dec(fin.titulo.titnum)
                           no-lock no-error.
                    if avail contratodd and
                        contratodd.crecod <> 999
                    then next.
                    
                    find first tabdac where 
                            tabdac.etbcod = fin.titulo.etbcod and
                                      tabdac.clicod = dec(fin.titulo.clifor) and
                                      tabdac.numlan = fin.titulo.titnum and
                                      tabdac.parlan = fin.titulo.titpar and
                                      tabdac.datemi = fin.titulo.titdtemi and
                                      tabdac.tiplan = "RECEBIMENTO" and
                                      tabdac.sitlan = "LEBES"
                                      NO-LOCK NO-ERROR.
                                      
                    if avail tabdac and
                             tabdac.datlan < vdti
                    then.
                    else do:
                        p-principal = 0.
                        p-acrescimo = 0.
                        p-seguro = 0.
                        p-juros = fin.titulo.titjuro.
                        run retorna-principal-acrescimo-titulo.p
                                        (input recid(fin.titulo),
                                            output p-principal, 
                                            output p-acrescimo,
                                            output p-seguro,
                                            output p-crepes).
 
                        if p-principal + p-acrescimo + p-seguro
                                            <> fin.titulo.titvlcob
                        then do:
                            if p-principal + p-acrescimo + p-seguro
                                        > fin.titulo.titvlcob
                            then p-acrescimo = p-acrescimo - 
                                ((p-principal + p-acrescimo + p-seguro) - 
                                    fin.titulo.titvlcob).
                            else if p-principal + p-acrescimo + p-seguro
                                        < fin.titulo.titvlcob
                                then p-principal = p-principal +
                                    (fin.titulo.titvlcob - 
                                    (p-principal + p-acrescimo + p-seguro)).

                        end.
                        if p-principal <= 0
                        then assign
                            p-principal = fin.titulo.titvlcob 
                                            - fin.titulo.titdes
                            p-seguro = fin.titulo.titdes                
                            p-acrescimo = 0.
                             
                        p-tiplan = "RECEBIMENTO".
                        p-sitlan = "LEBES".
                        run put-recebimento.
                    end.
                    
                end.
                
            end.
            for each sc2015 where
                     sc2015.etbcobra = tt-estab.etbcod and
                     sc2015.titdtpag = vdata1 
                     no-lock:
                if sc2015.modcod <> "CRE" 
                then next.    
                find first tabdac where   
                           tabdac.etbcod = sc2015.etbcod and
                           tabdac.clicod = sc2015.clifor and
                           tabdac.numlan = sc2015.titnum and
                           tabdac.parlan = sc2015.titpar and
                           tabdac.datemi = sc2015.titdtemi and
                           tabdac.tiplan = "RECEBIMENTO" and
                           tabdac.sitlan = "LEBES" and
                           tabdac.situacao = 9
                           no-lock no-error.
                if avail tabdac
                then do:
                    p-principal = tabdac.vallan.
                    p-seguro    = tabdac.seguro.
                    p-acrescimo = tabdac.acrescimo.
                    p-tiplan = "RECEBIMENTO".
                    p-sitlan = "LEBES".
                    run put-recebimentoSC.
                end.
            end.

            /*** recebimento NOVACAO ****/

            for each tit-novado where 
                     tit-novado.etbcod > 0  no-lock:

                p-principal = 0.
                p-acrescimo = 0.
                p-seguro = 0.
                p-juros = 0.
                find titulo of tit-novado no-lock no-error.
                if avail titulo
                then do:
                    run retorna-principal-acrescimo-titulo.p
                                        (input recid(fin.titulo),
                                            output p-principal, 
                                            output p-acrescimo,
                                            output p-seguro,
                                            output p-crepes).
                    if p-principal + p-acrescimo + p-seguro <> titulo.titvlcob
                    then do:
                        if p-principal + p-acrescimo + p-seguro 
                                            > titulo.titvlcob
                        then p-acrescimo = p-acrescimo -
                            ((p-principal + p-acrescimo + p-seguro) 
                                                    - titulo.titvlcob).
                        else if p-principal + p-acrescimo + p-seguro 
                                            < titulo.titvlcob
                            then p-principal = p-principal + 
                                (titulo.titvlcob - 
                                (p-principal + p-acrescimo + p-seguro)).

                    end. 
                end.
                if p-principal <= 0
                then assign
                    p-principal = titulo.titvlcob - titulo.titdes
                    p-seguro = titulo.titdes
                    p-acrescimo = 0.
                    
                if titulo.cobcod = 10
                then do:
                    p-tiplan = "RECNOVACAO".
                    p-sitlan = "FINANCEIRA".
                    run put-recebimento-novacao.
                end.
                else do:
                    p-tiplan = "RECNOVACAO".
                    p-sitlan = "LEBES".
                    run put-recebimento-novacao.
                end.
            end.                                                        
            
            /*** pagamento contratodd  *****/

            for each titulosal where 
                     titulosal.etbcobra = tt-estab.etbcod and
                     titulosal.titdtpag = vdata1 and
                     titulosal.titpar = 1 no-lock:
                     
                if titulosal.titvlcob <= 0
                then next.

                 find contratodd where
                     contratodd.cont-num = dec(titulosal.titnum)
                     no-lock no-error.
 
                if not avail contratodd or
                   contratodd.crecod = 999
                then next.
 
                if not can-find(first tabdac where
                                       tabdac.etbcod = titulosal.etbcod and
                                       tabdac.clicod = titulosal.clifor and
                                       tabdac.numlan = titulosal.titnum and
                                       tabdac.parlan = ? and
                                       tabdac.datemi = titulosal.titdtemi and
                                       tabdac.tiplan begins "EMI" and
                                       tabdac.sitlan = "LEBES")
                                       
                then do:
                    tt-receb.recebimento_forasaldo =
                        tt-receb.recebimento_forasaldo + titulosal.titvlcob.
                    next.    
                end.     
                  
                find first tabdac where
                                       tabdac.etbcod = titulosal.etbcod and
                                       tabdac.clicod = titulosal.clifor and
                                       tabdac.numlan = titulosal.titnum and
                                       tabdac.parlan = ? and
                                       tabdac.datemi = titulosal.titdtemi and
                                       tabdac.tiplan begins "EMI" and
                                       tabdac.sitlan = "INCOBRAVEL"
                                       no-lock no-error.
                if avail tabdac 
                then next.                        
                  
                p-principal = titulosal.titvlcob.
                p-acrescimo = 0.
                
                p-tiplan = "RECEBIMENTO".
                p-sitlan = "LEBES".
                run put-recebimento-titulosal.
                
            end.
            
            for each envfinan where 
                     envfinan.etbcod = tt-estab.etbcod and
                     envfinan.envsit = "EST" and
                     envfinan.dt1 = vdata1
                     no-lock.
                     
                find first titulo where
                           titulo.empcod = envfinan.empcod and
                           titulo.titnat = envfinan.titnat and
                           titulo.modcod = envfinan.modcod and
                           titulo.etbcod = envfinan.etbcod and
                           titulo.clifor = envfinan.clifor and
                           titulo.titnum = envfinan.titnum and
                           titulo.titpar = envfinan.titpar
                           no-lock no-error.
                if not avail titulo then next.
                           
                p-principal = 0.
                p-acrescimo = 0.
                p-seguro = 0.
                run retorna-principal-acrescimo-titulo.p
                                        (input recid(titulo),
                                            output p-principal, 
                                            output p-acrescimo,
                                            output p-seguro,
                                            output p-crepes).
                
                if p-principal + p-acrescimo + p-seguro <> titulo.titvlcob
                then do:
                    if p-principal + p-acrescimo + p-seguro > titulo.titvlcob
                    then p-acrescimo = p-acrescimo -
                        ((p-principal + p-acrescimo + p-seguro) 
                                        - titulo.titvlcob).
                    else if p-principal + p-acrescimo + p-seguro
                                            < titulo.titvlcob
                        then p-principal = p-principal + 
                            (titulo.titvlcob - 
                            (p-principal + p-acrescimo + p-seguro)).

                end. 
                if p-principal <= 0
                then assign
                    p-principal = titulo.titvlcob - titulo.titdes
                    p-seguro = titulo.titdes
                    p-acrescimo = 0.
                    
                run put-fetitulo.
                
            end.
        end.            
        if v-index = 1 or v-index = 2
        then do: 
        run devolucao.

        for each d-contrato no-lock:
            run put-devolucao.
        end.    

        run vendavista.
        
        for each tit-vista no-lock:
            run put-vendavista.
        end.    
        end.
    end.
end.            

output close.

output stream tl close.

def temp-table tt-total like tt-venda.

def var ok-venda as log.
def var ok-recebimento as log.
def var ok-entrada as log.
def var ok-recarga as log.

if v-index = 1
then do:
    for each estab no-lock:
        for each tabdac where
             tabdac.etblan = estab.etbcod and
             tabdac.datlan >= vdti and
             tabdac.datlan <= vdtf
             :
            delete tabdac.
        end.
    end. 
    for each tt-tabdac no-lock:
        find tabdac where
         tabdac.etbcod = tt-tabdac.etbcod and
         tabdac.clicod = tt-tabdac.clicod and
         tabdac.numlan = tt-tabdac.numlan and
         tabdac.parlan = tt-tabdac.parlan and
         tabdac.datemi = tt-tabdac.datemi and
         tabdac.tiplan = tt-tabdac.tiplan and
         tabdac.sitlan = tt-tabdac.sitlan
         no-error.
        if not avail tabdac
        then do:
            create tabdac.
            buffer-copy tt-tabdac to tabdac.
        end.
    end.
    for each tabdicem where tabdicem.datref >= vdti and
                          tabdicem.datref <= vdtf:
        delete tabdicem.
    end.
    for each tt-venda no-lock:
        create tabdicem.
        buffer-copy tt-venda to tabdicem.
    end. 
    for each tabdicre where tabdicre.datref >= vdti and
                          tabdicre.datref <= vdtf:
        delete tabdicre.
    end.
    for each tt-receb no-lock:
        create tabdicre.
        buffer-copy tt-receb to tabdicre.
    end.           
end.
else if v-index = 2
then do:
    for each estab no-lock:
        for each tabdac where
             tabdac.etblan = estab.etbcod and
             tabdac.datlan >= vdti and
             tabdac.datlan <= vdtf and
             tabdac.tiplan begins "EMI"
             :
    
            delete tabdac.
        end.
    end. 
    for each tt-tabdac no-lock:
        find tabdac where
             tabdac.etbcod = tt-tabdac.etbcod and
             tabdac.clicod = tt-tabdac.clicod and
             tabdac.numlan = tt-tabdac.numlan and
             tabdac.parlan = tt-tabdac.parlan and
             tabdac.datemi = tt-tabdac.datemi and
             tabdac.tiplan = tt-tabdac.tiplan and
             tabdac.sitlan = tt-tabdac.sitlan
             no-error.
        
        if not avail tabdac
        then create tabdac.
        buffer-copy tt-tabdac to tabdac.
    end.
    for each tabdicem where tabdicem.datref >= vdti and
                          tabdicem.datref <= vdtf:
        delete tabdicem.
    end.
    for each tt-venda no-lock:
    
        create tabdicem.
        buffer-copy tt-venda to tabdicem.

    end. 
end.
else if v-index = 3
then do:
    for each estab no-lock:
        for each tabdac where
             tabdac.etblan = estab.etbcod and
             tabdac.datlan >= vdti and
             tabdac.datlan <= vdtf and
             tabdac.tiplan begins "REC"
             :
    
            delete tabdac.
        end.
    end. 
    for each tt-tabdac no-lock:
        find tabdac where
             tabdac.etbcod = tt-tabdac.etbcod and
             tabdac.clicod = tt-tabdac.clicod and
             tabdac.numlan = tt-tabdac.numlan and
             tabdac.parlan = tt-tabdac.parlan and
             tabdac.datemi = tt-tabdac.datemi and
             tabdac.tiplan = tt-tabdac.tiplan and
             tabdac.sitlan = tt-tabdac.sitlan
             no-error.
        
        if not avail tabdac
        then create tabdac.
        buffer-copy tt-tabdac to tabdac.
    end.

    for each tabdicre where tabdicre.datref >= vdti and
                          tabdicre.datref <= vdtf:
        delete tabdicre.
    end.
    for each tt-receb no-lock:
        create tabdicre.
        buffer-copy tt-receb to tabdicre.
    end. 
end.
/*
output to ttreceb.txt.
for each tt-receb no-lock:
    put tt-receb.datref skip.
end.    
output close.
*/
procedure put-vendavista:
        find first tt-tabdac where
             tt-tabdac.etbcod = tit-vista.etbcod and
             tt-tabdac.clicod = tit-vista.clifor and
             tt-tabdac.numlan = tit-vista.titnum and
             tt-tabdac.parlan = tit-vista.titpar and
             tt-tabdac.datemi = tit-vista.titdtemi and
             tt-tabdac.tiplan = "VENDAVISTA" and
             tt-tabdac.sitlan = "LEBES"
             no-lock no-error.
        if not avail tt-tabdac 
        then do on error undo: 
            create tt-tabdac.
            assign
                tt-tabdac.etbcod = tit-vista.etbcod
                tt-tabdac.etblan = tit-vista.etbcod
                tt-tabdac.etbpag = tit-vista.etbcob
                tt-tabdac.clicod = tit-vista.clifor
                tt-tabdac.numlan = tit-vista.titnum
                tt-tabdac.parlan = tit-vista.titpar
                tt-tabdac.datemi = tit-vista.titdtemi
                tt-tabdac.datven = tit-vista.titdtven
                tt-tabdac.datlan = tit-vista.titdtemi
                tt-tabdac.datpag = tit-vista.titdtpag
                tt-tabdac.datexp = today
                tt-tabdac.vallan = tit-vista.titvlcob
                tt-tabdac.tiplan = "VENDAVISTA"
                tt-tabdac.sitlan = "LEBES"
                tt-tabdac.hislan = "VENDAVISTA" 
                tt-tabdac.anolan = year(tit-vista.titdtemi)
                tt-tabdac.meslan = month(tit-vista.titdtemi)
                tt-tabdac.natlan = "V"
                .
            release tt-tabdac no-error.

        end. 

end procedure.

procedure put-contrato:

     find first tt-tabdac where
         tt-tabdac.etbcod = fin.contrato.etbcod and
         tt-tabdac.clicod = contrato.clicod and
         tt-tabdac.numlan = string(contrato.contnum) and
         tt-tabdac.parlan = ? and
         tt-tabdac.datemi = contrato.dtinicial and
         tt-tabdac.tiplan = "EMISSAO"  and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
    if not avail tt-tabdac 
    then do on error undo: 

        create tt-tabdac.
        assign
            tt-tabdac.etbcod = contrato.etbcod
            tt-tabdac.etblan = contrato.etbcod
            tt-tabdac.etbpag = ?
            tt-tabdac.clicod = contrato.clicod
            tt-tabdac.numlan = string(contrato.contnum)
            tt-tabdac.parlan = ?
            tt-tabdac.datemi = contrato.dtinicial
            tt-tabdac.datven = ?
            tt-tabdac.datlan = contrato.dtinicial
            tt-tabdac.datpag = ?
            tt-tabdac.datexp = today
            tt-tabdac.vallan = vtitvlcob
            tt-tabdac.tiplan = "EMISSAO"
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = "EMISSAO " + string(contrato.contnum)
            tt-tabdac.anolan = year(contrato.dtinicial)
            tt-tabdac.meslan = month(contrato.dtinicial)
            tt-tabdac.natlan = "+"
            tt-tabdac.seguro = v-seguro
            .
        release tt-tabdac no-error.
    end. 
    
     if p-sitlan = "LEBES"
     then assign
            tt-venda.venda_prazo_lebes = 
            tt-venda.venda_prazo_lebes + vtitvlcob
            tt-venda.venda_seguro_lebes =
            tt-venda.venda_seguro_lebes + v-seguro 
            .
     else if p-sitlan = "FINANCEIRA"
         then assign
                tt-venda.venda_prazo_fdrebes =
                     tt-venda.venda_prazo_fdrebes + vtitvlcob
                tt-venda.venda_seguro_fdrebes =
                     tt-venda.venda_seguro_fdrebes + v-seguro
                     .
         else if p-sitlan = "SEMCUPOM"
            then tt-venda.venda_prazo_semcupom = 
                                tt-venda.venda_prazo_semcupom + vtitvlcob
                                .
            else tt-venda.venda_prazo_outras =
                                tt-venda.venda_prazo_outras + vtitvlcob .

     
     if vacrescimo > 0
     then do:           
        /******* ACRESCIMO ********/
    
        find first tt-tabdac where
         tt-tabdac.etbcod = contrato.etbcod and
         tt-tabdac.clicod = contrato.clicod and
         tt-tabdac.numlan = string(contrato.contnum) and
         tt-tabdac.parlan = ? and
         tt-tabdac.datemi = contrato.dtinicial and
         tt-tabdac.tiplan = "ACRESCIMO" and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
        if not avail tt-tabdac 
        then do on error undo: 
            create tt-tabdac.
            assign
            tt-tabdac.etbcod = contrato.etbcod
            tt-tabdac.etblan = contrato.etbcod
            tt-tabdac.etbpag = ?
            tt-tabdac.clicod = contrato.clicod
            tt-tabdac.numlan = string(contrato.contnum)
            tt-tabdac.parlan = ?
            tt-tabdac.datemi = contrato.dtinicial
            tt-tabdac.datven = ?
            tt-tabdac.datlan = contrato.dtinicial
            tt-tabdac.datpag = ?
            tt-tabdac.datexp = today
            tt-tabdac.vallan = vacrescimo
            tt-tabdac.tiplan = "ACRESCIMO"
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = "ACRESCIMO " + string(contrato.contnum)
            tt-tabdac.anolan = year(contrato.dtinicial)
            tt-tabdac.meslan = month(contrato.dtinicial)
            tt-tabdac.natlan = "+"
            .
            release tt-tabdac no-error.
        end. 
        
        if p-sitlan = "LEBES"
        then tt-venda.acrescimo_lebes = tt-venda.acrescimo_lebes + vacrescimo.
        else if  p-sitlan = "FINANCEIRA"
            then tt-venda.acrescimo_fdrebes =
                                tt-venda.acrescimo_fdrebes + vacrescimo .
            else if p-sitlan = "SEMCUPOM"
                then  tt-venda.acrescimo_venda_semcupom =
                                tt-venda.acrescimo_venda_semcupom + vacrescimo.
                else  tt-venda.acrescimo_venda_outras =
                                tt-venda.acrescimo_venda_outras + vacrescimo.
                                                                    

     end.
end procedure.

procedure put-fccontrato:

    find first tt-tabdac where
         tt-tabdac.etbcod = fc-contrato.etbcod and
         tt-tabdac.clicod = fc-contrato.clicod and
         tt-tabdac.numlan = string(fc-contrato.contnum) and
         tt-tabdac.parlan = ? and
         tt-tabdac.datemi = fc-contrato.dtinicial and
         tt-tabdac.tiplan = "EMICANFINAN" and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
    if not avail tt-tabdac 
    then do on error undo: 
        create tt-tabdac.
        assign
            tt-tabdac.etbcod = fc-contrato.etbcod
            tt-tabdac.etblan = fc-contrato.etbcod
            tt-tabdac.etbpag = ?
            tt-tabdac.clicod = fc-contrato.clicod
            tt-tabdac.numlan = string(fc-contrato.contnum)
            tt-tabdac.parlan = ?
            tt-tabdac.datemi = fc-contrato.dtinicial
            tt-tabdac.datven = ?
            tt-tabdac.datlan = fc-contrato.dtinicial
            tt-tabdac.datpag = ?
            tt-tabdac.datexp = today
            tt-tabdac.vallan = vtitvlcob
            tt-tabdac.tiplan = "EMICANFINAN"
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = "EMICANFINAN" + string(fc-contrato.contnum)
            tt-tabdac.anolan = year(fc-contrato.dtinicial)
            tt-tabdac.meslan = month(fc-contrato.dtinicial)
            tt-tabdac.natlan = "+"
            tt-tabdac.seguro = v-seguro
            .
        release tt-tabdac no-error.
    end. 
    
     
     tt-venda.cancelamentos_fdrebes = 
            tt-venda.cancelamentos_fdrebes + vtitvlcob.
     tt-venda.venda_seguro_fdrebes = 
        tt-venda.venda_seguro_fdrebes + v-seguro.
     
     if vacrescimo > 0
     then do:           
        /******* ACRESCIMO ********/
        find first tt-tabdac where
         tt-tabdac.etbcod = fc-contrato.etbcod and
         tt-tabdac.clicod = fc-contrato.clicod and
         tt-tabdac.numlan = string(fc-contrato.contnum) and
         tt-tabdac.parlan = ? and
         tt-tabdac.datemi = fc-contrato.dtinicial and
         tt-tabdac.tiplan = "ACRCANFINAN" and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
        if not avail tt-tabdac 
        then do on error undo: 
            create tt-tabdac.
            assign
            tt-tabdac.etbcod = fc-contrato.etbcod
            tt-tabdac.etblan = fc-contrato.etbcod
            tt-tabdac.etbpag = ?
            tt-tabdac.clicod = fc-contrato.clicod
            tt-tabdac.numlan = string(fc-contrato.contnum)
            tt-tabdac.parlan = ?
            tt-tabdac.datemi = fc-contrato.dtinicial
            tt-tabdac.datven = ?
            tt-tabdac.datlan = fc-contrato.dtinicial
            tt-tabdac.datpag = ?
            tt-tabdac.datexp = today
            tt-tabdac.vallan = vacrescimo
            tt-tabdac.tiplan = "ACRCANFINAN"
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = "ACRCANFINAN" + string(fc-contrato.contnum)
            tt-tabdac.anolan = year(fc-contrato.dtinicial)
            tt-tabdac.meslan = month(fc-contrato.dtinicial)
            tt-tabdac.natlan = "+"
            .
            release tt-tabdac no-error.
        end. 
        
        tt-venda.acrescimo_cancelamento_fdrebes = 
                tt-venda.acrescimo_cancelamento_fdrebes + vacrescimo.
     end.
     
end procedure.

procedure put-contratodd:

    find first tt-tabdac where
         tt-tabdac.etbcod = contratodd.etbcod and
         tt-tabdac.clicod = contratodd.clicod and
         tt-tabdac.numlan = string(contratodd.cont-num) and
         tt-tabdac.parlan = ? and
         tt-tabdac.datemi = contratodd.dtinicial and
         tt-tabdac.tiplan = "EMISSAO" and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
    if not avail tt-tabdac 
    then do on error undo: 
        create tt-tabdac.
        assign
            tt-tabdac.etbcod = contratodd.etbcod
            tt-tabdac.etblan = contratodd.etbcod
            tt-tabdac.etbpag = ?
            tt-tabdac.clicod = contratodd.clicod
            tt-tabdac.numlan = string(contratodd.cont-num)
            tt-tabdac.parlan = ?
            tt-tabdac.datemi = contratodd.dtinicial
            tt-tabdac.datven = ?
            tt-tabdac.datlan = contratodd.dtinicial
            tt-tabdac.datpag = ?
            tt-tabdac.datexp = today
            tt-tabdac.vallan = vtitvlcob
            tt-tabdac.tiplan = "EMISSAO"
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = "EMISSAO " + string(contratodd.cont-num)
            tt-tabdac.anolan = year(contratodd.dtinicial)
            tt-tabdac.meslan = month(contratodd.dtinicial)
            tt-tabdac.natlan = "+"
            .
        release tt-tabdac no-error.
     end. 

     tt-venda.venda_prazo_adicional = 
        tt-venda.venda_prazo_adicional + vtitvlcob.
 
end procedure.

procedure put-recebimento:

     find first tt-tabdac where
         tt-tabdac.etblan = vetb-pag and
         tt-tabdac.datlan = fin.titulo.titdtpag and
         tt-tabdac.clicod = titulo.clifor and
         tt-tabdac.numlan = titulo.titnum and
         tt-tabdac.parlan = titulo.titpar and
         tt-tabdac.tiplan = p-tiplan and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
    if not avail tt-tabdac 
    then do on error undo: 
        create tt-tabdac.
        assign
            tt-tabdac.etbcod = titulo.etbcod
            tt-tabdac.etblan = vetb-pag
            tt-tabdac.etbpag = titulo.etbcob
            tt-tabdac.clicod = titulo.clifor
            tt-tabdac.numlan = titulo.titnum
            tt-tabdac.parlan = titulo.titpar
            tt-tabdac.datemi = titulo.titdtemi
            tt-tabdac.datven = titulo.titdtven
            tt-tabdac.datlan = titulo.titdtpag
            tt-tabdac.datpag = titulo.titdtpag
            tt-tabdac.datexp = today
            tt-tabdac.vallan = titulo.titvlcob
            tt-tabdac.tiplan = p-tiplan
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = p-tiplan + " " + string(titulo.titnum)
            tt-tabdac.anolan = year(titulo.titdtpag)
            tt-tabdac.meslan = month(titulo.titdtpag)
            tt-tabdac.natlan = "-"
            tt-tabdac.principal = p-principal
            tt-tabdac.acrescimo = p-acrescimo
            tt-tabdac.seguro = p-seguro
            .
        release tt-tabdac no-error.
    end. 
    if p-crepes > 0
    then do:
        assign
             tt-receb.define_receb_cpess[1] = "REC - CREDITO PESSOAL"
             tt-receb.receb_cpess[1] = 
                        tt-receb.receb_cpess[1] + p-crepes.
    end.
     if p-seguro > 0
     then do:
         assign
             tt-receb.define_receb_seguro[1] = "REC - SEGURO"
             tt-receb.receb_seguro[1] = 
                        tt-receb.receb_seguro[1] + p-seguro.
     end.
     
     if p-tiplan = "RECNOVACAO"
     then assign
            tt-receb.recebimento_novacao = 
                tt-receb.recebimento_novacao + titulo.titvlcob
            tt-receb.recebimento_principal_novacao =
                tt-receb.recebimento_principal_novacao + p-principal
            tt-receb.recebimento_acrescimo_novacao =
                tt-receb.recebimento_acrescimo_novacao + p-acrescimo
            tt-receb.receb_seguro_novacao = 
                tt-receb.receb_seguro_novacao + p-seguro
                .
     else if p-sitlan = "LEBES"
         then assign
                tt-receb.recebimento_lebes = 
                tt-receb.recebimento_lebes + titulo.titvlcob
                tt-receb.recebimento_principal_lebes =
                tt-receb.recebimento_principal_lebes + p-principal
                tt-receb.recebimento_acrescimo_lebes =
                tt-receb.recebimento_acrescimo_lebes + p-acrescimo
                tt-receb.receb_seguro_lebes = 
                        tt-receb.receb_seguro_lebes + p-seguro
                .
         else if p-sitlan = "FINANCEIRA"
         then assign
                tt-receb.recebimento_fdrebes =
                        tt-receb.recebimento_fdrebes + titulo.titvlcob
                tt-receb.recebimento_principal_fdrebes =
                tt-receb.recebimento_principal_fdrebes + p-principal
                tt-receb.recebimento_acrescimo_fdrebes =
                tt-receb.recebimento_acrescimo_fdrebes + p-acrescimo
                tt-receb.receb_seguro_fdrebes = 
                    tt-receb.receb_seguro_fdrebes + p-seguro

                .
    

    if p-tiplan = "RECNOVACAO"
    then do:
    end.
    else do:
        if titulo.moecod = "PDM" 
        then do:
            for each titpag where
                      titpag.empcod = titulo.empcod and
                      titpag.titnat = titulo.titnat and
                      titpag.modcod = titulo.modcod and
                      titpag.etbcod = titulo.etbcod and
                      titpag.clifor = titulo.clifor and
                      titpag.titnum = titulo.titnum and
                      titpag.titpar = titulo.titpar
                      no-lock:
                 
                 find first tt-recmoeda where
                       tt-recmoeda.etbcod = vetb-pag and
                       tt-recmoeda.datref = titulo.titdtpag and
                       tt-recmoeda.moecod = titpag.moecod
                       no-error.
                 if not avail tt-recmoeda
                 then do:
                        create tt-recmoeda.
                        assign
                                tt-recmoeda.etbcod = vetb-pag
                                tt-recmoeda.datref = titulo.titdtpag
                                tt-recmoeda.moecod = titpag.moecod.
                 end.
                 tt-recmoeda.valor = tt-recmoeda.valor + titpag.titvlpag.

                 find first moeda where 
                               moeda.moecod = titpag.moecod
                               no-lock no-error.
                 if not avail moeda
                 then find first moeda where
                                moeda.moecod = "REA"
                                no-lock no-error.
                 vi = 0.
                 do vi = 1 to 15:
                    if tt-receb.define_recebimento_moeda[vi] = ""
                    then tt-receb.define_recebimento_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom.
                    if tt-receb.define_recebimento_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom
                    then do:
                        if p-sitlan = "LEBES"
                        then 
                        assign
                            tt-receb.recebimento_moeda_lebes[vi] =
                                tt-receb.recebimento_moeda_lebes[vi] + 
                                titpag.titvlpag
                            tt-receb.receb_moeda_principal_lebes[vi] =
                            tt-receb.receb_moeda_principal_lebes[vi] +
                            (p-principal * (titpag.titvlpag / titulo.titvlpag))
                            tt-receb.receb_moeda_acrescimo_lebes[vi] = 
                            tt-receb.receb_moeda_acrescimo_lebes[vi] +
                            (p-acrescimo * (titpag.titvlpag / titulo.titvlpag))
                            tt-receb.receb_moeda_juros_lebes[vi] = 
                            tt-receb.receb_moeda_juros_lebes[vi] +
                        (titulo.titjuro * (titpag.titvlpag / titulo.titvlpag))
                            .
                        else if p-sitlan = "FINANCEIRA"
                            then 
                            assign
                            tt-receb.recebimento_moeda_fdrebes[vi] = 
                             tt-receb.recebimento_moeda_fdrebes[vi] +
                              titpag.titvlpag
                              tt-receb.receb_moeda_principal_fdrebes[vi] =
                            tt-receb.receb_moeda_principal_fdrebes[vi] +
                            (p-principal * (titpag.titvlpag / titulo.titvlpag))
                            tt-receb.receb_moeda_acrescimo_fdrebes[vi] = 
                            tt-receb.receb_moeda_acrescimo_fdrebes[vi] +
                            (p-acrescimo * (titpag.titvlpag / titulo.titvlpag))
                            tt-receb.receb_moeda_juros_fdrebes[vi] = 
                            tt-receb.receb_moeda_juros_fdrebes[vi] +
                           (titulo.titjur * (titpag.titvlpag / titulo.titvlpag))
                            .
                        leave.
                    end.    
                 end.               
            end.
        end.
        else do:
            find first tt-recmoeda where
                       tt-recmoeda.etbcod = vetb-pag and
                       tt-recmoeda.datref = titulo.titdtpag and
                       tt-recmoeda.moecod = titulo.moecod
                       no-error.
            if not avail tt-recmoeda
            then do:
                        create tt-recmoeda.
                        assign
                                tt-recmoeda.etbcod = vetb-pag
                                tt-recmoeda.datref = titulo.titdtpag
                                tt-recmoeda.moecod = titulo.moecod.
            end.           
            tt-recmoeda.valor = tt-recmoeda.valor + titulo.titvlcob.

            find first moeda where  moeda.moecod = titulo.moecod
                               no-lock no-error.
            if not avail moeda
            then find first moeda where moeda.moecod = "REA"
                                no-lock no-error.
            vi = 0.
            do vi = 1 to 15:
                if tt-receb.define_recebimento_moeda[vi] = ""
                then tt-receb.define_recebimento_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom.
                if tt-receb.define_recebimento_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom
                then do:
                    if p-sitlan = "LEBES"
                    then assign
                        tt-receb.recebimento_moeda_lebes[vi] =
                            tt-receb.recebimento_moeda_lebes[vi] 
                            + titulo.titvlcob
                        tt-receb.receb_moeda_principal_lebes[vi] =
                            tt-receb.receb_moeda_principal_lebes[vi] 
                            + p-principal
                        tt-receb.receb_moeda_acrescimo_lebes[vi] =
                            tt-receb.receb_moeda_acrescimo_lebes[vi] 
                            + p-acrescimo
                        tt-receb.receb_moeda_juros_lebes[vi] = 
                            tt-receb.receb_moeda_juros_lebes[vi] +
                            titulo.titjuro
                            .
                      else if p-sitlan = "FINANCEIRA"
                        then assign
                            tt-receb.recebimento_moeda_fdrebes[vi] =
                                tt-receb.recebimento_moeda_fdrebes[vi] +
                                titulo.titvlcob
                            tt-receb.receb_moeda_principal_fdrebes[vi] =
                                    tt-receb.receb_moeda_principal_fdrebes[vi] 
                                + p-principal
                            tt-receb.receb_moeda_acrescimo_fdrebes[vi] =
                               tt-receb.receb_moeda_acrescimo_fdrebes[vi] 
                                + p-acrescimo
                            tt-receb.receb_moeda_juros_fdrebes[vi] = 
                            tt-receb.receb_moeda_juros_fdrebes[vi] +
                            titulo.titjuro
                            .
  
                    leave.
                end.    
            end.         
        end.        
    end.
                   
    if titulo.titjuro > 0
    then do:
        
        find first tt-tabdac where
         tt-tabdac.etblan = vetb-pag and
         tt-tabdac.datlan = titulo.titdtpag and
         tt-tabdac.clicod = titulo.clifor and
         tt-tabdac.numlan = titulo.titnum and
         tt-tabdac.parlan = titulo.titpar and
         tt-tabdac.tiplan = "JUROS" and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
        if not avail tt-tabdac 
        then do on error undo: 
            create tt-tabdac.
            assign
            tt-tabdac.etbcod = titulo.etbcod
            tt-tabdac.etblan = vetb-pag
            tt-tabdac.etbpag = titulo.etbcob
            tt-tabdac.clicod = titulo.clifor
            tt-tabdac.numlan = titulo.titnum
            tt-tabdac.parlan = titulo.titpar
            tt-tabdac.datemi = titulo.titdtemi
            tt-tabdac.datven = titulo.titdtven
            tt-tabdac.datlan = titulo.titdtpag
            tt-tabdac.datpag = titulo.titdtpag
            tt-tabdac.datexp = today
            tt-tabdac.vallan = titulo.titjuro
            tt-tabdac.tiplan = "JUROS"
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = "JUROS " + string(titulo.titnum)
            tt-tabdac.anolan = year(titulo.titdtpag)
            tt-tabdac.meslan = month(titulo.titdtpag)
            tt-tabdac.natlan = "J"
            .
            release tt-tabdac no-error.
        end. 
        
        if p-sitlan = "LEBES"
        then tt-receb.juros_lebes = tt-receb.juros_lebes + titulo.titjuro.
        else if p-sitlan = "FINANCEIRA"
            then tt-receb.juros_fdrebes = tt-receb.juros_fdrebes
                        + titulo.titjuro.
    end.

end procedure.

procedure put-recebimentoSC:

     find first tt-tabdac where
         tt-tabdac.etblan = vetb-pag and
         tt-tabdac.datlan = sc2015.titdtpag and
         tt-tabdac.clicod = sc2015.clifor and
         tt-tabdac.numlan = sc2015.titnum and
         tt-tabdac.parlan = sc2015.titpar and
         tt-tabdac.tiplan = p-tiplan and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
    if not avail tt-tabdac 
    then do on error undo: 
        create tt-tabdac.
        assign
            tt-tabdac.etbcod = sc2015.etbcod
            tt-tabdac.etblan = vetb-pag
            tt-tabdac.etbpag = sc2015.etbcob
            tt-tabdac.clicod = sc2015.clifor
            tt-tabdac.numlan = sc2015.titnum
            tt-tabdac.parlan = sc2015.titpar
            tt-tabdac.datemi = sc2015.titdtemi
            tt-tabdac.datven = sc2015.titdtven
            tt-tabdac.datlan = sc2015.titdtpag
            tt-tabdac.datpag = sc2015.titdtpag
            tt-tabdac.datexp = today
            tt-tabdac.vallan = sc2015.titvlcob
            tt-tabdac.tiplan = p-tiplan
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = p-tiplan + " " + string(sc2015.titnum)
            tt-tabdac.anolan = year(sc2015.titdtpag)
            tt-tabdac.meslan = month(sc2015.titdtpag)
            tt-tabdac.natlan = "-"
            tt-tabdac.principal = p-principal
            tt-tabdac.acrescimo = p-acrescimo
            tt-tabdac.seguro    = p-seguro
            tt-tabdac.situacao  = 9
            .
        release tt-tabdac no-error.
    end. 
    
     if p-seguro > 0
     then do:
         assign
             tt-receb.define_receb_seguro[1] = "REC - SEGURO"
             tt-receb.receb_seguro[1] = 
                        tt-receb.receb_seguro[1] + p-seguro.
     end.
     
     if p-tiplan = "RECNOVACAO"
     then assign
            tt-receb.recebimento_novacao = 
                tt-receb.recebimento_novacao + sc2015.titvlcob
            tt-receb.recebimento_principal_novacao =
                tt-receb.recebimento_principal_novacao + p-principal
            tt-receb.recebimento_acrescimo_novacao =
                tt-receb.recebimento_acrescimo_novacao + p-acrescimo
            tt-receb.receb_seguro_novacao = 
                tt-receb.receb_seguro_novacao + p-seguro
                .
     else if p-sitlan = "LEBES"
         then assign
                tt-receb.recebimento_lebes = 
                tt-receb.recebimento_lebes + sc2015.titvlcob
                tt-receb.recebimento_principal_lebes =
                tt-receb.recebimento_principal_lebes + p-principal
                tt-receb.recebimento_acrescimo_lebes =
                tt-receb.recebimento_acrescimo_lebes + p-acrescimo
                tt-receb.receb_seguro_lebes = 
                        tt-receb.receb_seguro_lebes + p-seguro
                .
         else if p-sitlan = "FINANCEIRA"
         then assign
                tt-receb.recebimento_fdrebes =
                        tt-receb.recebimento_fdrebes + sc2015.titvlcob
                tt-receb.recebimento_principal_fdrebes =
                tt-receb.recebimento_principal_fdrebes + p-principal
                tt-receb.recebimento_acrescimo_fdrebes =
                tt-receb.recebimento_acrescimo_fdrebes + p-acrescimo
                tt-receb.receb_seguro_fdrebes = 
                    tt-receb.receb_seguro_fdrebes + p-seguro

                .
    

    if p-tiplan = "RECNOVACAO"
    then do:
    end.
    else do:
        if sc2015.moecod = "PDM" 
        then do:
            for each titpag where
                      titpag.empcod = sc2015.empcod and
                      titpag.titnat = sc2015.titnat and
                      titpag.modcod = sc2015.modcod and
                      titpag.etbcod = sc2015.etbcod and
                      titpag.clifor = sc2015.clifor and
                      titpag.titnum = sc2015.titnum and
                      titpag.titpar = sc2015.titpar
                      no-lock:
                 
                 find first tt-recmoeda where
                       tt-recmoeda.etbcod = vetb-pag and
                       tt-recmoeda.datref = sc2015.titdtpag and
                       tt-recmoeda.moecod = titpag.moecod
                       no-error.
                 if not avail tt-recmoeda
                 then do:
                        create tt-recmoeda.
                        assign
                                tt-recmoeda.etbcod = vetb-pag
                                tt-recmoeda.datref = sc2015.titdtpag
                                tt-recmoeda.moecod = titpag.moecod.
                 end.
                 tt-recmoeda.valor = tt-recmoeda.valor + titpag.titvlpag.

                 find first moeda where 
                               moeda.moecod = titpag.moecod
                               no-lock no-error.
                 if not avail moeda
                 then find first moeda where
                                moeda.moecod = "REA"
                                no-lock no-error.
                 vi = 0.
                 do vi = 1 to 15:
                    if tt-receb.define_recebimento_moeda[vi] = ""
                    then tt-receb.define_recebimento_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom.
                    if tt-receb.define_recebimento_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom
                    then do:
                        if p-sitlan = "LEBES"
                        then 
                        assign
                            tt-receb.recebimento_moeda_lebes[vi] =
                                tt-receb.recebimento_moeda_lebes[vi] + 
                                titpag.titvlpag
                            tt-receb.receb_moeda_principal_lebes[vi] =
                            tt-receb.receb_moeda_principal_lebes[vi] +
                            (p-principal * (titpag.titvlpag / sc2015.titvlpag))
                            tt-receb.receb_moeda_acrescimo_lebes[vi] = 
                            tt-receb.receb_moeda_acrescimo_lebes[vi] +
                            (p-acrescimo * (titpag.titvlpag / sc2015.titvlpag))
                            tt-receb.receb_moeda_juros_lebes[vi] = 
                            tt-receb.receb_moeda_juros_lebes[vi] +
                        (sc2015.titjuro * (titpag.titvlpag / sc2015.titvlpag))
                            .
                        else if p-sitlan = "FINANCEIRA"
                            then 
                            assign
                            tt-receb.recebimento_moeda_fdrebes[vi] = 
                             tt-receb.recebimento_moeda_fdrebes[vi] +
                              titpag.titvlpag
                              tt-receb.receb_moeda_principal_fdrebes[vi] =
                            tt-receb.receb_moeda_principal_fdrebes[vi] +
                            (p-principal * (titpag.titvlpag / sc2015.titvlpag))
                            tt-receb.receb_moeda_acrescimo_fdrebes[vi] = 
                            tt-receb.receb_moeda_acrescimo_fdrebes[vi] +
                            (p-acrescimo * (titpag.titvlpag / sc2015.titvlpag))
                            tt-receb.receb_moeda_juros_fdrebes[vi] = 
                            tt-receb.receb_moeda_juros_fdrebes[vi] +
                           (sc2015.titjur * (titpag.titvlpag / sc2015.titvlpag))
                            .
                        leave.
                    end.    
                 end.               
            end.
        end.
        else do:
            find first tt-recmoeda where
                       tt-recmoeda.etbcod = vetb-pag and
                       tt-recmoeda.datref = sc2015.titdtpag and
                       tt-recmoeda.moecod = sc2015.moecod
                       no-error.
            if not avail tt-recmoeda
            then do:
                        create tt-recmoeda.
                        assign
                                tt-recmoeda.etbcod = vetb-pag
                                tt-recmoeda.datref = sc2015.titdtpag
                                tt-recmoeda.moecod = sc2015.moecod.
            end.           
            tt-recmoeda.valor = tt-recmoeda.valor + sc2015.titvlcob.

            find first moeda where  moeda.moecod = sc2015.moecod
                               no-lock no-error.
            if not avail moeda
            then find first moeda where moeda.moecod = "REA"
                                no-lock no-error.
            vi = 0.
            do vi = 1 to 15:
                if tt-receb.define_recebimento_moeda[vi] = ""
                then tt-receb.define_recebimento_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom.
                if tt-receb.define_recebimento_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom
                then do:
                    if p-sitlan = "LEBES"
                    then assign
                        tt-receb.recebimento_moeda_lebes[vi] =
                            tt-receb.recebimento_moeda_lebes[vi] 
                            + sc2015.titvlcob
                        tt-receb.receb_moeda_principal_lebes[vi] =
                            tt-receb.receb_moeda_principal_lebes[vi] 
                            + p-principal
                        tt-receb.receb_moeda_acrescimo_lebes[vi] =
                            tt-receb.receb_moeda_acrescimo_lebes[vi] 
                            + p-acrescimo
                        tt-receb.receb_moeda_juros_lebes[vi] = 
                            tt-receb.receb_moeda_juros_lebes[vi] +
                            sc2015.titjuro
                            .
                      else if p-sitlan = "FINANCEIRA"
                        then assign
                            tt-receb.recebimento_moeda_fdrebes[vi] =
                                tt-receb.recebimento_moeda_fdrebes[vi] +
                                sc2015.titvlcob
                            tt-receb.receb_moeda_principal_fdrebes[vi] =
                                    tt-receb.receb_moeda_principal_fdrebes[vi] 
                                + p-principal
                            tt-receb.receb_moeda_acrescimo_fdrebes[vi] =
                               tt-receb.receb_moeda_acrescimo_fdrebes[vi] 
                                + p-acrescimo
                            tt-receb.receb_moeda_juros_fdrebes[vi] = 
                            tt-receb.receb_moeda_juros_fdrebes[vi] +
                            sc2015.titjuro
                            .
  
                    leave.
                end.    
            end.         
        end.        
    end.
                   
    if sc2015.titjuro > 0
    then do:
        
        find first tt-tabdac where
         tt-tabdac.etblan = vetb-pag and
         tt-tabdac.datlan = sc2015.titdtpag and
         tt-tabdac.clicod = sc2015.clifor and
         tt-tabdac.numlan = sc2015.titnum and
         tt-tabdac.parlan = sc2015.titpar and
         tt-tabdac.tiplan = "JUROS" and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
        if not avail tt-tabdac 
        then do on error undo: 
            create tt-tabdac.
            assign
            tt-tabdac.etbcod = sc2015.etbcod
            tt-tabdac.etblan = vetb-pag
            tt-tabdac.etbpag = sc2015.etbcob
            tt-tabdac.clicod = sc2015.clifor
            tt-tabdac.numlan = sc2015.titnum
            tt-tabdac.parlan = sc2015.titpar
            tt-tabdac.datemi = sc2015.titdtemi
            tt-tabdac.datven = sc2015.titdtven
            tt-tabdac.datlan = sc2015.titdtpag
            tt-tabdac.datpag = sc2015.titdtpag
            tt-tabdac.datexp = today
            tt-tabdac.vallan = sc2015.titjuro
            tt-tabdac.tiplan = "JUROS"
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = "JUROS " + string(sc2015.titnum)
            tt-tabdac.anolan = year(sc2015.titdtpag)
            tt-tabdac.meslan = month(sc2015.titdtpag)
            tt-tabdac.natlan = "J"
            .
            release tt-tabdac no-error.
        end. 
        
        if p-sitlan = "LEBES"
        then tt-receb.juros_lebes = tt-receb.juros_lebes + sc2015.titjuro.
        else if p-sitlan = "FINANCEIRA"
            then tt-receb.juros_fdrebes = tt-receb.juros_fdrebes
                        + sc2015.titjuro.
    end.

end procedure.

procedure put-recebimento-novacao:

    find first tt-tabdac where
         tt-tabdac.etblan = vetb-pag and
         tt-tabdac.datlan = tit-novado.titdtpag and
         tt-tabdac.clicod = tit-novado.clifor and
         tt-tabdac.numlan = tit-novado.titnum and
         tt-tabdac.parlan = tit-novado.titpar and
         tt-tabdac.tiplan = p-tiplan and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
    if not avail tt-tabdac 
    then do:
        find first tt-tabdac where
                   tt-tabdac.etbcod = vetb-pag and
                   tt-tabdac.clicod = tit-novado.clifor and
                   tt-tabdac.numlan = tit-novado.titnum and
                   tt-tabdac.parlan = tit-novado.titpar and
                   tt-tabdac.datemi = tit-novado.titdtemi and
                   tt-tabdac.tiplan = p-tiplan  and
                   tt-tabdac.sitlan = p-sitlan
                   no-lock no-error.
        if not avail tt-tabdac
        then do on error undo: 
        create tt-tabdac.
        assign
            tt-tabdac.etbcod = tit-novado.etbcod
            tt-tabdac.etblan = vetb-pag
            tt-tabdac.etbpag = tit-novado.etbcob
            tt-tabdac.clicod = tit-novado.clifor
            tt-tabdac.numlan = tit-novado.titnum
            tt-tabdac.parlan = tit-novado.titpar
            tt-tabdac.datemi = tit-novado.titdtemi
            tt-tabdac.datven = tit-novado.titdtven
            tt-tabdac.datlan = tit-novado.titdtpag
            tt-tabdac.datpag = tit-novado.titdtpag
            tt-tabdac.datexp = today
            tt-tabdac.vallan = tit-novado.titvlcob
            tt-tabdac.tiplan = p-tiplan
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = p-tiplan + " " + string(tit-novado.titnum)
            tt-tabdac.anolan = year(tit-novado.titdtpag)
            tt-tabdac.meslan = month(tit-novado.titdtpag)
            tt-tabdac.natlan = "-"
            tt-tabdac.principal = p-principal
            tt-tabdac.acrescimo = p-acrescimo
            .
        release tt-tabdac no-error.
        end.
    end. 
    if p-sitlan = "FINANCEIRA"
    then
        assign
            tt-receb.recebimento_novacao = 
                tt-receb.recebimento_novacao + tit-novado.titvlcob
            tt-receb.recebimento_principal_novacao =
                tt-receb.recebimento_principal_novacao + p-principal
            tt-receb.recebimento_acrescimo_novacao = 
                tt-receb.recebimento_acrescimo_novacao + p-acrescimo
            tt-receb.recebimento_novacao_fdrebes = 
                tt-receb.recebimento_novacao_fdrebes + tit-novado.titvlcob
            tt-receb.rec_principal_novacao_fdrebes =
                tt-receb.rec_principal_novacao_fdrebes + p-principal
            tt-receb.rec_acrescimo_novacao_fdrebes = 
                tt-receb.rec_acrescimo_novacao_fdrebes + p-acrescimo
             .
    else 
        assign
            tt-receb.recebimento_novacao = 
                tt-receb.recebimento_novacao + tit-novado.titvlcob
            tt-receb.recebimento_principal_novacao =
                tt-receb.recebimento_principal_novacao + p-principal
            tt-receb.recebimento_acrescimo_novacao = 
                tt-receb.recebimento_acrescimo_novacao + p-acrescimo
            tt-receb.recebimento_novacao_lebes = 
                tt-receb.recebimento_novacao_lebes + tit-novado.titvlcob
            tt-receb.rec_principal_novacao_lebes =
                tt-receb.rec_principal_novacao_lebes + p-principal
            tt-receb.rec_acrescimo_novacao_lebes = 
                tt-receb.rec_acrescimo_novacao_lebes + p-acrescimo
            .
end procedure.


procedure put-recebimento-titulosal:

     find first tt-tabdac where
         tt-tabdac.etblan = vetb-pag and
         tt-tabdac.datlan = titulosal.titdtpag and
         tt-tabdac.clicod = titulosal.clifor and
         tt-tabdac.numlan = titulosal.titnum and
         tt-tabdac.parlan = titulosal.titpar and
         tt-tabdac.tiplan = p-tiplan   and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
    if not avail tt-tabdac 
    then do on error undo: 
        create tt-tabdac.
        assign
            tt-tabdac.etbcod = titulosal.etbcod
            tt-tabdac.etblan = vetb-pag
            tt-tabdac.etbpag = titulosal.etbcob
            tt-tabdac.clicod = titulosal.clifor
            tt-tabdac.numlan = titulosal.titnum
            tt-tabdac.parlan = titulosal.titpar
            tt-tabdac.datemi = titulosal.titdtemi
            tt-tabdac.datven = titulosal.titdtven
            tt-tabdac.datlan = titulosal.titdtpag
            tt-tabdac.datpag = titulosal.titdtpag
            tt-tabdac.datexp = today
            tt-tabdac.vallan = titulosal.titvlcob
            tt-tabdac.tiplan = p-tiplan
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = p-tiplan + " " + string(titulosal.titnum)
            tt-tabdac.anolan = year(titulosal.titdtpag)
            tt-tabdac.meslan = month(titulosal.titdtpag)
            tt-tabdac.natlan = "-"
            tt-tabdac.principal = p-principal
            tt-tabdac.acrescimo = p-acrescimo
            .
        release tt-tabdac no-error.
    end. 
    
    tt-receb.recebimento_lebes = tt-receb.recebimento_lebes +
                         titulosal.titvlcob.
    tt-receb.recebimento_principal_lebes = 
            tt-receb.recebimento_principal_lebes + p-principal.
    tt-receb.recebimento_acrescimo_lebes =
            tt-receb.recebimento_acrescimo_lebes + p-acrescimo.
    
    find first tt-recmoeda where
                tt-recmoeda.etbcod = titulosal.etbcobra and
                tt-recmoeda.datref = titulosal.titdtpag and
                tt-recmoeda.moecod = titulosal.moecod
                       no-error.
    if not avail tt-recmoeda
    then do:
        create tt-recmoeda.
        assign
            tt-recmoeda.etbcod = titulosal.etbcobra
            tt-recmoeda.datref = titulosal.titdtpag
            tt-recmoeda.moecod = titulosal.moecod.
    end.           
    tt-recmoeda.valor = tt-recmoeda.valor +  titulosal.titvlcob.

    find first moeda where  moeda.moecod = titulosal.moecod
                               no-lock no-error.
    if not avail moeda
    then find first moeda where moeda.moecod = "REA"
                                no-lock no-error.
    vi = 0.
    do vi = 1 to 15:
        if tt-receb.define_recebimento_moeda[vi] = ""
        then tt-receb.define_recebimento_moeda[vi] = 
                     moeda.moecod + " - " + moeda.moenom.
        if tt-receb.define_recebimento_moeda[vi] = 
                       moeda.moecod + " - " + moeda.moenom
        then do:
            assign
                tt-receb.recebimento_moeda_lebes[vi] =
                   tt-receb.recebimento_moeda_lebes[vi] +   
                   fin.titulosal.titvlcob
                tt-receb.receb_moeda_principal_lebes[vi] =
                   tt-receb.receb_moeda_principal_lebes[vi] +   
                   p-principal
                tt-receb.receb_moeda_acrescimo_lebes[vi] =
                   tt-receb.receb_moeda_acrescimo_lebes[vi] +   
                   p-acrescimo
                   .
            leave.
        end.
    end. 
end procedure.

procedure put-contratonov:

     find first tt-tabdac where
         tt-tabdac.etbcod = n-contrato.etbcod and
         tt-tabdac.clicod = n-contrato.clicod and
         tt-tabdac.numlan = string(n-contrato.contnum) and
         tt-tabdac.parlan = ? and
         tt-tabdac.datemi = n-contrato.dtinicial and
         tt-tabdac.tiplan = "EMINOVACAO" and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
    if not avail tt-tabdac 
    then do on error undo: 
        create tt-tabdac.
        assign
            tt-tabdac.etbcod = n-contrato.etbcod
            tt-tabdac.etblan = n-contrato.etbcod
            tt-tabdac.etbpag = ?
            tt-tabdac.clicod = n-contrato.clicod
            tt-tabdac.numlan = string(n-contrato.contnum)
            tt-tabdac.parlan = ?
            tt-tabdac.datemi = n-contrato.dtinicial
            tt-tabdac.datven = ?
            tt-tabdac.datlan = n-contrato.dtinicial
            tt-tabdac.datpag = ?
            tt-tabdac.datexp = today
            tt-tabdac.vallan = vtitvlcob
            tt-tabdac.tiplan = "EMINOVACAO"
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = "EMINOVACAO" + string(n-contrato.contnum)
            tt-tabdac.anolan = year(n-contrato.dtinicial)
            tt-tabdac.meslan = month(n-contrato.dtinicial)
            tt-tabdac.natlan = "+"
            tt-tabdac.principal = p-principal
            tt-tabdac.acrescimo = p-acrescimo
            .
        release tt-tabdac no-error.
     end. 
     
     tt-venda.valor_novacao = tt-venda.valor_novacao + vtitvlcob.

     if p-sitlan = "LEBES"
     then  novacao_lebes = novacao_lebes + vtitvlcob.
     else  novacao_fdrebes = novacao_fdrebes + vtitvlcob.

     if vacrescimo > 0
     then do:           
        /******* ACRESCIMO ********/
        
        find first tt-tabdac where
         tt-tabdac.etbcod = n-contrato.etbcod and
         tt-tabdac.clicod = n-contrato.clicod and
         tt-tabdac.numlan = string(n-contrato.contnum) and
         tt-tabdac.parlan = ? and
         tt-tabdac.datemi = n-contrato.dtinicial and
         tt-tabdac.tiplan = "ACRNOVACAO" and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
        if not avail tt-tabdac 
        then do on error undo: 
            create tt-tabdac.
            assign
            tt-tabdac.etbcod = n-contrato.etbcod
            tt-tabdac.etblan = n-contrato.etbcod
            tt-tabdac.etbpag = ?
            tt-tabdac.clicod = n-contrato.clicod
            tt-tabdac.numlan = string(n-contrato.contnum)
            tt-tabdac.parlan = ?
            tt-tabdac.datemi = n-contrato.dtinicial
            tt-tabdac.datven = ?
            tt-tabdac.datlan = n-contrato.dtinicial
            tt-tabdac.datpag = ?
            tt-tabdac.datexp = today
            tt-tabdac.vallan = vacrescimo
            tt-tabdac.tiplan = "ACRNOVACAO"
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = "ACRNOVACAO" + string(n-contrato.contnum)
            tt-tabdac.anolan = year(n-contrato.dtinicial)
            tt-tabdac.meslan = month(n-contrato.dtinicial)
            tt-tabdac.natlan = "+"
            .
            release tt-tabdac no-error.
        end. 
        
        tt-venda.acrescimo_novacao = 
                        tt-venda.acrescimo_novacao + vacrescimo.

        if p-sitlan = "LEBES"
        then tt-venda.acrescimo_novacao_lebes =
             tt-venda.acrescimo_novacao_lebes + vacrescimo.
        else tt-venda.acrescimo_novacao_fdrebes =
             tt-venda.acrescimo_novacao_fdrebes + vacrescimo.
     end.
end procedure.

procedure put-devolucao:
     
     if d-contrato.vltotal > 0
     then do:
         find first tt-tabdac where
            tt-tabdac.etbcod = d-contrato.etbcod and
            tt-tabdac.clicod = d-contrato.clicod and
            tt-tabdac.numlan = string(d-contrato.contnum) and
            tt-tabdac.parlan = ? and
            tt-tabdac.datemi = d-contrato.dtinicial and
            tt-tabdac.tiplan = "DEVOLUCAO" and
            tt-tabdac.sitlan = "LEBES"
            no-lock no-error.
        if not avail tt-tabdac 
        then do on error undo: 
            create tt-tabdac.
            assign
                tt-tabdac.etbcod = d-contrato.etbcod
                tt-tabdac.etblan = d-contrato.etbcod
                tt-tabdac.etbpag = ?
                tt-tabdac.clicod = d-contrato.clicod
                tt-tabdac.numlan = string(d-contrato.contnum)
                tt-tabdac.parlan = ?
                tt-tabdac.datemi = d-contrato.dtinicial
                tt-tabdac.datven = ?
                tt-tabdac.datlan = d-contrato.dtinicial
                tt-tabdac.datpag = ?
                tt-tabdac.datexp = today
                tt-tabdac.vallan = d-contrato.vltotal
                tt-tabdac.tiplan = "DEVOLUCAO"
                tt-tabdac.sitlan = "LEBES"
                tt-tabdac.hislan = "DEVOLUCAO " + string(d-contrato.contnum)
                tt-tabdac.anolan = year(d-contrato.dtinicial)
                tt-tabdac.meslan = month(d-contrato.dtinicial)
                tt-tabdac.natlan = "-"
            .
            release tt-tabdac no-error.
        end. 
          
        tt-venda.devolucao_prazo = 
            tt-venda.devolucao_prazo + d-contrato.vltotal.
     end.
     if d-contrato.vlfrete > 0
     then do:           
        /***ESTORNO***/
        
        
         find first tt-tabdac where
            tt-tabdac.etbcod = d-contrato.etbcod and
            tt-tabdac.clicod = d-contrato.clicod and
            tt-tabdac.numlan = string(d-contrato.contnum) and
            tt-tabdac.parlan = ? and
            tt-tabdac.datemi = d-contrato.dtinicial and
            tt-tabdac.tiplan = "ESTORNO" and
            tt-tabdac.sitlan = "LEBES"
            no-lock no-error.
        if not avail tt-tabdac 
        then do on error undo: 
            create tt-tabdac.
            assign
                tt-tabdac.etbcod = d-contrato.etbcod
                tt-tabdac.etblan = d-contrato.etbcod
                tt-tabdac.etbpag = ?
                tt-tabdac.clicod = d-contrato.clicod
                tt-tabdac.numlan = string(d-contrato.contnum)
                tt-tabdac.parlan = ?
                tt-tabdac.datemi = d-contrato.dtinicial
                tt-tabdac.datven = ?
                tt-tabdac.datlan = d-contrato.dtinicial
                tt-tabdac.datpag = ?
                tt-tabdac.datexp = today
                tt-tabdac.vallan = d-contrato.vlfrete
                tt-tabdac.tiplan = "ESTORNO"
                tt-tabdac.sitlan = "LEBES"
                tt-tabdac.hislan = "ESTORNO " + string(d-contrato.contnum)
                tt-tabdac.anolan = year(d-contrato.dtinicial)
                tt-tabdac.meslan = month(d-contrato.dtinicial)
                tt-tabdac.natlan = "+"
            .
            release tt-tabdac no-error.
        end.         
        
        tt-venda.estorno_devolucao = 
            tt-venda.estorno_devolucao + d-contrato.vlfrete.
     end.
     if d-contrato.vlentra > 0
     then do:
        find first tt-tabdac where
            tt-tabdac.etbcod = d-contrato.etbcod and
            tt-tabdac.clicod = d-contrato.clicod and
            tt-tabdac.numlan = string(d-contrato.contnum) and
            tt-tabdac.parlan = ? and
            tt-tabdac.datemi = d-contrato.dtinicial and
            tt-tabdac.tiplan = "DEVVISTA" and
            tt-tabdac.sitlan = "LEBES"
            no-lock no-error.
        if not avail tt-tabdac 
        then do on error undo: 
            create tt-tabdac.
            assign
                tt-tabdac.etbcod = d-contrato.etbcod
                tt-tabdac.etblan = d-contrato.etbcod
                tt-tabdac.etbpag = ?
                tt-tabdac.clicod = d-contrato.clicod
                tt-tabdac.numlan = string(d-contrato.contnum)
                tt-tabdac.parlan = ?
                tt-tabdac.datemi = d-contrato.dtinicial
                tt-tabdac.datven = ?
                tt-tabdac.datlan = d-contrato.dtinicial
                tt-tabdac.datpag = ?
                tt-tabdac.datexp = today
                tt-tabdac.vallan = d-contrato.vlentra
                tt-tabdac.tiplan = "DEVVISTA"
                tt-tabdac.sitlan = "LEBES"
                tt-tabdac.hislan = "DEVVISTA " + string(d-contrato.contnum)
                tt-tabdac.anolan = year(d-contrato.dtinicial)
                tt-tabdac.meslan = month(d-contrato.dtinicial)
                tt-tabdac.natlan = "DV"
            .
            release tt-tabdac no-error.
        end. 
          
        tt-venda.devolucao_vista = 
            tt-venda.devolucao_vista + d-contrato.vlentra.
     
    end.

     
end procedure.


procedure put-fetitulo:

     find first tt-tabdac where
         tt-tabdac.etblan = vetb-pag and
         tt-tabdac.datlan = envfinan.dt1 and
         tt-tabdac.clicod = fin.titulo.clifor and
         tt-tabdac.numlan = titulo.titnum and
         tt-tabdac.parlan = titulo.titpar and
         tt-tabdac.tiplan = "RECESTFINAN" and
         tt-tabdac.sitlan = "LEBES"
         no-lock no-error.
    if not avail tt-tabdac 
    then do on error undo: 
        create tt-tabdac.
        assign
            tt-tabdac.etbcod = titulo.etbcod
            tt-tabdac.etblan = vetb-pag
            tt-tabdac.etbpag = titulo.etbcob
            tt-tabdac.clicod = titulo.clifor
            tt-tabdac.numlan = titulo.titnum
            tt-tabdac.parlan = titulo.titpar
            tt-tabdac.datemi = titulo.titdtemi
            tt-tabdac.datven = titulo.titdtven
            tt-tabdac.datlan = envfinan.dt1
            tt-tabdac.datpag = titulo.titdtpag
            tt-tabdac.datexp = today
            tt-tabdac.vallan = titulo.titvlcob
            tt-tabdac.tiplan = "RECESTFINAN"
            tt-tabdac.sitlan = "LEBES"
            tt-tabdac.hislan = "RECESTFINAN " + string(titulo.titnum)
            tt-tabdac.anolan = year(envfinan.dt1)
            tt-tabdac.meslan = month(envfinan.dt1)
            tt-tabdac.natlan = "-"
            tt-tabdac.principal = p-principal
            tt-tabdac.acrescimo = p-acrescimo
            tt-tabdac.seguro = p-seguro
            .
        release tt-tabdac no-error.
    end. 
     
    if p-seguro > 0
    then do:
         assign
             tt-receb.define_receb_seguro[1] = "REC - SEGURO"
             tt-receb.receb_seguro[1] = 
                        tt-receb.receb_seguro[1] + p-seguro.
    end.

    tt-receb.estorno_cancelamento_fdrebes = 
                tt-receb.estorno_cancelamento_fdrebes + 
                (titulo.titvlcob - titulo.titdes).
    tt-receb.receb_seguro_lebes = tt-receb.receb_seguro_lebes + p-seguro. 
end procedure.


procedure devolucao:

    def buffer bplani for com.plani.
    def buffer cplani for com.plani.
    def buffer bmovim for com.movim.
    def buffer cmovim for com.movim.
    def buffer ctitulo for fin.titulo.

    for each ctdevven where ctdevven.etbcod = tt-estab.etbcod and
                            ctdevven.pladat = vdata1 /*and
                            ctdevven.placod-ven = 0*/  and
                            ctdevven.serie = "1"
                            no-lock break by placod :


        if first-of(placod)
        then do: 
            find first com.plani where plani.movtdc = ctdevven.movtdc and
                          plani.etbcod = ctdevven.etbcod and
                          plani.placod = ctdevven.placod and
                          plani.serie = "1"
                          no-lock no-error.
            if not avail plani
            then next.
        end.
        
        if ctdevven.placod-ven > 0
        then
        find first bplani where bplani.movtdc = ctdevven.movtdc-ven and
                          bplani.etbcod = ctdevven.etbcod-ven and
                          bplani.placod = ctdevven.placod-ven 
                          no-lock no-error.
        
        
        find first cplani where cplani.movtdc = ctdevven.movtdc-ori and
                          cplani.etbcod = ctdevven.etbcod-ori and
                          cplani.placod = ctdevven.placod-ori
                          no-lock no-error.
            
        if avail cplani
        then do:
           
            find first fin.contnf where contnf.etbcod = cplani.etbcod and
                              contnf.placod = cplani.placod
                              no-lock no-error.
            
            if avail contnf
            then do:
                find first d-contrato where 
                          d-contrato.contnum = contnf.contnum
                          no-error.
                if not avail d-contrato
                then do:
                    create d-contrato.
                    assign
                        d-contrato.contnum = contnf.contnum
                        d-contrato.etbcod  = contnf.etbcod
                        d-contrato.dtinicial = vdata1
                        d-contrato.clicod = cplani.desti
                        .
                end.

                find first btitulo where btitulo.empcod = 19 and
                                  btitulo.titnat = no and
                                  btitulo.modcod = "CRE" and
                                  btitulo.etbcod = cplani.etbcod and
                                  btitulo.clifor = cplani.desti  and
                                  btitulo.titnum = string(contnf.contnum) and
                                  btitulo.moecod = "DEV"  
                                  no-lock no-error.
                if avail btitulo
                then
                for each fin.titulo where titulo.empcod = 19 and
                                  titulo.titnat = no and
                                  titulo.modcod = "CRE" and
                                  titulo.etbcod = cplani.etbcod and
                                  titulo.clifor = cplani.desti  and
                                  titulo.titnum = string(contnf.contnum) 
                                  no-lock:
                                  
                    if titulo.titdtemi = cplani.pladat and 
                        titulo.moecod = "DEV"
                        and titulo.etbcob = ?
                    then  assign
                        d-contrato.vltotal = 
                            d-contrato.vltotal + titulo.titvlcob
                            .
                    else if titulo.etbcob = cplani.etbcod and
                        ctdevven.pladat = titulo.titdtpag
                    then assign
                        d-contrato.vltotal =
                            d-contrato.vltotal + titulo.titvlcob.
                    else            
                    assign
                        d-contrato.vltotal =
                        d-contrato.vltotal + titulo.titvlcob
                        d-contrato.vlfrete =
                        d-contrato.vlfrete + titulo.titvlcob.
                end.  
                else do:

                     d-contrato.vlentra = d-contrato.vlentra +
                                cplani.platot.
                end.
            end.
            else do: 
              
                find first d-contrato where 
                          d-contrato.contnum = cplani.numero and
                          d-contrato.etbcod  = cplani.etbcod
                          no-error.
                if not avail d-contrato
                then do:
                    create d-contrato.
                    assign
                        d-contrato.contnum = cplani.numero
                        d-contrato.etbcod  = cplani.etbcod
                        d-contrato.dtinicial = vdata1
                        d-contrato.clicod = cplani.desti
                        .
                 end.
                 
                 d-contrato.vlentra = d-contrato.vlentra +
                    cplani.platot.
            end.
        end.
    end.

end procedure.

procedure vendavista:
    def var v-recarga as log.
    if tt-estab.etbcod <> 200
    then do:
    for each plani where plani.movtdc = 5 and
                             plani.etbcod = tt-estab.etbcod and
                             plani.pladat = vdata1 /*and
                             plani.crecod = 1 */
                             no-lock:
            
        if plani.crecod = 2 then next.
            
        if substr(plani.notped,1,1) = "C" and
                       (plani.ufemi <> "" or
                        (plani.ufdes <> "" and
                         plani.ufdes <> "C"))
        then do:
            find first fin.titulo where
                titulo.empcod = 19 and
                titulo.titnat = no and
                titulo.modcod = "VVI" and
                titulo.etbcod = plani.etbcod and
                titulo.clifor = plani.desti and
                titulo.titnum = plani.serie + string(plani.numero) and
                titulo.titpar = 1 and
                titulo.titdtemi = plani.pladat
                no-lock no-error.
            if avail fin.titulo 
            then do:
            
                create tit-vista.
                buffer-copy fin.titulo to tit-vista.
            
                if titulo.moecod = "PDM"
                then do:
                    for each titpag where
                          titpag.empcod = titulo.empcod and
                          titpag.titnat = titulo.titnat and
                          titpag.modcod = titulo.modcod and
                          titpag.etbcod = titulo.etbcod and
                          titpag.clifor = titulo.clifor and
                          titpag.titnum = titulo.titnum and
                          titpag.titpar = titulo.titpar
                          no-lock:
                        find first moeda where 
                               moeda.moecod = titpag.moecod
                               no-lock no-error.
                        if not avail moeda
                        then find first moeda where
                                moeda.moecod = "REA"
                                no-lock no-error.
                        vi = 0.
                        do vi = 1 to 15:
                            if tt-venda.define_venda_moeda[vi] = ""
                            then tt-venda.define_venda_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom.
                        
                            if tt-venda.define_venda_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom
                            then do:
                                tt-venda.venda_moeda[vi] =
                                tt-venda.venda_moeda[vi] + titpag.titvlpag.
                                leave.
                            end.    
                        end.         
                        tt-venda.venda_vista =
                               tt-venda.venda_vista + titpag.titvlpag.
                    
                    end.               
                end.            
                else do:
                     find first moeda where 
                               moeda.moecod = titulo.moecod
                               no-lock no-error.
                     if not avail moeda
                     then find first moeda where
                                moeda.moecod = "REA"
                                no-lock no-error.
                     vi = 0.
                     do vi = 1 to 15:
                        if tt-venda.define_venda_moeda[vi] = ""
                        then tt-venda.define_venda_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom.
                        
                        if tt-venda.define_venda_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom
                        then do:
                            tt-venda.venda_moeda[vi] =
                             tt-venda.venda_moeda[vi] + titulo.titvlcob.
                            leave.
                        end.    
                    end.         
                    tt-venda.venda_vista =
                           tt-venda.venda_vista + titulo.titvlcob.
                    
                end. 
            end.
            else do:
                find first moeda where
                                moeda.moecod = "REA"
                                no-lock no-error.
                     vi = 0.
                do vi = 1 to 15:
                        if tt-venda.define_venda_moeda[vi] = ""
                        then tt-venda.define_venda_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom.
                        
                        if tt-venda.define_venda_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom
                        then do:
                            tt-venda.venda_moeda[vi] =
                             tt-venda.venda_moeda[vi] + plani.platot.
                            leave.
                        end.    
                end.         
                tt-venda.venda_vista =
                           tt-venda.venda_vista + plani.platot.
            end.
        end. 
        else do:
            v-recarga = no.
            for each com.movim where
                     movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc 
                     no-lock:
                find produ where produ.procod = movim.procod no-lock.
                if produ.pronom matches "*recarga*"
                then assign
                    tt-venda.venda_recarga[1] =
                     tt-venda.venda_recarga[1] + (movim.movpc * movim.movqtm)
                    tt-venda.venda_vista = tt-venda.venda_vista +
                        (movim.movpc * movim.movqtm)
                     v-recarga = yes.  
                     .
            end.
            if v-recarga = yes
            then do:
                tt-venda.define_venda_recarga[1] = "REC - RECARGA".
                /*create tit-vista.
                buffer-copy titulo to tit-vista.
                */
            end.
        end.                   
    end.
    end.
    else do: 
        for each plani where plani.movtdc = 5 and
                             plani.etbcod = tt-estab.etbcod and
                             plani.pladat = vdata1 /*and
                             plani.crecod = 1 */
                             no-lock:

            if plani.modcod = "CAN"
            then next.
        
            find first moeda where
                                moeda.moecod = "REA"
                                no-lock no-error.
                     vi = 0.
            do vi = 1 to 15:
                        if tt-venda.define_venda_moeda[vi] = ""
                        then tt-venda.define_venda_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom.
                        
                        if tt-venda.define_venda_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom
                        then do:
                            tt-venda.venda_moeda[vi] =
                             tt-venda.venda_moeda[vi] + plani.platot.
                            leave.
                        end.    
            end.         
            tt-venda.venda_vista =
                           tt-venda.venda_vista + plani.platot.
        end.
    end.
    
    /******
    for each fin.titulo where
             titulo.etbcobra = tt-estab.etbcod and
             titulo.titdtpag = vdata1 and
             titulo.modcod   = "VVI"
             no-lock:
        
        find first com.plani where plani.etbcod = tt-estab.etbcod and
                         plani.movtdc = 5 and
                         plani.emite = tt-estab.etbcod and
                         plani.serie = "V" and
                         plani.numero = int(trim(substr(titulo.titnum,2,9)))
                         no-lock no-error.
        if avail plani and
                substr(plani.notped,1,1) = "C" and
                       plani.ufemi <> ""
        then do: 
            
            create tit-vista.
            buffer-copy titulo to tit-vista.
            
            if titulo.moecod = "PDM"
            then do:
                for each titpag where
                      titpag.empcod = titulo.empcod and
                      titpag.titnat = titulo.titnat and
                      titpag.modcod = titulo.modcod and
                      titpag.etbcod = titulo.etbcod and
                      titpag.clifor = titulo.clifor and
                      titpag.titnum = titulo.titnum and
                      titpag.titpar = titulo.titpar
                      no-lock:
                    find first moeda where 
                               moeda.moecod = titpag.moecod
                               no-lock no-error.
                    if not avail moeda
                    then find first moeda where
                                moeda.moecod = "REA"
                                no-lock no-error.
                    vi = 0.
                    do vi = 1 to 15:
                        if tt-venda.define_venda_moeda[vi] = ""
                        then tt-venda.define_venda_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom.
                        
                        if tt-venda.define_venda_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom
                        then do:
                            tt-venda.venda_moeda[vi] =
                             tt-venda.venda_moeda[vi] + titpag.titvlpag.
                            leave.
                        end.    
                    end.         
                    tt-venda.venda_vista =
                           tt-venda.venda_vista + titpag.titvlpag.
                    
                 end.               
            end.            
            else do:
                     find first moeda where 
                               moeda.moecod = titulo.moecod
                               no-lock no-error.
                     if not avail moeda
                     then find first moeda where
                                moeda.moecod = "REA"
                                no-lock no-error.
                     vi = 0.
                     do vi = 1 to 15:
                        if tt-venda.define_venda_moeda[vi] = ""
                        then tt-venda.define_venda_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom.
                        
                        if tt-venda.define_venda_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom
                        then do:
                            tt-venda.venda_moeda[vi] =
                             tt-venda.venda_moeda[vi] + titulo.titvlcob.
                            leave.
                        end.    
                    end.         
                    tt-venda.venda_vista =
                           tt-venda.venda_vista + titulo.titvlcob.
                    
            end.                     
        end.                         
        else if avail plani
        then do:
            
            v-recarga = no.
            for each com.movim where
                     movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc 
                     no-lock:
                find produ where produ.procod = movim.procod no-lock.
                if produ.pronom matches "*recarga*"
                then assign
                    tt-venda.venda_recarga[1] =
                     tt-venda.venda_recarga[1] + (movim.movpc * movim.movqtm)
                    tt-venda.venda_vista = tt-venda.venda_vista +
                        (movim.movpc * movim.movqtm)
                     v-recarga = yes.  
                     .
            end.
            if v-recarga = yes
            then do:
                tt-venda.define_venda_recarga[1] = "REC - RECARGA".
                create tit-vista.
                buffer-copy titulo to tit-vista.
            end.
        end.
    end. 
    ****************/
            
end procedure.

