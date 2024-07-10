/*
*
*    tab_ini.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter p-tipo as char.

/***
def var vetbcod like estab.etbcod.
find first tab_ini where
           tab_ini.etbcod = setbcod no-lock no-error.
if avail tab_ini
then vetbcod = setbcod.
else vetbcod = 0.

if vetbcod = 0
then update vetbcod with frame f1 row 5 side-label 1 down width 80.
***/

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao ","","",""].

def buffer btab_ini       for tab_ini.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tab_ini where recid(tab_ini) = recatu1 no-lock.
    if not available tab_ini
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tab_ini).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tab_ini
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
            find tab_ini where recid(tab_ini) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field tab_ini.parametro help ""
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
                    if not avail tab_ini
                    then leave.
                    recatu1 = recid(tab_ini).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tab_ini
                    then leave.
                    recatu1 = recid(tab_ini).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tab_ini
                then next.
                color display white/red tab_ini.parametro with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tab_ini
                then next.
                color display white/red tab_ini.parametro with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tab_ini
                 with frame f-tab_ini color black/cyan
                      centered side-label row 5 1 col.
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tab_ini on error undo.
                    create tab_ini.
                    update tab_ini.
                    recatu1 = recid(tab_ini).
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tab_ini on error undo.
                    find tab_ini where recid(tab_ini) = recatu1 exclusive.
                    update tab_ini.valor.
                end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tab_ini).
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
        tab_ini.etbcod column-label "Etb"
        tab_ini.cxacod column-label "Cxa"
        tab_ini.parametro
        tab_ini.valor
        tab_ini.dtincl
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        tab_ini.parametro
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tab_ini.parametro
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first tab_ini where /*tab_ini.etbcod = vetbcod and*/
                tab_ini.parametro begins p-tipo no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next tab_ini  where /*tab_ini.etbcod = vetbcod and*/
                tab_ini.parametro begins p-tipo
                                                no-lock no-error.
             
if par-tipo = "up" 
then  find prev tab_ini where /*tab_ini.etbcod = vetbcod and*/
                tab_ini.parametro begins p-tipo
                                        no-lock no-error.
        
end procedure.
         
