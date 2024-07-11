/*               to                   sfpl
*                                 R
*
*/

{admcab.i new}
def buffer blimarea for limarea.
    
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" parametros "," filiais"," inclusao "," exclusao"," -"].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


    form  
        limarea.liacod
        limarea.lianom column-label "companha"  format "x(26)"
        limarea.campoRET
        limarea.listaModcod
        
        
        with frame frame-a 8 down centered row 8
        no-box.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find limarea where recid(limarea) = recatu1 no-lock.
    if not available limarea
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(limarea).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available limarea
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find limarea where recid(limarea) = recatu1 no-lock.

        status default "".
        
        if false
        then esqcom1[5] = " exclusao".
        else esqcom1[5] = "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field limarea.lianom

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
                    if not avail limarea
                    then leave.
                    recatu1 = recid(limarea).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail limarea
                    then leave.
                    recatu1 = recid(limarea).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail limarea
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail limarea
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
            
            
            if esqcom1[esqpos1] = " filiais "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run fin/limestab.p (recid(limarea)).
                
            end. 
            
            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(limarea).
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
        limarea.liacod
        limarea.lianom
        limarea.campoRET
        limarea.listaModcod
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        limarea.liacod
        limarea.lianom
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        limarea.liacod
        limarea.lianom
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        limarea.liacod
        limarea.lianom
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first limarea  where
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next limarea  where
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev limarea  where
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo:

        find current limarea exclusive.
        disp limarea.liacod limarea.lianom format "x(26)".
        disp    
            limarea 
            .
        disp listamodcod format "x(22)"
             listatpcontrato format "x(12)".

                    
        update
            limarea
                except liacod listamodcod listatpcontrato campodtval
        with 1 col 
            row 7
            centered
               overlay.
        if limarea.usavctolim
        then update limarea.campodtval.
        else limarea.campodtval = "".
        disp limarea.campodtval.
        update limarea.listamodcod.
        if lookup ("CRE",limarea.listamodcod) > 0
        then update limarea.listatpcontrato
                help "C - CDC NORMAL, N - NOVACAO , FA - FEIRAO ANTIGO, F - FEIRAO , L - L&P".
        else limarea.listatpcontrato = "".

    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    find last blimarea no-lock no-error.
    create limarea.
    prec = recid(limarea).
    
    update
        limarea.liacod
        limarea.lianom format "x(26)"
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
    find current limarea exclusive no-wait no-error.
    if avail limarea
    then do:
        for each  limestab where limestab.liacod =  limarea.liacod.
            delete limestab.
        end.
        delete limarea.    
    end.        
end.
end procedure.
