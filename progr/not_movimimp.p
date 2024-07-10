/*
#1 04/19 - Projeto ICMS Efetivo
*
*    movimimp.p    -    Esqueleto de Programacao
*
*/
def input parameter par-recid-movim as recid no-undo.

find movim where recid(movim) = par-recid-movim no-lock.

def var recatu1      as recid.
def var reccont      as int.
def var esqpos1      as int.
def var esqcom1      as char format "x(12)" extent 5 initial [" Retorna ",""].

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find movimimp where recid(movimimp) = recatu1 no-lock.
    if not available movimimp
    then do.
        message "Sem impostos" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(movimimp).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available movimimp
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find movimimp where recid(movimimp) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field movimimp.impcodigo help ""
                go-on(cursor-down cursor-up
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".

            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail movimimp
                    then leave.
                    recatu1 = recid(movimimp).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail movimimp
                    then leave.
                    recatu1 = recid(movimimp).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail movimimp
                then next.
                color display white/red movimimp.impcodigo with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail movimimp
                then next.
                color display white/red movimimp.impcodigo with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error" or
           keyfunction(lastkey) = "return"
        then leave bl-princ.

        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(movimimp).
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
    find imposto of movimimp no-lock.
    display
        movimimp.impcodigo
        imposto.impnome
        movimimp.impBaseC
        movimimp.impAliq
        movimimp.impValor
        movimimp.impvlraux1
        with frame frame-a 8 down centered color white/red row 10
            title " Impostos ".
end procedure.


procedure color-message.
    color display message
        movimimp.impcodigo
        imposto.impnome
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        movimimp.impcodigo
        imposto.impnome
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first movimimp where movimimp.etbcod = movim.etbcod and 
                               movimimp.placod = movim.placod and
                               movimimp.movseq = movim.movseq
                                                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next movimimp  where movimimp.etbcod = movim.etbcod and 
                               movimimp.placod = movim.placod and
                               movimimp.movseq = movim.movseq
                                                no-lock no-error.
             
if par-tipo = "up" 
then find prev movimimp  where movimimp.etbcod = movim.etbcod and 
                               movimimp.placod = movim.placod and
                               movimimp.movseq = movim.movseq
                                        no-lock no-error.
        
end procedure.
