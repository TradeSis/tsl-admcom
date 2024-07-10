{admcab.i}

def input parameter par-rec as recid.

def var var-propriedades as char.
def var vct as int.
def var vcomport as char.

def temp-table tt-comport
    field Campo as char format "x(20)"
    field Valor as char format "x(30)".

find neuclien where recid(neuclien) = par-rec no-lock.
find clien where clien.clicod = neuclien.clicod no-lock no-error.

run neuro/comportamento.p (neuclien.clicod, ?, output var-propriedades).

do vct = 1 to num-entries(var-propriedades, "#").
    vcomport = entry(vct, var-propriedades, "#").
    if num-entries(vcomport, "=") = 2
    then do.
        create tt-comport.
        tt-comport.campo = entry(1, vcomport, "=").
        tt-comport.valor = entry(2, vcomport, "=").
    end.
end.

/*
*
*    tt-comport.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5.

form
    esqcom1
    with frame f-com1
                 row 8 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-comport where recid(tt-comport) = recatu1 no-lock.
    if not available tt-comport
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(tt-comport).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tt-comport
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:
            find tt-comport where recid(tt-comport) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field tt-comport.Campo help ""
                go-on(cursor-down cursor-up
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".

            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-comport
                    then leave.
                    recatu1 = recid(tt-comport).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-comport
                    then leave.
                    recatu1 = recid(tt-comport).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-comport
                then next.
                color display white/red tt-comport.Campo with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-comport
                then next.
                color display white/red tt-comport.Campo with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-comport).
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
    display tt-comport 
        with frame frame-a 7 down centered color white/red row 9
        title " Comportamento ".
end procedure.


procedure color-message.
    color display message
        tt-comport.Campo
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        tt-comport.Campo
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first tt-comport where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next tt-comport  where true no-lock no-error.
             
if par-tipo = "up" 
then find prev tt-comport where true   no-lock no-error.
        
end procedure.

