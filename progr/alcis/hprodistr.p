/* alcis/hprodistr.p */
/* Projeto Melhorias Mix - Luciano    */

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5.

{admcab.i}
def input parameter par-rec as recid.

find prodistr where recid(prodistr) = par-rec no-lock.
find produ of prodistr no-lock.
disp produ.procod
    produ.pronom no-label
    prodistr.lipqtd label "Reservada"
    prodistr.preqtent label "Utilizada"
    with frame f-produ side-label row 3 no-box color message.

form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find hprodistr where recid(hprodistr) = recatu1 no-lock.
    if not available hprodistr
    then do.
        message "Sem historico" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(hprodistr).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available hprodistr
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find hprodistr where recid(hprodistr) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field hprodistr.data help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.

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
                    if not avail hprodistr
                    then leave.
                    recatu1 = recid(hprodistr).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail hprodistr
                    then leave.
                    recatu1 = recid(hprodistr).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail hprodistr
                then next.
                color display white/red hprodistr.data with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail hprodistr
                then next.
                color display white/red hprodistr.data with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(hprodistr).
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
    display hprodistr.data
        string(hprodistr.hora,"HH:MM:SS") label "Hora" format "x(8)"
/*        hprodistr.lipqtd   format ">>>>>>9"  label "Reserv" */
        hprodistr.preqtent format ">>>>>>9"  label "Utilizada"
        hprodistr.proposta format "x(40)" column-label ""        
        with frame frame-a 11 down centered color white/red row 7 overlay.
end procedure.

procedure color-message.
color display message
        hprodistr.data
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        hprodistr.data
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first hprodistr where of prodistr no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next hprodistr  where of prodistr no-lock no-error.
             
if par-tipo = "up" 
then find prev hprodistr where of prodistr   no-lock no-error.
        
end procedure.
         
