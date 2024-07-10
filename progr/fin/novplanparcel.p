/*               to                   sfpl
*                                 R
*
*/

{admcab.i}

def input param par-rec as recid. 
    
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" altera "," "," "," "," "].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def buffer bnovplanparcel for novplanparcel.
find novplanos where recid(novplanos) = par-rec no-lock.

    form  
        
        novplanparcel.titpar
        novplanparcel.perc_parcel

        with frame frame-a 7 down centered row 9
            title novplanos.planom overlay.

def var vqtdparcel as int.
def var vi as int.
find first novplanparcel of novplanos no-lock no-error.
if avail novplanparcel
then do:
    vqtdparcel = 0. 
    for each novplanparcel of novplanos no-lock.
        vqtdparcel = vqtdparcel + 1.
    end.
    if novplanos.com_entrada
    then do:
        if novplanos.qtd_vezes + 1 = vqtdparcel
        then.
        else do:
            for each novplanparcel of novplanos.
                delete novplanparcel.
            end.    
        end.
    end.
    else do:
        if novplanos.qtd_vezes = vqtdparcel
        then.
        else do:
            for each novplanparcel of novplanos.
                delete novplanparcel.
            end.    
        end.

    end.
end.
def var vtotal as dec format "->>>>9.99".

find first novplanparcel of novplanos no-lock no-error.
if not avail novplanparcel
then do:
    vtotal = 100.
    do vi = 1 to novplanos.qtd_vezes.
        create novplanparcel.
        novplanparcel.camcod = novplanos.camcod.
        novplanparcel.planom = novplanos.planom.
        novplanparcel.titpar = vi.
        novplanparcel.perc_parcel = vtotal / novplanos.qtd_vezes.
    end.
    
    
end.
    vtotal = 0.
    for each novplanparcel of novplanos no-lock.
        vtotal = vtotal + novplanparcel.perc_parcel.
    end.        
    

bl-princ:
repeat:

    disp vtotal no-label
        with frame ftotal
        row screen-lines - 1
        centered
        side-labels no-box.
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find novplanparcel where recid(novplanparcel) = recatu1 no-lock.
    if not available novplanparcel
    then do.
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(novplanparcel).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available novplanparcel
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find novplanparcel where recid(novplanparcel) = recatu1 no-lock.

        status default "".
        
                        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field novplanparcel.titpar

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
                    if not avail novplanparcel
                    then leave.
                    recatu1 = recid(novplanparcel).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail novplanparcel
                    then leave.
                    recatu1 = recid(novplanparcel).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail novplanparcel
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail novplanparcel
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            

            if esqcom1[esqpos1] = " altera"
            then do:
                run paltera.
                find novplanparcel where recid(novplanparcel) = recatu1 no-lock.
                leave.
            end.
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(novplanparcel).
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
        novplanparcel.titpar
        novplanparcel.perc_parcel
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        novplanparcel.titpar
        novplanparcel.perc_parcel

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        novplanparcel.titpar
        novplanparcel.perc_parcel
        
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
                novplanparcel.titpar
        novplanparcel.perc_parcel

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first novplanparcel  of novplanos
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next novplanparcel  of novplanos
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev novplanparcel of novplanos
                no-lock no-error.

end.    
        
end procedure.



procedure paltera.

    do on error undo:

        find current novplanparcel exclusive.
        update  novplanparcel.perc_parcel
            with frame frame-a.
        vtotal = 100. 
        for each bnovplanparcel of novplanos where 
            bnovplanparcel.titpar <= novplanparcel.titpar and
            bnovplanparcel.titpar > 0. 
            vtotal = vtotal - bnovplanparcel.perc_parcel.
        end. 
        vqtdparcel = 0. 
        for each bnovplanparcel of novplanos where
                bnovplanparcel.titpar > novplanparcel.titpar.
            vqtdparcel = vqtdparcel + 1.                
        end.

        if vtotal <= 0 or vqtdparcel = 0
        then do:
            novplanparcel.perc_parcel = novplanparcel.perc_parcel + vtotal.
            vtotal = 100.
            for each bnovplanparcel of novplanos where
                    bnovplanparcel.titpar <= novplanparcel.titpar and
                    bnovplanparcel.titpar > 0.
                vtotal = vtotal - bnovplanparcel.perc_parcel.
            end. 
            
        end.

        for each bnovplanparcel of novplanos where
                bnovplanparcel.titpar > novplanparcel.titpar.
            bnovplanparcel.perc_parcel = vtotal / vqtdparcel.
        end.
    end.    
    
    vtotal = 0.
    for each novplanparcel of novplanos where
            novplanparcel.titpar > 0 no-lock.
        vtotal = vtotal + novplanparcel.perc_parcel.
    end.        

    pause 0.
    disp vtotal 
    with frame ftotal.
    pause 0.
    
end.



