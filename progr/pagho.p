/*----------------------------------------------------------------------------*/
/* /usr/admfin/agend.p                                             Agenda     */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 08/12/92 Oscar   Criacao                                                   */
/*----------------------------------------------------------------------------*/
{cab.i}
def var wtitval like titulo.titvlcob.
def var wtottit like titulo.titvlcob.
def buffer ytitulo for titulo.
def buffer xtitulo for titulo.
def var wtitvl like titulo.titvlcob.
def var wrsp as logical format "Sim/Nao".
def var wetbcod like titulo.etbcod initial 0.
def var wmodcod like titulo.modcod initial "".
def var wtitnat like titulo.titnat.
def var wclifor like titulo.clifor.
def var wdti    like titdtven label "Periodo" initial today.
def var wdtf    like titdtven.
def var wtot      as dec format ">,>>>,>>>,>>9.99" label "Total".
def var wseq as i extent 2.
def var i as i.
def var wopcao as char.
def var wforcli as i format "999999" label "For/Cli".
define  temp-table wktit
        field seq as   i label "Nr" format "99"
        field empcod   like titulo.empcod
        field modcod   like titulo.modcod
        field clifor   like titulo.clifor
        field titnum   like titulo.titnum
        field titpar   like titulo.titpar
        field cobcod   like titulo.cobcod
        field titdtven like titulo.titdtven
        field titdtemi like titulo.titdtemi
        field titvlcob like titulo.titvlcob
        field etbcod   like titulo.etbcod.
wdtf = wdti + 30.

    assign wetbcod = 1.
    display wetbcod label "Estabelec." colon 12
            with column 50 side-labels 1 down width 31 row 4 frame f1.
    if wetbcod <> 0
       then do:
               find estab where estab.etbcod = wetbcod.
               display etbnom no-label format "x(10)" with frame f1.
       end.
    assign wmodcod = "CRE".
    display wmodcod label "Modal/Natur" colon 12 with frame f1.

    display " - " with frame f1.

    if wmodcod = "CRE"
       then wtitnat = no.
    display wtitnat no-label with frame f1.
    repeat:
        if wtitnat
           then do with column 1 side-labels 1 down width 48 row 4 frame ff:
             wclifor = 0.
             update wclifor validate(wclifor = 0 or
                                   can-find(forne where forne.forcod = wclifor),
                                    "Fornecedor nao cadastrado")
                                    colon 12.
             if wclifor <> 0
                then do:
                        find forne where forne.forcod = wclifor.
                        display fornom format "x(32)" no-label at 14.
                end.
           end.
           else do with column 1 side-labels 1 down width 48 row 4 frame fc:
             wclifor = 0.
             update wclifor validate(wclifor = 0 or
                                   can-find(clien where clien.clicod = wclifor),
                                    "Cliente nao Cadastrado")
                                    colon 12.
             if wclifor <> 0
                then do:
                        find clien where clien.clicod = wclifor.
                        display clinom format "x(32)" no-label at 14.
                end.
           end.

        form wtot colon 12 with frame ftot width 31 row 19 column 50 side-label.

        for each wktit:
            delete wktit.
        end.
        assign wseq[1] = 0
               i = 0
               wtot = 0.
    for each titulo where titulo.clifor = wclifor and
                          titnat   =   wtitnat     and
                         (titsit   =   "LIB"        or
                          titsit   =   "BLO")      and
                          titulo.etbcod = wetbcod  and
                          titulo.modcod = wmodcod no-lock
                                    by titulo.titdtven
                                    by titulo.clifor
                                    by titulo.modcod
                                    by titulo.titnum
                                    by titulo.titpar:
            create wktit.
            i = i + 1.
            assign seq = i
                   wktit.empcod   = titulo.empcod
                   wktit.modcod   = titulo.modcod
                   wktit.clifor   = titulo.clifor
                   wktit.titnum   = titulo.titnum
                   wktit.titpar   = titulo.titpar
                   wktit.cobcod   = titulo.cobcod
                   wktit.titdtven = titulo.titdtven
                   wktit.titdtemi = titulo.titdtemi
                   wktit.titvlcob = titulo.titvlcob
                   wktit.etbcod   = titulo.etbcod.


        end.
        l1:
        repeat with frame f2 7 down width 80:
            form            wktit.seq
                            wktit.titdtemi
                 space(2)   wktit.titdtven
                 space(2)   wktit.modcod
                 space(2)   wktit.titnum
                 space(2)   wktit.titpar
                 space(2)   wktit.etbcod
                 space(2)  wktit.titvlcob with frame f2 7 down width 80 row 8.

            for each wktit where seq >= wseq[1]
                                    i = 1 to 7:
            wtot = wtot + wktit.titvlcob.
               display wktit.seq with frame f2.
                display wktit.titnum
                        wktit.titpar
                        wktit.titdtemi
                        wktit.titdtven
                        wktit.titvlcob
                        wktit.etbcod
                        with frame f2.
                down with frame f2.
            display wtot with frame ftot.
                if i = 1
                   then wseq[1] = seq.
                wseq[2] = seq.
            end.
            if wtot = 0
               then do:
                       message "Nenhum Titulo p/ este Periodo".
                       undo,leave.
               end.
            wtot = 0.
            up frame-line (f2) - 1 with frame f2.

            repeat on endkey undo,leave l1:

                hide frame f4f.
                hide frame f4c.
                hide frame f5.
                hide frame f6c.
                hide frame f7.
                choose row wktit.seq
                help "[C] para Consulta, [P] para Pagamento, PG-DOWN e PG-UP"
                             go-on(PAGE-DOWN PAGE-UP C c P p)
                             with frame f2.
                wopcao = keyfunction(lastkey).
                if wopcao = "PAGE-UP"
                    then do:
                    hide message no-pause.
                    find last wktit where seq < wseq[1] no-error.

                    if not available wktit
                        then do:
                        message "Nao ha mais registros".
                    /*  clear frame f2 all.
                        HIDE FRAME F2 .   */
                        undo.
                    end.

                    for each wktit where seq < wseq[1]
                                             by seq descending
                                             i = 1 to frame-down (f2):

                        if i = 1
                            then wseq[2] = seq.
                            if i = frame-down (f2)
                                 then wseq[1] = seq.
                    end.
                    clear frame f2 all.
                    leave.
                end.
                if wopcao = "PAGE-DOWN"
                    then do:
                    hide message no-pause.
                    find first wktit where seq > wseq[2] no-error.

                    if not available wktit
                        then do:
                                   message "Nao ha mais registros".
                              /*   clear frame f2 all.
                                   HIDE FRAME F2 .  */
                                   undo.
                     end.

                        wseq[1] = seq.
                        clear frame f2 all.
                        leave.
                end.
             form titulo.titdtemi colon 15
                  titulo.titdtven colon 15
                  titulo.titvljur colon 57
                  titulo.titvlcob colon 15
                  titulo.titdtdes colon 57
                  titulo.cobcod colon 15
                  cobra.cobnom no-label at 20
                  titulo.titvldes colon 57
                  with side-labels 1 down width 80 frame f5 overlay.
              form titulo.bancod colon 15
                           bandesc no-label at 26
                   titulo.agecod colon 15
                           agedesc no-label at 26
                           with side-labels 1 down width 80 frame f6c overlay.
              if wopcao = "C"  or
                 wopcao = "c"
                 then do:
                         if input wktit.seq = 0
                            then do:
                                   message "Escolha uma das linhas preenchidas".
                                   clear frame f2 all.
                                   HIDE FRAME F2 .
                                   undo.

                        end.
                         find first wktit where wktit.seq = input wktit.seq.
                         find titulo where titulo.empcod = wktit.empcod and
                                           titulo.modcod = wktit.modcod and
                                           titulo.clifor = wktit.clifor and
                                           titulo.titnum = wktit.titnum and
                                           titulo.titpar = wktit.titpar.

                         if wtitnat
                            then do:
                                    find forne where forne.forcod =
                                                           titulo.clifor .
                                    display titulo.clifor colon 15
                                            forne.fornom  no-label colon 30
                                            titulo.titnum colon 15
                                            titulo.titpar colon 57
                                            with side-labels 1 down width 80
                                                 frame f4f overlay row 8.
                             end.
                             else do:
                                     find clien where clien.clicod =
                                                        titulo.clifor.
                                     display titulo.clifor colon 10
                                             clien.clinom  no-label colon 25
                                             titulo.titnum colon 10
                                             titulo.titpar colon 52
                                             with side-labels 1 down width 80
                                                  frame f4c overlay row 8.
                             end.

                         find cobra of titulo.
                         display titulo.titdtemi
                                 titulo.titdtven
                                 titulo.titvlcob
                                 titulo.cobcod
                                 cobra.cobnom
                                 titulo.titvljur
                                 titulo.titdtdes
                                 titulo.titvldes with frame f5.
                         if  titulo.cobcod = 1
                             then do with side-labels 1 down
                                          width 80 frame f6c overlay:
                                 display titulo.bancod.
                                 find banco where banco.bancod = titulo.bancod.
                                 display bandesc no-label.
                                 display titulo.agecod.
                                 find agenc of banco where
                                               agenc.agecod = titulo.agecod.
                                 display agedesc no-label.
                             end.
                         display titulo.titobs with no-labels
                                width 80 title " Observacoes " frame f7 overlay.
                         pause.
           /*   clear frame f2 all.
                HIDE FRAME F2 .  */
                end.


                if wopcao = "P"  or
                   wopcao = "p"
                    then do:
                    if input wktit.seq = 0
                        then do:
                        message "Escolha uma das linhas preenchidas".
                                clear frame f2 all.
                        HIDE FRAME F2 .
                        undo.
                    end.
                    find first wktit where wktit.seq = input wktit.seq.
                    find titulo where titulo.empcod = wktit.empcod and
                                      titulo.modcod = wktit.modcod and
                                      titulo.clifor = wktit.clifor and
                                      titulo.titnum = wktit.titnum and
                                      titulo.titpar = wktit.titpar.

                    if titulo.titnat
                        then do:
                        find forne where forne.forcod = titulo.clifor.
                    end.
                    else do:
                        find clien where clien.clicod = titulo.clifor.
                    end.

                    find cobra of titulo.
                    if  titulo.cobcod = 1
                        then do with side-labels 1 down
                        width 80 frame f6c overlay:
                        find banco where banco.bancod = titulo.bancod.
                        find agenc of banco where
                                           agenc.agecod = titulo.agecod.
                    end.

                    def var wtitnum like titulo.titnum.
                    def var wtitpar like titulo.titpar.
                    def var wcobcod like cobra.cobcod.

                    form titulo.titdtemi colon 15
                         titulo.titdtven colon 15
                         titulo.titvlcob colon 15
                         titulo.titvljur colon 15
                         titulo.titdtdes colon 15
                         titulo.titvldes colon 15
                         with side-labels 1 down width 40
                         title " Cobranca " frame f15.
                    find cobra of titulo.
                    display titulo.titdtemi
                        titulo.titdtven
                        titulo.titvlcob
                        titulo.titvljur
                        titulo.titdtdes
                        titulo.titvldes with frame f15.
                    form titdtpag colon 15
                         titvlpag colon 15
                         titdesc  colon 15
                         titjuro  colon 15
                         wcobcod  colon 15
                         cobra.cobnom no-label
                         with side-labels 1 down width 40 column 41
                         title " Pagamento " frame f18.

                    assign titdtpag = today.
                    update titdtpag with frame f18.
                    if titdtpag > titulo.titdtven then do:
                        assign titvlpag = titulo.titvlcob
                               + (titvljur * (titdtpag - titulo.titdtven)).
                    end.
                    else
                        assign titvlpag = titulo.titvlcob.

                        assign wtitval = titulo.titvlpag.
                        assign wcobcod = titulo.cobcod.
                        update titvlpag with frame f18.
                        if titvlpag >= titulo.titvlcob
                            then titjuro = titvlpag - titulo.titvlcob.

                        else do:
                            assign wtitvl = titulo.titvlcob.
                            assign wrsp = yes.
                            display "  Confirma PAGAMENTO PARCIAL ?"
                                with frame fpag color messages
                                width 40 overlay row 10 centered.
                        update wrsp no-label with frame fpag.
                        if wrsp then do:
                            find last xtitulo where
                                        xtitulo.clifor = wktit.clifor and
                                        xtitulo.titnum = wktit.titnum.
                            create ytitulo.
                            assign ytitulo.empcod = wktit.empcod
                                   ytitulo.modcod = wktit.modcod
                                   ytitulo.clifor = wktit.clifor
                                   ytitulo.titnum = wktit.titnum
                                   ytitulo.cobcod = titulo.cobcod
                                   ytitulo.titpar   = xtitulo.titpar + 1
                                   ytitulo.titdtemi = today
                                   ytitulo.titdtven = titulo.titdtpag
                                   ytitulo.titvlcob = wtitval - titulo.titvlpag
                                   ytitulo.titnumger = titulo.titnum
                                   ytitulo.titparger = titulo.titpar.
                                   clear frame fpag all.
                            display ytitulo.clifor
                                    ytitulo.titnum
                                    ytitulo.titpar
                                    ytitulo.titdtemi
                                    ytitulo.titdtven
                                    ytitulo.titvlcob
                                    with frame fmos width 40 1 column
                                              title " Titulo Gerado " overlay
                                              centered row 10.
                            pause.
                            clear frame fmos.
                        end.
                        else undo,retry.

                    end.
                    display titulo.titdesc
                            titulo.titjuro
                            wcobcod
                        validate(can-find(cobra where cobra.cobcod = wcobcod),
                                "Tipo de Pagamento invalido.")
                        label "Local Pagam."
                        with frame f18.
                    find cobra where cobra.cobcod = wcobcod.
                    display cobra.cobnom with frame f18.
                    pause 0 before-hide.
                    if wcobcod = 1
                    then do with side-labels 1 down width 80 frame f19 row 17
                        overlay:
                        update titulo.titbanpag colon 15.
                        find banco where banco.bancod = titulo.titbanpag.
                        display bandesc no-label at 26.
                        update titulo.titagepag colon 15.
                        find agenc of banco
                            where agenc.agecod = titulo.titagepag.
                        display agedesc no-label at 26.
                        update titulo.titchepag colon 15.
                    end.
                    assign titulo.titsit = "IMP".
                    delete wktit.
                    clear frame f2 all.
                    hide frame ftot.

                    PAUSE BEFORE-HIDE.
                    leave.
                END.

            end.
        end.
        end.

        do on endkey undo,leave on error undo,leave:

        if available clien
        then
            find first titulo where titulo.clifor = clien.clicod and
                                    titulo.titsit = "IMP" no-error.
        if available titulo then do:

            hide message no-pause.
            message "Deseja imprimir RECIBO ?" update wrsp.
            if wrsp then do:
                def var t as i.
                def var tval like titulo.titvlpag.

                output to printer. /* through value("lp -dcrediario -s"). */
                put unformatted chr(27) + chr(67) + chr(24).
                put unformatted chr(18).

                for each titulo where titulo.clifor = clien.clicod and
                                      titulo.titsit = "IMP"
                                            break by titulo.titsit:
                                              /*  by titulo.titnum
                                                  by titulo.titpar:  */

                    t = t + 1.
                    tval = tval + titulo.titvlpag.

                    if t = 1 then do:
                        display skip(4) today at 50 no-label skip(1)
                                with frame frec1 width 80 no-box.
                        display clien.clinom at 5 no-label format "x(40)"
                                    "("
                                    clien.clicod no-label
                                    ")"
                                    skip(2)
                                    with frame frec2 width 80 no-box.
                    end.
                    if t <= 5 then do:
                        display space(14) titulo.titnum
                                space(9)  titulo.titpar
                                space(2)  titulo.titvlpag
                                with frame frec3 width 80 no-box no-labels.
                    end.
                    if
                        t = 5 then do:
                        put skip(6 - t).
                        display
                            "FATO: PORTO ALEGRE FICA CHEIA DE HOMENS" at 3
                            "NO VERAO. MOTIVO: LIQUIDACAO DE ALTO   " at 3
                            tval format ">>>,>>9.99" at 46
                            "VERAO HOMEM.                           " at 3
                            skip(5)
                            with no-label frame ftottit.
                        t = 0.
                        tval = 0.
                    end.

                    if last-of(titulo.titsit)
                        then do:
                        put skip(6 - t).
                        display
                        "FATO: PORTO ALEGRE FICA CHEIA DE HOMENS" at 3
                        "NO VERAO.MOTIVO: LIQUIDACAO DE ALTO    " at 3
                        tval format ">>>,>>9.99" at 46
                        " VERAO HOMEM.                          " at 3
                        skip(1)
                        with no-label frame ftittot2.
                        t = 0.
                        tval = 0.
                    end.

                    titulo.titsit = "PAG".
                end.
                output close.
            /*
            for each titulo of clien where titulo.titsit = "IMP":
                titulo.titsit = "PAG".
            end.
            */

            end.
        end.
        else undo,leave.
        end.
