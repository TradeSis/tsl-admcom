
def var i-senx           as int.
def var vsenhax          as char format "x(6)".
def var vsenha1x         like vsenhax.
def var vpag             as   log.
        vpag = no.
        if vpag then leave.
        display with frame flado column 42 side-label
                title " Pagamento " color white/cyan width 38 row 6.
        assign tt-titulo.titdtpag = vdtpag
               tt-titulo.titdtpag = vdate
               tt-titulo.datexp   = today
               tt-titulo.cxacod   = 99
               tt-titulo.cxmdat   = today.
        update tt-titulo.titdtpag colon 15 with frame flado.
        i-senx = 0.
        repeat on endkey undo, leave bl-princ.

            UPDATE vetbcobra       colon 15 label "Est.Cobrador"
                   with frame flado.
            if vetbcobra <> 90 and
               vetbcobra <> 996 and
               vetbcobra <> 997 and
               vetbcobra <> 98
            then do:
                message "Filial Invalida".
                undo, retry.
            end.

            /* vsenha1x = "". */
            update vsenha1x BLANK
                       with frame fsenhax overlay centered row 10 color
                                black/red no-label.
            if vetbcobra = 90 
            then do:
                if vsenha1x <> "9632"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
            end.

            if vetbcobra = 996
            then do:
                if vsenha1x <> "gre95"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
            end.
 
            if vetbcobra = 997
            then do:
                if vsenha1x <> "2983"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
            end.
 
            if vetbcobra = 998
            then do:
                if vsenha1x <> "1983"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
            end.

 
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                bell.
                message "Estabelecimento nao Cadastrado !!".
                undo, retry.
            end.
            leave.
        end.
        assign vdtpag    = tt-titulo.titdtpag
               vdate     = tt-titulo.titdtpag
               vtitvlpag = 0.

        do on error undo, retry:
            update vtitvlpag validate
                  (vtitvlpag > 0 or vtitvlpag = tt-titulo.titvlpag,
                                        "Valor Invalido") colon 15
                    with frame flado.

            if vtitvlpag > tt-titulo.titvlcob
            then do:
                bell.
                message "Valor pagamento maior do que o Cobrado !!".
                undo, retry.
            end.
        end.
        tt-titulo.cobcod = 2.
        if vtitvlpag >= tt-titulo.titvlcob
        then tt-titulo.titjuro = vtitvlpag - tt-titulo.titvlcob.
        else do:
            assign sresp = yes.
            display "  Confirma PAGAMENTO PARCIAL ?"
                                with frame fpag color messages
                                width 40 overlay row 10 centered.
            update sresp no-label with frame fpag.
            hide frame fpag no-pause.
            if sresp
            then do:
                find last btt-titulo use-index titnum where
                          btt-titulo.empcod   = wempre.empcod and
                          btt-titulo.titnat   = tt-titulo.titnat and
                          btt-titulo.modcod   = tt-titulo.modcod and
                          btt-titulo.etbcod   = tt-titulo.etbcod and
                          btt-titulo.clifor   = tt-titulo.clifor and
                          btt-titulo.titnum   = tt-titulo.titnum.
                create ctt-titulo.
                assign ctt-titulo.empcod = btt-titulo.empcod
                       ctt-titulo.modcod = btt-titulo.modcod
                       ctt-titulo.clifor = btt-titulo.clifor
                       ctt-titulo.titnat = btt-titulo.titnat
                       ctt-titulo.etbcod = btt-titulo.etbcod
                       ctt-titulo.titnum = btt-titulo.titnum
                       ctt-titulo.cobcod = tt-titulo.cobcod
                       ctt-titulo.titpar   = btt-titulo.titpar + 1
                       ctt-titulo.titdtemi = tt-titulo.titdtemi
                       ctt-titulo.titdtven = tt-titulo.titdtven
                       ctt-titulo.titvlcob = tt-titulo.titvlcob - vtitvlpag
                       ctt-titulo.titnumger = tt-titulo.titnum
                       ctt-titulo.titparger = tt-titulo.titpar
                       ctt-titulo.titsit    = "IMP"
                       ctt-titulo.datexp    = today.
                display ctt-titulo.titnum
                        ctt-titulo.titpar
                        ctt-titulo.titdtemi
                        ctt-titulo.titdtven
                        ctt-titulo.titvlcob
                        with frame fmos width 40 1 column
                             title " tt-titulo Gerado " overlay
                                              column 41 row 10.
            end.
            else tt-titulo.titdesc = tt-titulo.titvlcob - vtitvlpag.
        end.
        update tt-titulo.titjuro colon 15
               with frame flado.
        l-desc:
        do on endkey undo.
            update tt-titulo.titdesc colon 15
                   with frame flado.
            if tt-titulo.titdesc >= tt-titulo.titvlcob
            then do:
                message "Desconto maior que o valor principal".
                undo l-desc.
            end.
        end.

        assign tt-titulo.titvlpag = vtitvlpag + tt-titulo.titjuro
               tt-titulo.titvlpag = tt-titulo.titvlpag - tt-titulo.titdesc
               tt-titulo.titsit   = "PAG"
               tt-titulo.etbcobra = vetbcobra
               tt-titulo.cxacod   = 99.
        
        sresp = no.
                 
        message "Deseja quitar todo contrato" update sresp.
        if sresp 
        then do: 
            
            for each btt-titulo where btt-titulo.empcod   = tt-titulo.empcod and
                                   btt-titulo.titnat   = tt-titulo.titnat and
                                   btt-titulo.modcod   = tt-titulo.modcod and
                                   btt-titulo.etbcod   = tt-titulo.etbcod and
                                   btt-titulo.clifor   = tt-titulo.clifor and
                                   btt-titulo.titnum   = tt-titulo.titnum and
                                   btt-titulo.titpar   > tt-titulo.titpar:
                                 

                assign btt-titulo.titvlpag = tt-titulo.titvlpag
                       btt-titulo.titdtpag = tt-titulo.titdtpag
                       btt-titulo.titsit   = "PAG"
                       btt-titulo.etbcobra = vetbcobra
                       btt-titulo.cxacod   = 99
                       btt-titulo.cxmdat   = today
                       btt-titulo.datexp = today
                       btt-titulo.exportado = no.

                        
            end.            

        end.
       
