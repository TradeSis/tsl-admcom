
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

{admcab.i}

def input  parameter p-operadora like operadoras.opecod.
def output parameter p-tipviv  like promoviv.tipviv format ">>>9".

def buffer bpromoviv  for  promoviv.
def var v-tipviv     like promoviv.tipviv.


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
        find promoviv where recid(promoviv) = recatu1 no-lock.
        
    if not available promoviv
    then esqvazio = yes.
    else esqvazio = no.

    clear frame frame-a all no-pause.
    
    if not esqvazio
    then do:
        run frame-a.
        pause 0.
    end.

    recatu1 = recid(promoviv).
    
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available promoviv
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
            find promoviv where recid(promoviv) = recatu1 no-lock.

            run color-message.
            choose field promoviv.tipviv
                         promoviv.provivnom help ""
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
                    if not avail promoviv
                    then leave.
                    recatu1 = recid(promoviv).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail promoviv
                    then leave.
                    recatu1 = recid(promoviv).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail promoviv
                then next.
                color display white/red promoviv.provivnom 
                                        promoviv.tipviv
                                        with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail promoviv
                then next.
                color display white/red promoviv.provivnom
                                        promoviv.tipviv
                                        with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
        
            p-tipviv = promoviv.tipviv.
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
        recatu1 = recid(promoviv).
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
    display promoviv.tipviv    no-label format ">>>9"
            promoviv.provivnom no-label
            with frame frame-a 7 down color white/red row 10
                    col 40
                    title " Serviço " overlay.
end procedure.

procedure color-message.
    color display message
            promoviv.tipviv    no-label format ">>>9"
            promoviv.provivnom
            with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
            promoviv.tipviv    no-label format ">>>9"
            promoviv.provivnom
             with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first promoviv where promoviv.opecod = p-operadora
                              and promoviv.exportado = yes no-lock no-error.
    else  
        find last promoviv  where promoviv.opecod = p-operadora
                              and promoviv.exportado = yes no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next promoviv  where promoviv.opecod = p-operadora
                              and promoviv.exportado = yes no-lock no-error.
    else  
        find prev promoviv  where promoviv.opecod = p-operadora
                              and promoviv.exportado = yes no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev promoviv where promoviv.opecod = p-operadora
                             and promoviv.exportado = yes no-lock no-error.
    else   
        find next promoviv where promoviv.opecod = p-operadora
                             and promoviv.exportado = yes no-lock no-error.
        
end procedure.
