/* #082022 helio bau */
{admcab.i }

def input param ptitle as char.
def buffer bbauprodu for bauprodu.

    
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" parametros "," planos" , "  "," "," -"].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

    form  
      bauprodu.procod
      bauprodu.tiposervico
        bauprodu.serieLebes      

       with frame frame-a 8 down centered row 8
       title ptitle.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find bauprodu where recid(bauprodu) = recatu1 no-lock.
    if not available bauprodu
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(bauprodu).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available bauprodu
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find bauprodu where recid(bauprodu) = recatu1 no-lock.

        status default "".
        
        if false
        then esqcom1[5] = " exclusao".
        else esqcom1[5] = "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field bauprodu.tiposervico

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
                    if not avail bauprodu
                    then leave.
                    recatu1 = recid(bauprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail bauprodu
                    then leave.
                    recatu1 = recid(bauprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail bauprodu
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail bauprodu
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            

            if esqcom1[esqpos1] = " parametros "
            then do:
                hide frame f-com1 no-pause.

                run pparametros.    
                leave.
            end.
            if esqcom1[esqpos1] = " inclusao "
            then do:
                hide frame f-com1 no-pause.
                run pinclui (output recatu1).
                run pparametros.
                leave.
                
            end. 
            if esqcom1[esqpos1] = " exclusao "
            then do:
                run color-message.

                run pexclui.
                recatu1 = ?.
                leave.
            end. 
            if esqcom1[esqpos1] = " planos "
            then do:
            
                run bau/bauplan.p (input recid(bauprodu)).
            
            end.        
            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(bauprodu).
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
    find produ of bauprodu no-lock.
    
    display  
      bauprodu.procod
      bauprodu.tiposervico
    bauprodu.serieLebes      

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
      bauprodu.procod
      bauprodu.tiposervico
               bauprodu.serieLebes

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
      bauprodu.procod
      bauprodu.tiposervico
               bauprodu.serieLebes

        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
      bauprodu.procod
      bauprodu.tiposervico
               bauprodu.serieLebes

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first bauprodu  
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next bauprodu  
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev bauprodu  
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo
     with 1 col
                 row 8
                             centered
                                            overlay.
                                            

        find current bauprodu exclusive.
        
        update bauprodu.procod.
        update bauprodu.serieLebes.

    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    find last bbauprodu no-lock no-error.
    create bauprodu.

    prec = recid(bauprodu).
    
    update
        bauprodu.tiposervico = "JEQUITI"
        bauprodu.procod
        bauprodu.serieLebes        
        with row 9 
        centered
        overlay 1 column.

        find produ where produ.procod = bauprodu.procod no-lock no-error.
        if not avail produ        
        then do:
            message "produto nao cadastrado".
            undo.
        end.    
    


end.


end procedure.



procedure pexclui.
sresp = yes.
message color normal "confirma?" update sresp.
if sresp
then do on error undo:
    find current bauprodu exclusive no-wait no-error.
    if avail bauprodu
    then delete bauprodu.
end.
end procedure.
