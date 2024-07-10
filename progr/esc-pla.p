
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

{admcab.i}

def temp-table tt-planoviv like planoviv.
    
def input  parameter p-tipviv    like promoviv.tipviv format ">>>9".
def input  parameter p-operadora like operadoras.opecod.
def output parameter p-codviv    like planoviv.codviv format ">>>9".

def buffer btt-planoviv  for  planoviv.
def var v-codviv     like planoviv.codviv.


for each operadoras where operadoras.opecod = p-operadora no-lock:
    for each promoviv where promoviv.opecod = operadoras.opecod
                        and promoviv.tipviv = p-tipviv
                        and promoviv.exportado = yes no-lock:
        
        for each proplaviv where proplaviv.tipviv = promoviv.tipviv no-lock:

            find planoviv where planoviv.codviv = proplaviv.codviv 
                            and planoviv.exportado = yes no-lock no-error.
            if avail planoviv
            then do:
                find tt-planoviv where 
                     tt-planoviv.codviv = planoviv.codviv no-error.
                if not avail tt-planoviv
                then do:
                    create tt-planoviv.
                    assign tt-planoviv.codviv    = planoviv.codviv
                           tt-planoviv.planomviv = planoviv.planomviv
                           tt-planoviv.exportado = planoviv.exportado.
                end.
            end.
        end.
    end.                        
end.

find first tt-planoviv no-lock no-error.
if not avail tt-planoviv
then do:
    message "Nenhum Plano encontrado p/esta Operadora e Promocao.".
    leave.
end.

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
        find tt-planoviv where recid(tt-planoviv) = recatu1 no-lock.
        
    if not available tt-planoviv
    then esqvazio = yes.
    else esqvazio = no.

    clear frame frame-a all no-pause.
    
    if not esqvazio
    then do:
        run frame-a.
        pause 0.
    end.

    recatu1 = recid(tt-planoviv).
    
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-planoviv
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
            find tt-planoviv where recid(tt-planoviv) = recatu1 no-lock.

            run color-message.
            choose field tt-planoviv.codviv
                         tt-planoviv.planomviv help ""
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
                    if not avail tt-planoviv
                    then leave.
                    recatu1 = recid(tt-planoviv).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-planoviv
                    then leave.
                    recatu1 = recid(tt-planoviv).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-planoviv
                then next.
                color display white/red tt-planoviv.planomviv 
                                        tt-planoviv.codviv
                                        with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-planoviv
                then next.
                color display white/red tt-planoviv.planomviv
                                        tt-planoviv.codviv
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
        
            p-codviv = tt-planoviv.codviv.
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
        recatu1 = recid(tt-planoviv).
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
    display tt-planoviv.codviv    no-label format ">>>9"
            tt-planoviv.planomviv no-label
            with frame frame-a 7 down color white/red row 10
                    col 40
                    title " Plano " overlay.
end procedure.

procedure color-message.
    color display message
            tt-planoviv.codviv    no-label format ">>>9"
            tt-planoviv.planomviv
            with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
            tt-planoviv.codviv    no-label format ">>>9"
            tt-planoviv.planomviv
             with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-planoviv where
                              tt-planoviv.exportado = yes no-lock no-error.
    else  
        find last tt-planoviv  where
                              tt-planoviv.exportado = yes no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-planoviv  where
                              tt-planoviv.exportado = yes no-lock no-error.
    else  
        find prev tt-planoviv  where
                              tt-planoviv.exportado = yes no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-planoviv where
                             tt-planoviv.exportado = yes no-lock no-error.
    else   
        find next tt-planoviv where
                             tt-planoviv.exportado = yes no-lock no-error.
        
end procedure.
