/*
*
*    etiqpla.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i new}

def input parameter par-rec         as recid.

find plani  where recid(plani) = par-rec no-lock.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
    initial [" "].

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find etiqpla where recid(etiqpla) = recatu1 no-lock.
    if not available etiqpla
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.

    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(etiqpla).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available etiqpla
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find etiqpla where recid(etiqpla) = recatu1 no-lock.

            status default "".

            run color-message.
            choose field etiqpla.oscod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".

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
                    if not avail etiqpla
                    then leave.
                    recatu1 = recid(etiqpla).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail etiqpla
                    then leave.
                    recatu1 = recid(etiqpla).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail etiqpla
                then next.
                color display white/red etiqpla.oscod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail etiqpla
                then next.
                color display white/red etiqpla.oscod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" 
        then do:
            form etiqpla
                 with frame f-etiqpla color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-etiqpla.
                    disp etiqpla.
                end.
        end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(etiqpla).
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

    find asstec of etiqpla no-lock no-error.
    if avail asstec
    then find produ of asstec no-lock no-error.

    display
        etiqpla.oscod column-label "OS"
        etiqpla.data
        string(etiqpla.hora, "hh:mm:ss")
        asstec.etbcod when avail asstec
        asstec.procod when avail asstec
        produ.pronom  when avail produ format "x(20)"
        with frame frame-a 11 down centered color white/red row 5
        title string(plani.numero).
end procedure.


procedure color-message.
color display message
        etiqpla.data
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        etiqpla.data 
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first etiqpla where etiqpla.etbpla = plani.etbcod
                          and etiqpla.plaplani = plani.placod
                                                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next etiqpla  where etiqpla.etbpla = plani.etbcod
                          and etiqpla.plaplani = plani.placod
                                                no-lock no-error.
             
if par-tipo = "up" 
then find prev etiqpla where etiqpla.etbpla = plani.etbcod
                         and etiqpla.plaplani = plani.placod
                                        no-lock no-error.
        
end procedure.
         
