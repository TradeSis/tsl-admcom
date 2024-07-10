/*
*
*    Esqueletao de Programacao
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial [ "Marca/Desmarca"," Cria "," Exclui ","", ""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" ","","","",""].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ", " ", " ", " ", " "].

{admcab.i}

def buffer baplicativo       for aplicativo.
def buffer caplicativo       for aplicativo.
def var vaplicod         like aplicativo.aplicod.

def temp-table wfesc
    field rec   as recid.

def buffer baplifun for aplifun.

form func.funcod
     func.funape
     func.funnom
        with 1 column color white/cyan frame fmostra
                title "SEGURANCA DE MENU POR USUARIO".

prompt-for func.funcod
        with row 4 column 15 frame fmostra.

find func where func.etbcod = 999 and
                func.funcod = input func.funcod no-lock.

display funnom
        funape with frame fmostra.

for each wfesc.
    delete wfesc.
end.

for each baplifun where baplifun.funcod = func.funcod no-lock.
    find caplicativo of baplifun no-lock.
    create wfesc.
    assign wfesc.rec = recid(caplicativo).
end.

def var vesc as char format "x(3)".

    form
        esqcom1
            with frame f-com1
                 row screen-lines
                  no-box no-labels side-labels column 1 centered.
    form
        esqcom2
            with frame f-com2
                 row 3 no-box no-labels side-labels column 1
                 centered.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:
    pause 0.
    form aplicativo.aplicod with frame f-aplicativo  row 4 1 column centered
                                 color black/cyan.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then
        find first aplicativo where
            true no-lock no-error.
    else
        find aplicativo where recid(aplicativo) = recatu1 no-lock.
    if not available aplicativo
    then do:
        leave.
    end.
    clear frame frame-a all no-pause.

    find first wfesc where wfesc.rec = recid(aplicativo) no-error.
    if avail wfesc then vesc = " * ". else vesc = "".
    display
        vesc no-label
        aplicativo.aplicod
            with frame frame-a 15 down color white/red no-label.

    recatu1 = recid(aplicativo).
    find aplicativo where recid(aplicativo) = recatu1 no-lock.
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next aplicativo where
                true no-lock no-error.
        if not available aplicativo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        find first wfesc where wfesc.rec = recid(aplicativo) no-error.
        if avail wfesc then vesc = " * ". else vesc = "".
        display
            vesc
            aplicativo.aplicod
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find aplicativo where recid(aplicativo) = recatu1 no-lock.

        status default
            if esqregua
            then esqhel1[esqpos1] + if esqpos1 > 1 and
                                       esqhel1[esqpos1] <> ""
                                    then string(aplicativo.aplicod)
                                    else ""
            else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                    then string(aplicativo.aplicod)
                                    else "".

        choose field aplicativo.aplicod help ""
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down   page-up
                  PF4 F4 ESC return) color white/black.

        status default "".

        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next aplicativo where
                    true no-lock no-error.
                if not avail aplicativo
                then leave.
                recatu1 = recid(aplicativo).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev aplicativo where
                    true no-lock no-error.
                if not avail aplicativo
                then leave.
                recatu1 = recid(aplicativo).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next aplicativo where
                true no-lock no-error.
            if not avail aplicativo
            then next.
            color display white/red aplicativo.aplicod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev aplicativo where
                true no-lock no-error.
            if not avail aplicativo
            then next.
            color display white/red aplicativo.aplicod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave:
          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = " Menu "
            then do:
                run menfun.p (input aplicativo.aplicod).
            end.
            if esqcom1[esqpos1] = "Marca/Desmarca"
            then do with frame f-aplicativo.
                find first wfesc where wfesc.rec = recid(aplicativo)
                            no-error.
                if not avail wfesc
                then do:
                    create wfesc.
                    wfesc.rec = recid(aplicativo).
                end.
                else do:
                    find aplifun where aplifun.funcod = func.funcod and
                         aplifun.aplicod = aplicativo.aplicod no-error.
                    if avail aplifun
                    then delete aplifun.
                    delete wfesc.
                end.
            end.
            if esqcom1[esqpos1] = " Cria "
            then do with frame f-aplicativo.
                for each wfesc:
                    find aplicativo where recid(aplicativo) = wfesc.rec
                        no-lock no-error.
                    if not can-find(aplifun where
                                    aplifun.funcod = func.funcod and
                                    aplifun.aplicod = aplicativo.aplicod)
                    then do:
                        create aplifun.
                        assign aplifun.funcod  = func.funcod
                               aplifun.aplicod = aplicativo.aplicod.
                        delete wfesc.
                    end.
                end.
                recatu1 = ?.
                for each baplifun where baplifun.funcod = func.funcod no-lock.
                    find caplicativo of baplifun no-lock.
                    create wfesc.
                    assign wfesc.rec = recid(caplicativo).
                end.
                leave.
            end.
            if esqcom1[esqpos1] = " Exclui "
            then do with frame f-aplicativo.
                for each wfesc:
                    find aplicativo where recid(aplicativo) = wfesc.rec
                        no-lock no-error.
                    if not avail aplicativo
                    then next.
                    find aplifun where aplifun.funcod = func.funcod and
                         aplifun.aplicod = aplicativo.aplicod no-error.
                    if avail aplifun
                    then delete aplifun.
                    delete wfesc.
                end.
                recatu1 = ?.
                for each baplifun where baplifun.funcod = func.funcod no-lock.
                    find caplicativo of baplifun no-lock.
                    create wfesc.
                    assign wfesc.rec = recid(caplicativo).
                end.
                leave.
            end.
          end.
          else do:
            if esqcom2[esqpos2] <> ""
            then do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                    with frame f-com2.
                message esqregua esqpos2 esqcom2[esqpos2].
                pause.
            end.
          end.
        end.
        find first wfesc where wfesc.rec = recid(aplicativo) no-error.
        if avail wfesc then vesc = " * ". else vesc = "".
        display
            vesc
                aplicativo.aplicod
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(aplicativo).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
