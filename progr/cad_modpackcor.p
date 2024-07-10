/*
*
*    cad_modpackcor.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-rec  as recid.
def input parameter par-oper as char.

def var vct as int.
def temp-table tt-modpackcor
    field modpcod like modpackcor.modpcod
    field cor    like modpackcor.cor
    
    index cor cor.

find modpack where recid(modpack) = par-rec no-lock.
find grade of modpack no-lock.
/***
disp 
    modpack.modpcod
    modpack.modpnom  no-label
    modpack.gracod
    grade.granom no-label format "x(20)"
    with frame f-modpack row 3 side-labe no-box color message.
***/

do vct = 1 to modpack.cores.
    find modpackcor where modpackcor.modpcod = modpack.modpcod
                      and modpackcor.cor     = vct
                    no-lock no-error.
    if not avail modpackcor
    then do.
        create modpackcor.
        assign
            modpackcor.modpcod = modpack.modpcod
            modpackcor.cor     = vct.
    end.
end.

create tt-modpackcor.
tt-modpackcor.modpcod = 0.

for each modpackcor of modpack no-lock.
    create tt-modpackcor.
    buffer-copy modpackcor to tt-modpackcor.
end.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 2.

def buffer bmodpackcor       for modpackcor.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels column 50.
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
        find tt-modpackcor where recid(tt-modpackcor) = recatu1 no-lock.
    if not available tt-modpackcor
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(tt-modpackcor).
    if par-oper = "Altera"
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-modpackcor
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
            find tt-modpackcor where recid(tt-modpackcor) = recatu1 no-lock.
            find modpackcor where modpackcor.modpcod = tt-modpackcor.modpcod
                           and modpackcor.cor    = tt-modpackcor.cor
                         no-lock no-error.
            if avail modpackcor
            then run cad_modpackcortam.p (recid(modpackcor),"Consulta").
            else run cad_modpackcortam.p (recid(modpack),   "Total").

            if par-oper <> "Altera"
            then leave bl-princ.

            if avail modpackcor
            then esqcom1[1] = " Tamanhos ".
            else esqcom1 = "".
            disp esqcom1 with frame f-com1.

            status default "TAB - Altera tamanhos".
            run color-message.
            choose field tt-modpackcor.cor help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
            status default "".
        end.
            if (keyfunction(lastkey) = "TAB" or
                keyfunction(lastkey) = "return") and tt-modpackcor.cor > 0
            then do:
                run cad_modpackcortam.p (recid(modpackcor), "Altera").
                leave.
            end.
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
                    if not avail tt-modpackcor
                    then leave.
                    recatu1 = recid(tt-modpackcor).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-modpackcor
                    then leave.
                    recatu1 = recid(tt-modpackcor).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-modpackcor
                then next.
                color display white/red tt-modpackcor.cor with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-modpackcor
                then next.
                color display white/red tt-modpackcor.cor with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-modpackcor).
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

    def var vqtdecor like modpackcortam.qtde.
    def var vqtdepak like modpackcortam.qtde.
    def var vperc    as dec.
    
    for each modpackcortam of modpack no-lock.
        if modpackcortam.cor = tt-modpackcor.cor
        then vqtdecor = vqtdecor + modpackcortam.qtde.
        vqtdepak = vqtdepak + modpackcortam.qtde.
    end.

    if vqtdepak > 0
    then
        if tt-modpackcor.cor = 0
        then assign
                vqtdecor = vqtdepak
                vperc    = 100.
        else
            assign
                vperc    = vqtdecor / vqtdepak * 100.

    display
        tt-modpackcor.cor 
        vqtdecor
        vperc format ">>9.99" label "%"
        with frame frame-a screen-lines - 10 down color white/red row 5 col 52.

end procedure.


procedure color-message.
color display message
        tt-modpackcor.cor
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        tt-modpackcor.cor
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then   find first tt-modpackcor no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then   find next tt-modpackcor  no-lock no-error.
             
if par-tipo = "up" 
then   find prev tt-modpackcor  no-lock no-error.
        
end procedure.
