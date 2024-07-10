/*
*
*    gcorfabri.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," "].
def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

{admcab.i}
def input parameter par-rec as recid.
find gru_cores where recid(gru_cores) = par-rec no-lock.
display gru_cores.gruccod colon 20 label "Grupo de Cor"
        gru_cores.grucnom no-label
        with frame fff row 3 side-label no-box color message width 81.

def buffer bgcorfabri       for gcorfabri.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
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
        find gcorfabri where recid(gcorfabri) = recatu1 no-lock.
    if not available gcorfabri
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(gcorfabri).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available gcorfabri
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
            find gcorfabri where recid(gcorfabri) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(gcorfabri.gruccod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(gcorfabri.gruccod)
                                        else "".
            run color-message.
            choose field gcorfabri.fabcod help ""
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
                    if not avail gcorfabri
                    then leave.
                    recatu1 = recid(gcorfabri).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail gcorfabri
                    then leave.
                    recatu1 = recid(gcorfabri).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail gcorfabri
                then next.
                color display white/red gcorfabri.fabcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail gcorfabri
                then next.
                color display white/red gcorfabri.fabcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form gcorfabri
                 with frame f-gcorfabri color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-gcorfabri on error undo.
                    create gcorfabri.
                    gcorfabri.gruccod = gru_cores.gruccod.
                    update gcorfabri.fabcod.
                    find fabri of gcorfabri no-lock no-error.
                    if not avail fabri
                    then do.
                        message "Fabricante invalido".
                        undo.
                    end.
                    
                    recatu1 = recid(gcorfabri).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-gcorfabri.
                    disp gcorfabri.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-gcorfabri on error undo.
                    find gcorfabri where recid(gcorfabri) = recatu1 
                        exclusive.
                    update gcorfabri.fabcod.
                    find fabri of gcorfabri no-lock no-error.
                    if not avail fabri
                    then do.
                        message "Fabricante invalida".
                        undo.
                    end.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" gcorfabri.fabcod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next gcorfabri where of gru_cores no-error.
                    if not available gcorfabri
                    then do:
                        find gcorfabri where recid(gcorfabri) = recatu1.
                        find prev gcorfabri where of gru_cores no-error.
                    end.
                    recatu2 = if available gcorfabri
                              then recid(gcorfabri)
                              else ?.
                    find gcorfabri where recid(gcorfabri) = recatu1
                            exclusive.
                    delete gcorfabri.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    leave.
                end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(gcorfabri).
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
find fabri of gcorfabri no-lock.
display gcorfabri.fabcod
        fabri.fabnom
        gcorfabri.situacao
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
color display message
        gcorfabri.fabcod
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        gcorfabri.fabcod
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first gcorfabri where of gru_cores
                                                no-lock no-error.
    else  
        find last gcorfabri  where of gru_cores
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next gcorfabri  where of gru_cores
                                                no-lock no-error.
    else  
        find prev gcorfabri   where of gru_cores
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev gcorfabri where of gru_cores  
                                        no-lock no-error.
    else   
        find next gcorfabri where of gru_cores 
                                        no-lock no-error.
        
end procedure.
         
