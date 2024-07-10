/* itim/itim_data.p */

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial no.
def var esqcom1         as char format "x(15)" extent 5
    init [" Consulta "," Alteracao ","Check End Batch", ""].
def var esqcom2         as char format "x(12)" extent 5.

{admcab.i}

def buffer blog_tbcntgen       for log_tbcntgen.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels centered.
form
    esqcom2
    with frame f-com2 row screen-lines no-box no-labels centered.
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
        find log_tbcntgen where recid(log_tbcntgen) = recatu1 no-lock.
    if not available log_tbcntgen
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(log_tbcntgen).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available log_tbcntgen
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
            find log_tbcntgen where recid(log_tbcntgen) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field log_tbcntgen.Data help ""
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
                    if not avail log_tbcntgen
                    then leave.
                    recatu1 = recid(log_tbcntgen).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail log_tbcntgen
                    then leave.
                    recatu1 = recid(log_tbcntgen).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail log_tbcntgen
                then next.
                color display white/red log_tbcntgen.Data with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail log_tbcntgen
                then next.
                color display white/red log_tbcntgen.Data with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form 
                 with frame f-log_tbcntgen color black/cyan
                      centered side-label row 5 1 column.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " alteracao " 
                then do with frame f-log_tbcntgen.
                    run alteracao.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = "Check End Batch"
                then run check-end.
                
                if esqcom1[esqpos1] = " Consulta " 
                then do with frame f-log_tbcntgen.
                    display log_tbcntgen.data
                            string(log_tbcntgen.hora,"HH:MM:SS") label "Hora"
                            datini column-label "Data Alterada"
                            funcod
                            motivo format "x(37)"
                            with frame f-log_tbcntgen .
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
        recatu1 = recid(log_tbcntgen).
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
display log_tbcntgen.data
        string(log_tbcntgen.hora,"HH:MM:SS") label "Hora"
        datini column-label "Data Alterada"
        funcod
        motivo format "x(37)"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
color display message
        log_tbcntgen.Data
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        log_tbcntgen.Data
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first log_tbcntgen where true
                                                no-lock no-error.
    else  
        find last log_tbcntgen  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next log_tbcntgen  where true
                                                no-lock no-error.
    else  
        find prev log_tbcntgen   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev log_tbcntgen where true  
                                        no-lock no-error.
    else   
        find next log_tbcntgen where true 
                                        no-lock no-error.
        
end procedure.


procedure alteracao.
def var vdtini as date.
def var vdtfim as date.
def var vmotivo as char.

find first tbcntgen where tbcntgen.tipcon = 10 and
                          tbcntgen.etbcod = 0 no-lock.
vdtini = tbcntgen.datini.
vdtfim = tbcntgen.datfim.
update "Data do processamento" vdtini format "99/99/9999" skip
        with no-label
            row 8 overlay color message centered.
if vdtini entered
then do.
    message "Confirma a alteracao da data de exportacao ?"
            update sresp.
    if sresp = no then leave.
    do on error undo.
        update "Motivo" vmotivo format "x(60)".
        if length(vmotivo) < 15 
        then do.
            message "Informe um motivo com mais de 15 caracteres". 
            undo.
        end.
    end.
    do on error undo.            
        find first tbcntgen where tbcntgen.tipcon = 10 and
                                  tbcntgen.etbcod = 0.
        tbcntgen.datini = vdtini.
        tbcntgen.datfim = vdtini. 
        pause 1 no-message.
        create log_tbcntgen. 
        ASSIGN log_tbcntgen.tipcon = tbcntgen.tipcon 
               log_tbcntgen.datini = tbcntgen.datini 
               log_tbcntgen.datfim = tbcntgen.datfim 
               log_tbcntgen.dtexp  = today
               log_tbcntgen.Data   = today
               log_tbcntgen.hora   = time
               log_tbcntgen.funcod = sfuncod
               log_tbcntgen.Motivo = vMotivo.
    end.
end.    

end procedure.


procedure check-end.
    def var vcheck as int.

    find first tbcntgen where tbcntgen.tipcon = 10 and
                              tbcntgen.etbcod = 0 no-lock.
    vcheck = int(tbcntgen.campo1[1]).
    update vcheck label "Check End Batch" format "9" validate (vcheck > 0,"")
        with frame f-check side-label centered.
    
    do on error undo.            
        find first tbcntgen where tbcntgen.tipcon = 10 and
                                  tbcntgen.etbcod = 0.
        tbcntgen.campo1[1] = string(vcheck).
    end.    
end procedure.

