{admcab.i}

{retorna-pacnv.i new}

def var p-seguro as dec.
def var p-principal as dec.
def var p-acrescimo as dec.
def var p-juros as dec.
def var p-crepes as dec.

def var vi as int.
def var vb as int.

def var p-sitlan as char.
def var p-tiplan as char.
def var vnum-lan as char.

def buffer btitulo for fin.titulo.

def temp-table tt-tabdac like tabdac17.

def temp-table tt-rec-moe
    field etbcod like estab.etbcod
    field datref as date
    field moecod like fin.moeda.moecod
    field valor as dec
    index i1 etbcod moecod.

def buffer moeda for fin.moeda.

def var vdti as date.
def var vdtf as date.
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
    
def temp-table tt-venda like tabcem17.
def temp-table tt-receb like tabcre17.

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
/***
def temp-table tt-estab
    field etbcod like estab.etbcod
    .

for each estab.
create tt-estab.
tt-estab.etbcod = estab.etbcod .
end.
***/
def var vdia as int.
def var vmes as int.
def var vano as int.

def var varqexp as char.
def stream tl .
def var vdata1 as date. 
def var vhist as char.
def var varquivo as char.
def var vetbcod like estab.etbcod.
    
/*****************    
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
***********/
      
def var vrecebe-ant as dec.

def var vclifor as char.

def temp-table tt-contrato 
    field dtinicial like fin.contrato.dtinicial
    field contnum like fin.contrato.contnum
    field vltotal like fin.contrato.vltotal
    field vlacres as dec
    .

def temp-table fc-contrato like fin.contrato.
def temp-table d-contrato like fin.contrato.
def temp-table e-contrato like fin.contrato.
def temp-table tit-vista like fin.titulo.

def var val-novacao as dec.
def var vtitnum like fin.titulo.titnum.
/*output to value(varqexp).*/
output stream tl to terminal.

def var v-principal as dec.
def var v-acrescimo as dec.
def var v-novacao as log format "Sim/Nao".
def var v-financiado as dec.
def var v-clientes as dec.
def var v-entrada as dec.
def var v-seguro as dec.
def var v-crepes as dec.
def var vendap-fiscal  as dec.
def var vendap-servico as dec.
def var vendap-recarga as dec.
def var vendap-cartaopresente as dec.
def new shared temp-table tit-novado like fin.titulo.
def var venda-total as dec.
for each tt-tabdac: delete tt-tabdac. end.
update 
vetblan like estab.etbcod label "Filial" 
        with frame f2 side-label width 80.
if vetblan > 0
then do:
    find estab where estab.etbcod = vetblan no-lock no-error.
    disp estab.etbnom no-label with frame f2.
end.
else disp "Todas as filiais" @ estab.etbnom with frame f2.

update vdti at 1 label "Periodo" vdtf label "a" with frame f2 side-label.

sresp = no.
Message "Confirma iniciar processamento?" update sresp.
if not sresp then return.
def var v-abate as dec.

def temp-table tt-contnum no-undo
    field contnum like contrato.contnum
    index i1 contnum
    .
    
def temp-table tt-estab
    field etbcod like estab.etbcod
    .

for each estab no-lock.
    if vetblan > 0 and vetblan <> estab.etbcod then next.
    create tt-estab.
    tt-estab.etbcod = estab.etbcod .
end.

for each tt-estab  no-lock:       
    if tt-estab.etbcod >= 900 and
       tt-estab.etbcod <> 993
    then vetb-pag = 996.
    else vetb-pag = tt-estab.etbcod.

    for each tt-contdat: delete tt-contdat. end.
    for each tt-venda. delete tt-venda. end.
    for each tt-receb. delete tt-receb. end.
    for each tt-tabdac. delete tt-tabdac. end.
    
    do vdata1 = vdti to vdtf:
        disp stream tl "Processando ... " tt-estab.etbcod vdata1 
                with frame fxy1 no-label 1 down centered no-box
                color message .
        pause 0.
        
        disp "Emissao " string(time,"hh:mm:ss")
        with frame f-d down. 
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
        
        for each fc-contrato: delete fc-contrato. end.
        for each d-contrato: delete d-contrato. end.
        for each e-contrato: delete e-contrato. end.
        for each tit-novado: delete tit-novado. end.
        for each tit-vista: delete tit-vista. end.
        for each tt-contnum: delete tt-contnum. end.
        assign
            p-principal = 0
            p-acrescimo = 0
            p-juros = 0.
            
        for each contrato where contrato.etbcod = tt-estab.etbcod and
                                contrato.dtinicial = vdata1
                                no-lock:
            create tt-contnum.
            tt-contnum.contnum = contrato.contnum.
        end.                         
        for each plani where plani.etbcod  = tt-estab.etbcod and
                             plani.movtdc  = 5 and
                             plani.pladat  = vdata1 and
                             plani.crecod  = 2
                             no-lock:
        
            if plani.modcod = "CAN" then next.
            if plani.platot < plani.protot then next.
            
            if substr(plani.notped,1,1) = "C" and
                       (plani.ufemi <> "" or
                        (plani.ufdes <> "" and
                         plani.ufdes <> "C"))
            then.
            else next.

            
            vendap-fiscal = 0 .
            vendap-servico = 0.
            vendap-recarga = 0.
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:
                find produ where produ.procod = movim.procod
                                            no-lock no-error.
                
                
                if not avail produ then next.
                if produ.proipiper = 98 
                then vendap-servico = vendap-servico 
                            + (movim.movpc * movim.movqtm).
                else if produ.pronom matches "*RECARGA*" 
                then vendap-recarga = vendap-recarga
                            + (movim.movpc * movim.movqtm).
                else if produ.pronom matches "*CARTAO PRESENTE*"
                then vendap-cartaopresente = vendap-cartaopresente
                        + (movim.movpc * movim.movqtm).
                else vendap-fiscal = vendap-fiscal + 
                                (movim.movpc * movim.movqtm).
            end.
            venda-total = venda-total + vendap-fiscal.
            if vendap-recarga > 0
            then do:
                tt-venda.define_venda_recarga[2] = "REC - p/RECARGA".
                tt-venda.venda_recarga[2] =
                     tt-venda.venda_recarga[2] + vendap-recarga.
                     .
            end.
            if vendap-cartaopresente > 0
            then do:
                tt-venda.define_venda_cartaopresente[2] = 
                            "CPR - p/CARTAO PRESENTE".
                tt-venda.venda_recarga[2] =
                     tt-venda.venda_recarga[2] + vendap-cartaopresente.
                     .
            end.
            if vendap-fiscal = 0 then next.
            /*
            message vendap-recarga vendap-cartaopresente vendap-fiscal.
            pause. */
            assign
                        v-principal = 0
                        v-acrescimo = 0
                        v-novacao = no
                        v-financiado = 0
                        v-clientes = 0
                        vtitvlcob = 0
                        v-entrada = 0
                        vacrescimo = 0
                        v-seguro = 0
                        v-crepes = 0
                        v-abate = 0.
                        .
            find first contnf where contnf.etbcod = plani.etbcod and
                                  contnf.placod = plani.placod  and
                                  contnf.notaser = plani.serie
                                  no-lock no-error.
            if avail contnf 
            then do:
                find first contrato where 
                           contrato.contnum = contnf.contnum and
                           contrato.etbcod = contnf.etbcod and
                           contrato.dtinicial = plani.pladat
                           no-lock no-error.              
                if avail contrato
                then do:
                    find first envfinan where 
                               envfinan.empcod = 19
                           and envfinan.titnat = no
                           and envfinan.modcod = "CRE"
                           and envfinan.etbcod = contrato.etbcod
                           and envfinan.clifor = contrato.clicod
                           and envfinan.titnum = string(contrato.contnum)
                           and envfinan.envsit = "INC"
                           no-lock no-error.
                    
                    assign
                        v-principal = 0
                        v-acrescimo = 0
                        v-novacao = no
                        v-financiado = 0
                        v-clientes = 0
                        vtitvlcob = 0
                        v-entrada = 0
                        vacrescimo = 0
                        v-seguro = 0
                        v-crepes = 0
                        v-abate = 0.
                        .
                    /*
                    find last titulo where
                              titulo.empcod = 19 and
                              titulo.titnat = no and
                              titulo.modcod = contrato.modcod and
                              titulo.etbcod = contrato.etbcod and
                              titulo.clifor = contrato.clicod and
                              titulo.titnum = string(contrato.contnum)
                              no-lock no-error.
                    */
                              
                    run principal-renda(input recid(plani),
                                        input recid(contrato),
                                        input ?).
                    
                    assign
                        v-principal  = pacnv-principal
                        v-acrescimo  = pacnv-acrescimo
                        v-novacao    = pacnv-novacao
                        v-entrada = pacnv-entrada
                        v-seguro = pacnv-seguro
                        v-crepes = pacnv-crepes
                        v-abate  = pacnv-abate
                        .

                    v-abate = 0.
                    if vendap-fiscal > v-principal and v-abate = 0
                    then v-abate = vendap-fiscal - v-principal.

                    if v-entrada > 0
                    then do:
                        assign
                            vtitvlcob  = v-entrada
                            vacrescimo = 0
                            p-sitlan = "ENTRADA"
                            vnum-lan = string(contrato.contnum)
                            .
                        run put-contrato.   
                    end.
                    if v-abate > 0
                    then do:
                        assign
                            vtitvlcob  = v-abate
                            vacrescimo = 0
                            p-sitlan = "OUTROS"
                            vnum-lan = string(contrato.contnum)
                            .
                        run put-contrato.   
                    end.
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
                            tt-venda.define_venda_cpess[1] = 
                                            "CP - CREDITO PESSOAL"
                            tt-venda.venda_cpess[1] = 
                                tt-venda.venda_cpess[1] + v-crepes
                                tt-venda.venda_seguro_fdrebes =
                                tt-venda.venda_seguro_fdrebes + v-crepes.
                                .
                        if vendap-fiscal > 0
                        then do:
                            assign
                            vtitvlcob = vendap-fiscal
                            vacrescimo = 0.
                            p-sitlan = "SEMCUPOM".
                            vnum-lan = string(contrato.contnum).
                            run put-contrato.        
                        end.   
                    end.
                    if v-principal > 0 
                    then do:
                        assign
                            vtitvlcob = v-principal
                            vacrescimo = v-acrescimo
                             .
                        
                        if substr(plani.notped,1,1) = "C" and
                                (plani.ufemi <> "" or
                                 (plani.ufdes <> "" and
                                  plani.ufdes <> "C"))
                        then do: 
                            if avail envfinan 
                            then p-sitlan = "FINANCEIRA".
                            else p-sitlan = "LEBES".
                            vnum-lan = string(contrato.contnum).
                            run put-contrato.
                        end.
                        else do:
                            p-sitlan = "SEMCUPOM".
                            vnum-lan = string(contrato.contnum).
                            run put-contrato.        
                        end.            
                    end.
                    find first tt-contnum where
                               tt-contnum.contnum = contrato.contnum
                               no-error.
                    if avail tt-contnum
                    then delete tt-contnum.      
                end.
                else do:

                    assign
                        v-principal = 0
                        v-acrescimo = 0
                        v-novacao = no
                        v-financiado = 0
                        v-clientes = 0
                        vtitvlcob = 0
                        vacrescimo = 0
                        v-entrada = 0
                        v-seguro = 0
                        v-crepes = 0
                        v-abate = 0.
                        .
                    /***
                    run /admcom/custom/Claudir/retorna-pacnv-valores.p
                               (input recid(plani),
                                input ?,
                                input ?).
                    ***/

                    run principal-renda(input recid(plani),
                                        input ?,
                                        input ?).
                    
                    assign
                        v-principal  = pacnv-principal
                        v-acrescimo  = pacnv-acrescimo
                        v-novacao    = pacnv-novacao
                        v-entrada = pacnv-entrada
                        v-seguro = pacnv-seguro
                        v-crepes = pacnv-crepes
                        v-abate  = pacnv-abate
                        .

                    v-abate = 0.
                    if vendap-fiscal > v-principal and v-abate = 0
                    then v-abate = vendap-fiscal - v-principal.

                    if v-abate > 0
                    then do:
                        assign
                            vtitvlcob  = v-abate
                            vacrescimo = 0
                            p-sitlan = "OUTROS"
                            vnum-lan = string(contnf.contnum)
                            .
                        run put-contrato.   
                    end.
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
                            tt-venda.define_venda_cpess[1] = 
                                            "CP - CREDITO PESSOAL"
                            tt-venda.venda_cpess[1] = 
                                tt-venda.venda_cpess[1] + v-crepes
                                tt-venda.venda_seguro_fdrebes =
                                tt-venda.venda_seguro_fdrebes + v-crepes.
                                .
                        if vendap-fiscal > 0
                        then do:
                            assign
                            vtitvlcob = vendap-fiscal
                            vacrescimo = 0.
                            p-sitlan = "SEMCUPOM".
                            vnum-lan = string(contnf.contnum).
                            run put-contrato.        
                        end.   
                    end.
                    if v-principal > 0 
                    then do:
                        assign
                            vtitvlcob = v-principal
                            vacrescimo = v-acrescimo .
                        
                        if substr(plani.notped,1,1) = "C" and
                                (plani.ufemi <> "" or
                                 (plani.ufdes <> "" and
                                  plani.ufdes <> "C"))
                        then do: 
                            p-sitlan = "LEBES".
                            vnum-lan = string(contnf.contnum).
                            run put-contrato.
                        end.
                        else do:
                            p-sitlan = "SEMCUPOM".
                            vnum-lan = string(contnf.contnum).
                            run put-contrato.        
                        end.            
                    end.
                    find first tt-contnum where
                               tt-contnum.contnum = contnf.contnum no-error.
                    if avail tt-contnum
                    then delete tt-contnum.           
                end.
            end.
            /****
            else if avail contnf and vendap-recarga > 0
            then do:
                tt-venda.define_venda_recarga[2] = "REC - p/RECARGA".
                tt-venda.venda_recarga[2] =
                     tt-venda.venda_recarga[2] + vendap-recarga.
                     .
            end.
            else if avail contnf and vendap-cartaopresente > 0
            then do:
                tt-venda.define_venda_cartaopresente[2] = 
                            "CPR - p/CARTAO PRESENTE".
                tt-venda.venda_recarga[2] =
                     tt-venda.venda_recarga[2] + vendap-cartaopresente.
                     .
            end.
            else if avail contnf and vendap-servico > 0
            then do:
                
            end.
            ****/
            else do:
                assign
                    vtitvlcob  = vendap-fiscal
                    vacrescimo = 0
                    p-sitlan = "OUTROS"
                    vnum-lan = string(plani.numero).
                    .
                run put-contrato.    
            end.
        end.

        /*********** NOVAÇÃO DE DIVIDA ****************/
        def var v-juro as dec.
        for each tt-contnum: 
            find contrato where contrato.contnum = tt-contnum.contnum
                                no-lock no-error.
            if not avail contrato then next.                    
            find first titulo where
                       titulo.clifor = contrato.clicod and
                       titulo.titnum = string(contrato.contnum) and
                       titulo.titpar = 1
                       no-lock no-error.
            if avail titulo
            then next. 
            v-principal = 0.
            for each tit_novacao where
                     tit_novacao.ger_contnum = contrato.contnum no-lock:
                v-principal = v-principal + tit_novacao.ori_titvlcob.
            end.         
            v-financiado = 0.
            v-clientes = 0.
            v-acrescimo = 0.
            v-juro = 0.
            for each   titulo where
                       titulo.clifor = contrato.clicod and
                       titulo.titnum = string(contrato.contnum) and
                       titulo.titpar > 30
                       no-lock:
                if titulo.cobcod = 10
                then v-financiado = v-financiado + titulo.titvlcob.
                else v-clientes = v-clientes + titulo.titvlcob. 
                if v-juro = 0
                then v-juro = dec(acha("JURO-ATU",titulo.titobs[1])).
            end.
            if v-juro < contrato.vltotal - v-principal
            then v-principal = v-principal + v-juro.
            v-acrescimo = (v-financiado + v-clientes) - v-principal.
            if v-acrescimo < 0
            then assign
                    v-principal = v-principal + v-acrescimo
                    v-acrescimo = 0.
            vtitvlcob = v-principal.
            vacrescimo = v-acrescimo.
            if v-financiado > 0
            then p-sitlan = "FINANCEIRA".
            else if v-clientes > 0
                then p-sitlan = "LEBES". 
            run put-contratonov.
            /*find first tt-contnum where
                       tt-contnum.contnum = contrato.contnum no-error.
            if avail tt-contnum
            then*/ delete tt-contnum.           
        end.
        
        /****                        
        for each contrato where contrato.etbcod = tt-estab.etbcod and
                                contrato.dtinicial = vdata1 and
                                contrato.crecod = 1
                                no-lock:
            find first titulo where
                       titulo.clifor = contrato.clicod and
                       titulo.titnum = string(contrato.contnum) and
                       titulo.titpar = 1
                       no-lock no-error.
            if avail titulo
            then next. 
            find first titulo where
                       titulo.clifor = contrato.clicod and
                       titulo.titnum = string(contrato.contnum) and
                       titulo.titpar >= 30
                       no-lock no-error.
            if not avail titulo or
                acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = ?
            then next.    
            v-principal = 0.
            for each tit_novacao where
                     tit_novacao.ger_contnum = contrato.contnum no-lock:
                v-principal = v-principal + tit_novacao.ori_titvlcob.
            end.         
            v-financiado = 0.
            v-clientes = 0.
            v-acrescimo = 0.
            for each   titulo where
                       titulo.clifor = contrato.clicod and
                       titulo.titnum = string(contrato.contnum) and
                       titulo.titpar > 30
                       no-lock:
                if titulo.cobcod = 10
                then v-financiado = v-financiado + titulo.titvlcob.
                else v-clientes = v-clientes + titulo.titvlcob. 
            end.
            v-acrescimo = (v-financiado + v-clientes) - v-principal.
            if v-acrescimo < 0
            then assign
                    v-principal = v-principal + v-acrescimo
                    v-acrescimo = 0.
            vtitvlcob = v-principal.
            vacrescimo = v-acrescimo.
            if v-financiado > 0
            then p-sitlan = "FINANCEIRA".
            else if v-clientes > 0
                then p-sitlan = "LEBES". 
            run put-contratonov.
            find first tt-contnum where
                       tt-contnum.contnum = contrato.contnum no-error.
            if avail tt-contnum
            then delete tt-contnum.  
        end. 
        *******/        
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
                /**************************
                run retorna-pacnv.p (input recid(plani),
                                        input recid(contrato), 
                                        output v-novacao,
                                        output v-financiado,
                                        output v-clientes,
                                        output v-principal, 
                                        output v-acrescimo,
                                        output v-seguro,
                                        output v-crepes,
                                        output v-abate).
                
                ***************/
                
                run principal-renda(input ?,
                                        input recid(contrato),
                                        input ?).
 
                assign
                    v-principal  = pacnv-principal
                    v-acrescimo  = pacnv-acrescimo
                    vtitvlcob  = v-principal
                    vacrescimo = v-acrescimo
                    .
                
                p-sitlan = "LEBES".
                run put-fccontrato.
                
        end.

        run vendavista.
        
        for each tit-vista no-lock:
            run put-vendavista.
        end. 
            
        run devolucao.

        for each d-contrato no-lock:
            run put-devolucao.
        end.
         
        output to value("/admcom/relat/sobra-contrato-"
                        + string(vdata1,"99999999") + ".txt").
        for each tt-contnum :
            put tt-contnum.contnum format ">>>>>>>>>9" skip.
        end.
        output close.
        
        disp "Recebimento" string(time,"hh:mm:ss")
        with frame f-d. 
        pause 0.
            
        /******** RECEBIMENTO ***********/

        /* titulos receber no perirodo ***/
        
        for each titulo where
                 titulo.titnat = no and
                 titulo.titdtven = vdata1 and
                 titulo.etbcod = tt-estab.etbcod and
                 titulo.modcod = "CRE" and
                 titulo.titsit = "LIB"
                 no-lock:
            if titulo.titsit = "PAG" then next.      
            if titulo.titvlcob <= 0 then next.
            if titulo.clifor = 1 then next.
            if titulo.titpar = 0 then next.
            assign    
                p-principal = 0
                p-acrescimo = 0
                p-seguro = 0
                p-juros = titulo.titjuro
                p-crepes = 0.
                
            run principal-renda(input ?, input ?, input recid(titulo)).


            assign
                p-principal = pacnv-principal
                p-acrescimo = pacnv-acrescimo
                p-seguro    = pacnv-seguro
                p-crepes    = pacnv-crepes
                tt-receb.receber_principal = tt-receb.receber_principal +
                                p-principal
                tt-receb.receber_acrescimo = tt-receb.receber_acrescimo +
                                p-acrescimo
                tt-receb.receber_seguro = tt-receb.receber_seguro +
                                p-seguro
                tt-receb.receber_crepes = tt-receb.receber_crepes +
                                p-crepes
                .
            if titulo.cobcod = 10
            then do:
                tt-receb.receber_principal_fdrebes = 
                tt-receb.receber_principal_fdrebes + p-principal.
                tt-receb.receber_acrescimo_fdrebes = 
                tt-receb.receber_acrescimo_fdrebes + p-acrescimo.
            end.
            else do:
                tt-receb.receber_principal_lebes = 
                tt-receb.receber_principal_lebes + p-principal.
                tt-receb.receber_acrescimo_lebes = 
                tt-receb.receber_acrescimo_lebes + p-acrescimo.
            end.        
        end.         

        /***** titulos recebidos no periodo *****/

        for each titulo where
                 titulo.etbcobra = tt-estab.etbcod and
                 titulo.titdtpag = vdata1 and
                 titulo.titnat = no
                 no-lock:

            if titulo.modcod <> "CRE" then next.
            if titulo.titvlcob <= 0 then next.
            if titulo.clifor = 1 then next.
            if titulo.titnat = yes then next.
            
            if titulo.titpar = 0
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
            end.
            else do:
            
                find first TSC2017 where
                                   TSC2017.empcod = titulo.empcod and
                                   TSC2017.titnat = titulo.titnat and
                                   TSC2017.modcod = titulo.modcod and
                                   TSC2017.etbcod = titulo.etbcod and
                                   TSC2017.clifor = titulo.clifor and
                                   TSC2017.titnum = titulo.titnum and
                                   TSC2017.titpar = titulo.titpar
                                   no-error.
                if avail TSC2017 then next. 
                
                assign    
                    p-principal = 0
                    p-acrescimo = 0
                    p-seguro = 0
                    p-juros = titulo.titjuro
                    p-crepes = 0.
                
                run principal-renda(input ?, input ?, recid(titulo)).

                assign
                    p-principal = pacnv-principal
                    p-acrescimo = pacnv-acrescimo
                    p-seguro    = pacnv-seguro
                    p-crepes    = pacnv-crepes
                    .
            
                /****
                disp titulo.titnum titulo.moecod
                p-principal p-acrescimo cobcod. pause.
                
                if p-acrescimo = ?
                then do:
                    disp titulo.titnum titulo.clifor p-principal p-acrescimo(total).
                end. 
                ****/   
                
                if p-crepes > 0
                then do:
                        p-tiplan = "RECCREPES".
                        p-sitlan = "FINANCEIRA".
                        p-principal = p-crepes.
                        run put-recebimento.
                end. 
                else do:
                    
                    if titulo.cobcod = 10
                    then do:                     
                        if titulo.moecod = "NOV"
                        then do:
                            p-tiplan = "RECNOVACAO".
                            p-sitlan = "FINANCEIRA".
                            run put-recebimento-novacao.
                        end.
                        else do:
                            p-tiplan = "RECEBIMENTO".
                            p-sitlan = "FINANCEIRA".
                            run put-recebimento.
                        end.
                    end.
                    else do:
                        if titulo.moecod = "NOV"
                        then do:
                            p-tiplan = "RECNOVACAO".
                            p-sitlan = "LEBES".
                            run put-recebimento-novacao.
                        end.
                        else do:
                            p-tiplan = "RECEBIMENTO".
                            p-sitlan = "LEBES".
                            run put-recebimento.
                        end.
                    end.
                end.
                if titulo.titdtven >= vdti and
                   titulo.titdtven <= vdtf
                then do:
                    assign
                         tt-receb.receber_principal = 
                            tt-receb.receber_principal + p-principal
                         tt-receb.receber_acrescimo = 
                            tt-receb.receber_acrescimo + p-acrescimo
                         tt-receb.receber_seguro = 
                            tt-receb.receber_seguro + p-seguro
                         tt-receb.receber_crepes = 
                            tt-receb.receber_crepes + p-crepes
                         .
                    if titulo.cobcod = 10
                    then do:
                        tt-receb.receber_principal_fdrebes = 
                        tt-receb.receber_principal_fdrebes + p-principal.
                        tt-receb.receber_acrescimo_fdrebes = 
                        tt-receb.receber_acrescimo_fdrebes + p-acrescimo.
                    end.
                    else do:
                        tt-receb.receber_principal_lebes = 
                        tt-receb.receber_principal_lebes + p-principal.
                        tt-receb.receber_acrescimo_lebes = 
                        tt-receb.receber_acrescimo_lebes + p-acrescimo.
                    end.   
                end.
            end.
        end.

        for each TSC2017 where
                 TSC2017.titnat = no and
                 TSC2017.etbcobra = tt-estab.etbcod and
                 TSC2017.titdtpagaux = vdata1 and
                 TSC2017.titsit = "PAG"
                 no-lock:
            
                find first titulo where
                           titulo.empcod = TSC2017.empcod and
                           titulo.titnat = TSC2017.titnat and
                           titulo.modcod = TSC2017.modcod and
                           titulo.etbcod = TSC2017.etbcod and
                           titulo.clifor = TSC2017.clifor and
                           titulo.titnum = TSC2017.titnum and
                           titulo.titpar = TSC2017.titpar
                           no-lock  no-error.
                if not avail titulo then next. 
                
                assign    
                    p-principal = 0
                    p-acrescimo = 0
                    p-seguro = 0
                    p-juros = titulo.titjuro
                    p-crepes = 0.
                
                run principal-renda(input ?, input ?, recid(titulo)).

                assign
                    p-principal = pacnv-principal
                    p-acrescimo = pacnv-acrescimo
                    p-seguro    = pacnv-seguro
                    p-crepes    = pacnv-crepes
                    .
            
                p-tiplan = "RECEBIMENTO".
                p-sitlan = "LEBES".
                run put-recebimentoTSC.

                if titulo.titdtven >= vdti and
                   titulo.titdtven <= vdtf
                then do:
                    assign
                         tt-receb.receber_principal = 
                            tt-receb.receber_principal + p-principal
                         tt-receb.receber_acrescimo = 
                            tt-receb.receber_acrescimo + p-acrescimo
                         tt-receb.receber_seguro = 
                            tt-receb.receber_seguro + p-seguro
                         tt-receb.receber_crepes = 
                            tt-receb.receber_crepes + p-crepes
                         .
                    if titulo.cobcod = 10
                    then do:
                        tt-receb.receber_principal_fdrebes = 
                        tt-receb.receber_principal_fdrebes + p-principal.
                        tt-receb.receber_acrescimo_fdrebes = 
                        tt-receb.receber_acrescimo_fdrebes + p-acrescimo.
                    end.
                    else do:
                        tt-receb.receber_principal_lebes = 
                        tt-receb.receber_principal_lebes + p-principal.
                        tt-receb.receber_acrescimo_lebes = 
                        tt-receb.receber_acrescimo_lebes + p-acrescimo.
                    end.   
                end.

        end.    
             
        /**** estornados financeira ****/
           
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
               
            assign    
                    p-principal = 0
                    p-acrescimo = 0
                    p-seguro = 0
                    p-juros = titulo.titjuro
                    p-crepes = 0.
                
            run principal-renda(input ?, input ?, input recid(titulo)).

            assign
                    p-principal = pacnv-principal
                    p-acrescimo = pacnv-acrescimo
                    p-seguro    = pacnv-seguro
                    p-crepes    = pacnv-crepes
                    .
                    
            run put-fetitulo.
                
        end.

        /**** outros ***/
        
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

        
        disp "Fim" string(time,"hh:mm:ss")
            with frame f-d.
        down with frame f-d  .
        pause 1. 
    end.
    run grava-registros.
end.
                    
output stream tl close.
/*
disp venda-total. pause.
*/
def temp-table tt-total like tt-venda.

def var ok-venda as log.
def var ok-recebimento as log.
def var ok-entrada as log.
def var ok-recarga as log.

procedure grava-registros.
    for each tabdac17 where
             tabdac17.etblan = tt-estab.etbcod and
             tabdac17.datlan >= vdti and
             tabdac17.datlan <= vdtf
             :
            delete tabdac17.
    end. 
    for each tt-tabdac no-lock:
        find tabdac17 where
         tabdac17.etbcod = tt-tabdac.etbcod and
         tabdac17.clicod = tt-tabdac.clicod and
         tabdac17.numlan = tt-tabdac.numlan and
         tabdac17.parlan = tt-tabdac.parlan and
         tabdac17.datemi = tt-tabdac.datemi and
         tabdac17.tiplan = tt-tabdac.tiplan and
         tabdac17.sitlan = tt-tabdac.sitlan
         no-error.
        if not avail tabdac17
        then do:
            create tabdac17.
            buffer-copy tt-tabdac to tabdac17.
        end.
    end.
    for each tabcem17 where 
             tabcem17.etbcod = tt-estab.etbcod and
             tabcem17.datref >= vdti and
                          tabcem17.datref <= vdtf:
        delete tabcem17.
    end.
    for each tt-venda no-lock:
        create tabcem17.
        buffer-copy tt-venda to tabcem17.
    end. 
    for each tabcre17 where 
             tabcre17.etbcod = tt-estab.etbcod and
             tabcre17.datref >= vdti and
                          tabcre17.datref <= vdtf:
        delete tabcre17.
    end.
    for each tt-receb no-lock:
        create tabcre17.
        buffer-copy tt-receb to tabcre17.
    end.           
    
    /****
    for each estab no-lock:
        for each tabdac17 where
             tabdac17.etblan = estab.etbcod and
             tabdac17.datlan >= vdti and
             tabdac17.datlan <= vdtf and
             tabdac17.tiplan begins "REC"
             :
    
            delete tabdac17.
        end.
    end. 
    for each tt-tabdac no-lock:
        find tabdac17 where
             tabdac17.etbcod = tt-tabdac.etbcod and
             tabdac17.clicod = tt-tabdac.clicod and
             tabdac17.numlan = tt-tabdac.numlan and
             tabdac17.parlan = tt-tabdac.parlan and
             tabdac17.datemi = tt-tabdac.datemi and
             tabdac17.tiplan = tt-tabdac.tiplan and
             tabdac17.sitlan = tt-tabdac.sitlan
             no-error.
        
        if not avail tabdac17
        then create tabdac17.
        buffer-copy tt-tabdac to tabdac17.
    end.

    for each tabcre17 where tabcre17.datref >= vdti and
                          tabcre17.datref <= vdtf:
        delete tabcre17.
    end.
    for each tt-receb no-lock:
        create tabcre17.
        buffer-copy tt-receb to tabcre17.
    end.
     ****/
end procedure.

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
         tt-tabdac.etbcod = plani.etbcod and
         tt-tabdac.clicod = plani.desti and
         tt-tabdac.numlan = vnum-lan and
         tt-tabdac.parlan = ? and
         tt-tabdac.datemi = plani.pladat and
         tt-tabdac.tiplan = "EMISSAO"  and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
    if not avail tt-tabdac 
    then do on error undo: 

        create tt-tabdac.
        assign
            tt-tabdac.etbcod = plani.etbcod
            tt-tabdac.etblan = plani.etbcod
            tt-tabdac.etbpag = ?
            tt-tabdac.clicod = plani.desti
            tt-tabdac.numlan = vnum-lan
            tt-tabdac.parlan = ?
            tt-tabdac.datemi = plani.pladat
            tt-tabdac.datven = ?
            tt-tabdac.datlan = plani.pladat
            tt-tabdac.datpag = ?
            tt-tabdac.datexp = today
            tt-tabdac.vallan = vtitvlcob
            tt-tabdac.tiplan = "EMISSAO"
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = "EMISSAO " + vnum-lan
            tt-tabdac.anolan = year(plani.pladat)
            tt-tabdac.meslan = month(plani.pladat)
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
            else if p-sitlan = "OUTROS"
                then tt-venda.venda_prazo_outras =
                                tt-venda.venda_prazo_outras + vtitvlcob .

     
     if vacrescimo > 0
     then do:           
        /******* ACRESCIMO ********/
    
        find first tt-tabdac where
         tt-tabdac.etbcod = plani.etbcod and
         tt-tabdac.clicod = plani.desti and
         tt-tabdac.numlan = vnum-lan and
         tt-tabdac.parlan = ? and
         tt-tabdac.datemi = plani.pladat and
         tt-tabdac.tiplan = "ACRESCIMO" and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
        if not avail tt-tabdac 
        then do on error undo: 
            create tt-tabdac.
            assign
            tt-tabdac.etbcod = plani.etbcod
            tt-tabdac.etblan = plani.etbcod
            tt-tabdac.etbpag = ?
            tt-tabdac.clicod = plani.desti
            tt-tabdac.numlan = vnum-lan
            tt-tabdac.parlan = ?
            tt-tabdac.datemi = plani.pladat
            tt-tabdac.datven = ?
            tt-tabdac.datlan = plani.pladat
            tt-tabdac.datpag = ?
            tt-tabdac.datexp = today
            tt-tabdac.vallan = vacrescimo
            tt-tabdac.tiplan = "ACRESCIMO"
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = "ACRESCIMO " + vnum-lan
            tt-tabdac.anolan = year(plani.pladat)
            tt-tabdac.meslan = month(plani.pladat)
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

    /****
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
    ***/
end procedure.

procedure put-recebimento:

     find first tt-tabdac where
         tt-tabdac.etblan = vetb-pag and
         tt-tabdac.datlan = titulo.titdtpag and
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
    else if p-seguro > 0
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

procedure put-recebimentoTSC:

     find first tt-tabdac where
         tt-tabdac.etblan = vetb-pag and
         tt-tabdac.datlan = vdata1 and
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
            tt-tabdac.datlan = vdata1
            tt-tabdac.datpag = titulo.titdtpag
            tt-tabdac.datexp = today
            tt-tabdac.vallan = titulo.titvlcob
            tt-tabdac.tiplan = p-tiplan
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = p-tiplan + " " + string(titulo.titnum)
            tt-tabdac.anolan = year(vdata1)
            tt-tabdac.meslan = month(vdata1)
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
    else if p-seguro > 0
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
                       tt-recmoeda.datref = vdata1 and
                       tt-recmoeda.moecod = titpag.moecod
                       no-error.
                 if not avail tt-recmoeda
                 then do:
                        create tt-recmoeda.
                        assign
                                tt-recmoeda.etbcod = vetb-pag
                                tt-recmoeda.datref = vdata1
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
                       tt-recmoeda.datref = vdata1 and
                       tt-recmoeda.moecod = titulo.moecod
                       no-error.
            if not avail tt-recmoeda
            then do:
                        create tt-recmoeda.
                        assign
                                tt-recmoeda.etbcod = vetb-pag
                                tt-recmoeda.datref = vdata1
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
         tt-tabdac.datlan = vdata1 and
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
            tt-tabdac.datlan = vdata1
            tt-tabdac.datpag = titulo.titdtpag
            tt-tabdac.datexp = today
            tt-tabdac.vallan = titulo.titjuro
            tt-tabdac.tiplan = "JUROS"
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = "JUROS " + string(titulo.titnum)
            tt-tabdac.anolan = year(vdata1)
            tt-tabdac.meslan = month(vdata1)
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
         tt-tabdac.datlan = titulo.titdtpag and
         tt-tabdac.clicod = titulo.clifor and
         tt-tabdac.numlan = titulo.titnum and
         tt-tabdac.parlan = titulo.titpar and
         tt-tabdac.tiplan = p-tiplan and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
    if not avail tt-tabdac 
    then do:
        find first tt-tabdac where
                   tt-tabdac.etbcod = vetb-pag and
                   tt-tabdac.clicod = titulo.clifor and
                   tt-tabdac.numlan = titulo.titnum and
                   tt-tabdac.parlan = titulo.titpar and
                   tt-tabdac.datemi = titulo.titdtemi and
                   tt-tabdac.tiplan = p-tiplan  and
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
            .
        release tt-tabdac no-error.
        end.
    end. 
    if p-sitlan = "FINANCEIRA"
    then
        assign
            tt-receb.recebimento_novacao = 
                tt-receb.recebimento_novacao + titulo.titvlcob
            tt-receb.recebimento_principal_novacao =
                tt-receb.recebimento_principal_novacao + p-principal
            tt-receb.recebimento_acrescimo_novacao = 
                tt-receb.recebimento_acrescimo_novacao + p-acrescimo
            tt-receb.recebimento_novacao_fdrebes = 
                tt-receb.recebimento_novacao_fdrebes + titulo.titvlcob
            tt-receb.rec_principal_novacao_fdrebes =
                tt-receb.rec_principal_novacao_fdrebes + p-principal
            tt-receb.rec_acrescimo_novacao_fdrebes = 
                tt-receb.rec_acrescimo_novacao_fdrebes + p-acrescimo
             .
    else 
        assign
            tt-receb.recebimento_novacao = 
                tt-receb.recebimento_novacao + titulo.titvlcob
            tt-receb.recebimento_principal_novacao =
                tt-receb.recebimento_principal_novacao + p-principal
            tt-receb.recebimento_acrescimo_novacao = 
                tt-receb.recebimento_acrescimo_novacao + p-acrescimo
            tt-receb.recebimento_novacao_lebes = 
                tt-receb.recebimento_novacao_lebes + titulo.titvlcob
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
         tt-tabdac.etbcod = contrato.etbcod and
         tt-tabdac.clicod = contrato.clicod and
         tt-tabdac.numlan = string(contrato.contnum) and
         tt-tabdac.parlan = ? and
         tt-tabdac.datemi = contrato.dtinicial and
         tt-tabdac.tiplan = "EMINOVACAO" and
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
            tt-tabdac.tiplan = "EMINOVACAO"
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = "EMINOVACAO" + string(contrato.contnum)
            tt-tabdac.anolan = year(contrato.dtinicial)
            tt-tabdac.meslan = month(contrato.dtinicial)
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
         tt-tabdac.etbcod = contrato.etbcod and
         tt-tabdac.clicod = contrato.clicod and
         tt-tabdac.numlan = string(contrato.contnum) and
         tt-tabdac.parlan = ? and
         tt-tabdac.datemi = contrato.dtinicial and
         tt-tabdac.tiplan = "ACRNOVACAO" and
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
            tt-tabdac.tiplan = "ACRNOVACAO"
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = "ACRNOVACAO" + string(contrato.contnum)
            tt-tabdac.anolan = year(contrato.dtinicial)
            tt-tabdac.meslan = month(contrato.dtinicial)
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

    for each plani where plani.etbcod = tt-estab.etbcod and
                         plani.pladat = vdata1 and
                         plani.movtdc = 12 
                         no-lock:

        if plani.serie = "U" then next.

        for each ctdevven where
                 ctdevven.etbcod = plani.etbcod and
                 ctdevven.placod = plani.placod and
                 ctdevven.movtdc = plani.movtdc
                 no-lock:

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
                    else d-contrato.vlentra = d-contrato.vlentra +
                                cplani.platot.
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
    end.                     
end procedure.

procedure vendavista:
    def var v-recarga as log.
    def var v-outm as dec.
    def var venda-fiscal as dec.
    v-outm = 0.
    def var vtotv as dec.
    
    if tt-estab.etbcod <> 200
    then do:
    for each plani where plani.movtdc = 5 and
                             plani.etbcod = tt-estab.etbcod and
                             plani.pladat = vdata1 and
                             plani.crecod = 1 
                             no-lock:
            
        if plani.modcod = "CAN" then next.
        if plani.platot < plani.protot then next.
        if substr(plani.notped,1,1) = "C" and
                       (plani.ufemi <> "" or
                        (plani.ufdes <> "" and
                         plani.ufdes <> "C") or
                         plani.serie <> "V")
        then do:
            v-recarga = no.
            venda-fiscal = 0.
            for each com.movim where
                     movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc and
                     movim.movdat = plani.pladat
                     no-lock:
                find produ where produ.procod = movim.procod no-lock.
                if produ.pronom matches "*recarga*"
                then assign
                    tt-venda.venda_recarga[1] =
                     tt-venda.venda_recarga[1] + (movim.movpc * movim.movqtm)
                     v-recarga = yes  
                     .
                else if produ.pronom matches "*CARTAO PRESENTE*"
                then assign
                    tt-venda.define_venda_cartaopresente[1] =
                                        "CPR - CARTAO PRESENTE"
                    tt-venda.venda_cartaopresente[1] =
                                tt-venda.venda_cartaopresente[1]
                                    + (movim.movpc * movim.movqtm)
                                    .
                else venda-fiscal = venda-fiscal +
                        (movim.movpc * movim.movqtm).
            end.
            if v-recarga = yes
            then do:
                tt-venda.define_venda_recarga[1] = "REC - RECARGA".
            end.

            if venda-fiscal = 0
            then next.
            venda-total = venda-total + venda-fiscal.
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
                v-outm = plani.protot - titulo.titvlcob.
                v-outm = 0.
                /*if v-outm < 0
                then do:
                    message plani.numero plani.protot titulo.titvlcob.
                    pause.
                end.*/
                find first tit-vista of titulo no-error.
                if not avail tit-vista
                then create tit-vista.
                buffer-copy fin.titulo to tit-vista.

                /****
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
                                moeda.moecod = "CHP"
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
                else*/ do:

                if titulo.moecod = "PDM" or titulo.moecod = "CAR"
                then do:
                    find first moeda where 
                               moeda.moecod = "CAR" no-lock no-error.
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
                                tt-venda.venda_moeda[vi] + venda-fiscal.
                                leave.
                            end.    
                    end.         
                    tt-venda.venda_vista =
                               tt-venda.venda_vista + venda-fiscal.
                    
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
                             tt-venda.venda_moeda[vi] + venda-fiscal.
                            leave.
                        end.    
                    end.         
                    tt-venda.venda_vista =
                           tt-venda.venda_vista + venda-fiscal.
                    
                end. 
                end.
                if v-outm <> 0
                then do:
                    vi = 0.
                     do vi = 1 to 15:
                        if tt-venda.define_venda_moeda[vi] = ""
                        then tt-venda.define_venda_moeda[vi] = 
                                 "OUT - Outros ".
                        
                        if tt-venda.define_venda_moeda[vi] = 
                                "OUT - Outros"
                        then do:
                            tt-venda.venda_moeda[vi] =
                             tt-venda.venda_moeda[vi] + v-outm.
                            leave.
                        end.    
                    end.         
                    tt-venda.venda_vista =
                           tt-venda.venda_vista + v-outm.
                    
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
                             tt-venda.venda_moeda[vi] + plani.protot.
                            leave.
                        end.    
                end.         
                tt-venda.venda_vista =
                           tt-venda.venda_vista + plani.protot.
            end.
        end. 
        else do:
            v-recarga = no.
            for each com.movim where
                     movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc and
                     movim.movdat = plani.pladat
                     no-lock:
                find produ where produ.procod = movim.procod no-lock.
                if produ.pronom matches "*recarga*"
                then assign
                    tt-venda.venda_recarga[1] =
                     tt-venda.venda_recarga[1] + (movim.movpc * movim.movqtm)
                    /*tt-venda.venda_vista = tt-venda.venda_vista +
                        (movim.movpc * movim.movqtm)*/
                     v-recarga = yes  
                     .
                else if produ.pronom matches "*CARTAO PRESENTE*"
                then assign
                    tt-venda.define_venda_cartaopresente[1] =
                                        "CPR - CARTAO PRESENTE"
                    tt-venda.venda_cartaopresente[1] =
                                tt-venda.venda_cartaopresente[1]
                                    + (movim.movpc * movim.movqtm)
                                    .
                    
            end.
            if v-recarga = yes
            then do:
                tt-venda.define_venda_recarga[1] = "REC - RECARGA".
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

            vtotv = 0.
            if plani.modcod = "CAN" then next.
            if plani.platot < plani.protot then next.
            vtotv = 0.
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:
                find produ where produ.procod = movim.procod no-lock no-error.
                
                {valida-venda-fiscal.i}
                
                vtotv = vtotv + (movim.movpc * movim.movqtm).
            end.
            if vtotv > 0
            then do:
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
                             tt-venda.venda_moeda[vi] + vtotv. 
                            leave.
                        end.    
                end.
            end.        
             
            /****
            if plani.frete > 0
            then do:
                vi = 0.
                do vi = 1 to 15:
                    if tt-venda.define_venda_moeda[vi] = ""
                    then tt-venda.define_venda_moeda[vi] = 
                                "FRE - FRETE".
                        
                    if tt-venda.define_venda_moeda[vi] = 
                                "FRE - FRETE"
                    then do:
                            tt-venda.venda_moeda[vi] =
                             tt-venda.venda_moeda[vi] + plani.frete.
                            leave.
                    end.    
                end.
            end. 
            ****/            

            tt-venda.venda_vista =
                           tt-venda.venda_vista + vtotv.

         end.
    end.
    
end procedure.

procedure principal-renda:

    def input parameter rec-plani    as recid.
    def input parameter rec-contrato as recid.
    def input parameter rec-titulo   as recid.
    
    assign
        pacnv-avista     = 0
        pacnv-aprazo     = 0
        pacnv-principal  = 0
        pacnv-acrescimo  = 0
        pacnv-entrada    = 0
        pacnv-seguro     = 0
        pacnv-crepes     = 0
        pacnv-troca      = 0
        pacnv-voucher    = 0
        pacnv-black      = 0
        pacnv-chepres    = 0
        pacnv-combo      = 0
        pacnv-abate      = 0
        pacnv-novacao    = no
        pacnv-renovacao  = no
        pacnv-feiraonl   = no
        pacnv-cpfautoriza = ""
        pacnv-juroatu     = 0
        pacnv-juroacr     = 0
        .
        
    if rec-titulo = ?
    then do:
        run /admcom/custom/Claudir/retorna-pacnv-valores.p 
                    (input rec-plani, 
                     input rec-contrato, 
                     input rec-titulo).
    end.
    else do:
    find first titpacnv where
               titpacnv.modcod = titulo.modcod and
               titpacnv.etbcod = titulo.etbcod and 
               titpacnv.clifor = titulo.clifor and
               titpacnv.titnum = titulo.titnum and
               titpacnv.titdtemi = titulo.titdtemi
                       no-lock no-error.
    if not avail titpacnv
    then do:
        create titpacnv.
        assign
            titpacnv.modcod   = titulo.modcod
            titpacnv.etbcod   = titulo.etbcod
            titpacnv.clifor   = titulo.clifor
            titpacnv.titnum   = titulo.titnum
            titpacnv.titdtemi = titulo.titdtemi
            titpacnv.titvlcob = titulo.titvlcob
            titpacnv.titdes   = titulo.titdes
            .
          
        run /admcom/custom/Claudir/retorna-pacnv-valores.p 
                    (input rec-plani, 
                     input rec-contrato, 
                     input rec-titulo).

        if  pacnv-principal <= 0 or
            pacnv-acrescimo <= 0
        then assign
                 pacnv-principal = titulo.titvlcob
                 pacnv-acrescimo = 0
                 .

        assign
            titpacnv.principal = pacnv-principal
            titpacnv.acrescimo = pacnv-acrescimo
            .
    end.
    else assign
             pacnv-principal = titpacnv.principal
             pacnv-acrescimo = titpacnv.acrescimo
             pacnv-seguro    = titpacnv.titdes
             .
    end.
end procedure.

