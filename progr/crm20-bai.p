
def shared temp-table tt-bairro
    field bairro as char
    field marca  as log format "*/ "
    index ibairro is primary unique bairro.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.


def var esqcom1         as char format "x(14)" extent 5
    initial [" Marca "," Confirma"," Marca Todos ","",""].

def var esqcom2         as char format "x(14)" extent 5
            initial [" "," ","","",""].

{admcab.i}

def buffer btt-bairro       for tt-bairro.


form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    
    
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-bairro where recid(tt-bairro) = recatu1 no-error.
        
    if not available tt-bairro
    then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-bairro).
    
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    
    if not esqvazio
    then repeat:
        run leitura (input "seg").
    
        if not available tt-bairro
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
            find tt-bairro where recid(tt-bairro) = recatu1 no-error.

            run color-message.
            
            choose field tt-bairro.marca tt-bairro.bairro help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).

            run color-normal.
            
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-bairro
                    then leave.
                    recatu1 = recid(tt-bairro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-bairro
                    then leave.
                    recatu1 = recid(tt-bairro).
                end.
                leave.
            end.
    
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-bairro
                then next.
                color display white/red tt-bairro.marca tt-bairro.bairro 
                              with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-bairro
                then next.
                color display white/red tt-bairro.marca tt-bairro.bairro
                                        with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:

            hide frame frame-a no-pause.
            
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Confirma "
                then do:
                    leave bl-princ.
                end.
                if esqcom1[esqpos1] = " Marca "
                then do with frame f-marca1 on error undo.

                    find tt-bairro where recid(tt-bairro) = recatu1 no-error.
                    if not avail tt-bairro then leave.
                    
                    if tt-bairro.marca = no
                    then tt-bairro.marca = yes.
                    else tt-bairro.marca = no.
                
                end.

                if esqcom1[esqpos1] = " Marca Todos "
                then do:
                    for each tt-bairro:
                        tt-bairro.marca = yes.
                    end.
                    leave.
                end.
                
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                
                
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-bairro).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    display tt-bairro.marca  column-label "*"
            tt-bairro.bairro column-label "Bairro" format "x(50)"
            with frame frame-a 11 down color white/red row 5 centered.
end procedure.

procedure color-message.
    color display message
                  tt-bairro.marca column-label "*"
                  tt-bairro.bairro column-label "Bairro"
                  with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
                  tt-bairro.marca column-label "*"
                  tt-bairro.bairro column-label "Bairro"
                  with frame frame-a.
end procedure.




procedure leitura.

    def input parameter par-tipo as char.
        
    if par-tipo = "pri"
    then do: 
        if esqascend
        then do:
             find first tt-bairro where true no-error.
             
        end.     
        else do: 
             find last tt-bairro where true no-error.
             
        end.
    end.                                         
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        if esqascend  
        then do:
             find next tt-bairro where true no-error. 

        end.             
        else do: 
             find prev tt-bairro where true no-error.
             
        end.            
    end.
             
             
    if par-tipo = "up" 
    then do:
        if esqascend   
        then do:  
             find prev tt-bairro where true no-error.
             
        end.
        else do:
             find next tt-bairro where true no-error.
             
        end.
    end.        
        
end procedure.
