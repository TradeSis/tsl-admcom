{admcab.i}

def shared temp-table tt-func-aux
    field funcod like func.funcod
    field funnom like func.funnom
    index ifunc is primary unique funcod.

def buffer btt-func-aux for tt-func-aux.

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
    initial [" Incluir func no Filtro ",
             " Excluir func do Filtro ",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].


def var vtt-func-aux         like tt-func-aux.funcod.


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

for each tt-func-aux:
delete tt-func-aux.
end.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-func-aux where recid(tt-func-aux) = recatu1 no-lock.
    if not available tt-func-aux
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-func-aux).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-func-aux
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
            find tt-func-aux where recid(tt-func-aux) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-func-aux.funnom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-func-aux.funnom)
                                        else "".
            run color-message.
            choose field tt-func-aux.funcod tt-func-aux.funnom help ""
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
                    if not avail tt-func-aux
                    then leave.
                    recatu1 = recid(tt-func-aux).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-func-aux
                    then leave.
                    recatu1 = recid(tt-func-aux).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-func-aux
                then next.
                color display white/red tt-func-aux.funcod
                                        tt-func-aux.funnom
                                        with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-func-aux
                then next.
                color display white/red tt-func-aux.funcod
                                        tt-func-aux.funnom with frame frame-a.
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

                    create tt-func-aux.
                    update tt-func-aux.funcod
                           with frame frame-a.
                    
                    find func where func.etbcod = 999
                                and func.funcod = tt-func-aux.funcod no-error.
                    if not avail func
                    then do:
                        delete tt-func-aux.
                        message "Funcionário nao cadastrado.".
                        undo.
                    end.
                    else tt-func-aux.funnom = func.funnom.

                    run frame-a.                    
                    if frame-line(frame-a) = frame-down(frame-a)
                    then scroll with frame frame-a.
                    else down with frame frame-a.
                    
                end.

                if esqcom1[esqpos1] = " Excluir "
                then do on error undo.
                    message "Confirma Exclusao de " tt-func-aux.funnom
                            "?"
                            update sresp.
                    if not sresp
                    then undo, leave.
                    
                    find next tt-func-aux where true no-error.
                    if not available tt-func-aux
                    then do:
                        find tt-func-aux where recid(tt-func-aux) = recatu1.
                        find prev tt-func-aux where true no-error.
                    end.
                    
                    recatu2 = if available tt-func-aux
                              then recid(tt-func-aux)
                              else ?.
                    
                    find tt-func-aux where recid(tt-func-aux) = recatu1
                            exclusive.
                    delete tt-func-aux.
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
        recatu1 = recid(tt-func-aux).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        find first tt-func-aux where tt-func-aux.funcod = 0.
        if avail tt-func-aux
        then
            delete tt-func-aux.
        recatu1 = ?.    
            
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.


procedure frame-a.
display tt-func-aux.funcod column-label "Funcionario"    format ">>>>>>9"
        tt-func-aux.funnom column-label "Nome"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
    color display message
            tt-func-aux.funcod
            tt-func-aux.funnom
            with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-func-aux.funcod
        tt-func-aux.funnom
        with frame frame-a.
end procedure.

procedure leitura. 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-func-aux where true
                                                no-lock no-error.
    else  
        find last tt-func-aux  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-func-aux  where true
                                                no-lock no-error.
    else  
        find prev tt-func-aux   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-func-aux where true  
                                        no-lock no-error.
    else   
        find next tt-func-aux where true 
                                        no-lock no-error.
        
end procedure.
         


