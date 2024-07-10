/*
*
*    MANUTENCAO EM PLANOS DE CONTA                         piso.p  02/05/95
*
*/

{admcab.i}
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(15)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].


def buffer bpiso       for piso.
def var vetbcod         like piso.etbcod.


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

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first piso where
            true no-error.
    else
        find piso where recid(piso) = recatu1.
    if not available piso
    then do:
        form
            with frame f-altera
            overlay row 6 2 column centered color white/cyan.
        message "Cadastro de pisoelecimento Vazio".
        message "Deseja Incluir "  update sresp.
        if not sresp
        then undo.
        do with frame f-altera:
            create piso.
            update  piso.etbcod
                    piso.pismes
                    piso.pisdia
                    piso.pisrep
                    piso.pisval.
        end.
    end.
    clear frame frame-a all no-pause.

    display piso.etbcod column-label "Filial"
            piso.pismes column-label "Mes"
            piso.pisdia column-label "Dias Trab."
            piso.pisrep column-label "Repouso"
            piso.pisval column-label "Piso"
                with frame frame-a 14 down centered color white/red.

    recatu1 = recid(piso).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next piso where
                true.
        if not available piso
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.

        display piso.etbcod
                piso.pismes
                piso.pisdia
                piso.pisrep
                piso.pisval with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find piso where recid(piso) = recatu1.

        choose field piso.etbcod
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
                find next piso where
                    true no-error.
                if not avail piso
                then leave.
                recatu2 = recid(piso).
            end.
            if reccont = frame-down(frame-a)
            then recatu1 = recatu2.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev piso where
                    true no-error.
                if not avail piso
                then leave.
                recatu1 = recid(piso).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next piso where
                true no-error.
            if not avail piso
            then next.
            color display white/red
                piso.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev piso where
                true no-error.
            if not avail piso
            then next.
            color display white/red
                piso.etbcod.
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
            then do with frame f-altera.

                create piso.
                update  piso.etbcod
                        piso.pismes
                        piso.pisdia
                        piso.pisrep
                        piso.pisval.
                recatu1 = recid(piso).
                leave.
            end.
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao" or
               esqcom1[esqpos1] = "Alteracao" or
               esqcom1[esqpos1] = "Listagem"
            then do with frame f-altera:
                disp  piso.etbcod
                      piso.pismes
                      piso.pisdia
                      piso.pisrep
                      piso.pisval.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera:
                update piso.etbcod
                       piso.pismes
                       piso.pisdia
                       piso.pisrep
                       piso.pisval.

            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-altera:
                message "Confirma Exclusao de" piso.pismes update sresp.
                if not sresp
                then undo.
                find next piso where true no-error.
                if not available piso
                then do:
                    find piso where recid(piso) = recatu1.
                    find prev piso where true no-error.
                end.
                recatu2 = if available piso
                          then recid(piso)
                          else ?.
                find piso where recid(piso) = recatu1.
                delete piso.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do:
                message "Confirma Impressao do pisoelecimento" update sresp.
                if not sresp
                then undo.
                recatu2 = recatu1.
                output to printer.
                for each piso:
                    display piso.
                end.
                output close.
                recatu1 = recatu2.
                leave.
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

        display piso.etbcod
                piso.pismes
                piso.pisdia
                piso.pisrep
                piso.pisval with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(piso).
   end.
end.
