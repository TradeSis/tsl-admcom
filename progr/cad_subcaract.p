/*
*
*    subcaract.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-oper as char.
def input parameter par-rec  as recid.

find caract where recid(caract) = par-rec no-lock.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 3
    initial [" Inclusao "," Alteracao "," "].

def buffer bsubcaract       for subcaract.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 40.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    if par-oper <> "Consulta"
    then disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find subcaract where recid(subcaract) = recatu1 no-lock.
    if not available subcaract
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(subcaract).
    if par-oper <> "Consulta"
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available subcaract
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.
    if par-oper = "Consulta"
    then return.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find subcaract where recid(subcaract) = recatu1 no-lock.

            status default "".

            run color-message.
            choose field subcaract.subcod help ""
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
                    if not avail subcaract
                    then leave.
                    recatu1 = recid(subcaract).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail subcaract
                    then leave.
                    recatu1 = recid(subcaract).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail subcaract
                then next.
                color display white/red subcaract.subcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail subcaract
                then next.
                color display white/red subcaract.subcod with frame frame-a.
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
                    find last bsubcaract no-lock.
                    create subcaract.
                    assign
                        subcaract.carcod = caract.carcod
                        subcaract.subcod = bsubcaract.subcod + 1
                        subcaract.subcar = subcaract.subcod.
                    disp subcaract.subcod.
                    update subcaract.subdes.
                    recatu1 = recid(subcaract).
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame frame-a on error undo.
                    find subcaract where recid(subcaract) = recatu1 exclusive.
                    update subcaract.subdes.
                end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(subcaract).
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
        subcaract.subcod column-label "Cod"
        subcaract.subdes
        with frame frame-a 11 down color white/red row 5 col 40
            title caract.cardes.
end procedure.


procedure color-message.
    color display message
        subcaract.subcod
        subcaract.subdes
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        subcaract.subcod
        subcaract.subdes
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first subcaract of caract no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next subcaract  of caract no-lock no-error.
             
if par-tipo = "up" 
then find prev subcaract of caract   no-lock no-error.
        
end procedure.
