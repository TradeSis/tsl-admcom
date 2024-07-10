/*
*
*    prof226.p    -    Esqueleto de Programacao    com esqvazio
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
    initial [" Consulta "," Precos 1701  ", " Precos 810 ", " Custos 405 ",
                                " MIX 323 "].
def var esqcom2         as char format "x(12)" extent 5
            initial ["  ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i }

def var vbusca          as   char label "SKU".
def var primeiro        as   log.

def buffer bprof226       for prof226.
def var vprof226         like prof226.sku_id.

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
        find prof226 where recid(prof226) = recatu1 no-lock.
    if not available prof226
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(prof226).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available prof226
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
            find prof226 where recid(prof226) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(prof226.sku_id)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(prof226.sku_id)
                                        else "".
            run color-message.
            choose field prof226.sku_id help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      1 2 3 4 5 6 7 8 9 0 
                      page-down   page-up
                      tab PF4 F4 ESC return) .
            run color-normal.
            status default "".
            if keyfunction(lastkey) = "0" or
               keyfunction(lastkey) = "1" or
               keyfunction(lastkey) = "2" or 
               keyfunction(lastkey) = "3" or 
               keyfunction(lastkey) = "4" or 
               keyfunction(lastkey) = "5" or 
               keyfunction(lastkey) = "6" or 
               keyfunction(lastkey) = "7" or 
               keyfunction(lastkey) = "8" or 
               keyfunction(lastkey) = "9"
            then do with frame fbusca
                        centered color normal side-labels row 10 overlay:
                pause 0.
                vbusca = keyfunction(lastkey).
                primeiro = yes.
                update vbusca
                    editing:
                        if primeiro
                        then do:
                            apply keycode("cursor-right").
                            primeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                end.
                /* update vbusca.*/
                recatu2 = recid(Prof226).
                find first Prof226 
                            where 
                            Prof226.sku_ID >= vbusca 
                                no-lock no-error.                        
                if avail Prof226
                then recatu1 = recid(Prof226).
                else recatu1 = recatu2.
                leave.
            end.

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
                    if not avail prof226
                    then leave.
                    recatu1 = recid(prof226).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail prof226
                    then leave.
                    recatu1 = recid(prof226).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail prof226
                then next.
                color display white/red prof226.sku_id with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail prof226
                then next.
                color display white/red prof226.sku_id with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form prof226
                 with frame f-prof226 color black/cyan
                      centered side-label row 5 1 column.
            if esqcom1[esqpos1] <> " MIX 323 "
            then hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Precos 1701 " 
                then do with frame f-prof226 on error undo.
                    hide frame f-com1  no-pause. 
                    hide frame f-com2  no-pause.
                    run itim/tprodu1701.p (prof226.sku_id).
                    view frame f-com1. 
                    view frame f-com2.
                    recatu1 = recid(prof226).
                    leave.
                end.
                if esqcom1[esqpos1] = " Precos 810 " 
                then do with frame f-prof226 on error undo.
                    hide frame f-com1  no-pause. 
                    hide frame f-com2  no-pause.
                    run itim/tprodu810.p (prof226.sku_id).
                    view frame f-com1. 
                    view frame f-com2.
                    recatu1 = recid(prof226).
                    leave.
                end.
                if esqcom1[esqpos1] = " Custos 405 " 
                then do with frame f-prof226 on error undo.
                    hide frame f-com1  no-pause. 
                    hide frame f-com2  no-pause.
                    run itim/tprodu405.p (prof226.sku_id).
                    view frame f-com1. 
                    view frame f-com2.
                    recatu1 = recid(prof226).
                    leave.
                end.

                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-prof226.
                    disp prof226.
                end.
                if esqcom1[esqpos1] = " MIX 323 "
                then do with frame f-prof226 on error undo.
                    clear frame frame-a all no-pause.
                    run frame-a.
                    hide frame f-com1  no-pause. 
                    hide frame f-com2  no-pause.
                    run itim/tprodu323.p (int(prof226.sku_id)).
                    view frame f-com1. 
                    view frame f-com2.
                    recatu1 = recid(prof226).
                    leave.
                    
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" prof226.sku_id
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next prof226 where true no-error.
                    if not available prof226
                    then do:
                        find prof226 where recid(prof226) = recatu1.
                        find prev prof226 where true no-error.
                    end.
                    recatu2 = if available prof226
                              then recid(prof226)
                              else ?.
                    find prof226 where recid(prof226) = recatu1
                            exclusive.
                    delete prof226.
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
                    then run lprof226.p (input 0).
                    else run lprof226.p (input prof226.sku_id).
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
        recatu1 = recid(prof226).
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
    find produ where produ.procod = int(prof226.sku_id) no-lock no-error. 
    display prof226.sku_id
            produ.pronom when avail produ format "x(36)"
            prof226.motivo format "x(20)"
            prof226.data_expo label "Exportacao"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.

color display message
        prof226.sku_id
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        prof226.sku_id
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first prof226 where true
                                                no-lock no-error.
    else  
        find last prof226  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next prof226  where true
                                                no-lock no-error.
    else  
        find prev prof226   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev prof226 where true  
                                        no-lock no-error.
    else   
        find next prof226 where true 
                                        no-lock no-error.
        
end procedure.
         
