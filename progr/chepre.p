/*
*
*    MANUTENCAO EM chequeELECIMENTOS                         estab.p    02/05/95
*
*/

{admcab.i}
def var vsit like cheque.chesit.
def buffer bclien for clien.
def var vopcao          as  char format "x(10)" extent 2
                                    initial ["Por Codigo","Por Cheque"] .
def var vnum like cheque.chenum.
def var vban like cheque.cheban.
def var vage like cheque.cheage.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
  initial ["Inclusao","Alteracao","Exclusao","Consulta","Procura","Pagamento"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bcheque       for cheque.
def var vchenum         like cheque.chenum.

form cheque.nome   colon 9
     cheque.chenum colon 9
     cheque.cheven colon 29
     cheque.cheval
     cheque.cheban colon 9
     banco.bandesc no-label
         with frame f-altera side-label
            overlay row 6  color white/cyan centered.

    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
    /*
    update vsit label "Situacao" with frame f-si color message no-box
                                    centered row 4 side-label.

    */
bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first cheque where cheque.cheetb = 900 and
                                cheque.chesit = "LIB" no-error.
    else
        find cheque where recid(cheque) = recatu1.
        vinicio = no.
    if not available cheque
    then do:
        message "Cadastro de cheque Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-altera side-label
            overlay row 6  color white/cyan centered:
                do transaction:
                    create cheque.
                    cheque.cheetb = 900.
                    update cheque.nome
                           cheque.chenum
                           cheque.cheven
                           cheque.cheval.
                    cheque.cheemi = today.

                    do on error undo:
                        update cheque.cheban colon 9.
                        find banco where banco.bancod = cheque.cheban
                                    no-lock no-error.
                        if not avail banco
                        then do:
                            message "Banco nao Cadastrado".
                            undo, retry.
                        end.
                        display banco.bandesc no-label.
                    end.
                    cheque.chesit = "LIB".
                    vinicio = yes.
                end.
        end.
    end.
    clear frame frame-a all no-pause.
    display cheque.nome
            cheque.chenum
            cheque.cheven
            cheque.cheval
            with frame frame-a 14 down centered color white/red.

    recatu1 = recid(cheque).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next cheque where cheque.cheetb = 900 and
                               cheque.chesit = "LIB".
        if not available cheque
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio = no
        then
        down
            with frame frame-a.
        display cheque.nome
                cheque.chenum
                cheque.cheven
                cheque.cheval with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find cheque where recid(cheque) = recatu1.

        choose field cheque.chenum
            go-on(cursor-down cursor-up
                  page-down   page-up
                  cursor-left cursor-right
                  tab PF4 F4 ESC return).
        hide message no-pause.
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
                esqpos1 = if esqpos1 = 6
                          then 6
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
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
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next cheque where cheque.cheetb = 900 and
                                       cheque.chesit = "LIB" no-error.
                if not avail cheque
                then leave.
                recatu2 = recid(cheque).
            end.
            if reccont = frame-down(frame-a)
            then recatu1 = recatu2.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev cheque where cheque.cheetb = 900 and
                                       cheque.chesit = "LIB" no-error.
                if not avail cheque
                then leave.
                recatu1 = recid(cheque).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next cheque where cheque.cheetb = 900  and
                                   cheque.chesit = "LIB" no-error.
            if not avail cheque
            then next.
            color display white/red
                cheque.chenum.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev cheque where cheque.cheetb = 900 and
                                   cheque.chesit = "LIB" no-error.
            if not avail cheque
            then next.
            color display white/red
                cheque.chenum.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.
          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do transaction with frame f-altera no-validate.
                create cheque.
                /* {cheque.i} */
                cheque.cheetb = 900.
                update cheque.nome
                       cheque.chenum
                       cheque.cheven
                       cheque.cheval.
                cheque.cheemi = today.
                do on error undo:
                    update cheque.cheban colon 9.
                    find banco where banco.bancod = cheque.cheban
                                no-lock no-error.
                    if not avail banco
                    then do:
                        message "Banco nao Cadastrado".
                        undo, retry.
                    end.
                    display banco.bandesc no-label.
                end.
                cheque.chesit = "LIB".


                recatu1 = recid(cheque).
                leave.
            end.
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao" or
               esqcom1[esqpos1] = "Listagem"
            then do with frame f-altera no-validate:
                display cheque.nome
                        cheque.chenum
                        cheque.cheven
                        cheque.cheval
                        cheque.cheban.
                pause.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do transaction with frame f-altera no-validate:
                update cheque.nome
                       cheque.chenum
                       cheque.cheven
                       cheque.cheval.

                do on error undo:
                    update cheque.cheban colon 9.
                    find banco where banco.bancod = cheque.cheban
                                no-lock no-error.
                    if not avail banco
                    then do:
                        message "Banco nao Cadastrado".
                        undo, retry.
                    end.
                    display banco.bandesc no-label.
                end.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do transaction with frame f-altera4:
                message "Confirma Exclusao de" cheque.chenum update sresp.
                if not sresp
                then leave.
                find next cheque where cheque.cheetb = 900 and
                                       cheque.chesit = "LIB" no-error.
                if not available cheque
                then do:
                    find cheque where recid(cheque) = recatu1.
                    find prev cheque where cheque.cheetb = 900 and
                                           cheque.chesit = "LIB" no-error.
                end.
                recatu2 = if available cheque
                          then recid(cheque)
                          else ?.
                find cheque where recid(cheque) = recatu1.
                delete cheque.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Procura"
            then do:
                hide frame fprocura no-pause.
                hide frame f-procura no-pause.
                display vopcao
                         help "Escolha a Opcao"
                        with frame fescolha no-label
                        centered row 6 overlay color white/cyan.
                choose field vopcao with frame fescolha.
                if frame-index = 1
                then do with frame fprocura overlay row 9 1 column
                                color white/cyan:
                    prompt-for bclien.clicod.
                    find first bclien where bclien.clicod = input bclien.clicod
                                                    no-error.
                    if not avail bclien
                    then leave.
                    else do:
                        find first cheque where cheque.clicod = bclien.clicod
                                                    no-error.
                        if not avail cheque
                        then do:
                            message "Nenhum cheque para este cliente".
                            undo, retry.
                        end.
                        else recatu1 = recid(cheque).
                    end.
                    leave.
                end.
                else do:
                    update vnum label "Numero"
                           vban label "Banco"
                           vage label "Agencia" with frame f-procura
                                1 column centered color message overlay.
                    find cheque where cheque.chenum = vnum and
                                      cheque.cheban = vban and
                                      cheque.cheage = vage no-error.
                    if not avail cheque
                    then do:
                        message "Cheque nao Cadastrado".
                        undo, retry.
                    end.
                    else recatu1 = recid(cheque).
                end.
                /* recatu1 = recatu2. */
                leave.
            end.
            if esqcom1[esqpos1] = "Pagamento"
            then do transaction:
                display cheque.clicod
                        cheque.nome no-label with frame f-cli side-label
                                    row 4 color withe/red no-box centered.
                display cheque.chenum colon 10
                        cheque.cheban colon 40
                        cheque.cheage colon 60
                        cheque.cheemi colon 10
                        cheque.cheven colon 40
                        cheque.cheval colon 60
                                      with frame f-pag1 color black/cyan
                                            width 80 side-label.

                if cheque.chesit = "PAG"
                then do:
                    message "Cheque ja esta pago, deseja liberar?" update sresp.
                    if sresp
                    then cheque.chesit = "LIB".
                         cheque.chepag = ?.
                         cheque.chejur = 0.
                end.
                else do:
                    cheque.chesit = "PAG".
                    update cheque.chepag label "Data Pagamento"
                           cheque.chejur label "Vl.Juros"
                                 with frame f-pag
                                    1 column color black/cyan overlay centered.
                    display (cheque.cheval + cheque.chejur) label "Valor Pago"
                                with frame f-pag.
                    leave.
                end.
            end.
          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end.
          view frame frame-a .
        end.
        if keyfunction (lastkey) = "end-error"
         then view frame frame-a.
        hide frame f-cli no-pause.

        display cheque.nome
                cheque.chenum
                cheque.cheven
                cheque.cheval with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(cheque).
   end.
end.
