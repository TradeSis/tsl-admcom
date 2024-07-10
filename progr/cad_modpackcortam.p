/*
*
*    modpackcortam.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-rec  as recid.
def input parameter par-oper as char.

def var vct     as int.
def var vtitulo as char.
def temp-table tt-grade
    field tamcod    like taman.tamcod
    field qtde      like modpackcortam.qtde.

if par-oper = "Total"
then do.
    find modpack where recid(modpack) = par-rec no-lock.
    find grade of modpack no-lock.
    vtitulo = "T.Geral".
    for each gratam of grade no-lock break by gratam.graord.
        create tt-grade.
        tt-grade.tamcod = gratam.tamcod.
        for each modpackcortam of modpack
                               where modpackcortam.tamcod = gratam.tamcod
            no-lock.
            tt-grade.qtde = tt-grade.qtde + modpackcortam.qtde.
        end.
    end.
end.
else do.
    find modpackcor where recid(modpackcor) = par-rec no-lock.
    find modpack of modpackcor no-lock.
    find grade of modpack no-lock.
    vtitulo = "Cor:" + string(modpackcor.cor).
    for each gratam of grade no-lock break by gratam.graord.
        create tt-grade.
        tt-grade.tamcod = gratam.tamcod.

        find modpackcortam of modpackcor
                           where modpackcortam.tamcod = gratam.tamcod
            no-lock no-error.
        if avail modpackcortam
        then tt-grade.qtde = modpackcortam.qtde.
    end.
end.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 2
    initial [" Alteracao ",""].

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels column 56.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    if par-oper = "Altera"
    then disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-grade where recid(tt-grade) = recatu1 no-lock.
    if not available tt-grade
    then do.
        message "Sem tamanhos na grade" view-as alert-box.
        leave.
    end.

    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(tt-grade).
    if par-oper = "Altera"
    then color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tt-grade
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    if par-oper <> "Altera"
    then leave.

    repeat with frame frame-a:

            find tt-grade where recid(tt-grade) = recatu1 no-lock.

            status default "".

            run color-message.
            choose field tt-grade.tamcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
            status default "".

            if keyfunction(lastkey) = "TAB"
            then leave bl-princ.

            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 2 then 2 else esqpos1 + 1.
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
                    if not avail tt-grade
                    then leave.
                    recatu1 = recid(tt-grade).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-grade
                    then leave.
                    recatu1 = recid(tt-grade).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-grade
                then next.
                color display white/red tt-grade.tamcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-grade
                then next.
                color display white/red tt-grade.tamcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Alteracao "
            then do with frame frame-a on error undo.
                find tt-grade where recid(tt-grade) = recatu1 exclusive.
                update tt-grade.qtde.

                find modpackcortam of modpackcor
                                where modpackcortam.tamcod = tt-grade.tamcod
                                no-error.
                if not avail modpackcortam
                then do.
                    create modpackcortam.
                    assign
                        modpackcortam.modpcod = modpackcor.modpcod
                        modpackcortam.tamcod  = tt-grade.tamcod
                        modpackcortam.cor     = modpackcor.cor.
                end.
                modpackcortam.qtde = tt-grade.qtde.
            end.
        end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-grade).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
if par-oper = "Altera"
then do.
    hide frame f-com1  no-pause.
    hide frame frame-a no-pause.
end.

procedure frame-a.

    display
        tt-grade.tamcod
        tt-grade.qtde
        with frame frame-a screen-lines - 10 down color white/red row 5 col 68
            title vtitulo.
end procedure.


procedure color-message.
color display message
        tt-grade.tamcod
        tt-grade.qtde
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        tt-grade.tamcod
        tt-grade.qtde
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then   find first tt-grade no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then   find next tt-grade  no-lock no-error.
             
if par-tipo = "up" 
then   find prev tt-grade  no-lock no-error.
        
end procedure.
         
