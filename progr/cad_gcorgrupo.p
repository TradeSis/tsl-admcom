/*
*
*    gcorclasse.p    -    Esqueleto de Programacao    com esqvazio
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
    initial [" Inclusao "," Alteracao "," Exclusao "," "," "].
def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

{admcab.i}
def input parameter par-rec as recid.
find gru_cores where recid(gru_cores) = par-rec no-lock.
display gru_cores.gruccod colon 20 label "Grupo de Cor"
        gru_cores.grucnom no-label
        with frame fff row 3 side-label no-box color message width 81.

def buffer bgcorclasse       for gcorclasse.

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
        find gcorclasse where recid(gcorclasse) = recatu1 no-lock.
    if not available gcorclasse
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(gcorclasse).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available gcorclasse
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
            find gcorclasse where recid(gcorclasse) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(gcorclasse.gruccod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(gcorclasse.gruccod)
                                        else "".
            run color-message.
            choose field gcorclasse.clacod help ""
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
                    if not avail gcorclasse
                    then leave.
                    recatu1 = recid(gcorclasse).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail gcorclasse
                    then leave.
                    recatu1 = recid(gcorclasse).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail gcorclasse
                then next.
                color display white/red gcorclasse.clacod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail gcorclasse
                then next.
                color display white/red gcorclasse.clacod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            def var grupo-clacod like clase.clacod.
            form grupo-clacod
                 with frame f-gcorclasse color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-gcorclasse on error undo.
                    create gcorclasse.
                    gcorclasse.gruccod = gru_cores.gruccod.
                    update grupo-clacod label "Grupo".
                    gcorclasse.clacod = grupo-clacod.
                    find first clase of gcorclasse where
                            clase.clagrau = 2 and clatipo
                                        no-lock no-error.
                    if not avail clase then do.
                        message "Grupo invalido".
                        undo.
                    end.
                    
                    recatu1 = recid(gcorclasse).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-gcorclasse.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-gcorclasse on error undo.
                    find gcorclasse where recid(gcorclasse) = recatu1 
                        exclusive.
                    grupo-clacod = gcorclasse.clacod.
                    update grupo-clacod label "Grupo".
                    gcorclasse.clacod = grupo-clacod.
                    find first clase of gcorclasse where
                            clase.clagrau = 2 and clatipo
                                        no-lock no-error.
                    if not avail clase then do.
                        message "Grupo invalido".
                        undo.
                    end.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" gcorclasse.clacod "?"
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next gcorclasse where of gru_cores no-error.
                    if not available gcorclasse
                    then do:
                        find gcorclasse where recid(gcorclasse) = recatu1.
                        find prev gcorclasse where of gru_cores no-error.
                    end.
                    recatu2 = if available gcorclasse
                              then recid(gcorclasse)
                              else ?.
                    find gcorclasse where recid(gcorclasse) = recatu1
                            exclusive.
                    delete gcorclasse.
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
        recatu1 = recid(gcorclasse).
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
    find clase of gcorclasse no-lock.
    display
        gcorclasse.clacod column-label "Grupo"
        clase.clanom      column-label "Grupo"
        gcorclasse.situacao
        with frame frame-a screen-lines - 11 down centered color white/red
         row 5.
end procedure.

procedure color-message.
color display message
        gcorclasse.clacod
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        gcorclasse.clacod
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first gcorclasse where of gru_cores
                                                no-lock no-error.
    else  
        find last gcorclasse  where of gru_cores
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next gcorclasse  where of gru_cores
                                                no-lock no-error.
    else  
        find prev gcorclasse   where of gru_cores
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev gcorclasse where of gru_cores  
                                        no-lock no-error.
    else   
        find next gcorclasse where of gru_cores 
                                        no-lock no-error.
        
end procedure.
         
