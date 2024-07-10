
{admcab.i}

def input param prec as recid.

def buffer bbauplan for bauplan.
    
def var xtime as int.
def var vconta as int.



def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" inclusao "," moedas"," exclusao"," -"].




form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

find first bauprodu where recid(bauprodu) = prec no-lock.
    disp
        bauprodu.tiposervico
        bauprodu.procod
            with frame frame-cab centered row 3 no-box
            no-labels.



    form  
        
        bauplan.fincod
        finan.finnom        
        bauplan.moedaspdv        
        with frame frame-a 8 down centered row 8
        no-box.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find bauplan where recid(bauplan) = recatu1 no-lock.
    if not available bauplan
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(bauplan).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available bauplan
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find bauplan where recid(bauplan) = recatu1 no-lock.

        status default "".
        
        if bauplan.fincod = 0
        then esqcom1[2] = " moedas".
        else esqcom1[2] = "".
        
                disp esqcom1 with frame f-com1.
        
        
        run color-message.
            
        choose field bauplan.fincod

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
                    if not avail bauplan
                    then leave.
                    recatu1 = recid(bauplan).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail bauplan
                    then leave.
                    recatu1 = recid(bauplan).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail bauplan
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail bauplan
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
            if esqcom1[esqpos1] = " moedas "
            then do:
                hide frame f-com1 no-pause.
                run pmoedas.
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
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run fin/novplano.p (recid(bauplan)).
                
            end. 
            if esqcom1[esqpos1] = " filiais "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run fin/novestab.p (recid(bauplan)).
                
            end. 
            
            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(bauplan).
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
    find finan of bauplan no-lock no-error.
    display  
        bauplan.fincod
            finan.finnom  when avail finan       
        bauplan.moedaspdv        
            
        finan.finnpc
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        bauplan.fincod
        finan.finnom  
        bauplan.moedaspdv        

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        bauplan.fincod
        finan.finnom 
        bauplan.moedaspdv        
        
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        bauplan.fincod
        finan.finnom 
        bauplan.moedaspdv        
        
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first bauplan  where bauplan.tiposervico = bauprodu.tiposervico 
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next bauplan  where bauplan.tiposervico = bauprodu.tiposervico 

                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev bauplan  where bauplan.tiposervico = bauprodu.tiposervico 

                no-lock no-error.

end.    
        
end procedure.



procedure pinclui.
def output param prec as recid.
do on error undo.

    create bauplan.
    prec = recid(bauplan).
    bauplan.tiposervico = bauprodu.tiposervico.
        update bauplan.fincod            
        with centered row 8 side-labels.
    
    find finan where finan.fincod = bauplan.fincod no-error.
    if not avail finan
    then do:
        message "plano invalido".
        undo, return.
    end.        
                    
    disp finan.finnom.
                        
    pause 3.                        



end.


end procedure.



procedure pmoedas.
do on error undo.

    find current bauplan exclusive no-wait no-error.
    update bauplan.moedaspdv
        with centered row 8 side-labels.
    
    pause 3.                        

end.


end procedure.






procedure pexclui.
sresp = yes.
message color normal "confirma?" update sresp.
if sresp
then do on error undo:
    find current bauplan exclusive no-wait no-error.
    if avail bauplan
    then do:
        delete bauplan.    
    end.        
end.
end procedure.
