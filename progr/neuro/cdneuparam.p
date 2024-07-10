/*
*
*    neuparam.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i new}
def var vtipo like neuparam.tipo init 1.
def var vhora as char.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Situacao "," Consulta "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de neuparam ",
             " Alteracao da neuparam ",
             " Situacao  da neuparam ",
             " Consulta  da neuparam ",
             " Listagem  Geral de neuparam "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def buffer bneuparam       for neuparam.
def var vneuparam         like neuparam.etbcod.

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
        find neuparam where recid(neuparam) = recatu1 no-lock.
    if not available neuparam
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(neuparam).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available neuparam
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
            find neuparam where recid(neuparam) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(neuparam.etbcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(neuparam.etbcod)
                                        else "".
            run color-message.
            choose field neuparam.etbcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
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
                    if not avail neuparam
                    then leave.
                    recatu1 = recid(neuparam).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail neuparam
                    then leave.
                    recatu1 = recid(neuparam).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail neuparam
                then next.
                color display white/red neuparam.etbcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail neuparam
                then next.
                color display white/red neuparam.etbcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form neuparam
                 with frame f-neuparam color black/cyan
                      centered side-label row 5 with 1 col.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-neuparam on error undo.
                    prompt-for neuparam.etbcod.
                    find last bneuparam where bneuparam.tipo   = vtipo
                                          and bneuparam.etbcod = input
                                               neuparam.etbcod
                                        no-lock no-error.
                    create neuparam.
                    assign
                        neuparam.tipo    = vtipo
                        neuparam.etbcod  = input neuparam.etbcod
                        neuparam.seq     = if avail bneuparam
                                           then bneuparam.seq + 1
                                           else 1
                        neuparam.hrinclu = time.
                    disp neuparam.
                    update neuparam.campo
                        neuparam.operador
                        neuparam.valor
                        neuparam.neurotech
                        neuparam.gerarlog.
                    recatu1 = recid(neuparam).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Situacao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-neuparam.
                    disp neuparam.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-neuparam on error undo.
                    find neuparam where recid(neuparam) = recatu1 exclusive.
                    update neuparam.valor
                        neuparam.neurotech
                        neuparam.gerarlog.
                end.
                if esqcom1[esqpos1] = " Situacao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" neuparam.etbcod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find neuparam where recid(neuparam) = recatu1 exclusive.
                    neuparam.situacao = not neuparam.situacao.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
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
        recatu1 = recid(neuparam).
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
    vhora = string(neuparam.hrinclu, "hh:mm:ss").
    display neuparam except tipo
        with frame frame-a 11 down centered color white/red row 5.
    disp vhora @ neuparam.hrinclu with frame frame-a.
end procedure.

procedure color-message.
    color display message
        neuparam.etbcod
        neuparam.seq
        neuparam.campo
        neuparam.operador
        neuparam.valor
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
        neuparam.etbcod
        neuparam.seq
        neuparam.campo
        neuparam.operador
        neuparam.valor
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then find first neuparam where neuparam.tipo = vtipo no-lock no-error.
    else find last neuparam  where neuparam.tipo = vtipo no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then find next neuparam  where neuparam.tipo = vtipo no-lock no-error.
    else find prev neuparam  where neuparam.tipo = vtipo no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then find prev neuparam where neuparam.tipo = vtipo no-lock no-error.
    else find next neuparam where neuparam.tipo = vtipo no-lock no-error.
        
end procedure.
