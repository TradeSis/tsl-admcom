
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

{admcab.i}

def output parameter p-operadora like operadoras.opecod.

def buffer boperadoras       for operadoras.
def var voperadoras         like operadoras.opecod.


assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find operadoras where recid(operadoras) = recatu1 no-lock.
        
    if not available operadoras
    then esqvazio = yes.
    else esqvazio = no.

    clear frame frame-a all no-pause.
    
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(operadoras).
    
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available operadoras
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
            find operadoras where recid(operadoras) = recatu1 no-lock.

            run color-message.
            choose field operadoras.openom help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail operadoras
                    then leave.
                    recatu1 = recid(operadoras).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail operadoras
                    then leave.
                    recatu1 = recid(operadoras).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail operadoras
                then next.
                color display white/red operadoras.openom with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail operadoras
                then next.
                color display white/red operadoras.openom with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
        
            p-operadora = operadoras.opecod.
            leave bl-princ.
            
            if esqregua
            then do:
        
            end.
            else do:
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        recatu1 = recid(operadoras).
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
    display 
            operadoras.openom format "x(20)" no-label
            with frame frame-a 5 down centered color white/red row 12
                    title " Operadora " overlay.
end procedure.

procedure color-message.
    color display message
            operadoras.openom format "x(20)"
            with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
            operadoras.openom format "x(20)"
            with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first operadoras where true
                                                no-lock no-error.
    else  
        find last operadoras  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next operadoras  where true
                                                no-lock no-error.
    else  
        find prev operadoras   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev operadoras where true  
                                        no-lock no-error.
    else   
        find next operadoras where true 
                                        no-lock no-error.
        
end procedure.
