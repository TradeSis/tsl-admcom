/*
*
*    cmon.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial [""," Pesquisa",""].
def buffer bcmon for cmon.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find cmon where recid(cmon) = recatu1 no-lock.
    if not available cmon
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(cmon).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available cmon
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
            find cmon where recid(cmon) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field cmon.etbcod help ""
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
                    if not avail cmon
                    then leave.
                    recatu1 = recid(cmon).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cmon
                    then leave.
                    recatu1 = recid(cmon).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cmon
                then next.
                color display white/red cmon.etbcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cmon
                then next.
                color display white/red cmon.etbcod with frame frame-a.
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
            if esqcom1[esqpos1] = " Pesquisa "
            then do with frame f-pesq side-label.
                prompt-for cmon.etbcod label "Estab".
                find first bcmon where bcmon.etbcod = input cmon.etbcod
                        no-lock no-error.
                if avail bcmon
                then recatu1 = recid(bcmon).
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(cmon).
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
    find estab of cmon no-lock no-error.
    display
        cmon.etbcod column-label "Estab"
        estab.ufecod when avail estab
        estab.munic  when avail estab
        cmon.cxacod column-label "Caixa"
        cmon.cxanom
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
color display message
        cmon.etbcod
        cmon.cxacod
        cmon.cxanom
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        cmon.etbcod
        cmon.cxacod
        cmon.cxanom
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
        find first cmon where true
                                                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
        find next cmon  where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
        find prev cmon where true  
                                        no-lock no-error.
        
end procedure.
         
