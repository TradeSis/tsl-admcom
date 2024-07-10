def output parameter    vmoecod like moeda.moecod.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bMOEDA       for MOEDA.


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

    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then find first MOEDA where
            moeda.moetit = yes no-error.
    else
        find MOEDA where recid(MOEDA) = recatu1.
    if not available MOEDA
    then do:
        message "Nenhum cartao cadastrado".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.
    display moenom FORMAT "x(20)" no-label
            with frame frame-a 4 down overlay
                centered row 15.

    recatu1 = recid(MOEDA).
    repeat:
        find next MOEDA where moeda.moetit = yes no-lock.
        if not available MOEDA
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        display moenom
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find MOEDA where recid(MOEDA) = recatu1.

        choose field MOEDA.MOEnom
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  tab PF4 F4 ESC return).
    
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next MOEDA where
                moeda.moetit = yes no-error.
            if not avail MOEDA
            then next.
            color display white/red
                MOEDA.MOEnom.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev MOEDA where
                moeda.moetit = yes no-error.
            if not avail MOEDA
            then next.
            color display white/red
                MOEDA.MOEnom.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            vmoecod = "".
            hide frame frame-a no-pause.
            leave bl-princ.
        end.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
            hide frame frame-a no-pause.
            vmoecod = moeda.moecod.
            return.
        end.    
        /*
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        */
        display moeda.moenom 
                    with frame frame-a.
        recatu1 = recid(moeda).
   end.
end.
