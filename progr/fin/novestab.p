/*               to                   sfpl
*                                 R
*
*/

{admcab.i}

def input param par-rec as recid. 
def buffer bnovestab for novestab.
    
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" inclusao"," exclusao  ","-"," "].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


find novcampanha where recid(novcampanha) = par-rec no-lock.

    form  
        
        novestab.etbcod
        
        with frame frame-a 8 down centered row 8
            title novcampanha.camnom.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find novestab where recid(novestab) = recatu1 no-lock.
    if not available novestab
    then do.
        hide frame frame-a no-pause.
        message "sem nenhuma filial definida, a campanha vale para todas as filiais".
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(novestab).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available novestab
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find novestab where recid(novestab) = recatu1 no-lock.

        status default "".
        
                        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field novestab.etbcod

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

                run color-normal.
        hide message no-pause.
                 
        pause 0. 

                                                                
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
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
                    if not avail novestab
                    then leave.
                    recatu1 = recid(novestab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail novestab
                    then leave.
                    recatu1 = recid(novestab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail novestab
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail novestab
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            

            if esqcom1[esqpos1] = " exclusao "
            then do:
                run pexclui.    
                recatu1 = ?.
                leave.
            end.
            if esqcom1[esqpos1] = " inclusao "
            then do:
                hide frame f-com1 no-pause.
                run pinclui (output recatu1).
                leave.
                
            end. 
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(novestab).
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
    find estab where estab.etbcod = novestab.etbcod no-lock.
    display  
        novestab.etbcod
        estab.etbnom
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        novestab.etbcod
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        novestab.etbcod
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        novestab.etbcod

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first novestab  of novcampanha
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next novestab  of novcampanha
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev novestab of novcampanha
                no-lock no-error.

end.    
        
end procedure.



procedure pexclui.

    do on error undo:

        find current novestab exclusive.
        delete novestab.
    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    find last bnovestab no-lock no-error.
    create novestab.
    prec = recid(novestab).
    novestab.camcod = novcampanha.camcod.
    
    update
        novestab.etbcod
        with row 9 
        centered
        overlay.

    find estab where estab.etbcod = novestab.etbcod no-lock no-error.
    if not avail estab
    then do:
        message "filial nao cadastrada".
        pause.
        undo.
    end.
end.


end procedure.


