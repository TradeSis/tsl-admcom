{admcab.i}
                       pause 0.

def temp-table tt-nf 
    field etbcod like plani.etbcod
    field placod like plani.placod
    field numero like plani.numero
    field serie  like plani.serie
    field pladat like plani.pladat
    field movqtm like movim.movqtm
    field movpc  like movim.movpc
    index idata pladat desc.
    
form
    tt-nf.numero column-label "Número"
    tt-nf.serie  column-label "Série"
    tt-nf.pladat column-label "Emissão" format "99/99/9999"
    tt-nf.movqtm column-label "Quantidade"
    tt-nf.movpc  column-label "V.Unitário"
    with frame frame-a2 row 13 6 down overlay centered
    title " Notas Fiscais de Compra ".
     
 def input parameter p-procod like produ.procod.
 def var vdata as date format "99/99/9999".
    
for each tt-nf:
    delete tt-nf.
end.

                    do vdata = today - 365 to today:
                      for each tipmov where tipmov.movtdc = 1 or
                                            tipmov.movtdc = 4 no-lock:
                          for each movim where movim.procod = p-procod
                                         and movim.movtdc = tipmov.movtdc
                                         and movim.movdat = vdata no-lock.
                              find plani where plani.etbcod = movim.etbcod
                                           and plani.placod = movim.placod
                                           and plani.movtdc = movim.movtdc
                                           no-lock no-error.
                              if not avail plani then next.

                              disp plani.numero plani.pladat
                              with frame f-disp
                              centered side-labels 1 down. pause 0.
                              
                              find tt-nf where tt-nf.etbcod = plani.etbcod
                                           and tt-nf.placod = plani.placod
                                               no-error.

                              if not avail tt-nf
                              then do:
                                 create tt-nf.
                                 assign tt-nf.etbcod = plani.etbcod
                                        tt-nf.placod = plani.placod
                                        tt-nf.numero = plani.numero 
                                        tt-nf.serie  = plani.serie 
                                        tt-nf.pladat = plani.pladat
                                        tt-nf.movqtm = movim.movqtm
                                        tt-nf.movpc  = movim.movpc.
                              
                              end.
                          end.

                      end.  
                    end.
           
find first tt-nf no-error.
if not avail tt-nf
then do:
    message "Nao foram encontradas Notas para este produto".
    undo.
end.
hide frame f-disp no-pause.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," "," "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["  ",
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

def buffer btt-nf       for tt-nf.
def var vtt-nf         like tt-nf.numero.


form
    esqcom1
    with frame f-com1
                 row 11 no-box no-labels side-labels column 1 centered.
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
        find tt-nf where recid(tt-nf) = recatu1 no-lock.
    if not available tt-nf
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a2 all no-pause.
    if not esqvazio
    then do:
        run frame-a2.
    end.

    recatu1 = recid(tt-nf).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-nf
        then leave.
        if frame-line(frame-a2) = frame-down(frame-a2)
        then leave.
        down
            with frame frame-a2.
        run frame-a2.
    end.
    if not esqvazio
    then up frame-line(frame-a2) - 1 with frame frame-a2.

    repeat with frame frame-a2:

        if not esqvazio
        then do:
            find tt-nf where recid(tt-nf) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-nf.numero)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-nf.numero)
                                        else "".
            run color-message.

            choose field tt-nf.numero help ""
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
                do reccont = 1 to frame-down(frame-a2):
                    run leitura (input "down").
                    if not avail tt-nf
                    then leave.
                    recatu1 = recid(tt-nf).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a2):
                    run leitura (input "up").
                    if not avail tt-nf
                    then leave.
                    recatu1 = recid(tt-nf).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-nf
                then next.
                color display white/blue tt-nf.numero with frame frame-a2.
                if frame-line(frame-a2) = frame-down(frame-a2)
                then scroll with frame frame-a2.
                else down with frame frame-a2.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-nf
                then next.
                color display white/blue tt-nf.numero with frame frame-a2.
                if frame-line(frame-a2) = 1
                then scroll down with frame frame-a2.
                else up with frame frame-a2.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-nf
                 with frame f-tt-nf color black/cyan
                      centered side-label row 5 .
            hide frame frame-a2 no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Estoque " or esqvazio
                then do with frame f-tt-nf on error undo.

                   
                end.
                
                if esqcom1[esqpos1] = " Consulta "
                then do :

                    run connfcob9.p(input tt-nf.etbcod,
                                    input tt-nf.placod,
                                    input tt-nf.serie).
                                                 
                end.

                
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-nf.numero
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-nf where true no-error.
                    if not available tt-nf
                    then do:
                        find tt-nf where recid(tt-nf) = recatu1.
                        find prev tt-nf where true no-error.
                    end.
                    recatu2 = if available tt-nf
                              then recid(tt-nf)
                              else ?.
                    find tt-nf where recid(tt-nf) = recatu1
                            exclusive.
                    delete tt-nf.
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
                    then run ltt-nf.p (input 0).
                    else run ltt-nf.p (input tt-nf.numero).
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
            run frame-a2.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-nf).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a2 no-pause.


procedure frame-a2.
pause 0.
display 
    tt-nf.numero
    tt-nf.serie
    tt-nf.pladat
    tt-nf.movqtm
    tt-nf.movpc
    with frame frame-a2.

end procedure.
procedure color-message.
color display message
        tt-nf.numero
        tt-nf.serie
        tt-nf.pladat
        tt-nf.movqtm
        tt-nf.movpc
        with frame frame-a2.
end procedure.
procedure color-normal.
color display normal
        tt-nf.numero
        tt-nf.serie
        tt-nf.pladat
        tt-nf.movqtm
        tt-nf.movpc
        with frame frame-a2.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-nf where true
                                                no-lock no-error.
    else  
        find last tt-nf  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-nf  where true
                                                no-lock no-error.
    else  
        find prev tt-nf   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-nf where true  
                                        no-lock no-error.
    else   
        find next tt-nf where true 
                                        no-lock no-error.
        
end procedure.
    