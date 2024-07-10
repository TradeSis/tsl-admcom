/*
*
*    cobfil.p    -    Esqueleto de Programacao    com esqvazio
*
*/

{admcab.i}
def var par-loja   as log init yes.
par-loja = setbcod <> 999.



def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Inclusao", " Alteracao", " ","  ", ""].

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

    form 
        cobfil.etbcod
        cobfil.cobcod
        cobfil.cobnom
        cobfil.cobqtd
        with frame frame-a 9 down centered color white/red row 5.


bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find cobfil where recid(cobfil) = recatu1 no-lock.
    if not available cobfil
    then do.
        run inclusao.
        recatu1 = ?.
        next.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(cobfil).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available cobfil
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find cobfil where recid(cobfil) = recatu1 no-lock.

        status default "".

        
        disp esqcom1 with frame f-com1.
        
        run color-message.

        choose field cobfil.cobnom
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
        run color-normal.
        pause 0. 

                                                                
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
                    if not avail cobfil
                    then leave.
                    recatu1 = recid(cobfil).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cobfil
                    then leave.
                    recatu1 = recid(cobfil).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cobfil
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cobfil
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        
        
        if keyfunction(lastkey) = "return"
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Inclusao "
            then do on error undo.
                run inclusao.
                leave.
            end.
            if esqcom1[esqpos1] = " Alteracao "
            then do on error undo.
                find current cobfil exclusive.
                update cobfil.cobnom.
                recatu1 = recid(cobfil).
                leave.
            end.
            
            
        end.
        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(cobfil).
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

    disp 
        cobfil.etbcod
        cobfil.cobcod
        cobfil.cobnom
        cobfil.cobqtd
        with frame frame-a.
end procedure.

procedure color-message.
    color display message
        cobfil.etbcod
        cobfil.cobcod
        cobfil.cobnom
        cobfil.cobqtd

        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
        cobfil.etbcod
        cobfil.cobcod
        cobfil.cobnom
        cobfil.cobqtd

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
    if par-loja
    then do:
        find first cobfil  where cobfil.etbcod = setbcod
                no-lock no-error.
    end.
    else do:
        find first cobfil where
            true
            no-lock no-error.
    end.        
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    if par-loja
    then do:
        find next cobfil 
             where cobfil.etbcod = setbcod

                no-lock no-error.
    end.
    else do:
        find next cobfil where
            true
            no-lock no-error.
    end.        
end.    
             
if par-tipo = "up" 
then do:
    if par-loja
    then do:
       find prev cobfil  where
                cobfil.etbcod = setbcod
                no-lock no-error.
    end.
    else do:
        find prev cobfil where
            true
            no-lock no-error.
    end.        

end.    
        
end procedure.


procedure inclusao.
                scroll down with frame frame-a.
                create cobfil.
                if par-loja
                then do:
                    cobfil.etbcod = setbcod.
                    disp cobfil.etbcod.
                end.
                else do:
                    update cobfil.etbcod.
                end.
                update cobfil.cobcod.
                update cobfil.cobnom.
                recatu1 = recid(cobfil).
end.
