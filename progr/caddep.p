def input parameter p-clicod like clien.clicod.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," "].
def var esqcom2         as char format "x(15)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de dependentes ",
             " Alteracao da dependentes ",
             " Exclusao  da dependentes ",
             " Consulta  da dependentes ",
             " Listagem  Geral de dependentes "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

find clien where clien.clicod = p-clicod no-lock no-error.

def buffer bdependentes       for dependentes.
def var vdependentes         like dependentes.depnum.


form
    esqcom1
    with frame f-com1 overlay
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2 overlay
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
        find dependentes where recid(dependentes) = recatu1 no-lock.
    if not available dependentes
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(dependentes).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available dependentes
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
            find dependentes where recid(dependentes) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(dependentes.depnom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(dependentes.depnom)
                                        else "".
            run color-message.
            choose field dependentes.depnum dependentes.depnom help ""
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
                    if not avail dependentes
                    then leave.
                    recatu1 = recid(dependentes).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail dependentes
                    then leave.
                    recatu1 = recid(dependentes).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail dependentes
                then next.
                color display white/red 
                              dependentes.depnum
                              dependentes.depnom
                              
                              with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail dependentes
                then next.
                color display white/red 
                              dependentes.depnum 
                              dependentes.depnom
                              with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:

            form dependentes.depnum label "Numero"
                 dependentes.depnom label "Dependente"
                 dependentes.dtnasc label "Dt.Nascimento"
                 dependentes.tipdep label "Tipo Dependente"
                 with frame f-dependentes color black/cyan
                      centered side-label row 7 overlay 1 col
                      title " INCLUSAO - DEPENDENTES ".
            form dependentes.depnum label "Numero"
                 dependentes.depnom label "Dependente"
                 dependentes.dtnasc label "Dt.Nascimento"
                 dependentes.tipdep label "Tipo Dependente"
                 with frame f-dependentes2 color black/cyan
                      centered side-label row 7 overlay 1 col.

            hide frame frame-a no-pause.
            
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-dependentes on error undo.

                    find last bdependentes 
                        where bdependentes.clicod = p-clicod no-lock no-error.
                    
                    create dependentes.
                    
                    if avail bdependentes
                    then dependentes.depnum = bdependentes.depnum + 1.
                    else dependentes.depnum = 1.

                    disp dependentes.depnum.
                    update dependentes.depnom
                           dependentes.dtnasc
                           dependentes.tipdep.

                    recatu1 = recid(dependentes).
                    leave.
                end.
            
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-dependentes2.

                    disp dependentes.depnum
                         dependentes.depnom
                         dependentes.dtnasc
                         dependentes.tipdep.
                         
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-dependentes2 on error undo.
                    find dependentes where
                            recid(dependentes) = recatu1 
                        exclusive.
                    update dependentes.depnom
                           dependentes.dtnasc
                           dependentes.tipdep.
                           
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" dependentes.depnom
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next dependentes where 
                              dependentes.clicod = p-clicod no-error.
                    if not available dependentes
                    then do:
                        find dependentes where recid(dependentes) = recatu1.
                        find prev dependentes where 
                                  dependentes.clicod = p-clicod no-error.
                    end.
                    recatu2 = if available dependentes
                              then recid(dependentes)
                              else ?.
                    find dependentes where recid(dependentes) = recatu1
                            exclusive.
                    delete dependentes.
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
        recatu1 = recid(dependentes).
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
    
    find tipdep where tipdep.tipdep = dependentes.tipdep no-lock no-error.
    
    display dependentes.depnum column-label "Num"
            dependentes.depnom
            tipdep.descricao when avail tipdep column-label "Tipo de Dependente"            with frame frame-a 11 down width 80 color white/red row 5
                        title string("TITULAR: " + string(clien.clicod)
                                            + " - " + clien.clinom) overlay.

end procedure.

procedure color-message.

    find tipdep where tipdep.tipdep = dependentes.tipdep no-lock no-error.

    color display message
            dependentes.depnum
            dependentes.depnom
            tipdep.descricao when avail tipdep column-label "Tipo de Dependente"            with frame frame-a.
            
end procedure.

procedure color-normal.
    
    find tipdep where tipdep.tipdep = dependentes.tipdep no-lock no-error.

    color display normal
            dependentes.depnum
            dependentes.depnom
            tipdep.descricao when avail tipdep column-label "Tipo de Dependente"
            with frame frame-a.
            
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first dependentes where dependentes.clicod = p-clicod
                                                no-lock no-error.
    else  
        find last dependentes  where dependentes.clicod = p-clicod
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next dependentes  where dependentes.clicod = p-clicod
                                                no-lock no-error.
    else  
        find prev dependentes   where dependentes.clicod = p-clicod
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev dependentes where dependentes.clicod = p-clicod
                                        no-lock no-error.
    else   
        find next dependentes where dependentes.clicod = p-clicod
                                        no-lock no-error.
        
end procedure.
