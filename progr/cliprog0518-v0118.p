{admcab.i}
{retorna-pacnv.i new}

def var data-ori as date.
def var data-des as date.
def var valor-tr as dec format ">>>,>>>,>>9.99".

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

def buffer bopctbval for opctbval.
def buffer copctbval for opctbval.
def buffer dopctbval for opctbval.
def buffer bct-cartcl for ct-cartcl.
def buffer bctb-receb for ctb-receb.

def var vdinheiro as dec.
def var vt-cob as dec format ">>>,>>>,>>9.99".
def var vt-din as dec format ">>>,>>>,>>9.99".
def var vt-pag as dec format ">>>,>>>,>>9.99".
def var vt-jur as dec format ">>>,>>>,>>9.99".

def var vmoecod like fin.moeda.moecod.
def var valor-jr as dec.
def temp-table tt-opctbval like opctbval.

def var vatu as log format "Sim/Nao".
repeat:
    vatu = no.
    update data-ori Label "Origem"
       data-des label "Destino"
       valor-tr label "Valor Pago" format ">>,>>>,>>9.99"
       /*valor-jr label "Juro" format ">>>,>>9.99"*/
       vmoecod  label "Moeda"
       vatu     label "Atu"
       with frame f-dt down
       title " transfere recebimentos "
       .

    for each tt-opctbval: delete tt-opctbval. end.
    
    assign
        vt-cob = 0
        vt-din = 0
        vt-pag = 0
        vt-jur = 0
        .

    for each estab where estab.etbcod < 200 no-lock:
        
        disp "Processando... " estab.etbcod valor-tr vt-din vt-jur
        with frame f-dd 1 down no-box no-label
        row 15 centere color message overlay.
        pause 0.
    
    
        run pdv-moeda(input estab.etbcod, input data-ori).
        
        for each opctbval where opctbval.etbcod = estab.etbcod and
                        opctbval.datref = data-ori and
                        opctbval.t1 = "RECEBIMENTO" and
                        opctbval.t2 = "CRE" and
                        opctbval.t3 = "" and
                        opctbval.t4 = "" and
                        opctbval.t5 = "" and
                        opctbval.t6 = "LEBES" and
                        opctbval.t7 = "" and
                        opctbval.t8 = "" and
                        opctbval.t9 <> "" and
                        opctbval.t0 <> "" 
                     no-lock.
            find contrato where 
            contrato.contnum = int(opctbval.t9) no-lock no-error.
            if not avail contrato then next.
            find titulo where titulo.empcod = 19 and
                      titulo.titnat = no and
                      titulo.modcod = "CRE" and
                      titulo.etbcod = contrato.etbcod and
                      titulo.clifor = contrato.clicod and
                      titulo.titnum = opctbval.t9 and
                      titulo.titpar = int(opctbval.t0) and
                      titulo.titpar > 0 and
                      titulo.titvlpag = opctbval.valor and
                      titulo.titdes = 0
                      no-lock no-error.
            if avail titulo
            then do:

                vdinheiro = 0.
                run titulo-moeda.
                if vdinheiro > 0 and 
                   vdinheiro = titulo.titvlcob + titulo.titjuro and
                   vdinheiro = opctbval.valor
                then do:
                    if vt-din + vdinheiro <= valor-tr
                    then do:
                        assign
                            vt-cob = vt-cob + titulo.titvlcob
                            vt-din = vt-din + vdinheiro
                            vt-pag = vt-pag + titulo.titvlpag
                            vt-jur = vt-jur + titulo.titjuro.

                        if vatu
                        then do:
                            /*run ver-pacnv-titulo.
                              */
                            create tt-opctbval.
                            buffer-copy opctbval to tt-opctbval.
                            /*
                            assign
                                tt-opctbval.principal = pacnv-principal
                                tt-opctbval.acrescimo = pacnv-acrescimo
                                tt-opctbval.seguro    = pacnv-seguro
                                tt-opctbval.juro      = titulo.titjuro
                                .
                            */
                        end.
                        
                    end.
                end.
            end.
        end.
        disp vt-din vt-jur with frame f-dd .
        pause 0.
        disp vt-din with frame f-dt .
        pause 0.
    end.
    if vatu
    then do:
        for each tt-opctbval where tt-opctbval.t1 <> "":
            disp "Atualizando... " 
                tt-opctbval.t1
                tt-opctbval.t9
                tt-opctbval.t0
                with frame f-atu down overlay.
            pause 0.    
            find opctbval where 
                        opctbval.etbcod = tt-opctbval.etbcod and
                        opctbval.datref = tt-opctbval.datref and
                        opctbval.t1 = "RECEBIMENTO" and
                        opctbval.t2 = "CRE" and
                        opctbval.t3 = "" and
                        opctbval.t4 = "" and
                        opctbval.t5 = "" and
                        opctbval.t6 = "LEBES" and
                        opctbval.t7 = "" and
                        opctbval.t8 = "" and
                        opctbval.t9 = "" and
                        opctbval.t0 = "" 
                no-error.
            if avail opctbval
            then do:
                find bopctbval where 
                        bopctbval.etbcod = tt-opctbval.etbcod and
                        bopctbval.datref = data-des and
                        bopctbval.t1 = "RECEBIMENTO" and
                        bopctbval.t2 = "CRE" and
                        bopctbval.t3 = "" and
                        bopctbval.t4 = "" and
                        bopctbval.t5 = "" and
                        bopctbval.t6 = "LEBES" and
                        bopctbval.t7 = "" and
                        bopctbval.t8 = "" and
                        bopctbval.t9 = "" and
                        bopctbval.t0 = "" 
                no-error.
                if avail bopctbval
                then bopctbval.valor = bopctbval.valor + tt-opctbval.valor.
                else do:
                    create bopctbval.
                    assign
                        bopctbval.etbcod = tt-opctbval.etbcod 
                        bopctbval.datref = data-des 
                        bopctbval.t1 = "RECEBIMENTO"
                        bopctbval.t2 = "CRE" 
                        bopctbval.t3 = "" 
                        bopctbval.t4 = "" 
                        bopctbval.t5 = "" 
                        bopctbval.t6 = "LEBES" 
                        bopctbval.t7 = "" 
                        bopctbval.t8 = "" 
                        bopctbval.t9 = "" 
                        bopctbval.t0 = "" 
                        bopctbval.valor = tt-opctbval.valor.
                end.
                opctbval.valor = opctbval.valor - tt-opctbval.valor.
            end.
            /**** PRINCIPAL ***/
            find opctbval where 
                        opctbval.etbcod = tt-opctbval.etbcod and
                        opctbval.datref = tt-opctbval.datref and
                        opctbval.t1 = "RECEBIMENTO" and
                        opctbval.t2 = "CRE" and
                        opctbval.t3 = "" and
                        opctbval.t4 = "" and
                        opctbval.t5 = "" and
                        opctbval.t6 = "LEBES" and
                        opctbval.t7 = "PRINCIPAL" and
                        opctbval.t8 = "" and
                        opctbval.t9 = tt-opctbval.t9 and
                        opctbval.t0 = tt-opctbval.t0 
                        no-error.
            if avail opctbval
            then do:
                find    bopctbval where 
                        bopctbval.etbcod = opctbval.etbcod and
                        bopctbval.datref = opctbval.datref and
                        bopctbval.t1 = "RECEBIMENTO" and
                        bopctbval.t2 = "CRE" and
                        bopctbval.t3 = "" and
                        bopctbval.t4 = "" and
                        bopctbval.t5 = "" and
                        bopctbval.t6 = "LEBES" and
                        bopctbval.t7 = "PRINCIPAL" and
                        bopctbval.t8 = "" and
                        bopctbval.t9 = "" and
                        bopctbval.t0 = "" 
                        no-error.
                if avail bopctbval
                then do:
                    find copctbval where 
                        copctbval.etbcod = opctbval.etbcod and
                        copctbval.datref = data-des and
                        copctbval.t1 = "RECEBIMENTO" and
                        copctbval.t2 = "CRE" and
                        copctbval.t3 = "" and
                        copctbval.t4 = "" and
                        copctbval.t5 = "" and
                        copctbval.t6 = "LEBES" and
                        copctbval.t7 = "PRINCIPAL" and
                        copctbval.t8 = "" and
                        copctbval.t9 = "" and
                        copctbval.t0 = "" 
                        no-error.
                    if avail copctbval
                    then copctbval.valor = 
                                copctbval.valor + opctbval.valor.
                    else do:
                        create copctbval.
                        assign
                            copctbval.etbcod = opctbval.etbcod 
                            copctbval.datref = data-des 
                            copctbval.t1 = "RECEBIMENTO"
                            copctbval.t2 = "CRE" 
                            copctbval.t3 = "" 
                            copctbval.t4 = "" 
                            copctbval.t5 = "" 
                            copctbval.t6 = "LEBES" 
                            copctbval.t7 = "PRINCIPAL" 
                            copctbval.t8 = "" 
                            copctbval.t9 = "" 
                            copctbval.t0 = "" 
                            copctbval.valor = opctbval.valor.
                    end.             

                    bopctbval.valor = bopctbval.valor - opctbval.valor.

                end.      
                find    bopctbval where 
                        bopctbval.etbcod = opctbval.etbcod and
                        bopctbval.datref = opctbval.datref and
                        bopctbval.t1 = "RECEBIMENTO" and
                        bopctbval.t2 = "CRE" and
                        bopctbval.t3 = "" and
                        bopctbval.t4 = "" and
                        bopctbval.t5 = "" and
                        bopctbval.t6 = "LEBES" and
                        bopctbval.t7 = "PRINCIPAL" and
                        bopctbval.t8 = "REA-REAL" and
                        bopctbval.t9 = "" and
                        bopctbval.t0 = "" 
                        no-error.
                if avail bopctbval
                then do:
                    find copctbval where 
                        copctbval.etbcod = opctbval.etbcod and
                        copctbval.datref = data-des and
                        copctbval.t1 = "RECEBIMENTO" and
                        copctbval.t2 = "CRE" and
                        copctbval.t3 = "" and
                        copctbval.t4 = "" and
                        copctbval.t5 = "" and
                        copctbval.t6 = "LEBES" and
                        copctbval.t7 = "PRINCIPAL" and
                        copctbval.t8 = "REA-REAL" and
                        copctbval.t9 = "" and
                        copctbval.t0 = "" 
                        no-error.
                    if avail copctbval
                    then copctbval.valor = 
                                copctbval.valor + opctbval.valor.
                    else do:
                        create copctbval.
                        assign
                            copctbval.etbcod = opctbval.etbcod 
                            copctbval.datref = data-des 
                            copctbval.t1 = "RECEBIMENTO"
                            copctbval.t2 = "CRE" 
                            copctbval.t3 = "" 
                            copctbval.t4 = "" 
                            copctbval.t5 = "" 
                            copctbval.t6 = "LEBES" 
                            copctbval.t7 = "PRINCIPAL" 
                            copctbval.t8 = "REA-REAL" 
                            copctbval.t9 = "" 
                            copctbval.t0 = "" 
                            copctbval.valor = opctbval.valor.
                    end.             

                    bopctbval.valor = bopctbval.valor - opctbval.valor.
                    
                    find first ctb-receb where
                               ctb-receb.rectp  = "PARCELA" and
                               ctb-receb.etbcod = opctbval.etbcod and
                               ctb-receb.datref = opctbval.datref and
                               ctb-receb.moecod = "REA"
                               no-error.
                    if avail ctb-receb
                    then ctb-receb.valor1 = 
                                ctb-receb.valor1 - opctbval.valor.
                    find first bctb-receb where
                               bctb-receb.rectp  = "PARCELA" and
                               bctb-receb.etbcod = opctbval.etbcod and
                               bctb-receb.datref = data-des and
                               bctb-receb.moecod = "REA"
                               no-error.
                    if avail bctb-receb
                    then bctb-receb.valor1 =
                                bctb-receb.valor1 + opctbval.valor.    
                    else do:
                        create bctb-receb.
                        assign
                            bctb-receb.rectp  = "PARCELA"
                            bctb-receb.etbcod = opctbval.etbcod
                            bctb-receb.datref = data-des
                            bctb-receb.moecod = "REA"
                            bctb-receb.valor1 = opctbval.valor.
                    end.
                            
                    find first ct-cartcl where 
                           ct-cartcl.datref = opctbval.datref and
                           ct-cartcl.etbcod = opctbval.etbcod
                           no-error.
                    if avail ct-cartcl
                    then assign
                        ct-cartcl.recebimento = 
                                ct-cartcl.recebimento - opctbval.valor 
                        ct-cartcl.rec-caixa   = 
                                ct-cartcl.rec-caixa - opctbval.valor
                        ct-cartcl.rec-dinheiro = 
                                ct-cartcl.rec-dinheiro - opctbval.valor    
                                . 
                    find first bct-cartcl where 
                           bct-cartcl.datref = data-des and
                           bct-cartcl.etbcod = opctbval.etbcod
                           no-error.
                    if avail bct-cartcl
                    then assign
                        bct-cartcl.recebimento  =
                                bct-cartcl.recebimento + opctbval.valor
                        bct-cartcl.rec-caixa =
                                bct-cartcl.rec-caixa + opctbval.valor
                        bct-cartcl.rec-dinheiro =
                                bct-cartcl.rec-dinheiro + opctbval.valor
                        . 
                    else do:
                        create bct-cartcl.
                        assign
                            bct-cartcl.datref = data-des
                            bct-cartcl.etbcod = opctbval.etbcod
                            bct-cartcl.recebimento = opctbval.valor
                            bct-cartcl.rec-caixa = opctbval.valor
                            bct-cartcl.rec-dinheiro = opctbval.valor
                            .
                    end.
                end.
            end.
            /**** ACRESCIMO ***/
            find opctbval where 
                        opctbval.etbcod = tt-opctbval.etbcod and
                        opctbval.datref = tt-opctbval.datref and
                        opctbval.t1 = "RECEBIMENTO" and
                        opctbval.t2 = "CRE" and
                        opctbval.t3 = "" and
                        opctbval.t4 = "" and
                        opctbval.t5 = "" and
                        opctbval.t6 = "LEBES" and
                        opctbval.t7 = "ACRESCIMO" and
                        opctbval.t8 = "" and
                        opctbval.t9 = tt-opctbval.t9 and
                        opctbval.t0 = tt-opctbval.t0 
                        no-error.
            if avail opctbval
            then do:
                find    bopctbval where 
                        bopctbval.etbcod = opctbval.etbcod and
                        bopctbval.datref = opctbval.datref and
                        bopctbval.t1 = "RECEBIMENTO" and
                        bopctbval.t2 = "CRE" and
                        bopctbval.t3 = "" and
                        bopctbval.t4 = "" and
                        bopctbval.t5 = "" and
                        bopctbval.t6 = "LEBES" and
                        bopctbval.t7 = "ACRESCIMO" and
                        bopctbval.t8 = "" and
                        bopctbval.t9 = "" and
                        bopctbval.t0 = "" 
                        no-error.
                if avail bopctbval
                then do:
                    find copctbval where 
                        copctbval.etbcod = opctbval.etbcod and
                        copctbval.datref = data-des and
                        copctbval.t1 = "RECEBIMENTO" and
                        copctbval.t2 = "CRE" and
                        copctbval.t3 = "" and
                        copctbval.t4 = "" and
                        copctbval.t5 = "" and
                        copctbval.t6 = "LEBES" and
                        copctbval.t7 = "ACRESCIMO" and
                        copctbval.t8 = "" and
                        copctbval.t9 = "" and
                        copctbval.t0 = "" 
                        no-error.
                    if avail copctbval
                    then copctbval.valor = 
                                copctbval.valor + opctbval.valor.
                    else do:
                        create copctbval.
                        assign
                            copctbval.etbcod = opctbval.etbcod 
                            copctbval.datref = data-des 
                            copctbval.t1 = "RECEBIMENTO"
                            copctbval.t2 = "CRE" 
                            copctbval.t3 = "" 
                            copctbval.t4 = "" 
                            copctbval.t5 = "" 
                            copctbval.t6 = "LEBES" 
                            copctbval.t7 = "ACRESCIMO" 
                            copctbval.t8 = "" 
                            copctbval.t9 = "" 
                            copctbval.t0 = "" 
                            copctbval.valor = opctbval.valor.
                    end.             

                    bopctbval.valor = bopctbval.valor - opctbval.valor.

                end.      
                find    bopctbval where 
                        bopctbval.etbcod = opctbval.etbcod and
                        bopctbval.datref = opctbval.datref and
                        bopctbval.t1 = "RECEBIMENTO" and
                        bopctbval.t2 = "CRE" and
                        bopctbval.t3 = "" and
                        bopctbval.t4 = "" and
                        bopctbval.t5 = "" and
                        bopctbval.t6 = "LEBES" and
                        bopctbval.t7 = "ACRESCIMO" and
                        bopctbval.t8 = "REA-REAL" and
                        bopctbval.t9 = "" and
                        bopctbval.t0 = "" 
                        no-error.
                if avail bopctbval
                then do:
                    find copctbval where 
                        copctbval.etbcod = opctbval.etbcod and
                        copctbval.datref = data-des and
                        copctbval.t1 = "RECEBIMENTO" and
                        copctbval.t2 = "CRE" and
                        copctbval.t3 = "" and
                        copctbval.t4 = "" and
                        copctbval.t5 = "" and
                        copctbval.t6 = "LEBES" and
                        copctbval.t7 = "ACRESCIMO" and
                        copctbval.t8 = "REA-REAL" and
                        copctbval.t9 = "" and
                        copctbval.t0 = "" 
                        no-error.
                    if avail copctbval
                    then copctbval.valor = 
                                copctbval.valor + opctbval.valor.
                    else do:
                        create copctbval.
                        assign
                            copctbval.etbcod = opctbval.etbcod 
                            copctbval.datref = data-des 
                            copctbval.t1 = "RECEBIMENTO"
                            copctbval.t2 = "CRE" 
                            copctbval.t3 = "" 
                            copctbval.t4 = "" 
                            copctbval.t5 = "" 
                            copctbval.t6 = "LEBES" 
                            copctbval.t7 = "ACRESCIMO" 
                            copctbval.t8 = "REA-REAL" 
                            copctbval.t9 = "" 
                            copctbval.t0 = "" 
                            copctbval.valor = opctbval.valor.
                    end.             

                    bopctbval.valor = bopctbval.valor - opctbval.valor.

                    find first ctb-receb where
                               ctb-receb.rectp  = "ACRESCIMO" and
                               ctb-receb.etbcod = opctbval.etbcod and
                               ctb-receb.datref = opctbval.datref and
                               ctb-receb.moecod = "REA"
                               no-error.
                    if avail ctb-receb
                    then ctb-receb.valor1 = 
                                ctb-receb.valor1 - opctbval.valor.
                    find first bctb-receb where
                               bctb-receb.rectp  = "ACRESCIMO" and
                               bctb-receb.etbcod = opctbval.etbcod and
                               bctb-receb.datref = data-des and
                               bctb-receb.moecod = "REA"
                               no-error.
                    if avail bctb-receb
                    then bctb-receb.valor1 =
                                bctb-receb.valor1 + opctbval.valor.    
                    else do:
                        create bctb-receb.
                        assign
                            bctb-receb.rectp  = "ACRESCIMO"
                            bctb-receb.etbcod = opctbval.etbcod
                            bctb-receb.datref = data-des
                            bctb-receb.moecod = "REA"
                            bctb-receb.valor1 = opctbval.valor.
                    end.
                            
                    find first ct-cartcl where 
                           ct-cartcl.datref = opctbval.datref and
                           ct-cartcl.etbcod = opctbval.etbcod
                           no-error.
                    if avail ct-cartcl
                    then assign
                        ct-cartcl.recebimento = 
                                ct-cartcl.recebimento - opctbval.valor 
                        ct-cartcl.rec-caixa   = 
                                ct-cartcl.rec-caixa - opctbval.valor
                        ct-cartcl.rec-dinheiro =
                                ct-cartcl.rec-dinheiro - opctbval.valor    
                                . 
                    find first bct-cartcl where 
                           bct-cartcl.datref = data-des and
                           bct-cartcl.etbcod = opctbval.etbcod
                           no-error.
                    if avail bct-cartcl
                    then assign
                        bct-cartcl.recebimento  =
                                bct-cartcl.recebimento + opctbval.valor
                        bct-cartcl.rec-caixa =
                                bct-cartcl.rec-caixa + opctbval.valor
                        bct-cartcl.rec-dinheiro = 
                                bct-cartcl.rec-dinheiro + opctbval.valor
                        . 
                    else do:
                        create bct-cartcl.
                        assign
                            bct-cartcl.datref = data-des
                            bct-cartcl.etbcod = opctbval.etbcod
                            bct-cartcl.recebimento = opctbval.valor
                            bct-cartcl.rec-caixa = opctbval.valor
                            bct-cartcl.rec-dinheiro = opctbval.valor
                            .
                    end.
                end.             
            end.
            /**** JURO ATRASO ***/
            find opctbval where 
                        opctbval.etbcod = tt-opctbval.etbcod and
                        opctbval.datref = tt-opctbval.datref and
                        opctbval.t1 = "RECEBIMENTO" and
                        opctbval.t2 = "CRE" and
                        opctbval.t3 = "" and
                        opctbval.t4 = "" and
                        opctbval.t5 = "" and
                        opctbval.t6 = "LEBES" and
                        opctbval.t7 = "JURO ATRASO" and
                        opctbval.t8 = "" and
                        opctbval.t9 = tt-opctbval.t9 and
                        opctbval.t0 = tt-opctbval.t0 
                        no-error.
            if avail opctbval
            then do:
                find    bopctbval where 
                        bopctbval.etbcod = opctbval.etbcod and
                        bopctbval.datref = opctbval.datref and
                        bopctbval.t1 = "RECEBIMENTO" and
                        bopctbval.t2 = "CRE" and
                        bopctbval.t3 = "" and
                        bopctbval.t4 = "" and
                        bopctbval.t5 = "" and
                        bopctbval.t6 = "LEBES" and
                        bopctbval.t7 = "JURO ATRASO" and
                        bopctbval.t8 = "" and
                        bopctbval.t9 = "" and
                        bopctbval.t0 = "" 
                        no-error.
                if avail bopctbval
                then do:
                    find copctbval where 
                        copctbval.etbcod = opctbval.etbcod and
                        copctbval.datref = data-des and
                        copctbval.t1 = "RECEBIMENTO" and
                        copctbval.t2 = "CRE" and
                        copctbval.t3 = "" and
                        copctbval.t4 = "" and
                        copctbval.t5 = "" and
                        copctbval.t6 = "LEBES" and
                        copctbval.t7 = "JURO ATRASO" and
                        copctbval.t8 = "" and
                        copctbval.t9 = "" and
                        copctbval.t0 = "" 
                        no-error.
                    if avail copctbval
                    then copctbval.valor = 
                                copctbval.valor + opctbval.valor.
                    else do:
                        create copctbval.
                        assign
                            copctbval.etbcod = opctbval.etbcod 
                            copctbval.datref = data-des 
                            copctbval.t1 = "RECEBIMENTO"
                            copctbval.t2 = "CRE" 
                            copctbval.t3 = "" 
                            copctbval.t4 = "" 
                            copctbval.t5 = "" 
                            copctbval.t6 = "LEBES" 
                            copctbval.t7 = "JURO ATRASO" 
                            copctbval.t8 = "" 
                            copctbval.t9 = "" 
                            copctbval.t0 = "" 
                            copctbval.valor = opctbval.valor.
                    end.             

                    bopctbval.valor = bopctbval.valor - opctbval.valor.

                end.      
                find    bopctbval where 
                        bopctbval.etbcod = opctbval.etbcod and
                        bopctbval.datref = opctbval.datref and
                        bopctbval.t1 = "RECEBIMENTO" and
                        bopctbval.t2 = "CRE" and
                        bopctbval.t3 = "" and
                        bopctbval.t4 = "" and
                        bopctbval.t5 = "" and
                        bopctbval.t6 = "LEBES" and
                        bopctbval.t7 = "JURO ATRASO" and
                        bopctbval.t8 = "REA-REAL" and
                        bopctbval.t9 = "" and
                        bopctbval.t0 = "" 
                        no-error.
                if avail bopctbval
                then do:
                    find copctbval where 
                        copctbval.etbcod = opctbval.etbcod and
                        copctbval.datref = data-des and
                        copctbval.t1 = "RECEBIMENTO" and
                        copctbval.t2 = "CRE" and
                        copctbval.t3 = "" and
                        copctbval.t4 = "" and
                        copctbval.t5 = "" and
                        copctbval.t6 = "LEBES" and
                        copctbval.t7 = "JURO ATRASO" and
                        copctbval.t8 = "REA-REAL" and
                        copctbval.t9 = "" and
                        copctbval.t0 = "" 
                        no-error.
                    if avail copctbval
                    then copctbval.valor = 
                                copctbval.valor + opctbval.valor.
                    else do:
                        create copctbval.
                        assign
                            copctbval.etbcod = opctbval.etbcod 
                            copctbval.datref = data-des 
                            copctbval.t1 = "RECEBIMENTO"
                            copctbval.t2 = "CRE" 
                            copctbval.t3 = "" 
                            copctbval.t4 = "" 
                            copctbval.t5 = "" 
                            copctbval.t6 = "LEBES" 
                            copctbval.t7 = "JURO ATRASO" 
                            copctbval.t8 = "REA-REAL" 
                            copctbval.t9 = "" 
                            copctbval.t0 = "" 
                            copctbval.valor = opctbval.valor.
                    end.             

                    bopctbval.valor = bopctbval.valor - opctbval.valor.

                    find first ctb-receb where
                               ctb-receb.rectp  = "JURO ATRASO" and
                               ctb-receb.etbcod = opctbval.etbcod and
                               ctb-receb.datref = opctbval.datref and
                               ctb-receb.moecod = "REA"
                               no-error.
                    if avail ctb-receb
                    then ctb-receb.valor1 = 
                                ctb-receb.valor1 - opctbval.valor.
                    find first bctb-receb where
                               bctb-receb.rectp  = "JURO ATRASO" and
                               bctb-receb.etbcod = opctbval.etbcod and
                               bctb-receb.datref = data-des and
                               bctb-receb.moecod = "REA"
                               no-error.
                    if avail bctb-receb
                    then bctb-receb.valor1 =
                                bctb-receb.valor1 + opctbval.valor.    
                    else do:
                        create bctb-receb.
                        assign
                            bctb-receb.rectp  = "JURO ATRASO"
                            bctb-receb.etbcod = opctbval.etbcod
                            bctb-receb.datref = data-des
                            bctb-receb.moecod = "REA"
                            bctb-receb.valor1 = opctbval.valor.
                    end.
                            
                    find first ct-cartcl where 
                           ct-cartcl.datref = opctbval.datref and
                           ct-cartcl.etbcod = opctbval.etbcod
                           no-error.
                    if avail ct-cartcl
                    then assign
                        ct-cartcl.recebimento = 
                                ct-cartcl.recebimento - opctbval.valor 
                        ct-cartcl.rec-juro-dinheiro =
                                ct-cartcl.rec-juro-dinheiro - opctbval.valor    
                                . 
                    find first bct-cartcl where 
                           bct-cartcl.datref = data-des and
                           bct-cartcl.etbcod = opctbval.etbcod
                           no-error.
                    if avail bct-cartcl
                    then assign
                        bct-cartcl.recebimento  =
                                bct-cartcl.recebimento + opctbval.valor
                        bct-cartcl.rec-juro-dinheiro =
                                bct-cartcl.rec-juro-dinheiro + opctbval.valor
                        . 
                    else do:
                        create bct-cartcl.
                        assign
                            bct-cartcl.datref = data-des
                            bct-cartcl.etbcod = opctbval.etbcod
                            bct-cartcl.recebimento = opctbval.valor
                            bct-cartcl.rec-juro-dinheiro = opctbval.valor
                            .
                    end.
                end.             
            end.
            
            find dopctbval where 
                        dopctbval.etbcod = tt-opctbval.etbcod and
                        dopctbval.datref = tt-opctbval.datref and
                        dopctbval.t1 = tt-opctbval.t1 and
                        dopctbval.t2 = tt-opctbval.t2 and
                        dopctbval.t3 = tt-opctbval.t3 and
                        dopctbval.t4 = tt-opctbval.t4 and
                        dopctbval.t5 = tt-opctbval.t5 and
                        dopctbval.t6 = tt-opctbval.t6 and
                        dopctbval.t7 = tt-opctbval.t7 and
                        dopctbval.t8 = tt-opctbval.t8 and
                        dopctbval.t9 = tt-opctbval.t9 and
                        dopctbval.t0 = tt-opctbval.t0 
                        no-error.
            if avail dopctbval
            then assign
                     dopctbval.datori = dopctbval.datref
                     dopctbval.datref = data-des
                     .
            find dopctbval where 
                        dopctbval.etbcod = tt-opctbval.etbcod and
                        dopctbval.datref = tt-opctbval.datref and
                        dopctbval.t1 = tt-opctbval.t1 and
                        dopctbval.t2 = tt-opctbval.t2 and
                        dopctbval.t3 = tt-opctbval.t3 and
                        dopctbval.t4 = tt-opctbval.t4 and
                        dopctbval.t5 = tt-opctbval.t5 and
                        dopctbval.t6 = tt-opctbval.t6 and
                        dopctbval.t7 = "PRINCIPAL" and
                        dopctbval.t8 = tt-opctbval.t8 and
                        dopctbval.t9 = tt-opctbval.t9 and
                        dopctbval.t0 = tt-opctbval.t0 
                        no-error.
            if avail dopctbval
            then assign
                     dopctbval.datori = dopctbval.datref
                     dopctbval.datref = data-des
                     .
            find dopctbval where 
                        dopctbval.etbcod = tt-opctbval.etbcod and
                        dopctbval.datref = tt-opctbval.datref and
                        dopctbval.t1 = tt-opctbval.t1 and
                        dopctbval.t2 = tt-opctbval.t2 and
                        dopctbval.t3 = tt-opctbval.t3 and
                        dopctbval.t4 = tt-opctbval.t4 and
                        dopctbval.t5 = tt-opctbval.t5 and
                        dopctbval.t6 = tt-opctbval.t6 and
                        dopctbval.t7 = "ACRESCIMO" and
                        dopctbval.t8 = tt-opctbval.t8 and
                        dopctbval.t9 = tt-opctbval.t9 and
                        dopctbval.t0 = tt-opctbval.t0 
                        no-error.
            if avail dopctbval
            then assign
                     dopctbval.datori = dopctbval.datref
                     dopctbval.datref = data-des
                     .
            find dopctbval where 
                        dopctbval.etbcod = tt-opctbval.etbcod and
                        dopctbval.datref = tt-opctbval.datref and
                        dopctbval.t1 = tt-opctbval.t1 and
                        dopctbval.t2 = tt-opctbval.t2 and
                        dopctbval.t3 = tt-opctbval.t3 and
                        dopctbval.t4 = tt-opctbval.t4 and
                        dopctbval.t5 = tt-opctbval.t5 and
                        dopctbval.t6 = tt-opctbval.t6 and
                        dopctbval.t7 = "JURO ATRASO" and
                        dopctbval.t8 = tt-opctbval.t8 and
                        dopctbval.t9 = tt-opctbval.t9 and
                        dopctbval.t0 = tt-opctbval.t0 
                        no-error.
            if avail dopctbval
            then assign
                     dopctbval.datori = dopctbval.datref
                     dopctbval.datref = data-des
                     .
         
        end.
    end.
    /*
    disp vt-cob vt-din vt-pag vt-jur.
    */
    pause 10 no-message.
    
    leave.
end.

procedure ver-pacnv-titulo:
    
                    run principal-renda(input ?,
                                input ?,
                                input recid(titulo)).

                    if pacnv-principal > 0
                    then do:
                    end.
                    if pacnv-acrescimo > 0
                    then do:
                    end.
                    if pacnv-seguro > 0
                    then do:
                    end.
                    if titulo.titjuro > 0
                    then do:
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


/*****************
    
procedure ajusta-ctbreceb:

    def var vi as int.
    
    find first tabcre17 where
                           tabcre17.etbcod = estab.etbcod and
                           tabcre17.datref = data-ori
                           no-error.
                if not avail tabcre17
                then do:
                    create tabcre17.
                    assign
                        tabcre17.etbcod = estab.etbcod
                        tabcre17.datref = data-ori
                            .
                end.
                tabcre17.recebimento_lebes =
                             tabcre17.recebimento_lebes - tabdac17.vallan.
                
                tabcre17.juros_lebes = tabcre17.juros_lebes - titulo.titjuro.                
                find first fin.moeda where moeda.moecod = vmoecod
                       no-lock no-error.
                
                do vi = 1 to 15:
                    if tabcre17.define_recebimento_moeda[vi] = ""
                    then tabcre17.define_recebimento_moeda[vi] =
                                        moeda.moecod + " - " + moeda.moenom.
                    if tabcre17.define_recebimento_moeda[vi] =
                                 moeda.moecod + " - " + moeda.moenom
                    then do:
                        tabcre17.recebimento_moeda_lebes[vi] =
                        tabcre17.recebimento_moeda_lebes[vi] - tabdac17.vallan.
                        tabcre17.receb_moeda_juros_lebes[vi] =
                                tabcre17.receb_moeda_juros_lebes[vi] -
                                titulo.titjuro.
                        leave.
                    end.
                end.

    find ninja.ctbreceb where
             ctbreceb.rectp  = "RECEBIMENTO" and
             ctbreceb.etbcod =  estab.etbcod and
             ctbreceb.datref =  data-ori and
             ctbreceb.moecod = vmoecod
             no-error.
    if avail ctbreceb
    then assign
            ctbreceb.valor1 = ctbreceb.valor1 - tabdac17.vallan
            ctbreceb.valor2 = ctbreceb.valor2 + tabdac17.vallan.
    find first ninja.ctcartcl where 
               ctcartcl.etbcod = estab.etbcod and
               ctcartcl.datref = data-ori 
               no-error
               .
    if avail ctcartcl
    then assign
            ctcartcl.recebimento = ctcartcl.recebimento - tabdac17.vallan
            ctcartcl.juro        = ctcartcl.juro - titulo.titjuro
            .
  
    find first tabcre17 where
                           tabcre17.etbcod = estab.etbcod and
                           tabcre17.datref = data-des
                           no-error.
                if not avail tabcre17
                then do:
                    create tabcre17.
                    assign
                        tabcre17.etbcod = estab.etbcod
                        tabcre17.datref = data-des
                            .
                end.
                tabcre17.recebimento_lebes =
                             tabcre17.recebimento_lebes + tabdac17.vallan.
                tabcre17.juros_lebes = tabcre17.juros_lebes + titulo.titjuro.                
                find first moeda where moeda.moecod = vmoecod
                       no-lock no-error.
                do vi = 1 to 15:
                    if tabcre17.define_recebimento_moeda[vi] = ""
                    then tabcre17.define_recebimento_moeda[vi] =
                                        moeda.moecod + " - " + moeda.moenom.
                    if tabcre17.define_recebimento_moeda[vi] =
                                 moeda.moecod + " - " + moeda.moenom
                    then do:
                        tabcre17.recebimento_moeda_lebes[vi] =
                        tabcre17.recebimento_moeda_lebes[vi] + tabdac17.vallan.
                        tabcre17.receb_moeda_juros_lebes[vi] =
                                tabcre17.receb_moeda_juros_lebes[vi] +
                                titulo.titjuro.
                        leave.
                    end.
                end.
    find ninja.ctbreceb where
             ctbreceb.rectp  = "RECEBIMENTO" and
             ctbreceb.etbcod =  estab.etbcod and
             ctbreceb.datref =  data-des and
             ctbreceb.moecod = vmoecod
             no-error.
    if avail ctbreceb
    then assign
            ctbreceb.valor1 = ctbreceb.valor1 + tabdac17.vallan
            ctbreceb.valor3 = ctbreceb.valor3 + tabdac17.vallan.
    else do:
        create ctbreceb.
        assign
            ctbreceb.rectp  = "RECEBIMENTO"
            ctbreceb.etbcod =  estab.etbcod
            ctbreceb.datref =  data-des
            ctbreceb.moecod = vmoecod
            ctbreceb.valor1 = ctbreceb.valor1 + tabdac17.vallan
            ctbreceb.valor3 = ctbreceb.valor3 + tabdac17.vallan
            .
    end. 
    find first ninja.ctcartcl where 
               ctcartcl.etbcod = estab.etbcod and
               ctcartcl.datref = data-des 
               no-error
               .
    if avail ctcartcl
    then assign
            ctcartcl.recebimento = ctcartcl.recebimento + tabdac17.vallan
            ctcartcl.juro        = ctcartcl.juro + titulo.titjuro
            .
            
    else do:
        create ctcartcl.
        assign
            ctcartcl.etbcod = estab.etbcod 
            ctcartcl.datref = data-des
            ctcartcl.recebimento = tabdac17.vallan
            ctcartcl.juro        = titulo.titjuro
            .
    end.            
               
end procedure.

***********/

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
            if pag-titmoe.moecod = vmoecod
            then vdinheiro = pag-titmoe.titvlpag.
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
            if titpag.moecod = vmoecod
            then vdinheiro = titpag.titvlpag.
        end.
        else do:
            if titulo.moecod = vmoecod
            then vdinheiro = titulo.titvlpag.
        end.
    end.
end procedure.

