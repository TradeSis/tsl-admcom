/*
*
*    prof_1521.p    -    Esqueleto de Programacao    com esqvazio


            substituir    prof_1521
                          <tab>
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
    initial [" Consulta ",""].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}
def input parameter par-rec as recid.
find prof_1504 where recid(prof_1504) = par-rec no-lock.

display prof_1504.EVENT_ID format "x(15)"
EVENT_TYPE
EVENT_DESC format "x(30)"
        with frame frame-xxa 1 down centered row 3
                no-underline no-label no-box color message
                        width 81 .

def buffer bprof_1521       for prof_1521.
def var vprof_1521         like prof_1521.sub_EVENT_ID.


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
    
form prof_1521.sub_EVENT_ID
            with frame frame-a.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find prof_1521 where recid(prof_1521) = recatu1 no-lock.
    if not available prof_1521
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else leave.

    recatu1 = recid(prof_1521).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available prof_1521
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
            find prof_1521 where recid(prof_1521) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(prof_1521.SUB_EVENT_ID)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(prof_1521.SUB_EVENT_ID)
                                        else "".
            run color-message.
            choose field prof_1521.SUB_EVENT_ID help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
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
                    if not avail prof_1521
                    then leave.
                    recatu1 = recid(prof_1521).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail prof_1521
                    then leave.
                    recatu1 = recid(prof_1521).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail prof_1521
                then next.
                color display white/red prof_1521.SUB_EVENT_ID with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail prof_1521
                then next.
                color display white/red prof_1521.SUB_EVENT_ID with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form prof_1521.LINKED_SUB_EVENT_ID format "x(30)"
                    SUB_EVENT_DESC format "x(60)"
                    
                 with frame f-prof_1521 color black/cyan
                      centered side-label row 5 3 column.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-prof_1521 on error undo.
                    recatu1 = recid(prof_1521).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-prof_1521.
                    disp prof_1521 .
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-prof_1521 on error undo.
                    find prof_1521 where
                            recid(prof_1521) = recatu1 
                        exclusive.
                    update prof_1521.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" prof_1521.SUB_EVENT_ID
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next prof_1521 where of prof_1504 no-error.
                    if not available prof_1521
                    then do:
                        find prof_1521 where recid(prof_1521) = recatu1.
                        find prev prof_1521 where of prof_1504 no-error.
                    end.
                    recatu2 = if available prof_1521
                              then recid(prof_1521)
                              else ?.
                    find prof_1521 where recid(prof_1521) = recatu1
                            exclusive.
                    delete prof_1521.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run lprof_1521.p (input 0).
                    else run lprof_1521.p (input prof_1521.SUB_EVENT_ID).
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
        recatu1 = recid(prof_1521).
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
display prof_1521.sub_EVENT_ID  format "x(40)"
        prof_1521.SUB_EVENT_ID format "x(30)"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        prof_1521.SUB_EVENT_ID
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        prof_1521.SUB_EVENT_ID
        with frame frame-a.
end procedure.





procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first prof_1521 where of prof_1504
                                                no-lock no-error.
    else  
        find last prof_1521  where of prof_1504
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next prof_1521  where of prof_1504
                                                no-lock no-error.
    else  
        find prev prof_1521   where of prof_1504
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev prof_1521 where of prof_1504  
                                        no-lock no-error.
    else   
        find next prof_1521 where of prof_1504 
                                        no-lock no-error.
        
end procedure.
         
