{admcab.i}

def input  parameter par-fab like fabri.fabcod.
/**def output parameter par-pro like produ.procod.*/

def shared temp-table tt-cla
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def temp-table tt-pro
    field marca  as   char format "x"
    field procod like produ.procod
    field pronom like produ.pronom
    index iprodu is primary unique procod desc.

def shared temp-table tt-produ
    field procod like produ.procod.

find first tt-cla no-lock no-error.
if not avail tt-cla
then do: /* monta temp soh com os produtos do fabricante escolhido */

    for each produ where produ.fabcod = par-fab no-lock:
        find first tt-pro where
                   tt-pro.procod = produ.procod no-error.
        if not avail tt-pro
        then do:
            create tt-pro.
            assign tt-pro.procod = produ.procod
                   tt-pro.pronom = produ.pronom.
        end.
    end.

end.    
else do: /* monta temp com os produtos com classe = tt-cla e ou com do fabricante escolhido */
    for each tt-cla no-lock:
        for each produ where produ.clacod = tt-cla.clacod no-lock:

            if par-fab <> 0
            then if produ.fabcod <> par-fab
                 then next.
            
            find first tt-pro where
                       tt-pro.procod = produ.procod no-error.
            if not avail tt-pro
            then do:
                create tt-pro.
                assign tt-pro.procod = produ.procod
                       tt-pro.pronom = produ.pronom.
            end.
        end.            
    end.
end.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Selecionar "," "," "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Tecle Enter para selecionar o produto ",
             " ",
             " ",
             " ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].


def buffer btt-pro       for tt-pro.
def var vtt-pro         like tt-pro.procod.


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

recatu1 = ?.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-pro where recid(tt-pro) = recatu1 no-lock.
        
    if not available tt-pro
    then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-pro).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-pro
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
            find tt-pro where recid(tt-pro) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-pro.pronom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-pro.pronom)
                                        else "".
            run color-message.
            choose field tt-pro.marca
                         tt-pro.procod 
                         tt-pro.pronom help ""
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
                    if not avail tt-pro
                    then leave.
                    recatu1 = recid(tt-pro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-pro
                    then leave.
                    recatu1 = recid(tt-pro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-pro
                then next.
                color display white/red 
                tt-pro.marca
                tt-pro.procod 
                tt-pro.pronom with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-pro
                then next.
                color display white/red 
                    tt-pro.marca
                    tt-pro.procod 
                    tt-pro.pronom with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" 
        then do:
            form tt-pro
                 with frame f-tt-pro color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Selecionar " 
                then do with frame f-tt-pro on error undo.
                    /**par-pro = tt-pro.procod.
                    leave bl-princ.**/
                    
                    find tt-produ where 
                         tt-produ.procod = tt-pro.procod no-error.
                    if not avail tt-produ
                    then do:
                        create tt-produ.
                        assign tt-produ.procod = tt-pro.procod.
                        tt-pro.marca = "*".
                    end.    
                    else do:
                        tt-pro.marca = "".
                        delete tt-produ.
                    end. 
                end.
                
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-pro.
                    disp tt-pro.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-pro on error undo.
                    find tt-pro where
                            recid(tt-pro) = recatu1 
                        exclusive.
                    update tt-pro.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-pro.pronom
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-pro where true no-error.
                    if not available tt-pro
                    then do:
                        find tt-pro where recid(tt-pro) = recatu1.
                        find prev tt-pro where true no-error.
                    end.
                    recatu2 = if available tt-pro
                              then recid(tt-pro)
                              else ?.
                    find tt-pro where recid(tt-pro) = recatu1
                            exclusive.
                    delete tt-pro.
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
                    then run ltt-pro.p (input 0).
                    else run ltt-pro.p (input tt-pro.procod).
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
        recatu1 = recid(tt-pro).
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
    display tt-pro.marca  no-label
            tt-pro.procod column-label "Codigo"
            tt-pro.pronom column-label "Produto"
            with frame frame-a 11 down centered 
                       overlay color white/red row 5.
end procedure.
procedure color-message.
    color display message tt-pro.marca  no-label
                          tt-pro.procod column-label "Codigo"
                          tt-pro.pronom column-label "Produto"
                          with frame frame-a.
end procedure.
procedure color-normal.
    color display normal tt-pro.marca  no-label
                         tt-pro.procod column-label "Codigo" 
                         tt-pro.pronom column-label "Produto"
                         with frame frame-a.
end procedure.

procedure leitura. 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-pro where true
                                                no-lock no-error.
    else  
        find last tt-pro  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-pro  where true
                                                no-lock no-error.
    else  
        find prev tt-pro   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-pro where true  
                                        no-lock no-error.
    else   
        find next tt-pro where true 
                                        no-lock no-error.
        
end procedure.
         

/*****/
