/*
*
*    etiqmov.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Consulta "," "].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao de etiqmov ",
             " Alteracao da etiqmov ",
             " Consulta da etiqmov ",
             " "].

def buffer betiqmov       for etiqmov.

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
        find etiqmov where recid(etiqmov) = recatu1 no-lock.
    if not available etiqmov
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(etiqmov).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available etiqmov
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
            find etiqmov where recid(etiqmov) = recatu1 no-lock.

            status default
                esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(etiqmov.EtMovnom)
                                        else "".
            run color-message.
            choose field etiqmov.EtMovcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".

        end.
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
                    if not avail etiqmov
                    then leave.
                    recatu1 = recid(etiqmov).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail etiqmov
                    then leave.
                    recatu1 = recid(etiqmov).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail etiqmov
                then next.
                color display white/red etiqmov.EtMovcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail etiqmov
                then next.
                color display white/red etiqmov.EtMovcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form etiqmov
                 with frame f-etiqmov color black/cyan
                      centered side-label row 5 1 col.
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Inclusao " or esqvazio
            then do with frame f-etiqmov on error undo.
                create etiqmov.
                update etiqmov.
                recatu1 = recid(etiqmov).
                leave.
            end.
            if esqcom1[esqpos1] = " Consulta " or
               esqcom1[esqpos1] = " Alteracao "
            then do with frame f-etiqmov.
                disp etiqmov.
                if etiqmov.EtMov-Est > 0
                then do.
                    find tipmov where tipmov.movtdc = etiqmov.movtdc-est
                                no-lock no-error.
                    find betiqmov where betiqmov.EtMovcod = etiqmov.EtMov-Est
                                no-lock no-error.
                    disp
                        tipmov.movtnom when avail tipmov
                        betiqmov.EtMovNom when avail betiqmov.
                end.
            end.
            if esqcom1[esqpos1] = " Alteracao "
            then do with frame f-etiqmov on error undo.
                find etiqmov where recid(etiqmov) = recatu1 exclusive.
                update etiqmov except.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(etiqmov).
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
        etiqmov.EtMovcod
        etiqmov.EtMovNom
        etiqmov.sigla
        etiqmov.EtMov-Est
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
color display message
        etiqmov.EtMovcod
        etiqmov.EtMovNom
        etiqmov.sigla
        etiqmov.EtMov-Est
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        etiqmov.EtMovcod
        etiqmov.EtMovNom
        etiqmov.sigla
        etiqmov.EtMov-Est
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first etiqmov where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next etiqmov  where true no-lock no-error.
             
if par-tipo = "up" 
then find prev etiqmov where true  no-lock no-error.
        
end procedure.
         
