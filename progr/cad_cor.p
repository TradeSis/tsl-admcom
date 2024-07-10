/*           */
{admcab.i}

def var mordem as char extent 3 init [" Codigo"," Nome"," Pantone"].
def var vordem as int init 1.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Ordenacao "," Pesquisa",""].

def buffer bcor       for cor.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find cor where recid(cor) = recatu1 no-lock.
    if not available cor
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(cor).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available cor
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find cor where recid(cor) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field cor.corcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
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
                    if not avail cor
                    then leave.
                    recatu1 = recid(cor).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cor
                    then leave.
                    recatu1 = recid(cor).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cor
                then next.
                color display white/red cor.corcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cor
                then next.
                color display white/red cor.corcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form with frame f-cor color black/cyan
                      centered side-label row 5 1 col.
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-cor on error undo.
                    create cor.
                    update cor.corcod.

                    update cor except dtexp corcod.
                    cor.corcod = caps(cor.corcod).
                    cor.cornom = caps(cor.cornom).
                    recatu1 = recid(cor).
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame frame-a on error undo.
                    find cor where recid(cor) = recatu1 exclusive.
                    update cor except dtexp corcod.
                    cor.cornom = caps(cor.cornom).
                end.
                if esqcom1[esqpos1] = " Pesquisa "
                then do.
                    run pesquisa.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    leave.
                end.
                if esqcom1[esqpos1] = " Ordenacao "
                then do.
                    disp mordem with frame f-ordem no-label centered.
                    choose field mordem with frame f-ordem.
                    vordem = frame-index.
                    leave.
                end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(cor).
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
    display cor except dtexp
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
    color display message
        cor.corcod
        cor.cornom
        cor.pantone
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
        cor.corcod
        cor.cornom
        cor.pantone
        with frame frame-a.
end procedure.


procedure leitura . 

def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if vordem = 1
    then find first cor no-lock no-error.
    else if vordem = 2
    then find first cor use-index icor2 no-lock no-error.
    else if vordem = 3
    then find first cor use-index pantone no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if vordem = 1
    then find next cor  no-lock no-error.
    else if vordem = 2
    then find next cor  use-index icor2 no-lock no-error.
    else if vordem = 3
    then find next cor  use-index pantone no-lock no-error.

if par-tipo = "up" 
then
    if vordem = 1
    then find prev cor  no-lock no-error.
    else if vordem = 2
    then find prev cor  use-index icor2 no-lock no-error.
    else if vordem = 3
    then find prev cor  use-index pantone no-lock no-error.

end procedure.

procedure pesquisa.

    do on error undo with frame f-pesq side-label.
        prompt-for cor.corcod.
        if input cor.corcod <> ""
        then do.
            vordem = 1.
            find bcor where bcor.corcod = input cor.corcod no-lock no-error.
        end.
        else do.
            prompt-for cor.cornom.
            if input cor.cornom <> ""
            then do.
                vordem = 2.
                find first bcor where bcor.cornom begins input cor.cornom
                              no-lock no-error.
            end.
            else do.
                prompt-for cor.pantone.
                if input cor.pantone <> ""
                then do.
                    vordem = 3.
                    find first bcor where bcor.pantone begins input cor.pantone
                                  no-lock no-error.
                end.
            end.
        end.
        if avail bcor
        then recatu1 = recid(bcor).
    end.

end procedure.

