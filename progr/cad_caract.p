/*
*
*    caract.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(15)" extent 3
    initial ["Sub-Caracterist"," Inclusao "," Alteracao "].

def buffer bcaract       for caract.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find caract where recid(caract) = recatu1 no-lock.
    if not available caract
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(caract).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available caract
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find caract where recid(caract) = recatu1 no-lock.
            run cad_subcaract.p ("Consulta", recid(caract)).

            status default "".

            run color-message.
            choose field caract.carcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 3 then 3 else esqpos1 + 1.
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
                    if not avail caract
                    then leave.
                    recatu1 = recid(caract).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail caract
                    then leave.
                    recatu1 = recid(caract).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail caract
                then next.
                color display white/red caract.carcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail caract
                then next.
                color display white/red caract.carcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame frame-a on error undo.
                    clear frame frame-a.
                    find last bcaract no-lock no-error.
                    prompt-for caract.cardes.
    
                    find first caract where caract.cardes = input caract.cardes
                             no-lock no-error.
                    if not available caract
                    then do:
                        create caract.
                        assign 
                           caract.cardes = caps(input caract.cardes)
                           caract.carcod = if avail bcaract
                                           then bcaract.carcod + 1
                                           else 1.
                        recatu1 = recid(caract).
                    end.
                    else message "Ja' existe a ocorrencia no Sistema"
                                view-as alert-box.
                    leave.
                end.

                if esqcom1[esqpos1] = " Alteracao "
                then do with frame frame-a on error undo.
                    find caract where recid(caract) = recatu1 exclusive.
                    update caract.cardes.
                end.
                if esqcom1[esqpos1] = "Sub-Caracterist"
                then do.
                    hide frame f-com1 no-pause.
                    run cad_subcaract.p ("Manut", recid(caract)).
                    view frame f-com1.
                end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(caract).
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

display
    caract.carcod column-label "Cod."
    caract.cardes
        with frame frame-a 11 down color white/red row 5.
end procedure.


procedure color-message.
    color display message
        caract.carcod
        caract.cardes
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        caract.carcod
        caract.cardes
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then   find first caract where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then   find next caract  where true no-lock no-error.
             
if par-tipo = "up" 
then   find prev caract where true   no-lock no-error.
        
end procedure.
         
