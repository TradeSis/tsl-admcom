/*
*
*    grafabri.p    -    Esqueleto de Programacao    com esqvazio
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," "].
def var esqhel1         as char format "x(80)" extent 5.

{admcab.i}
def input parameter par-rec as recid.
find grade where recid(grade) = par-rec no-lock.
display grade.gracod colon 20 label "Grade"
        grade.granom no-label
        with frame fff row 3 side-label no-box color message
                        width 81.

def buffer bgrafabri       for grafabri.

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
        find grafabri where recid(grafabri) = recatu1 no-lock.
    if not available grafabri
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(grafabri).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available grafabri
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
            find grafabri where recid(grafabri) = recatu1 no-lock.

            status default "".

            run color-message.
            choose field grafabri.fabcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
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
                    if not avail grafabri
                    then leave.
                    recatu1 = recid(grafabri).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail grafabri
                    then leave.
                    recatu1 = recid(grafabri).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail grafabri
                then next.
                color display white/red grafabri.fabcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail grafabri
                then next.
                color display white/red grafabri.fabcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            def var vfabcod like fabri.fabcod.
            form vfabcod
                 with frame f-grafabri color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-grafabri on error undo.
                    create grafabri.
                    grafabri.gracod = grade.gracod.
                    update vfabcod label "Fabricante".
                    grafabri.fabcod = vfabcod.
                    find first fabri of grafabri where
                                        no-lock no-error.
                    if not avail fabri then do.
                        message "Fabricante invalido".
                        undo.
                    end.
                    
                    recatu1 = recid(grafabri).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-grafabri.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-grafabri on error undo.
                    find grafabri where recid(grafabri) = recatu1 exclusive.
                    vfabcod = grafabri.fabcod.
                    update vfabcod label "Fabricante".
                    grafabri.fabcod = vfabcod.
                    find first fabri of grafabri where
                                        no-lock no-error.
                    if not avail fabri then do.
                        message "Fabricante invalido".
                        undo.
                    end.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" grafabri.fabcod "?"
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next grafabri where of grade no-error.
                    if not available grafabri
                    then do:
                        find grafabri where recid(grafabri) = recatu1.
                        find prev grafabri where of grade no-error.
                    end.
                    recatu2 = if available grafabri
                              then recid(grafabri)
                              else ?.
                    find grafabri where recid(grafabri) = recatu1
                            exclusive.
                    delete grafabri.
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
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(grafabri).
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

    find fabri of grafabri no-lock.
    display
        grafabri.fabcod column-label "Fabricante"
        fabri.fabnom    column-label ""
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
color display message
        grafabri.fabcod
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        grafabri.fabcod
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first grafabri where of grade
                                                no-lock no-error.
    else  
        find last grafabri  where of grade
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next grafabri  where of grade
                                                no-lock no-error.
    else  
        find prev grafabri   where of grade
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev grafabri where of grade  
                                        no-lock no-error.
    else   
        find next grafabri where of grade 
                                        no-lock no-error.
        
end procedure.
         
