{admcab.i}

def shared temp-table tt-plano
    field fincod like finan.fincod
    field finnom like finan.finnom
    index iplano is primary unique fincod.

def buffer btt-plano for tt-plano.

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
    initial [" Incluir Plano no Filtro ",
             " Excluir Plano do Filtro ",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].


def var vtt-plano         like tt-plano.fincod.


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

for each tt-plano:
delete tt-plano.
end.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-plano where recid(tt-plano) = recatu1 no-lock.
    if not available tt-plano
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-plano).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-plano
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
            find tt-plano where recid(tt-plano) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-plano.finnom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-plano.finnom)
                                        else "".
            run color-message.
            choose field tt-plano.fincod tt-plano.finnom help ""
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
                    if not avail tt-plano
                    then leave.
                    recatu1 = recid(tt-plano).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-plano
                    then leave.
                    recatu1 = recid(tt-plano).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-plano
                then next.
                color display white/red tt-plano.fincod
                                        tt-plano.finnom
                                        with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-plano
                then next.
                color display white/red tt-plano.fincod
                                        tt-plano.finnom with frame frame-a.
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

                    create tt-plano.
                    update tt-plano.fincod
                           with frame frame-a.
                    
                    find finan where finan.fincod = tt-plano.fincod
                                                no-lock no-error. 
                    if not avail finan
                    then do:
                        delete tt-plano.
                        message "Plano nao cadastrado.".
                        undo.
                    end.
                    else tt-plano.finnom = finan.finnom.

                    run frame-a.                    
                    if frame-line(frame-a) = frame-down(frame-a)
                    then scroll with frame frame-a.
                    else down with frame frame-a.
                    
                end.

                if esqcom1[esqpos1] = " Excluir "
                then do on error undo.
                    message "Confirma Exclusao de" tt-plano.finnom
                            " do filtro ?"
                            update sresp.
                    if not sresp
                    then undo, leave.
                    
                    find next tt-plano where true no-error.
                    if not available tt-plano
                    then do:
                        find tt-plano where recid(tt-plano) = recatu1.
                        find prev tt-plano where true no-error.
                    end.
                    
                    recatu2 = if available tt-plano
                              then recid(tt-plano)
                              else ?.
                    
                    find tt-plano where recid(tt-plano) = recatu1
                            exclusive.
                    delete tt-plano.
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
        recatu1 = recid(tt-plano).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        find first tt-plano where tt-plano.fincod = 0.
        if avail tt-plano
        then
            delete tt-plano.
        recatu1 = ?.    
            
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.
/*
for each finan no-lock:

    create tt-plano.
    assign tt-plano.fincod = finan.fincod
           tt-plano.finnom = finan.finnom. 

end.
*/
procedure frame-a.
display tt-plano.fincod column-label "Plano"    format ">>>>>>9"
        tt-plano.finnom column-label "Descricao"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
    color display message
            tt-plano.fincod
            tt-plano.finnom
            with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-plano.fincod
        tt-plano.finnom
        with frame frame-a.
end procedure.

procedure leitura. 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-plano where true
                                                no-lock no-error.
    else  
        find last tt-plano  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-plano  where true
                                                no-lock no-error.
    else  
        find prev tt-plano   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-plano where true  
                                        no-lock no-error.
    else   
        find next tt-plano where true 
                                        no-lock no-error.
        
end procedure.
         
