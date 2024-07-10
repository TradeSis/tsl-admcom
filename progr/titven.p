/*
*
*    Esqueletao de Programacao                          titulo.p
*
*/
{admcab.i }
def var vinicio         as  log initial no.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(14)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(22)" extent 3
            initial ["Pagamento/Cancelamento", "Bloqueio/Liberacao",""].
def buffer btitulo      for titulo.
def buffer ctitulo      for titulo.
def var vempcod         like titulo.empcod.
def var vetbcod         like titulo.etbcod.
def var vmodcod         like titulo.modcod.
def var vtitnat         like titulo.titnat.
def var vcliforlab      as char format "x(12)".
def var vclifornom      as char format "x(30)".
def var vclifor         like titulo.clifor.
def var wperdes         as dec format ">9.99 %" label "Perc. Desc.".
def var wperjur         as dec format ">9.99 %" label "Perc. Juros".
def var vtitvlpag       like titulo.titvlpag.
def var vtitvlcob       like titulo.titvlcob.
def var vdtpag          like titulo.titdtpag.
def var vdate           as   date.
def var vetbcobra       like titulo.etbcobra.

form esqcom1
    with frame f-com1
    row 5 no-box no-labels side-labels column 1.
form esqcom2
    with frame f-com2
        row screen-lines - 2 title " OPERACOES " no-labels side-labels column 1
        centered.
FORM titulo.titnum     colon 15
    titulo.titpar     colon 15
    titulo.titdtemi   colon 15
    titulo.titdtven   colon 15
    titulo.titvlcob   colon 15
    titulo.cobcod     colon 15
    with frame ftitulo
        overlay row 7 color
        white/cyan side-label width 39.
form titulo.titbanpag colon 15
    banco.bandesc no-label
    titulo.titagepag colon 15
    agenc.agedesc no-label
    titulo.titchepag colon 15
    with frame fbancpg centered
         side-labels 1 down overlay
         color white/cyan row 16
         title " Banco Pago " width 80.
form titulo.bancod   colon 15
    banco.bandesc           no-label
    titulo.agecod   colon 15
    agenc.agedesc         no-label
    with frame fbanco centered
         side-labels 1 down
         color white/cyan row 16 .
form wperjur         colon 16
    titulo.titvljur colon 16 skip(1)
    titulo.titdtdes colon 16
    wperdes         colon 16
    titulo.titvldes colon 16
    with frame fjurdes
         overlay row 7 column 41 side-label
         color white/cyan  width 40.
form
    titulo.titobs[1] at 1
    titulo.titobs[2] at 1
    with no-labels width 80 row 16
         title " Observacoes " frame fobs
         color white/cyan .

form
    titulo.titdtpag colon 13 label "Dt.Pagam"
    titulo.titvlpag  colon 13
    titulo.cobcod    colon 13
    with frame fpag1 side-label
         row 10 color white/cyan
         overlay column 42 width 39 title " Pagamento " .
repeat:
    clear frame ff1 all.
    assign
        esqregua = yes
        esqpos1  = 1
        esqpos2  = 1
        recatu1  = ?.
    hide frame f-com1 no-pause.
    hide frame f-com2 no-pause.
    update vetbcod validate(can-find(estab where estab.etbcod = vetbcod),
                            "Estabelecimento Invalido") colon 18
           with frame ff1.
    find estab where estab.etbcod = vetbcod .
    display estab.etbnom no-label with frame ff1.
    update vmodcod validate(can-find(modal where modal.modcod = vmodcod),
                            "Modalidade Invalida") colon 18
           with frame ff1.
    find modal where modal.modcod = vmodcod.
    display modal.modnom no-label with frame ff1.
    update vtitnat colon 18
           with frame ff1 side-labels row 5 width 80 color white/cyan.
    hide frame ff1 no-pause.
    display vetbcod vmodcod vtitnat
            with frame ff no-box row 4 side-labels color white/red width 81.
    vcliforlab = if vtitnat
                 then "Fornecedor:"
                 else "   Cliente:".
    lclifor = if vtitnat
              then no
              else yes .

    display vcliforlab no-labels to 19 with frame ff1.
    prompt-for titulo.clifor no-label with frame ff1.
    if vtitnat
    then find forne where forne.forcod = input titulo.clifor.
    else find clien where clien.clicod = input titulo.clifor.
    vclifor = input frame ff1 titulo.clifor .
    vclifornom = if vtitnat
                 then forne.fornom
                 else clien.clinom.
    hide frame ff1 no-pause.
bl-princ:
repeat :
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first titulo use-index titdtven where
            titulo.empcod   = wempre.empcod and
            titulo.titnat   = vtitnat       and
            titulo.modcod   = vmodcod       and
            titulo.titdtven <= ?            and
            titulo.etbcod   = vetbcod       and
            titulo.clifor   = vclifor  no-error.
    else
        find titulo where recid(titulo) = recatu1.
    vinicio = no.
    if not available titulo
    then do:
        message "Cadastro de Titulos Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame ftitulo on error undo:
                create titulo.
                assign
                    titulo.empcod = wempre.empcod
                    titulo.titnat = vtitnat
                    titulo.modcod = vmodcod
                    titulo.etbcod = vetbcod.
                assign
                    titulo.clifor = vclifor.
                update titulo.titnum
                       titulo.titpar
                       titulo.titdtemi
                       titulo.titdtven
                       titulo.titvlcob
                       titulo.cobcod.
                find cobra where cobra.cobcod = titulo.cobcod.
                display cobra.cobnom  no-label.
                if cobra.cobban
                then do with frame fbanco.
                    update titulo.bancod colon 15.
                    find banco where banco.bancod = titulo.bancod.
                    display banco.bandesc .
                    update titulo.agecod.
                    find agenc of banco where agenc.agecod = titulo.agecod.
                    display agedesc.
                end.
                wperjur = 0 .
                update wperjur with frame fjurdes.
                titulo.titvljur = titulo.titvlcob * (wperjur / 100).
                update titulo.titvljur with frame fjurdes .
                wperdes = 0.
                update titulo.titdtdes
                       wperdes
                       with frame fjurdes.
                titulo.titvldes = titulo.titvlcob * (wperdes / 100).
                update titulo.titvldes
                       with frame fjurdes.
                update text(titobs)
                       with frame fobs .
                pause 0.
                vinicio = yes.
        end.
    end.
    clear frame frame-a all no-pause.
    display
        titulo.titnum
        titulo.titpar
        titulo.titdtemi format "99/99/99"   column-label "Dt.Emis"
        titulo.titvlcob format ">>,>>>,>>9.99" column-label "Valor Cobrado"
        titulo.titdtven format "99/99/99"   column-label "Dt.Vecto"
        titulo.titdtpag format "99/99/99"   column-label "Dt.Pagto"
        titulo.titvlpag when titulo.titvlpag > 0 format ">>,>>>,>>9.99"
                                            column-label "Valor Pago"
        titulo.titsit
            with frame frame-a 10 down centered color white/red
            title " " + vcliforlab + " " + vclifornom + " "
                    + " Cod.: " + string(vclifor) + " " width 80.

    recatu1 = recid(titulo).
    if esqregua
    then do:
        display esqcom1[esqpos1] with frame f-com1.
        color  display message esqcom1[esqpos1] with frame f-com1.
    end.
    else do:
        display esqcom2[esqpos2] with frame f-com2.
        color display message esqcom2[esqpos2] with frame f-com2.
    end.
    repeat:
        find next titulo use-index titdtven where
            titulo.empcod   = wempre.empcod and
            titulo.titnat   = vtitnat       and
            titulo.modcod   = vmodcod       and
            titulo.titdtven <= ?            and
            titulo.etbcod   = vetbcod       and
            titulo.clifor   = vclifor no-error.
        if not available titulo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if not vinicio
        then down with frame frame-a.
        display
            titulo.titnum
            titulo.titpar
            titulo.titdtemi
            titulo.titvlcob
            titulo.titdtven
            titulo.titdtpag
            titulo.titvlpag when titulo.titvlpag > 0
            titulo.titsit
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find titulo where recid(titulo) = recatu1.

        color display messages
            titulo.titpar.
        choose field titulo.titnum
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  tab PF4 F4 ESC return).
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 3
                          then 3
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next titulo use-index titdtven where
            titulo.empcod   = wempre.empcod and
            titulo.titnat   = vtitnat       and
            titulo.modcod   = vmodcod       and
            titulo.titdtven <= ?            and
            titulo.etbcod   = vetbcod   and
            titulo.clifor   = vclifor no-error.
            if not avail titulo
            then next.
            color display white/red
                titulo.titnum titulo.titpar.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev titulo use-index titdtven where
            titulo.empcod   = wempre.empcod and
            titulo.titnat   = vtitnat       and
            titulo.modcod   = vmodcod       and
            titulo.titdtven <= ?            and
            titulo.etbcod   = vetbcod       and
            titulo.clifor   = vclifor no-error.
            if not avail titulo
            then next.
            color display white/red
                titulo.titnum titulo.titpar.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
          if esqcom2[esqpos2] <> "Pagamento/Cancelamento" or
             esqcom2[esqpos2] <> "Bloqueio/Liberacao"
          then
            hide frame frame-a no-pause.
          display vcliforlab at 6 vclifornom
                with frame frame-b 1 down centered color blue/gray
                width 81 no-box no-label row 5 overlay.

          if esqregua
          then do:

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame ftitulo:
                create titulo.
                assign
                    titulo.empcod = wempre.empcod
                    titulo.titnat = vtitnat
                    titulo.modcod = vmodcod
                    titulo.etbcod = vetbcod.
                assign
                    titulo.clifor = vclifor.
                update titulo.titnum
                       titulo.titpar
                       titulo.titdtemi
                       titulo.titdtven
                       titulo.titvlcob
                       titulo.cobcod.
                find cobra where cobra.cobcod = titulo.cobcod.
                display cobra.cobnom .
                if cobra.cobban
                then do with frame fbanco:
                    update titulo.bancod.
                    find banco where banco.bancod = titulo.bancod.
                    display banco.bandesc .
                    update titulo.agecod.
                    find agenc of banco where agenc.agecod = titulo.agecod.
                    display agedesc.
                end.
                wperjur = 0 .
                update wperjur
                       with frame fjurdes.
                titulo.titvljur = titulo.titvlcob * (wperjur / 100).
                update titulo.titvljur with frame fjurdes .
                wperdes = 0.
                update titulo.titdtdes
                       wperdes
                       with frame fjurdes.
                titulo.titvldes = titulo.titvlcob * (wperdes / 100).
                update titulo.titvldes
                        with frame fjurdes.
                update text(titobs)
                       with frame fobs .
                pause 0.
                recatu1 = recid(titulo).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame ftitulo:
                vtitvlcob = titulo.titvlcob .
                update titulo.titnum
                       titulo.titpar
                       titulo.titdtemi
                       titulo.titdtven
                       titulo.titvlcob
                       titulo.cobcod.
                find cobra where cobra.cobcod = titulo.cobcod.
                display cobra.cobnom .
                if cobra.cobban
                then do with frame fbanco:
                    update titulo.bancod.
                    find banco where banco.bancod = titulo.bancod.
                    display banco.bandesc .
                    update titulo.agecod.
                    find agenc of banco where agenc.agecod = titulo.agecod.
                    display agedesc.
                end.
                update titulo.titvljur with frame fjurdes .
                update titulo.titdtdes
                       with frame fjurdes.
                update titulo.titvldes
                        with frame fjurdes.
                update text(titobs)
                       with frame fobs .
                if titulo.titvlcob <> vtitvlcob
                then do:
                   if titulo.titvlcob < vtitvlcob
                   then do:
                    assign sresp = yes.
                    display "  Confirma GERACAO DE NOVO TITULO ?"
                                with frame fGERT color messages
                                width 60 overlay row 10 centered.
                    update sresp no-label with frame fGERT.
                    if sresp then do:
                        find last btitulo where
                            btitulo.empcod   = wempre.empcod and
                            btitulo.titnat   = vtitnat       and
                            btitulo.modcod   = vmodcod       and
                            btitulo.etbcod   = vetbcod       and
                            btitulo.clifor   = vclifor       and
                            btitulo.titnum   = titulo.titnum.
                            create ctitulo.
                            assign
                                ctitulo.empcod = btitulo.empcod
                                ctitulo.modcod = btitulo.modcod
                                ctitulo.clifor = btitulo.clifor
                                ctitulo.titnat = btitulo.titnat
                                ctitulo.etbcod = btitulo.etbcod
                                ctitulo.titnum = btitulo.titnum
                                ctitulo.cobcod = titulo.cobcod
                                ctitulo.titpar   = btitulo.titpar + 1
                                ctitulo.titdtemi = today
                                ctitulo.titdtven = titulo.titdtven
                                ctitulo.titvlcob = vtitvlcob - titulo.titvlcob
                                ctitulo.titnumger = titulo.titnum
                                ctitulo.titparger = titulo.titpar.
                            display
                                    ctitulo.titnum
                                    ctitulo.titpar
                                    ctitulo.titdtemi
                                    ctitulo.titdtven
                                    ctitulo.titvlcob
                                    with frame fmos width 40 1 column
                                              title " Titulo Gerado " overlay
                                              centered row 10.
                            recatu1 = recid(ctitulo).
                            leave.
                        end.
                     end.
                     else do:
                        display "  Confirma AUMENTO NO VALOR DO TITULO?"
                                with frame faum color messages
                                width 60 overlay row 10 centered.
                        update sresp no-label with frame faum.
                        if not sresp
                        then undo, leave.
                    end.
                end.
            end.
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao"
            then do:
                disp
                    titulo.titnum
                    titulo.titpar
                    titulo.titdtemi
                    titulo.titdtven
                    titulo.titvlcob
                    titulo.cobcod
                        with frame ftitulo.

                disp
                    titulo.titvljur
                    titulo.titdtdes
                    titulo.titvldes
                        with frame fjurdes.

                disp
                    titulo.titobs[1] at 1
                    titulo.titobs[2] at 1
                    with frame fobs.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de Titulo"
                            titulo.titnum ",Parcela" titulo.titpar
                    update sresp.
                if not sresp
                then leave.
                find next titulo use-index titdtven where
            titulo.empcod   = wempre.empcod and
            titulo.titnat   = vtitnat       and
            titulo.modcod   = vmodcod       and
            titulo.titdtven <= ?            and
            titulo.etbcod   = vetbcod       and
            titulo.clifor   = vclifor no-error.
                if not available titulo
                then do:
                    find titulo where recid(titulo) = recatu1.
                    find prev titulo use-index titdtven where
            titulo.empcod   = wempre.empcod and
            titulo.titnat   = vtitnat       and
            titulo.modcod   = vmodcod       and
            titulo.titdtven <= ?            and
            titulo.etbcod   = vetbcod       and
            titulo.clifor   = vclifor no-error.
                end.
                recatu2 = if available titulo
                          then recid(titulo)
                          else ?.
                find titulo where recid(titulo) = recatu1.
                delete titulo.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de Titulos" update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each titulo:
                    display titulo.
                end.
                output close.
                recatu1 = recatu2.
                leave.
            end.

          end.
          else do:
            hide frame f-com2 no-pause.
            if esqcom2[esqpos2] = "Pagamento/Cancelamento"
            then
              if titulo.titsit = "LIB"
              then do with frame f-Paga overlay row 6 1 column centered.
                 display titulo.titnum    colon 13
                        titulo.titpar    colon 33 label "Pr"
                        titulo.titdtemi  colon 13
                        titulo.titdtven  colon 13
                        titulo.titvlcob  colon 13 label "Vl.Cobr."
                        with frame fdadpg side-label
                        overlay row 6 color white/cyan width 40
                        title " Titulo ".
                if titulo.titsit <> "LIB"
                then do:
                    bell.
                    message "Titulo com situacao ilegal para Pagamento,"
                            titulo.titsit.
                    pause.
                    leave.
                end.
               if titulo.modcod = "CRE"
               then do:
                    {titpagb4.i}
               end.
               else do:

                assign titulo.titdtpag = today.
                display titulo.titdtdes colon 13 label "Dt.Desc"
                            titulo.titvldes colon 13 label "Desc Diario"
                            titulo.titvljur colon 13
                            with frame fdadpg.
                update titulo.titdtpag
                           with frame fpag1.
                if titulo.titdtpag > titulo.titdtven
                then do:
                        assign titulo.titvlpag = titulo.titvlcob
                               + (titulo.titvljur *
                                    (titulo.titdtpag - titulo.titdtven)).
                end.
                else
                    if titulo.titdtpag <= titulo.titdtdes
                    then do:
                            titulo.titvlpag = titulo.titvlcob -
                                          (titulo.titvldes *
                                     ((titulo.titdtdes - titulo.titdtpag) + 1)).
                    end.
                    else
                            titulo.titvlpag = titulo.titvlcob .
                assign vtitvlpag = titulo.titvlpag.
                update titulo.titvlpag
                       with frame fpag1.
                update titulo.cobcod
                       with frame fpag1 .
                if titulo.titvlpag >= titulo.titvlcob
                then titulo.titjuro = titulo.titvlpag - titulo.titvlcob.
                else do:
                        assign sresp = yes.
                        display "  Confirma PAGAMENTO PARCIAL ?"
                                with frame fpag color messages
                                width 40 overlay row 10 centered.
                    update sresp no-label with frame fpag.
                    if sresp then do:
                        find last btitulo where
                            btitulo.empcod   = wempre.empcod and
                            btitulo.titnat   = vtitnat       and
                            btitulo.modcod   = vmodcod       and
                            btitulo.etbcod   = vetbcod       and
                            btitulo.clifor   = vclifor       and
                            btitulo.titnum   = titulo.titnum.
                            create ctitulo.
                            assign
                                ctitulo.empcod = btitulo.empcod
                                ctitulo.modcod = btitulo.modcod
                                ctitulo.clifor = btitulo.clifor
                                ctitulo.titnat = btitulo.titnat
                                ctitulo.etbcod = btitulo.etbcod
                                ctitulo.titnum = btitulo.titnum
                                ctitulo.cobcod = titulo.cobcod
                                ctitulo.titpar   = btitulo.titpar + 1
                                ctitulo.titdtemi = titulo.titdtemi

                                ctitulo.titdtven = if titulo.titdtpag <
                                                      titulo.titdtven
                                                   then titulo.titdtven
                                                   else titulo.titdtpag


                                ctitulo.titvlcob = vtitvlpag - titulo.titvlpag
                                ctitulo.titnumger = titulo.titnum
                                ctitulo.titparger = titulo.titpar.
                            display
                                    ctitulo.titnum
                                    ctitulo.titpar
                                    ctitulo.titdtemi
                                    ctitulo.titdtven
                                    ctitulo.titvlcob
                                    with frame fmos width 40 1 column
                                              title " Titulo Gerado " overlay
                                              centered row 10.
                        end.
                        else
                            titulo.titdesc = titulo.titvlcob - titulo.titvlpag.
                end.
                find cobra of titulo.
                if cobra.cobban
                then do with frame fbancpg :
                        update titulo.titbanpag .
                        find banco where banco.bancod = titulo.titbanpag.
                        display bandesc .
                        update titulo.titagepag .
                        find agenc of banco
                            where agenc.agecod = titulo.titagepag.
                        display agedesc no-label.
                        update titulo.titchepag.
                end.
                assign titulo.titsit = "PAG".
               end.
               recatu1 = recid(titulo).
               leave.
              end.
              else
                if titulo.titsit = "PAG"
                then do:
                    display titulo.titnum
                            titulo.titpar
                            titulo.titdtemi
                            titulo.titdtven
                            titulo.titvlcob
                            titulo.cobcod
                            with frame ftitulo.
                    display titulo.titdtpag titulo.titvlpag titulo.cobcod
                            with frame fpag1.
                    message "Confirma o Cancelamento do Pagamento ?"
                            update sresp.
                    if sresp
                    then assign titulo.titsit    = "LIB"
                                titulo.titdtpag  = ?
                                titulo.titvlpag  = 0
                                titulo.titbanpag = 0
                                titulo.titagepag = ""
                                titulo.titchepag = "".
                   recatu1 = recid(titulo).
                   next bl-princ.
                end.

            if esqcom2[esqpos2]  = "Bloqueio/Liberacao" and
               titulo.titsit    <> "PAG"
            then do:
                if titulo.titsit <> "BLO"
                then do:
                    message "Confirma o Bloqueio do Titulo ?" update sresp.
                    if sresp
                    then
                        titulo.titsit = "BLO".
                end.
                else
                    if titulo.titsit = "BLO"
                    then do:
                        message "Confirma a Liberacao do Titulo ?" update sresp.
                        if sresp
                        then
                            titulo.titsit = "LIB".
                     end.
            end.
          end.
          view frame frame-a.
          view frame f-com2 .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        display
            titulo.titnum
            titulo.titpar
            titulo.titdtemi
            titulo.titvlcob
            titulo.titdtven
            titulo.titdtpag
            titulo.titvlpag when titulo.titvlpag > 0
            titulo.titsit
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(titulo).
   end.
end.
end.
