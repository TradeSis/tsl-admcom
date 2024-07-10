{admcab.i}

def shared temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def buffer btt-clase for tt-clase.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Incluir "," Confirmar "," Excluir ","",""].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Incluir Clase no Filtro ",
             " Excluir Clase do Filtro ",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].


def var vtt-clase         like tt-clase.clacod.


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

for each tt-clase:
delete tt-clase.
end.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-clase where recid(tt-clase) = recatu1 no-lock.
    if not available tt-clase
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-clase).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-clase
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
            find tt-clase where recid(tt-clase) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-clase.clanom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-clase.clanom)
                                        else "".
            run color-message.
            choose field tt-clase.clacod tt-clase.clanom help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) /*color white/black*/.
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
                    if not avail tt-clase
                    then leave.
                    recatu1 = recid(tt-clase).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-clase
                    then leave.
                    recatu1 = recid(tt-clase).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-clase
                then next.
                color display white/red tt-clase.clacod
                                        tt-clase.clanom
                                        with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-clase
                then next.
                color display white/red tt-clase.clacod
                                        tt-clase.clanom with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            leave bl-princ.
        end.            

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Confirmar "
                then do on error undo.
                    leave bl-princ.
                end.
                if esqcom1[esqpos1] = " Incluir " or esqvazio
                then do on error undo.

                    create tt-clase.
                    update tt-clase.clacod
                           with frame frame-a.
                    
                    find clase where clase.clacod = tt-clase.clacod no-error.
                    if not avail clase
                    then do:
                        delete tt-clase.
                        message "Clase nao cadastrada.".
                        undo.
                    end.
                    else tt-clase.clanom = clase.clanom.

                    run frame-a.                    
                    if frame-line(frame-a) = frame-down(frame-a)
                    then scroll with frame frame-a.
                    else down with frame frame-a.
                    
                end.

                if esqcom1[esqpos1] = " Excluir "
                then do on error undo.
                    message "Confirma Exclusao de" tt-clase.clanom
                            " do filtro ?"
                            update sresp.
                    if not sresp
                    then undo, leave.
                    
                    find next tt-clase where true no-error.
                    if not available tt-clase
                    then do:
                        find tt-clase where recid(tt-clase) = recatu1.
                        find prev tt-clase where true no-error.
                    end.
                    
                    recatu2 = if available tt-clase
                              then recid(tt-clase)
                              else ?.
                    
                    find tt-clase where recid(tt-clase) = recatu1
                            exclusive.
                    delete tt-clase.
                    recatu1 = recatu2.
                    leave.
                end.                
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
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
        recatu1 = recid(tt-clase).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        find first tt-clase where tt-clase.clacod = 0.
        if avail tt-clase
        then
            delete tt-clase.
        recatu1 = ?.    
            
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

def temp-table tt-cla1 like tt-clase.
def buffer bclase for clase.
def buffer eclase for clase.
def buffer dclase for clase.
def buffer fclase for clase.

for each tt-clase:
    create tt-cla1.
    buffer-copy tt-clase to tt-cla1.
end.

for each tt-cla1.
    for each bclase where bclase.clasup = tt-cla1.clacod no-lock:
        create tt-clase.
        tt-clase.clacod = bclase.clacod.
        for each eclase where eclase.clasup = bclase.clacod no-lock:
            create tt-clase.
            tt-clase.clacod = eclase.clacod.
            for each dclase where dclase.clasup = eclase.clacod no-lock:
                create tt-clase.
                tt-clase.clacod = dclase.clacod.
                for each fclase where fclase.clasup = dclase.clacod no-lock:
                    create tt-clase.
                    tt-clase.clacod = fclase.clacod.
                end.
            end.
        end.
    end.            
end.    

procedure frame-a.
display tt-clase.clacod column-label "Classe"    format ">>>>>>>>9"
        tt-clase.clanom column-label "Descricao"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
    color display message
            tt-clase.clacod
            tt-clase.clanom
            with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-clase.clacod
        tt-clase.clanom
        with frame frame-a.
end procedure.

procedure leitura. 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-clase where true
                                                no-lock no-error.
    else  
        find last tt-clase  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-clase  where true
                                                no-lock no-error.
    else  
        find prev tt-clase   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-clase where true  
                                        no-lock no-error.
    else   
        find next tt-clase where true 
                                        no-lock no-error.
        
end procedure.
         
