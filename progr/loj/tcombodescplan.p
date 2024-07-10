/* helio 10072023 - combo de planos */
{admcab.i}

def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" setores"," parametros "," inclusao "," exclui",""].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def buffer ufinan for finan.

form  
    combodescplan.etbcod   column-label "fil"
    combodescplan.fincod   column-label "plano"
    finan.finnom format "x(15)" column-label "de"
    finan.finnpc 
    combodescplan.finusar column-label "plano"
    ufinan.finnom format "x(15)" column-label "para"

    combodescplan.percdesc         with frame frame-a 9 down centered row 7
        no-box.



disp 
    "COMBO DE DESCONTOS - DE PARA PLANOS " format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.



bl-princ:
repeat:
    
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find combodescplan where recid(combodescplan) = recatu1 no-lock.
    if not available combodescplan
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(combodescplan).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available combodescplan
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find combodescplan where recid(combodescplan) = recatu1 no-lock.
        /*
        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 6.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 6.
            esqcom1[vx] = "".
        end.     
        */
        
        disp esqcom1 with frame f-com1.
        
        run color-message.

        choose field combodescplan.fincod
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

        if keyfunction(lastkey) <> "return"
        then run color-normal.

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
                    if not avail combodescplan
                    then leave.
                    recatu1 = recid(combodescplan).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail combodescplan
                    then leave.
                    recatu1 = recid(combodescplan).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail combodescplan
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail combodescplan
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
            if esqcom1[esqpos1] = " exclui "
            then do:
                do on error undo:
                    message "confirme exclusao?" update sresp.
                    if sresp
                    then do:
                        find current combodescplan.
                        for each combodescset of combodescplan.
                            delete combodescset.
                        end.
                        delete combodescplan.    
                    end.                
                end.
                recatu1 = ?.
                leave.
                
            end. 
            if esqcom1[esqpos1] = " setores"
            then do:
                hide frame f-com1 no-pause.
                run loj/tcombodescset.p (input recatu1).
                leave.
                
            end. 

        end. 
        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(combodescplan).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame ftit no-pause.
hide frame ftot no-pause.
return.
 
procedure frame-a.
  

    find  finan where  finan.fincod = combodescplan.fincod no-lock.
    find ufinan where ufinan.fincod = combodescplan.finusar no-lock.   
    disp
    combodescplan.etbcod   
    combodescplan.fincod  
    finan.finnom 
    finan.finnpc
    combodescplan.finusar  
    ufinan.finnom 
    combodescplan.percdesc 

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
    combodescplan.etbcod   
    combodescplan.fincod  
    finan.finnom 
    combodescplan.finusar  
    ufinan.finnom 
    combodescplan.percdesc 
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
    combodescplan.etbcod   
    combodescplan.fincod  
    finan.finnom 
    combodescplan.finusar  
    ufinan.finnom 
    combodescplan.percdesc 
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
    combodescplan.etbcod   
    combodescplan.fincod  
    finan.finnom 
    combodescplan.finusar  
    ufinan.finnom 
    combodescplan.percdesc 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

    if par-tipo = "pri" 
    then do:
        find first combodescplan where    
                        no-lock no-error.
    end.    
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find next combodescplan where   
            no-lock no-error.
    end.    
    if par-tipo = "up" 
    then do:
        find prev combodescplan where 
            no-lock no-error.
    end.    

        
end procedure.





procedure pparametros.

    do on error undo:

        find current combodescplan exclusive.
        disp combodescplan.etbcod.
        disp    
            combodescplan  
                   with row 9 
        centered
        overlay 1 column.
                    
        update combodescplan.percdesc.
        if  combodescplan.percdesc > 100
        then do:
            message "percentual invalido.".
            undo, retry.
        end.   


    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    create combodescplan.
    prec = recid(combodescplan).
    disp
        combodescplan.etbcod 
        with row 9 
        centered
        overlay 1 column.
        update
            combodescplan.etbcod
            combodescplan.fincod.

        find finan where finan.fincod = combodescplan.fincod no-lock no-error.
        if not avail finan 
        then do:
            message "plano invalido".
            undo, retry.
        end.   
        update combodescplan.finusar.
        find ufinan where ufinan.fincod = combodescplan.finusar no-lock no-error.
        if not avail ufinan 
        then do:
            message "plano invalido".
            undo, retry.
        end.   

        if finan.finnpc <> ufinan.finnpc
        then do:
            message "planos com mumero de parcelas diferentes" finan.finnpc ufinan.finnpc.
            undo, retry.
        end.   


        update combodescplan.percdesc.
        if  combodescplan.percdesc > 100
        then do:
            message "percentual invalido.".
            undo, retry.
        end.   
                                              


end.


end procedure.


