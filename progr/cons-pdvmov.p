/*
*
*    pdvmov.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" "," Pesquisa "," Consulta "," "].
def var esqcom2         as char format "x(12)" extent 5
    initial [" pdvdoc "," pdvmovim "," pdvforma "," pdvmoe ",""].

def buffer bpdvmov       for pdvmov.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2 row screen-lines no-box no-labels column 1 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find pdvmov where recid(pdvmov) = recatu1 no-lock.
    if not available pdvmov
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(pdvmov).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available pdvmov
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
            find pdvmov where recid(pdvmov) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field pdvmov.etbcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail pdvmov
                    then leave.
                    recatu1 = recid(pdvmov).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail pdvmov
                    then leave.
                    recatu1 = recid(pdvmov).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail pdvmov
                then next.
                color display white/red pdvmov.etbcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail pdvmov
                then next.
                color display white/red pdvmov.etbcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form pdvmov
                 with frame f-pdvmov color black/cyan
                      centered side-label row 5 2 col.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Pesquisa " or esqvazio
                then do with frame f-pdvmov on error undo.
                    prompt-for
                        pdvmov.etbcod
                        pdvmov.datamov
                        cmon.cxacod
                        pdvmov.sequencia.
                    find first cmon where cmon.etbcod = input pdvmov.etbcod
                                      and cmon.cxacod = input cmon.cxacod
                                    no-lock.
                    find first bpdvmov where
                                    bpdvmov.etbcod  = input pdvmov.etbcod
                                and bpdvmov.cmocod  = cmon.cmocod
                                and bpdvmov.datamov = input pdvmov.datamov
                                and bpdvmov.sequencia = input pdvmov.sequencia
                                no-lock no-error.
                    if avail bpdvmov
                    then recatu1 = recid(bpdvmov).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-pdvmov.
                    disp pdvmov.
                    disp pdvmov.cmocod format ">>>>>>".
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                hide frame f-com1  no-pause.
                hide frame f-com2  no-pause.

                if esqcom2[esqpos2] = " pdvdoc "
                then run cons-pdvdoc.p (recid(pdvmov)).
                if esqcom2[esqpos2] = " pdvmovim "
                then run cons-pdvmovim.p (recid(pdvmov)).
                if esqcom2[esqpos2] = " pdvforma "
                then run cons-pdvforma.p (recid(pdvmov)).
                if esqcom2[esqpos2] = " pdvmoe "
                then run cons-pdvmoe.p (recid(pdvmov)).

                view frame f-com1.
                view frame f-com2.
                leave.
            end.
        end.
        if not esqvazio
        then run frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(pdvmov).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    find cmon of pdvmov no-lock no-error.
    display
        pdvmov.etbcod  column-label "Etb"
        pdvmov.datamov
        string(pdvmov.HoraMov, "hh:mm:ss")
        cmon.cxacod when avail cmon column-label "Caixa"
        pdvmov.sequencia
        pdvmov.ctmcod
        pdvmov.valortot
        with frame frame-a 11 down centered color white/red row 5.
end procedure.


procedure color-message.
    color display message
        pdvmov.etbcod
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        pdvmov.etbcod
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first pdvmov where true no-lock no-error.
    else  
        find last pdvmov  where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next pdvmov  where true no-lock no-error.
    else  
        find prev pdvmov  where true no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev pdvmov where true  no-lock no-error.
    else   
        find next pdvmov where true  no-lock no-error.
        
end procedure.
         
