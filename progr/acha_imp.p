{admcab.i}

def input  parameter     recatu1         as recid.
def output parameter     recatu2         as recid.

def var reccont         as int.
def var vinicio         as log.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 1 initial ["Seleciona"].

form
    esqcom1 with frame f-com1 row 3 no-box no-labels centered.
esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then find first impress where impress.etbcod = setbcod no-lock no-error.
    else find impress where recid(impress) = recatu1 no-lock.
    vinicio = yes.
   
    if not available impress
    then leave.
    clear frame frame-a all no-pause.
    display
        impress.codimp  column-label "Codigo"
        impress.nome    column-label "Nome"      format "x(25)"
        impress.nomeimp column-label "Descricao"
        with frame frame-a 7 down centered row 10 color white/cyan.

    recatu1 = recid(impress).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        find next impress where impress.etbcod = setbcod no-lock no-error.
        if not available impress
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
        display
            impress.codimp 
            impress.nome
            impress.nomeimp
            with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find impress where recid(impress) = recatu1 no-lock.

        choose field impress.codimp
            go-on(cursor-down cursor-up
                  page-down page-up
                  PF4 F4 ESC return).

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next impress where impress.etbcod = setbcod
                        no-lock no-error.
                if not avail impress
                then leave.
                recatu1 = recid(impress).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev impress where impress.etbcod = setbcod
                        no-lock no-error.
                if not avail impress
                then leave.
                recatu1 = recid(impress).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next impress where impress.etbcod = setbcod no-lock no-error.
            if not avail impress
            then next.
            color display normal impress.codimp.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev impress where impress.etbcod = setbcod no-lock no-error.
            if not avail impress
            then next.
            color display normal impress.codimp.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Seleciona"
            then do.
                recatu2 = recid(impress).
                leave bl-princ.
            end.
        end.
        display impress.codimp 
                impress.nome
                impress.nomeimp
                with frame frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(impress).
    end.
end.
hide frame frame-a no-pause.
hide frame f-com1 no-pause.

