/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
  initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem","Procura"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bfabri       for fabri.
def var vfabcod         like fabri.fabcod.


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
        find first fabri where
            true no-error.
    else
        find fabri where recid(fabri) = recatu1.
        vinicio = yes.
    if not available fabri
    then do:
        message "Cadastro de Fabricantes Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
                create fabri.
                update fabnom.
                assign fabfant = substr(fabnom,1,13).
                update fabfant.
                find last bfabri exclusive-lock no-error.
                if available bfabri
                then assign vfabcod = bfabri.fabcod.
                else assign vfabcod = 0.
                {di.v 2 "vfabcod"}
                assign fabri.fabcod = vfabcod.
        vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    display
        fabri.fabcod
        fabri.fabnom
        fabri.fabfant
        fabri.fabdtcad
            with frame frame-a 14 down centered.

    recatu1 = recid(fabri).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next fabri where
                true.
        if not available fabri
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then
        down
            with frame frame-a.
        display
            fabri.fabcod
            fabri.fabnom
            fabri.fabfant
            fabri.fabdtcad
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find fabri where recid(fabri) = recatu1.

        choose field fabri.fabnom
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
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
                esqpos2 = if esqpos2 = 6
                          then 6
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
                find next fabri where true no-error.
                if not avail fabri
                then leave.
                recatu1 = recid(fabri).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev fabri where true no-error.
                if not avail fabri
                then leave.
                recatu1 = recid(fabri).
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
            find next fabri where
                true no-error.
            if not avail fabri
            then next.
            color display normal
                fabri.fabnom.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev fabri where
                true no-error.
            if not avail fabri
            then next.
            color display normal
                fabri.fabnom.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame  frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.
                /*
                create fabri.
                update fabri.fabnom.
                assign fabri.fabfant = substr(fabri.fabnom,1,13).
                update fabri.fabfant.
                update fabri.repcod label "Repres.".
                find repre where repre.repcod = fabri.repcod no-lock no-error.
                if  avail repre
                then display repre.repnom no-label.
                find last bfabri exclusive-lock no-error.
                if available bfabri
                then assign vfabcod = bfabri.fabcod.
                else assign vfabcod = 0.
                {di.v 1 "vfabcod"}
                assign fabri.fabcod = vfabcod.
                recatu1 = recid(fabri).
                */
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                /*
                update fabri.fabnom.
                update fabri.fabfant.
                update fabri.repcod label "Repres.".
                find repre where repre.repcod = fabri.repcod
                                                no-lock no-error.
                if avail repre
                then display repre.repnom no-label.
                find forne where forne.forcod = fabri.fabcod no-error.
                if avail forne
                then forne.repcod = fabri.repcod.
                */
            end.
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp fabri.fabcod format ">>>>>>>>9"
                            with frame f-consulta.
                disp fabri with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" fabri.fabnom update sresp.
                if not sresp
                then leave.
                find next fabri where true no-error.
                if not available fabri
                then do:
                    find fabri where recid(fabri) = recatu1.
                    find prev fabri where true no-error.
                end.
                recatu2 = if available fabri
                          then recid(fabri)
                          else ?.
                find fabri where recid(fabri) = recatu1.
                delete fabri.
                recatu1 = recatu2.
                leave.
            end.

            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de Fabricantes" update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each fabri:
                    display fabri.
                end.
                output close.
                recatu1 = recatu2.
                leave.
            end.
            
            if esqcom1[esqpos1] = "Procura"
            then do with frame f-procura overlay row 6 1 column centered.
                update vfabcod format ">>>>>>>>9" 
                        with frame f-for centered row 15 overlay.
                find fabri where fabri.fabcod = vfabcod no-lock.
                recatu1 = recid(fabri).
                leave.
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end.
          view frame frame-a.
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        display
                fabri.fabcod format ">>>>>>>>9"
                fabri.fabnom
                fabri.fabfant
                fabri.fabdtcad
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(fabri).
   end.
end.
