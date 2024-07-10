/*               to                   sfpl
*                                 R
*
*/

{admcab.i}
def buffer btermos for termos.
    
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" termo "," parametros ", " inclusao "," exclusao"," -"].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

    form  
        
        termos.idtermo
        termos.termoNome 
        termos.termoCopias
        with frame frame-a 8 down centered row 8
        no-box.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find termos where recid(termos) = recatu1 no-lock.
    if not available termos
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(termos).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available termos
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find termos where recid(termos) = recatu1 no-lock.

        status default "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field termos.termoNome

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
                    if not avail termos
                    then leave.
                    recatu1 = recid(termos).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail termos
                    then leave.
                    recatu1 = recid(termos).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail termos
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail termos
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
                leave.
                
            end. 
            if esqcom1[esqpos1] = " exclusao "
            then do:
                run color-message.

                run pexclui.
                recatu1 = ?.
                leave.
            end. 
            
            
            if esqcom1[esqpos1] = " termo "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run termo/editor.p (recid(termos)).
                
            end. 
            
            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(termos).
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
        termos.termoNome
        termos.idtermo
        termos.termoCopias
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        termos.termoNome
        termos.idtermo
        termos.termoCopias

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        termos.termoNome
        termos.idtermo
        termos.termoCopias
        
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        termos.termoNome
        termos.idtermo
        termos.termoCopias
        
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first termos  where
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next termos  where
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev termos  where
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo:

        find current termos exclusive.
        disp    
        termos.idtermo 
        termos.termoNome 

        termos.termoCopias
                   with row 9 
        centered
        overlay 1 column.
                    
        update
            termos
                except termos.idtermo termos.termo.
        
    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    create termos.        
    prec = recid(termos).
    disp    
        termos.IDtermo 
        termos.termoNome 

        termos.termoCopias
                   with row 9 
        centered
        overlay 1 column.
    
    update
        termos.idtermo
        termos.termoNome
        termos.termoCopias
        with row 9 
        centered
        overlay 1 column.


end.


end procedure.



procedure pexclui.
sresp = yes.
message color normal "confirma?" update sresp.
if sresp
then do on error undo:
    find current termos exclusive no-wait no-error.
    if avail termos
    then do:
        delete termos.    
    end.        
end.
end procedure.
