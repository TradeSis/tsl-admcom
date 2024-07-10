/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def var recatu1         as recid.
def var reccont         as int.
def var vinicio         as log.
def var recatfeu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bfinpro       for finpro.
def input parameter      vfincod         like finpro.fincod.


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

    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first finpro where
            finpro.fincod = vfincod no-error.
    else
        find finpro where recid(finpro) = recatu1.
    vinicio = yes.
    if not available finpro
    then do:
        message "Cadastro de Produtos  Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1 overlay row 6 1 column centered.
            create finpro.
            update finpro.procod.
            find produ where produ.procod = finpro.procod no-lock no-error.
            if not avail produ
            then do:
                message "Produto nao Cadastrado".
                undo, retry.
            end.
            finpro.fincod = vfincod.
            vinicio = no.

        end.
    end.
    clear frame frame-a all no-pause.
    find produ where produ.procod = finpro.procod no-lock no-error.
    display finpro.procod
            produ.pronom column-label "Descricao"
                with frame frame-a 14 down centered.

    recatu1 = recid(finpro).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next finpro where finpro.fincod = vfincod.
        if not available finpro
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
        find produ where produ.procod = finpro.procod no-lock no-error.
        display finpro.procod 
                produ.pronom with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find finpro where recid(finpro) = recatu1.

        run color-message.
        choose field finpro.procod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        run color-normal.
        
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

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next finpro where finpro.fincod = vfincod no-error.
                if not avail finpro
                then leave.
                recatu1 = recid(finpro).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev finpro where finpro.fincod = vfincod no-error.
                if not avail finpro
                then leave.
                recatu1 = recid(finpro).
            end.
            leave.
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
            find next finpro where
                finpro.fincod = vfincod no-error.
            if not avail finpro
            then next.
            color display normal
                finpro.procod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev finpro where
                finpro.fincod = vfincod no-error.
            if not avail finpro
            then next.
            color display normal
                finpro.procod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then return. /* leave bl-princ. */

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.
                create finpro.
                update finpro.procod.
                find produ where produ.procod = finpro.procod no-lock.
                finpro.fincod = vfincod.
                recatu1 = recid(finpro).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update finpro.procod
                    with frame f-altera no-validate.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp finpro with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" finpro.procod update sresp.
                if not sresp
                then leave.
                find next finpro where finpro.fincod = vfincod no-error.
                if not available finpro
                then do:
                    find finpro where recid(finpro) = recatu1.
                    find prev finpro where finpro.fincod = vfincod no-error.
                end.
                recatu2 = if available finpro
                          then recid(finpro)
                          else ?.
                find finpro where recid(finpro) = recatu1.
                delete finpro.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de finproidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each finpro:
                    display finpro.
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
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a. 
        display finpro.procod
                produ.pronom with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(finpro).
   end.
end.

procedure color-message.
color display message
        finpro.procod
        produ.pronom
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        finpro.procod
        produ.pronom
        with frame frame-a.
end procedure.

