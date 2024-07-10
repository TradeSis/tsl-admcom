/*
*
*    tt-movim.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def shared temp-table tt-movim like movim.

def var vprotot   like  plani.protot.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
    initial [""," Alteracao ",""].

form
    esqcom1
    with frame f-com1
                 row 12 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-movim where recid(tt-movim) = recatu1 no-lock.
    if not available tt-movim
    then leave.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(tt-movim).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tt-movim
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            vprotot = 0.
            for each tt-movim no-lock.
                vprotot = vprotot + (tt-movim.movqtm * tt-movim.movpc).
            end.
            disp vprotot label "Total"
                 with frame f-sub row screen-lines side-label no-box.

            find tt-movim where recid(tt-movim) = recatu1 no-lock.
            find produ of tt-movim no-lock.

            status default "".

            run color-message.
            choose field tt-movim.procod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
            run color-normal.
            status default "".

            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-movim
                    then leave.
                    recatu1 = recid(tt-movim).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-movim
                    then leave.
                    recatu1 = recid(tt-movim).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-movim
                then next.
                color display white/red tt-movim.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-movim
                then next.
                color display white/red tt-movim.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Alteracao "
                then do with frame frame-a on error undo.
                    find tt-movim where recid(tt-movim) = recatu1 exclusive.
                    update tt-movim.movpc.
                end.
        end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-movim).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    find produ of tt-movim no-lock.
    display
        tt-movim.movseq
        tt-movim.procod
        produ.pronom format "x(30)"
        tt-movim.movqtm  column-label "Qtde" format ">>>9.99"
        tt-movim.movpc   format ">>>9.99"
        tt-movim.movqtm * tt-movim.movpc column-label "Total"
                    format ">>>>9.99"
        with frame frame-a 4 down centered color white/red row 13.
end procedure.

procedure color-message.
    color display message
        tt-movim.movseq
        tt-movim.procod
        produ.pronom
        tt-movim.movpc
        tt-movim.movqtm
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        tt-movim.movseq
        tt-movim.procod
        produ.pronom
        tt-movim.movpc
        tt-movim.movqtm
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then   find first tt-movim  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then   find next tt-movim   no-lock no-error.
             
if par-tipo = "up" 
then   find prev tt-movim   no-lock no-error.
        
end procedure.

