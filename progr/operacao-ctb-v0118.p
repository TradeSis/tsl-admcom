{admcab.i}
{retorna-pacnv.i new} 
message "11122". pause.
def temp-table tt-contrato no-undo
    field etbcod  like estab.etbcod
    field contnum like contrato.contnum
    field dtinicial like contrato.dtinicial
    field vltotal like contrato.vltotal
    field vlentra like contrato.vlentra
    index i1 etbcod contnum.

def temp-table fc-contrato like fin.contrato.
def temp-table tt-valores like opctbval.
def temp-table tt-titpag like titulo.
def temp-table tt-titdev like titulo.

def temp-table pag-titulo no-undo
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field titvlcob like titulo.titvlcob
    field titvlpag like titulo.titvlpag
    index i1 clifor titnum titpar
    .
def temp-table pag-titmoe no-undo
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field moecod like titulo.moecod
    field titvlpag like titulo.titvlpag
    index i1 clifor titnum titpar
    .

def var p-1 as char.
def var p-2 as char.
def var p-3 as char.
def var p-4 as char.
def var p-5 as char.
def var p-6 as char.
def var p-7 as char.
def var p-8 as char.
def var p-9 as char.
def var p-0 as char.

def var venda-total as dec format ">>>,>>>,>>9.99".
def var vtotal as dec format ">>>,>>>,>>9.99".
def var ventra as dec format ">>>,>>>,>>9.99".
def var vtotal-contrato as dec format ">>>,>>>,>>9.99".
def var ventra-contrato as dec format ">>>,>>>,>>9.99".
def var vtotal-venda as dec format ">>>,>>>,>>9.99".

def var vdata as date.
def shared var vdti as date.
def shared var vdtf as date.
def var vetbcod like estab.etbcod.

def var vendap-fiscal as dec.

/********DEVOLUCAO DE VENDA************/
def buffer ctitulo for titulo.

def temp-table tt-datap
    field pladat as date
    field conta  as int
    field contrato as dec
    field nfvenda as int
    field dtvenda as date
    field nfdevol as int
    field valquitado as dec
    field valdevolvido as dec.
    
def var ventrada as dec.
def var vsaida as dec.
def var vorigem as dec.
def buffer bplani for plani.
def buffer cplani for plani.
def buffer bmovim for movim.
def buffer cmovim for movim.
def var vtitdev as dec.
def var vtitpag as dec.
def var vvista as dec.
def var vprazo as dec.
def var vclifor as int.
def var vcontrato like contnf.contnum.
def var vconta-plani as integer.
def var tot-qtd-plani as integer.

def temp-table tt-plaqtd
    field placod like plani.placod.

def var vok-moveis as log .

/*************************/

procedure reinicia-variaveis:
    assign
        p-1 = ""
        p-2 = ""
        p-3 = ""
        p-4 = ""
        p-5 = ""
        p-6 = ""
        p-7 = ""
        p-8 = ""
        p-9 = ""
        p-0 = ""
        .
end procedure.

def var val-fal as dec.
def var vendap-outras as dec.
def var vendap-servico as dec. 
update vetbcod at 7 label "Filial"
       with frame f1 width 80 side-label
       title " GERA BASE DE DADOS " .
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if avail estab
    then disp estab.etbnom no-label with frame f1.
    else undo.
end.
else disp "Todas as filiais" @ estab.etbnom with frame f1.
       
update vdti at 1 label "Data inicial"
       vdtf label "Data final"
       with frame f1.
       
for each estab where (if vetbcod > 0 then estab.etbcod = vetbcod
                       else true) no-lock:
    disp estab.etbcod with frame ff side-label 1 down.
    pause 0.
    for each tt-valores: delete tt-valores. end.
    do vdata = vdti to vdtf:
        disp vdata label "Data" 
             string(time,"hh:mm:ss") no-label
        with frame fff down side-label column 30. pause 0.
        down with fram fff.

        for each tt-contrato: delete tt-contrato. end.
        assign
            vtotal-contrato = 0
            ventra-contrato = 0
            .
        
        for each plani where plani.etbcod  = estab.etbcod and
                             plani.movtdc  = 5 and
                             plani.pladat  = vdata 
                             no-lock:
        
            if plani.modcod = "CAN" then next.
            if plani.crecod = 2 and plani.modcod = "VVI" then next.
            if plani.crecod = 1 and plani.modcod = "FIN" then next.

            assign
                vendap-fiscal  = 0
                vendap-outras  = 0
                vendap-servico = 0.
            
            run reinicia-variaveis.
            p-1 = "VENDA".
            run grava-tt-valores(input plani.platot, "registro").
            
            if plani.crecod = 2
            then p-2 = "A-PRAZO".
            else p-2 = "A-VISTA".
            p-3 = plani.modcod.
            run grava-tt-valores(input plani.platot, "registro").
            p-9 = string(plani.numero).
            p-0 = plani.serie.
            run grava-tt-valores(input plani.platot, "plani").
            /*
            if plani.vlserv > 0
            then do:
                p-4 = "VLSERV".
                run grava-tt-valores(input plani.vlserv, "registro").
                p-9 = string(plani.numero).
                p-0 = plani.serie.
                run grava-tt-valores(input plani.vlserv, "plani").
            end.
            */
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:
                find produ where produ.procod = movim.procod
                                            no-lock no-error.
                
                if not avail produ then next.
                
                assign p-4 = "" p-5 = "" p-6 = "" p-7 = "" p-8 = "".

                if produ.proipiper = 98 
                then do:
                    vendap-servico = vendap-servico +
                            (movim.movpc * movim.movqtm).
                    p-4 = "SERVICO".
                    run grava-tt-valores(input (movim.movpc * movim.movqtm),
                                         "registro").
                    p-5 = produ.pronom.
                    run grava-tt-valores(input (movim.movpc * movim.movqtm),
                                        "registro").
                    p-9 = string(plani.numero).
                    p-0 = plani.serie.
                    run grava-tt-valores(input (movim.movpc * movim.movqtm),
                                    "plani").
                end.
                else if produ.pronom matches "*RECARGA*" 
                then do:
                    vendap-servico = vendap-servico +
                            (movim.movpc * movim.movqtm).
                    p-4 = "SERVICO".
                    run grava-tt-valores(input (movim.movpc * movim.movqtm),
                                    "registro").
                    p-5 = "RECARGA".
                    run grava-tt-valores(input (movim.movpc * movim.movqtm),
                                    "registro").
                    p-9 = string(plani.numero).
                    p-0 = plani.serie.
                    run grava-tt-valores(input (movim.movpc * movim.movqtm),
                                    "plani").
                end.
                else if produ.pronom matches "*CARTAO PRESENTE*"
                then do:
                    vendap-servico = vendap-servico +
                            (movim.movpc * movim.movqtm).
                    p-4 = "SERVICO".
                    run grava-tt-valores(input (movim.movpc * movim.movqtm),
                                        "registro").
                    p-5 = produ.pronom.
                    run grava-tt-valores(input (movim.movpc * movim.movqtm),
                                        "registro").
                    p-9 = string(plani.numero).
                    p-0 = plani.serie.
                    run grava-tt-valores(input (movim.movpc * movim.movqtm),
                                    "plani").
                end.
                else do:
                    assign p-5 = "" p-6 = "" p-7 = "" p-8 = "".
                    if substr(plani.notped,1,1) = "C" and
                       (plani.ufemi <> "" or
                        (plani.ufdes <> "" and
                         plani.ufdes <> "C"))
                    then do: 
                        assign p-4 = "FISCAL".
                        vendap-fiscal = vendap-fiscal +
                                        (movim.movpc * movim.movqtm).
                    end.
                    else do:
                        assign p-4 = "OUTRAS" .
                        vendap-outras = vendap-outras +
                                        (movim.movpc * movim.movqtm).
                    end.                    
                    run grava-tt-valores
                            (input (movim.movpc * movim.movqtm),
                            "registro").

                    p-9 = string(plani.numero).
                    p-0 = plani.serie.
                    run grava-tt-valores(input (movim.movpc * movim.movqtm),
                                "plani").
                end. 
                assign p-4 = "" p-5 = "" p-6 = "" p-7 = "" p-8 = "".
            end.

            find first contnf where contnf.etbcod = plani.etbcod and
                                    contnf.placod = plani.placod  and
                                    contnf.notaser = plani.serie
                                    no-lock no-error.
            if avail contnf 
            then do:
                
                find first contrato where 
                           contrato.dtinicial = plani.pladat and
                           contrato.contnum   = contnf.contnum and
                           contrato.etbcod    = contnf.etbcod 
                           no-lock no-error.              
                if avail contrato
                then do:
                    run reinicia-variaveis.
                    p-1 = "CONTRATO".
                    run grava-tt-valores(input contrato.vltotal, "registro").
                    
                    p-2 = contrato.modcod.
                    if plani.crecod = 2
                    then p-2 = "A-PRAZO".
                    else p-2 = "A-VISTA".
                    p-3 = contrato.modcod.
                    run grava-tt-valores(input contrato.vltotal, "registro").
                    p-9 = string(contrato.contnum).
                    p-0 = "".
                    run grava-tt-valores(input contrato.vltotal, "contrato").
                    
                    find first envfinan where
                       envfinan.empcod = 19 and
                       envfinan.titnat = no and
                       envfinan.modcod = contrato.modcod and
                       envfinan.etbcod = contrato.etbcod and
                       envfinan.clifor = contrato.clicod and
                       envfinan.titnum = string(contrato.contnum)
                       no-lock no-error.
                    if avail envfinan and
                        (envfinan.envsit = "INC" or
                         envfinan.envsit = "PAG")
                    then p-4 = "FINANCEIRA".
                    ELSE p-4 = "LEBES".
                    
                    run grava-informa-contrato(input recid(plani),
                                               input recid(contrato),
                                               input ?).
                    
                    find first tt-contrato where
                               tt-contrato.etbcod = estab.etbcod and 
                               tt-contrato.contnum = contrato.contnum
                               no-error.
                    if not avail tt-contrato
                    then do:
                        create tt-contrato.
                        assign
                            tt-contrato.etbcod  = contrato.etbcod
                            tt-contrato.contnum = contrato.contnum
                            .
                    end.
                end. 
                else do:
                    run reinicia-variaveis.
                    p-1 = "S/CONTRATO".
                    
                    if plani.crecod = 2
                    then p-2 = "A-PRAZO".
                    else p-2 = "A-VISTA".
                    p-3 = plani.modcod.
                    run grava-tt-valores(input plani.platot, "registro").
                    p-9 = string(plani.numero).
                    p-0 = plani.serie.
                    run grava-tt-valores(input plani.platot, "plani").
                    
                    run grava-informa-contrato(input recid(plani),
                                               input ?,
                                               input ?).

                end.
            end.
            else if plani.crecod = 2
            then do:

                run reinicia-variaveis.
                p-1 = "S/CONTRATO".
                    
                if plani.crecod = 2
                then p-2 = "A-PRAZO".
                else p-2 = "A-VISTA".
                p-3 = plani.modcod.
                run grava-tt-valores(input plani.platot, "registro").
                p-9 = string(plani.numero).
                p-0 = plani.serie.
                run grava-tt-valores(input plani.platot, "plani").
     
                run grava-informa-contrato(input recid(plani),
                                               input ?,
                                               input ?).
            end.
            else do:

                run grava-informa-contrato(input recid(plani),
                                           input ?,
                                           input ?).
                
                if plani.crecod = 1
                then do:
                    run paga-venda-vista(input recid(plani)).
                end.
            end.
        end.
        
        for each contrato where contrato.etbcod = estab.etbcod and
                                contrato.dtinicial = vdata
                                no-lock:
            find first tt-contrato where 
                       tt-contrato.etbcod = contrato.etbcod and
                       tt-contrato.contnum = contrato.contnum
                       no-lock no-error.
            if avail tt-contrato then next.           
                                
            run reinicia-variaveis.
            p-1 = "CONTRATO".
            run grava-tt-valores(input contrato.vltotal, "registro").
            
            p-2 = "OUTROS".
            p-3 = contrato.modcod.
            run grava-tt-valores(input contrato.vltotal, "registro").

            run principal-renda(input recid(plani),
                                        input recid(contrato),
                                        input ?).
            if pacnv-feiraonl
            then p-4 = "FEIRAO".
            if pacnv-novacao and pacnv-feiraonl
            then p-4 = "NOVACAO-" + p-4.
            else if pacnv-novacao
                then p-4 = "NOVACAO".
            if pacnv-renovacao and pacnv-feiraonl
            then p-4 = "RENOVACAO-" + p-4.
            else if pacnv-renovacao
                then p-4 = "RENOVACAO".
            
            if p-4 = "" then p-4 = "OUTROS".
            
            run grava-tt-valores(input pacnv-principal +
                                           pacnv-entrada +
                                           pacnv-acrescimo, "registro").

            p-9 = string(contrato.contnum).
            p-0 = "".
            run grava-tt-valores(input pacnv-principal +
                                           pacnv-entrada +
                                           pacnv-acrescimo, "contrato").
            
            find first envfinan where
                       envfinan.empcod = 19 and
                       envfinan.titnat = no and
                       envfinan.modcod = contrato.modcod and
                       envfinan.etbcod = contrato.etbcod and
                       envfinan.clifor = contrato.clicod and
                       envfinan.titnum = string(contrato.contnum)
                       no-lock no-error.
            if avail envfinan and
                (envfinan.envsit = "INC" or
                         envfinan.envsit = "PAG")
            then p-5 = "FINANCEIRA".
            ELSE p-5 = "LEBES". 
                
            run grava-tt-valores(input pacnv-principal +
                                           pacnv-entrada +
                                           pacnv-acrescimo, "registro").
            p-9 = string(contrato.contnum).
            p-0 = "".
            run grava-tt-valores(input pacnv-principal +
                                           pacnv-entrada +
                                           pacnv-acrescimo, "contrato").

            p-6 = "ORIGEM-LEBES".
            run grava-tt-valores(input pacnv-orinl, "registro").
            p-6 = "ORIGEM-FINANCEIRA".
            run grava-tt-valores(input pacnv-orinf, "registro").
            p-6 = "".   
            if pacnv-principal > 0
            then do:
                p-6 = "PRINCIPAL".
                run grava-tt-valores(input pacnv-principal, "registro").
                p-9 = string(contrato.contnum).
                p-0 = "".
                run grava-tt-valores(input pacnv-principal, "contrato").
            end.
            if pacnv-acrescimo > 0
            then do:
                p-6 = "ACRESCIMO".
                run grava-tt-valores(input pacnv-acrescimo, "registro").
                p-9 = string(contrato.contnum).
                p-0 = "".
                run grava-tt-valores(input pacnv-acrescimo, "contrato").
            end.
            if pacnv-entrada > 0
            then do:
                p-6 = "ENTRADA".
                run grava-tt-valores(input pacnv-entrada, "registro").
                p-9 = string(contrato.contnum).
                p-0 = "".
                run grava-tt-valores(input pacnv-entrada, "contrato").
            end.
            if pacnv-seguro > 0
            then do:
                p-6 = "SEGURO".
                run grava-tt-valores(input pacnv-seguro, "registro").
                p-9 = string(contrato.contnum).
                p-0 = "".
                run grava-tt-valores(input pacnv-seguro, "contrato").
            end.
            if pacnv-abate > 0
            then do:
                p-6 = "ABATE".
                run grava-tt-valores(input pacnv-abate, "regsitro").
                p-9 = string(contrato.contnum).
                p-0 = "".
                run grava-tt-valores(input pacnv-abate, "contrato").
                if pacnv-voucher > 0
                then do:
                    p-7 = "VOUCHER".
                    run grava-tt-valores(input pacnv-voucher, "registro").
                    p-9 = string(contrato.contnum).
                    p-0 = "".
                    run grava-tt-valores(input pacnv-voucher, "contrato").
                end.
                if pacnv-black > 0
                then do:
                    p-7 = "BLACK".
                    run grava-tt-valores(input pacnv-black, "registro").
                    p-9 = string(contrato.contnum).
                    p-0 = "".
                    run grava-tt-valores(input pacnv-black, "contrato").
                end. 
                if pacnv-chepres > 0
                then do:   
                    p-7 = "CHEPRES".
                    run grava-tt-valores(input pacnv-chepres, "registro").
                    p-9 = string(contrato.contnum).
                    p-0 = "".
                    run grava-tt-valores(input pacnv-chepres, "contrato").
                end.
                if pacnv-combo > 0
                then do:
                    p-7 = "COMBO".
                    run grava-tt-valores(input pacnv-combo, "registro").
                    p-9 = string(contrato.contnum).
                    p-0 = "".
                    run grava-tt-valores(input pacnv-combo, "contrato").
                end.
                if pacnv-troca > 0
                then do:
                    p-7 = "TROCA".
                    run grava-tt-valores(input pacnv-troca, "registro").
                    p-9 = string(contrato.contnum).
                    p-0 = "".
                    run grava-tt-valores(input pacnv-combo, "contrato").
                end.
            end.
            p-6 = "".
        end.    

        run pdv-moeda(input estab.etbcod, input vdata).
        
        for each titulo where
                 titulo.titnat = no and
                 titulo.titdtpag = vdata and
                 titulo.etbcobra = estab.etbcod /*and
                 titulo.titsit = "PAG" */
                 no-lock:

            if titulo.modcod <> "VVI"
            then do:
                run reinicia-variaveis.
                p-1 = "RECEBIMENTO".
                run grava-tt-valores(input titulo.titvlpag, "registro").
                p-2 = titulo.modcod.
                run grava-tt-valores(input titulo.titvlpag, "registro").

                assign p-6 = "" p-7 = "" p-9 = "" p-0 = "".
                if titulo.titpar = 0
                then do:
                    p-6 = "LEBES".
                    p-7 = "ENTRADA".
                    run grava-tt-valores(input titulo.titvlpag, "registro").
                    p-9 = titulo.titnum.
                    p-0 = string(titulo.titpar).
                    run grava-tt-valores(input titulo.titvlpag, "titulo").
                    run titulo-moeda.
                end.
                else do:
                    run principal-renda(input ?,
                                input ?,
                                input recid(titulo)).

                    if titulo.cobcod = 10
                    then p-6 = "FINANCEIRA".
                    else p-6 = "LEBES".
                    
                    run grava-tt-valores(input titulo.titvlpag, "registro").
                    p-9 = titulo.titnum.
                    p-0 = string(titulo.titpar).
                    run grava-tt-valores(input titulo.titvlpag, "titulo").

                    if pacnv-principal > 0
                    then do:
                        p-7 = "PRINCIPAL".
                        run grava-tt-valores(input pacnv-principal, "registro").
                        p-9 = titulo.titnum.
                        p-0 = string(titulo.titpar).
                        run grava-tt-valores(input pacnv-principal, "titulo").
                    end.
                    if pacnv-acrescimo > 0
                    then do:
                        p-7 = "ACRESCIMO".
                        run grava-tt-valores(input pacnv-acrescimo, "registro").
                        p-9 = titulo.titnum.
                        p-0 = string(titulo.titpar).
                        run grava-tt-valores(input pacnv-acrescimo, "titulo").
                    end.
                    if pacnv-seguro > 0
                    then do:
                        p-7 = "SEGURO".
                        run grava-tt-valores(input pacnv-seguro, "registro").
                        p-9 = titulo.titnum.
                        p-0 = string(titulo.titpar).
                        run grava-tt-valores(input pacnv-seguro, "titulo").
                    end.
                    if titulo.titjuro > 0
                    then do:
                        p-7 = "JURO ATRASO".
                        run grava-tt-valores(input titulo.titjuro, "registro").
                        p-9 = titulo.titnum.
                        p-0 = string(titulo.titpar).
                        run grava-tt-valores(input titulo.titjuro, "titulo").
                    end.
                    run titulo-moeda.
                end.
            end.
            else if titulo.cxacod < 30
            then do:
                run reinicia-variaveis.
                p-1 = "RECEBIMENTO".
                p-2 = "VVI".
                p-6 = "LEBES".

                run grava-tt-valores(input titulo.titvlpag, "registro").
                p-9 = titulo.titnum.
                p-0 = string(titulo.titpar).
                run grava-tt-valores(input titulo.titvlpag, "titulo").
                
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
                 
                    find first moeda where  moeda.moecod = titpag.moecod
                               no-lock no-error.
                    if not avail moeda or moeda.moecod = ""
                    then find first moeda where moeda.moecod = "REA"
                                no-lock no-error.

                    p-8 = moeda.moecod + "-" + moeda.moenom.

                    if titpag.moecod = "NOV"
                    then p-8 = "NOV-NOVACAO".
                    if titpag.moecod = "DEV"
                    then p-8 = "DEV-DEVOLUCAO".

                    run grava-tt-valores(input titpag.titvlpag, "registro").
                    p-9 = titulo.titnum.
                    p-0 = string(titulo.titpar).
                    run grava-tt-valores(input titpag.titvlpag, "titulo").
 
                end.
                else do:
                    find first moeda where  moeda.moecod = titulo.moecod
                               no-lock no-error.
                    if not avail moeda or moeda.moecod = ""
                    then find first moeda where moeda.moecod = "REA"
                                no-lock no-error.
            
                    p-8 = moeda.moecod + "-" + moeda.moenom.
             
                    if titulo.moecod = "NOV"
                    then p-8 = "NOV-NOVACAO".
                    if titulo.moecod = "DEV"
                    then p-8 = "DEV-DEVOLUCAO".
                    run grava-tt-valores(input titulo.titvlpag, "registro").
                    p-9 = titulo.titnum.
                    p-0 = string(titulo.titpar).
                    run grava-tt-valores(input titulo.titvlpag, "titulo").
 
                end.
            end.
        end.             
        run estorno-cancelamento-financeira.
        run devolucao-venda.

    end.
    run grava-registros.
end.

def var varquivo as char.

procedure grava-tt-valores :

    def input parameter p-valor as dec.
    def input parameter p-tipo as char.
    
    if p-valor <> 0
    then do:
        find first tt-valores where
               tt-valores.etbcod = estab.etbcod and
               tt-valores.datref = vdata and
               tt-valores.t1 = p-1 and
               tt-valores.t2 = p-2 and
               tt-valores.t3 = p-3 and
               tt-valores.t4 = p-4 and
               tt-valores.t5 = p-5 and
               tt-valores.t6 = p-6 and
               tt-valores.t7 = p-7 and
               tt-valores.t8 = p-8 and
               tt-valores.t9 = p-9 and
               tt-valores.t0 = p-0 
                               no-error.
        if not avail tt-valores
        then do:
            create tt-valores.
            assign
                tt-valores.etbcod = estab.etbcod
                tt-valores.datref = vdata 
                tt-valores.t1 = p-1
                tt-valores.t2 = p-2
                tt-valores.t3 = p-3
                tt-valores.t4 = p-4
                tt-valores.t5 = p-5
                tt-valores.t6 = p-6
                tt-valores.t7 = p-7
                tt-valores.t8 = p-8
                tt-valores.t9 = p-9
                tt-valores.t0 = p-0
                tt-valores.tipo = p-tipo
                .
        end. 
        tt-valores.valor = tt-valores.valor + p-valor.
    end.     
    
    assign p-9 = "" p-0 = "" .

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
        run retorna-pacnv-valores-contrato.p 
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
          
        run retorna-pacnv-valores-contrato.p 
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

procedure pdv-moeda:
    def input parameter p-etbcod like estab.etbcod.
    def input parameter p-data as date.
    def var vtroco as dec.
    for each pag-titulo. delete pag-titulo. end.
    for each pag-titmoe. delete pag-titmoe. end.
    for each pdvmov where
                 pdvmov.etbcod  = p-etbcod and
                 pdvmov.datamov = p-data no-lock:
        find first pdvmoeda of pdvmov
            where pdvmoeda.moecod = "CRE"
            no-lock no-error.
        if avail pdvmoeda then next.    
        for each pdvdoc of pdvmov where
            pdvdoc.clifor <> 1 and
            pdvdoc.titpar >= 0 
            no-lock:
            create pag-titulo.
            assign
                pag-titulo.clifor = pdvdoc.clifor
                pag-titulo.titnum = pdvdoc.contnum
                pag-titulo.titpar  = pdvdoc.titpar
                pag-titulo.titvlcob = pdvdoc.titvlcob
                pag-titulo.titvlpag = pdvdoc.valor
                .
             vtroco = 0.
             for each pdvmoeda of pdvmov no-lock:
                create pag-titmoe.
                assign
                    pag-titmoe.clifor = pdvdoc.clifor
                    pag-titmoe.titnum = pdvdoc.contnum
                    pag-titmoe.titpar  = pdvdoc.titpar
                    vtroco = pdvmov.valortroco *
                             (pdvmoe.valor / 
                             (pdvmov.valortot + pdvmov.valortroco))
                    pag-titmoe.moecod = pdvmoe.moecod
                    pag-titmoe.titvlpag = (pdvmoe.valor - vtroco) *
                            (pdvdoc.valor  / pdvmov.valortot)
                    .
            end.
        end.
    end.
end procedure.

procedure titulo-moeda:
    def var pag-p2k as log.
    pag-p2k = no.
    def var vpaga as dec init 0.
    if titulo.cxacod >= 30  and titulo.modcod <> "VVI" 
    then 
        for each   pag-titmoe where 
                    pag-titmoe.clifor = titulo.clifor and
                    pag-titmoe.titnum = titulo.titnum and
                    pag-titmoe.titpar = titulo.titpar
                    no-lock:
            pag-p2k = yes.
                
            find first moeda where moeda.moecod = pag-titmoe.moecod
                               no-lock no-error.
            if not avail moeda or moeda.moecod = ""
            then find first moeda where moeda.moecod = "REA"
                                no-lock no-error.
        
            p-8 = moeda.moecod + "-" + moeda.moenom.
            
            if pag-titmoe.moecod = "NOV"
            then p-8 = "NOV-NOVACAO".
            if pag-titmoe.moecod = "DEV"
            then p-8 = "DEV-DEVOLUCAO".

            p-7 = "".
            if titulo.titpar  > 0
            then do:
            if pacnv-principal > 0
            then do:
                vpaga = pacnv-principal *
                        (pag-titmoe.titvlpag / titulo.titvlpag).
                if vpaga = ? then vpaga = 0.        
                p-7 = "PRINCIPAL".
                run grava-tt-valores (input vpaga, "registro").
                p-9 = titulo.titnum.
                p-0 = string(titulo.titpar).
                run grava-tt-valores (input vpaga, "titulo").
            end.
            if pacnv-acrescimo > 0
            then do:
                vpaga = pacnv-acrescimo * 
                        (pag-titmoe.titvlpag / titulo.titvlpag).
                if vpaga = ? then vpaga = 0.        
                p-7 = "ACRESCIMO".
                run grava-tt-valores (input vpaga, "registro").
                p-9 = titulo.titnum.
                p-0 = string(titulo.titpar).
                run grava-tt-valores (input vpaga, "titulo").

            end.
            if titulo.titjuro > 0
            then do:
                vpaga = titulo.titjuro *
                        (pag-titmoe.titvlpag / titulo.titvlpag).
                if vpaga = ? then vpaga = 0.        
                p-7 = "JURO ATRASO".
                run grava-tt-valores (input vpaga, "registro").
                p-9 = titulo.titnum.
                p-0 = string(titulo.titpar).
                run grava-tt-valores (input vpaga, "titulo").

            end. 
            end.
            else do:
                p-7 = "ENTRADA".
                run grava-tt-valores(input titulo.titvlpag, "registro").
                p-9 = titulo.titnum.
                p-0 = string(titulo.titpar).
                run grava-tt-valores(input titulo.titvlpag, "titulo").
            end.   
        end.            
    
    if pag-p2k = no and titulo.cxacod < 30
    then do:
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
                 
            find first moeda where  moeda.moecod = titpag.moecod
                               no-lock no-error.
            if not avail moeda or moeda.moecod = ""
            then find first moeda where moeda.moecod = "REA"
                                no-lock no-error.

            p-8 = moeda.moecod + "-" + moeda.moenom.

            if titpag.moecod = "NOV"
            then p-8 = "NOV-NOVACAO".
            if titpag.moecod = "DEV"
            then p-8 = "DEV-DEVOLUCAO".

            p-7 = "".
            if titulo.titpar > 0
            then do:
            if pacnv-principal > 0
            then do:
                vpaga = pacnv-principal * (titpag.titvlpag / titulo.titvlpag).
                if vpaga = ? then vpaga = 0.
                p-7 = "PRINCIPAL".
                run grava-tt-valores (input vpaga, "registro").
                p-9 = titulo.titnum.
                p-0 = string(titulo.titpar).
                run grava-tt-valores (input vpaga, "titulo").
            end.
            if pacnv-acrescimo > 0
            then do:    
                vpaga = pacnv-acrescimo * (titpag.titvlpag / titulo.titvlpag).
                if vpaga = ? then vpaga = 0.
                p-7 = "ACRESCIMO".
                run grava-tt-valores (input vpaga, "registro").
                p-9 = titulo.titnum.
                p-0 = string(titulo.titpar).
                run grava-tt-valores (input vpaga, "titulo").
            end.
            if titulo.titjuro > 0
            then do:    
                vpaga = titulo.titjuro * (titpag.titvlpag / titulo.titvlpag).
                if vpaga = ? then vpaga = 0.
                p-7 = "JURO ATRASO".
                run grava-tt-valores (input vpaga, "registro").
                p-9 = titulo.titnum.
                p-0 = string(titulo.titpar).
                run grava-tt-valores (input vpaga, "titulo").
            end.
            end.
            else do:
                p-7 = "ENTRADA".
                run grava-tt-valores(input titulo.titvlpag, "registro").
                p-9 = titulo.titnum.
                p-0 = string(titulo.titpar).
                run grava-tt-valores(input titulo.titvlpag, "titulo").
            end.     
        end.
        else do:
            find first moeda where  moeda.moecod = titulo.moecod
                               no-lock no-error.
            if not avail moeda or moeda.moecod = ""
            then find first moeda where moeda.moecod = "REA"
                                no-lock no-error.
            
            p-8 = moeda.moecod + "-" + moeda.moenom.
             
            if titulo.moecod = "NOV"
            then p-8 = "NOV-NOVACAO".
            if titulo.moecod = "DEV"
            then p-8 = "DEV-DEVOLUCAO".

            p-7 = "".
            if titulo.titpar > 0
            then do:
            if pacnv-principal > 0
            then do:
                p-7 = "PRINCIPAL".
                run grava-tt-valores (input pacnv-principal, "registro").
                p-9 = titulo.titnum.
                p-0 = string(titulo.titpar).
                run grava-tt-valores (input pacnv-principal, "titulo").
            end.
            if pacnv-acrescimo > 0
            then do:
                p-7 = "ACRESCIMO".
                run grava-tt-valores (input pacnv-acrescimo, "registro").
                p-9 = titulo.titnum.
                p-0 = string(titulo.titpar).
                run grava-tt-valores (input pacnv-acrescimo, "titulo").
 
            end.
            if titulo.titjuro > 0
            then do:
                p-7 = "JURO ATRASO".
                run grava-tt-valores (input titulo.titjuro, "registro").
                p-9 = titulo.titnum.
                p-0 = string(titulo.titpar).
                run grava-tt-valores (input titulo.titjuro, "titulo").
            end.
            end.
            else do:
                p-7 = "ENTRADA".
                run grava-tt-valores(input titulo.titvlpag, "registro").
                p-9 = titulo.titnum.
                p-0 = string(titulo.titpar).
                run grava-tt-valores(input titulo.titvlpag, "titulo").
            end. 
        end.
    end.
end procedure.

procedure paga-venda-vista:
    def input parameter rec-plani as recid.
    def var vtroco as dec.
    def buffer bplani for plani.
    def var vv as dec.
    find bplani where recid(bplani) = rec-plani no-lock.
    
    for each pdvdoc where pdvdoc.etbcod = bplani.etbcod and
                      pdvdoc.placod = bplani.placod and
                      pdvdoc.datamov = bplani.pladat
                      no-lock:
        find pdvmov of pdvdoc no-lock.
        for each pdvmoeda of pdvmov no-lock.
            vtroco = pdvmov.valortroco *
                             (pdvmoe.valor / 
                             (pdvmov.valortot + pdvmov.valortroco)).
            find first moeda where  moeda.moecod = pdvmoe.moecod
                               no-lock no-error.
            if not avail moeda or moeda.moecod = ""
            then find first moeda where moeda.moecod = "REA"
                                no-lock no-error.
            
            vv = (pdvmoe.valor - vtroco) *
                            (pdvdoc.valor  / pdvmov.valortot).
            if vv = ? then vv = 0.
            run  reinicia-variaveis.
            p-1 = "RECEBIMENTO".
            p-2 = "VVI".
            /*p-3 = "PAG".*/
            p-6 = "LEBES".
            run grava-tt-valores(input vv, "registro").
            /*p-9 = string(plani.numero).
            p-0 = plani.serie.
            run grava-tt-valores(input vv, "plani").
            */  
            p-8 = moeda.moecod + "-" + moeda.moenom.
            run grava-tt-valores(input vv, "registro").

            p-9 = string(plani.numero).
            p-0 = plani.serie.
            run grava-tt-valores(input vv, "plani").
             
            /****
            
            if vendap-fiscal > 0
            then do:
                p-4 = "FISCAL".
                run grava-tt-valores (input vv * 
                                        (vendap-fiscal / bplani.platot)).
            end.
            if vendap-servico > 0
            then do:
                p-4 = "SERVICO".
                run grava-tt-valores (input vv * 
                                        (vendap-servico / bplani.platot)).
            end.
            if vendap-outras > 0
            then do:
                p-4 = "OUTRAS".
                run grava-tt-valores (input vv * 
                                        (vendap-outras / bplani.platot)).
            end.
            ****/
         end.
    end.
end procedure.    

procedure grava-registros:
    for each opctbval where
             opctbval.etbcod = estab.etbcod and
             opctbval.datref >= vdti and
             opctbval.datref <= vdtf:
        if opctbval.datori = ?
        then delete opctbval.
    end.             
    for each tt-valores.
        /*find first opctbval where opctbval.etbcod = tt-valores.etbcod and
                            opctbval.datref = tt-valores.datref and
                            opctbval.t1     = tt-valores.t1 and
                            opctbval.t2     = tt-valores.t2 and
                            opctbval.t3     = tt-valores.t3 and
                            opctbval.t4     = tt-valores.t4 and
                            opctbval.t5     = tt-valores.t5 and
                            opctbval.t6     = tt-valores.t6 and
                            opctbval.t7     = tt-valores.t7 and
                            opctbval.t8     = tt-valores.t8 and
                            opctbval.t9     = tt-valores.t9 and
                            opctbval.t0     = tt-valores.t0 and
                            opctbval.datori = ?
                            no-error.
        if not avail opctbval
        then*/ do:                    
            create opctbval.
            buffer-copy tt-valores to opctbval.
        end.
        /*else opctbval.valor = opctbval.valor + tt-valores.valor. 
        */
    end.    
end procedure.

procedure devolucao-venda:
    assign
        ventrada = 0 vsaida = 0 vorigem = 0 vvista = 0 vprazo = 0
        vtitdev = 0 vtitpag = 0.
        
    vconta-plani = 0.
    
    for each tt-plaqtd: delete tt-plaqtd. end.
    for each tt-datap: delete tt-datap. end.

    for each ctdevven where ctdevven.etbcod = estab.etbcod and
                            ctdevven.pladat = vdata and
                            ctdevven.placod-ven = 0  
                             no-lock break by ctdevven.placod :

        vvista = 0.
        vprazo = 0.
        vtitpag = 0.
        vtitdev = 0.
        for each tt-titpag: delete tt-titpag. end.
        for each tt-titdev: delete tt-titdev. end.

        vok-moveis = no.
        if first-of(ctdevven.placod)
        then do: 
            find first plani where plani.movtdc = ctdevven.movtdc and
                                   plani.etbcod = ctdevven.etbcod and
                                   plani.placod = ctdevven.placod 
                          no-lock no-error.
            if not avail plani
            then next.
            vok-moveis = no.
            for each movim where movim.movtdc = plani.movtdc and
                                 movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod
                             no-lock:
                vclifor = movim.ocnum[7].
                ventrada = ventrada + (movim.movpc * movim.movqtm).
                find produ where produ.procod = movim.procod no-lock no-error.
                if avail produ 
                    and produ.catcod = 31
                then vok-moveis = yes.    
            end.
        end.
        if not vok-moveis
        then next.
        
        find first tt-plaqtd where
                   tt-plaqtd.placod = ctdevven.placod
                   no-lock no-error.
        if not avail tt-plaqtd
        then do:
            create tt-plaqtd.
            tt-plaqtd.placod = ctdevven.placod.
            vconta-plani = vconta-plani + 1.
        end. 
        
        find first bplani where bplani.movtdc = ctdevven.movtdc-ven and
                          bplani.etbcod = ctdevven.etbcod-ven and
                          bplani.placod = ctdevven.placod-ven 
                          no-lock no-error.
        
        find first cplani where cplani.movtdc = ctdevven.movtdc-ori and
                          cplani.etbcod = ctdevven.etbcod-ori and
                          cplani.placod = ctdevven.placod-ori
                          no-lock no-error.
        if avail bplani
        then
            for each bmovim where bmovim.movtdc = bplani.movtdc and
                             bmovim.etbcod = bplani.etbcod  and
                             bmovim.placod = bplani.placod
                             no-lock:
                vsaida = vsaida + (bmovim.movpc * bmovim.movqtm).
            end.

        if avail cplani
        then do:
            for each cmovim where cmovim.movtdc = cplani.movtdc and
                             cmovim.etbcod = cplani.etbcod and
                             cmovim.placod = cplani.placod
                             no-lock:
                vorigem = vorigem + (cmovim.movpc * cmovim.movqtm).
            end.              
            find first contnf where contnf.etbcod = cplani.etbcod and
                              contnf.placod = cplani.placod
                              no-lock no-error.
            vclifor = cplani.desti.
            if avail contnf
            then vcontrato = contnf.contnum.
            else vcontrato = cplani.numero.
            find first tt-datap where 
                   tt-datap.pladat = ctdevven.pladat and
                   tt-datap.nfdevol = ctdevven.numero and
                   tt-datap.conta = vclifor   and
                   tt-datap.contrato = vcontrato
                    no-error.
            if not avail tt-datap
            then do:
                create tt-datap.
                assign
                    tt-datap.pladat = ctdevven.pladat
                    tt-datap.nfdevol = ctdevven.numero
                    tt-datap.conta = vclifor
                    tt-datap.contrato = vcontrato.
            end. 
            tt-datap.nfvenda = cplani.numero.
            tt-datap.dtvenda = cplani.pladat.
            
            if avail contnf
            then                    
            for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = no and
                                  titulo.modcod = "CRE" and
                                  titulo.etbcod = cplani.etbcod and
                                  titulo.clifor = cplani.desti  and
                                  titulo.titnum = string(vcontrato) 
                                  no-lock:
                                  
                if titulo.titdtemi = cplani.pladat and titulo.moecod = "DEV"
                    and titulo.etbcob = ?
                then do:
                    assign
                   vtitpag = vtitpag + titulo.titvlcob
                   tt-datap.valquitado = tt-datap.valquitado + titulo.titvlcob
                   .
                   create tt-titpag.
                   buffer-copy titulo to tt-titpag.
                end.   
                else if titulo.etbcob = cplani.etbcod 
                        and titulo.moecod <> "DEV" 
                        and (titulo.titdtpag < plani.pladat
                             or (titulo.titdtpag = plani.pladat and
                                 titulo.titpar = 0))
                then do: 
                assign
                 tt-datap.valdevolvido = tt-datap.valdevolvido + titulo.titvlpag
                 vtitdev = vtitdev + titulo.titvlpag.
                    create tt-titdev.
                    buffer-copy titulo to tt-titdev.
                end.
 
            end.
            else do:
                find first ctitulo where ctitulo.empcod = 19 and
                                        ctitulo.titnat = yes and
                                        ctitulo.modcod = "DEV" and
                                        ctitulo.etbcod = cplani.etbcod and
                                        ctitulo.clifor = cplani.desti  and
                                        ctitulo.titnum = string(vcontrato)
                                        no-lock no-error.
                if avail ctitulo
                then do:
                    for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  titulo.titnum = string(vcontrato) and
                                  titulo.titdtpag <> ? 
                                  no-lock:
                        assign
                 tt-datap.valdevolvido = tt-datap.valdevolvido + titulo.titvlcob
                 vtitdev = vtitdev + titulo.titvlpag.
 
                    end.
                end.
                else do:
                    find first titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  titulo.titnum = string(vcontrato) 
                                  no-lock no-error.
                    if avail titulo
                    then do:
                        for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  titulo.titnum = string(vcontrato) 
                                  no-lock:
                        assign
                 tt-datap.valdevolvido = tt-datap.valdevolvido + titulo.titvlcob
                 vtitdev = vtitdev + titulo.titvlpag.
                        end.
                    end.
                    else do:
                        for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  titulo.titnum = string(ctdevven.numero) 
                                  no-lock:
                           assign
                 tt-datap.valdevolvido = tt-datap.valdevolvido + titulo.titvlcob
                 vtitdev = vtitdev + titulo.titvlpag.
                        end.
                     end.
                end.
            end.
            if cplani.crecod = 1
            then vvista = vvista + cplani.platot.
            else vprazo = vprazo + cplani.platot. 
        end.

        run reinicia-variaveis.
        p-1 = "DEVOLUCAO".
        p-2 = "VENDA".

        run grava-tt-valores (input vvista + vprazo, "registro").
        p-9 = string(ctdevven.numero).
        p-0 = ctdevven.serie.
        run grava-tt-valores (input vvista + vprazo, "plani").

        if vvista > 0
        then do: 
            p-3 = "A-VISTA".
            run grava-tt-valores (input vvista, "registro").
            p-9 = string(ctdevven.numero).
            p-0 = ctdevven.serie.
            run grava-tt-valores (input vvista, "plani").
        end.
        if vprazo > 0
        then do:
            p-3 = "A-PRAZO".
            run grava-tt-valores (input vprazo, "registro").
            p-9 = string(ctdevven.numero).
            p-0 = ctdevven.serie.
            run grava-tt-valores (input vvista, "plani").
        end. 

        p-3 = "ACERTO".
        run grava-tt-valores(input vtitpag + vtitdev, "registro").
        p-9 = string(ctdevven.numero).
        p-0 = ctdevven.serie.
        run grava-tt-valores(input vtitpag + vtitdev, "plani"). 
        
        if vtitpag > 0
        then do:
            p-4 = "PAGO-DEV".
            run grava-tt-valores (input vtitpag, "registro").
            
            for each tt-titpag where tt-titpag.titnum <> "":
                p-9 = string(tt-titpag.titnum).
                p-0 = string(tt-titpag.titpar).
                run grava-tt-valores (input tt-titpag.titvlpag, "titulo").
            end.    
        end.
        if vtitdev > 0
        then do:
            p-4 = "DEVOLVIDO-PAG".
            run grava-tt-valores (input vtitdev, "registro").
            for each tt-titdev where tt-titdev.titnum <> "":
                p-9 = string(tt-titdev.titnum).
                p-0 = string(tt-titdev.titpar).
                run grava-tt-valores (input tt-titdev.titvlpag, "titulo").
            end. 
        end.
    end.
end procedure.

procedure estorno-cancelamento-financeira:

        for each fc-contrato: delete fc-contrato. end.
        
        for each envfinan where 
                     envfinan.etbcod = estab.etbcod and
                     envfinan.envsit = "CAN" and
                     envfinan.dt1 = vdata
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

        for each envfinan where 
                     envfinan.etbcod = estab.etbcod and
                     envfinan.envsit = "EST" and
                     envfinan.dt1 = vdata
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
                
                
                run principal-renda(input ?,
                                        input recid(contrato),
                                        input ?).
 
        
                run reinicia-variaveis.
                p-1 = "ESTORNO".
                p-2 = "FINANCEIRA".
                run grava-tt-valores (input contrato.vltotal, "registro").
                p-9 = string(contrato.contnum).
                run grava-tt-valores (input contrato.vltotal, "contrato").

                if pacnv-principal > 0
                then do: 
                    p-3 = "PRINCIPAL".
                    run grava-tt-valores (input pacnv-principal, "regsitro").
                    p-9 = string(contrato.contnum).
                    run grava-tt-valores (input pacnv-principal, "contrato").
                end.
                if pacnv-acrescimo > 0
                then do: 
                    p-3 = "ACRESCIMO".
                    run grava-tt-valores (input pacnv-acrescimo, "registro").
                    p-9 = string(contrato.contnum).
                    run grava-tt-valores (input pacnv-acrescimo, "contrato").
                end.
                if pacnv-entrada > 0
                then do:
                    p-3 = "ENTRADA".
                    run grava-tt-valores(input pacnv-entrada, "registro").
                    p-9 = string(contrato.contnum).
                    run grava-tt-valores(input pacnv-entrada, "contrato").
                end.
                if pacnv-seguro > 0
                then do:
                    p-3 = "SEGURO".
                    run grava-tt-valores(input pacnv-seguro, "registro").
                    p-9 = string(contrato.contnum).
                    run grava-tt-valores(input pacnv-seguro, "contrato").
                end.
                if pacnv-abate > 0
                then do:    
                    p-3 = "ABATE".
                    run grava-tt-valores(input pacnv-abate, "regsitro").
                    p-9 = string(contrato.contnum).
                    run grava-tt-valores(input pacnv-abate, "contrato").
                    if pacnv-voucher > 0
                    then do:
                            p-7 = "VOUCHER".
                            run grava-tt-valores(input pacnv-voucher,
                                                "registro").
                    end.
                    if pacnv-black > 0
                    then do:
                            p-7 = "BLACK".
                            run grava-tt-valores(input pacnv-black,
                                                "registro").
                    end. 
                    if pacnv-chepres > 0
                    then do:   
                            p-7 = "CHEPRES".
                            run grava-tt-valores(input pacnv-chepres,
                                                "registro").
                    end.
                    if pacnv-combo > 0
                    then do:
                            p-7 = "COMBO".
                            run grava-tt-valores(input pacnv-combo,
                                                "registro").
                    end.
                    if pacnv-troca > 0
                    then do:
                            p-7 = "TROCA".
                            run grava-tt-valores(input pacnv-troca,
                                                "registro").
                    end.
                end.
                
        end.
        
end procedure.

procedure grava-informa-contrato:
    def input parameter rec-plani as recid.
    def input parameter rec-contrato as recid.
    def input parameter rec-titulo as recid.
    def var v-numero as char.
    def var v-par    as char.
    if rec-contrato <> ?
    then assign
            v-numero = string(contrato.contnum)
            v-par = "".
    else if rec-plani <> ?
    then assign
             v-numero = string(plani.numero)
             v-par = plani.serie
             .
    else if rec-titulo <> ?
    then assign
             v-numero = titulo.titnum
             v-par    = string(titulo.titpar)
             .
    
    run principal-renda(input rec-plani,
                        input rec-contrato,
                        input rec-titulo).
    if plani.crecod = 2
    then run grava-tt-valores(pacnv-principal +
                         pacnv-acrescimo +
                         pacnv-entrada, "registro").

    p-6 = "".
    p-5 = "".
    if pacnv-principal > 0
    then do:
        p-5 = "PRINCIPAL".
        if plani.crecod = 2
        then do:
            run grava-tt-valores(input pacnv-principal, "registro").
            p-9 = v-numero.
            p-0 = v-par.
            run grava-tt-valores(input pacnv-principal, "titulo").
        end.
        p-6 = "".
        if vendap-fiscal > 0
        then do:
            val-fal = (pacnv-principal *
                                    (vendap-fiscal / plani.protot)).
            if plani.crecod = 2
            then p-6 = "FISCAL". 
            else p-4 = "FISCAL".
            run grava-tt-valores(input val-fal, "registro").
        end.
        if vendap-outras > 0
        then do:
            val-fal = (pacnv-principal * (vendap-outras / plani.protot)).
            if plani.crecod = 2
            then p-6 = "OUTRAS".
            else p-4 = "OUTRAS".
            run grava-tt-valores(input val-fal, "registro").
        end.
        if vendap-servico > 0 and plani.crecod = 2
        then do:
            val-fal = (pacnv-principal * (vendap-servico / plani.protot)).
            if plani.crecod = 2
            then p-6 = "SERVICOS".
            else p-4 = "SERVICOS".
            run grava-tt-valores(input val-fal, "registro").
        end.
        p-5 = "".
    end.
    p-6 = "".
    p-5 = "".
    if pacnv-acrescimo > 0
    then do:
        p-5 = "ACRESCIMO".
        run grava-tt-valores(input pacnv-acrescimo, "registro").
        p-9 = v-numero.
        p-0 = v-par.
        run grava-tt-valores(input pacnv-acrescimo, "titulo").
        if vendap-fiscal > 0
        then do:
            p-6 = "FISCAL". 
            run grava-tt-valores(input (pacnv-acrescimo *
                                        (vendap-fiscal / plani.protot)),
                                        "registro").
        end.
        if vendap-outras > 0
        then do:
            p-6 = "OUTRAS".
            run grava-tt-valores(input (pacnv-acrescimo *
                                        (vendap-outras / plani.protot)),
                                        "registro").
        end.
        if vendap-servico > 0
        then do:
            p-6 = "SERVICOS".
            run grava-tt-valores(input (pacnv-acrescimo *
                                       (vendap-servico / plani.protot)),
                                       "registro").
        end.
    end.
    p-6 = "".
    p-5 = "".
    if pacnv-entrada > 0
    then do:
        p-5 = "ENTRADA".
        run grava-tt-valores(input pacnv-entrada, "registro").
        p-9 = v-numero.
        p-0 = v-par.
        run grava-tt-valores(input pacnv-entrada, "titulo").
        if vendap-fiscal > 0
        then do:
            p-6 = "FISCAL". 
            run grava-tt-valores(input (pacnv-entrada *
                                       (vendap-fiscal / plani.protot)),
                                       "registro").
        end.
        if vendap-outras > 0
        then do:
            p-6 = "OUTRAS".
            run grava-tt-valores(input (pacnv-entrada *
                                       (vendap-outras / plani.protot)),
                                       "registro").
        end.
        if vendap-servico > 0
        then do:
            p-6 = "SERVICOS".
            run grava-tt-valores(input (pacnv-entrada *
                                       (vendap-servico / plani.protot)),
                                       "registro").
        end.
    end.
    p-6 = "".
    p-5 = "".
    if pacnv-seguro > 0
    then do:
        p-5 = "SEGURO".
        run grava-tt-valores(input pacnv-seguro, "registro").
        p-9 = v-numero.
        p-0 = v-par.
        run grava-tt-valores(input pacnv-seguro, "titulo").
    end.
    p-6 = "".
    p-5 = "".
    if pacnv-abate > 0
    then do:
        if plani.crecod = 1
        then p-4 = "FISCAL". 
        p-5 = "ABATE".

        run grava-tt-valores(input pacnv-abate, "registro").
        p-9 = v-numero.
        p-0 = v-par.
        run grava-tt-valores(input pacnv-abate, "titulo").
        if pacnv-voucher > 0
        then do:
            p-7 = "VOUCHER".
            run grava-tt-valores(input pacnv-voucher, "registro").
        end.
        if pacnv-black > 0
        then do:
            p-7 = "BLACK".
            run grava-tt-valores(input pacnv-black, "registro").
        end. 
        if pacnv-chepres > 0
        then do:   
            p-7 = "CHEPRES".
            run grava-tt-valores(input pacnv-chepres, "registro").
        end.
        if pacnv-combo > 0
        then do:
            p-7 = "COMBO".
            run grava-tt-valores(input pacnv-combo, "registro").
        end.
        if pacnv-troca > 0
        then do:
            p-7 = "TROCA".
            run grava-tt-valores(input pacnv-troca, "registro").
        end.
    end.
    p-5 = "".
    p-6 = "".
    p-7 = "".
    p-8 = "".
    p-9 = "".
    p-0 = "".

end procedure.
