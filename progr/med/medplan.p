
{admcab.i}

def input param par-procod as int.

def buffer bmedplan for medplan.
    
def var xtime as int.
def var vconta as int.



def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" inclusao "," exclusao"," -"].




form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

find first medprodu where medprodu.procod = par-procod no-lock.
find produ of medprodu no-lock.
    disp
        medprodu.procod
        produ.pronom
        medprodu.idmedico
            with frame frame-cab centered row 3 no-box
            no-labels.



    form  
        
        medplan.fincod
        finan.finnom        
        
        with frame frame-a 8 down centered row 8
        no-box.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find medplan where recid(medplan) = recatu1 no-lock.
    if not available medplan
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(medplan).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available medplan
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find medplan where recid(medplan) = recatu1 no-lock.

        status default "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field medplan.fincod

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
                    if not avail medplan
                    then leave.
                    recatu1 = recid(medplan).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail medplan
                    then leave.
                    recatu1 = recid(medplan).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail medplan
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail medplan
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
            if esqcom1[esqpos1] = " alteracao "
            then do:
                hide frame f-com1 no-pause.
                run paltera.
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
                run fin/novplano.p (recid(medplan)).
                
            end. 
            if esqcom1[esqpos1] = " filiais "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run fin/novestab.p (recid(medplan)).
                
            end. 
            
            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(medplan).
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
    find finan of medplan no-lock no-error.
    display  
        medplan.fincod
            finan.finnom  when avail finan       
        finan.finnpc
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        medplan.fincod
        finan.finnom  

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        medplan.fincod
        finan.finnom 
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        medplan.fincod
        finan.finnom 
        
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first medplan  where medplan.procod = par-procod 
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next medplan  where medplan.procod = par-procod 

                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev medplan  where medplan.procod = par-procod 

                no-lock no-error.

end.    
        
end procedure.



procedure pinclui.
def output param prec as recid.
do on error undo.

    create medplan.
    prec = recid(medplan).
    medplan.procod = par-procod.
        update medplan.fincod            
        with centered row 8 side-labels.
    
    find finan where finan.fincod = medplan.fincod no-error.
    if not avail finan
    then do:
        message "plano invalido".
        undo, return.
    end.        
                    
    disp finan.finnom.
                        
    pause 3.                        



end.


end procedure.





procedure pexclui.
sresp = yes.
message color normal "confirma?" update sresp.
if sresp
then do on error undo:
    find current medplan exclusive no-wait no-error.
    if avail medplan
    then do:
        delete medplan.    
    end.        
end.
end procedure.
