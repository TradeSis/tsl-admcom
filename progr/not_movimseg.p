/*
*
*    movimseg.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-rec         as recid.

find plani where recid(plani) = par-rec no-lock.

def buffer seg-movim for movim.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5.

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
    else find movimseg where recid(movimseg) = recatu1 no-lock.
    if not available movimseg
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(movimseg).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available movimseg
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find movimseg where recid(movimseg) = recatu1 no-lock.

            status default "".

            run color-message.
            choose field movimseg.movseq help ""
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
                    if not avail movimseg
                    then leave.
                    recatu1 = recid(movimseg).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail movimseg
                    then leave.
                    recatu1 = recid(movimseg).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail movimseg
                then next.
                color display white/red movimseg.movseq with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail movimseg
                then next.
                color display white/red movimseg.movseq with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

/*
        if keyfunction(lastkey) = "return"
        then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
        end.
*/
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(movimseg).
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

    def buffer sprodu for produ.

    find seg-movim where seg-movim.etbcod = movimseg.etbcod
                     and seg-movim.placod = movimseg.placod
                     and seg-movim.movseq = movimseg.Seg-movseq
                   no-lock.
    find sprodu of seg-movim no-lock.

    find movim where movim.etbcod = movimseg.etbcod
                 and movim.placod = movimseg.placod
                 and movim.movseq = movimseg.movseq
               no-lock.
    find produ of movim no-lock.

    display
        movimseg.movseq
        seg-movim.procod
        sprodu.pronom format "x(12)"
        movim.procod
        produ.pronom  format "x(19)"
        movimseg.movpc
        movimseg.certifi format "x(15)"
        with frame frame-a 7 down centered row 10 color white/red.
end procedure.


procedure color-message.
color display message
        movimseg.movseq
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        movimseg.movseq
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first movimseg where movimseg.etbcod = plani.etbcod
                           and movimseg.placod = plani.placod
                         no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next movimseg  where movimseg.etbcod = plani.etbcod
                           and movimseg.placod = plani.placod
                         no-lock no-error.
             
if par-tipo = "up" 
then find prev movimseg  where movimseg.etbcod = plani.etbcod
                           and movimseg.placod = plani.placod
                         no-lock no-error.
        
end procedure.
         
