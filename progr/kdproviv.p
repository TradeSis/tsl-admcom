
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Consulta "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  ",
             " Alteracao ",
             " Consulta  ",
             "   ",
             "   "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

def buffer bpromoviv       for promoviv.
def var vpromoviv         like promoviv.tipviv.


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
        find promoviv where recid(promoviv) = recatu1 no-lock.
    if not available promoviv
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(promoviv).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available promoviv
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
            find promoviv where recid(promoviv) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(promoviv.provivnom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(promoviv.provivnom)
                                        else "".
            run color-message.
            choose field promoviv.tipviv 
                         promoviv.provivnom
                         operadoras.openom
                         promoviv.exportado
                help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) color white/black.
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
                    if not avail promoviv
                    then leave.
                    recatu1 = recid(promoviv).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail promoviv
                    then leave.
                    recatu1 = recid(promoviv).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail promoviv
                then next.
                color display white/red 
                      promoviv.tipviv 
                      promoviv.provivnom                  
                      operadoras.openom
                      promoviv.exportado
                      with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail promoviv
                then next.
                color display white/red promoviv.tipviv 
                                        promoviv.provivnom
                                        operadoras.openom
                                        promoviv.exportado 
                                        with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            hide frame f-promoviv no-pause.
            leave bl-princ.
        end.
        
        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form promoviv.tipviv    label "Codigo"
                 promoviv.provivnom label "Promocao"
                 promoviv.opecod    label "Operadora"
                 promoviv.exportado label "Situacao"
                    format "Ativo/Inativo"
                 with frame f-promoviv color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-promoviv on error undo.
                    create promoviv.
                    promoviv.exportado = yes.
                    disp promoviv.exportado 
                        label "Situacao" format "Ativo/Inativo".

                    update promoviv.tipviv label "Codigo" format ">>>9"
                           promoviv.provivnom label "Promocao" 
                           promoviv.opecod  label "Operadora".
                    
                    recatu1 = recid(promoviv).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-promoviv.
                    disp promoviv.tipviv label "Codigo" format ">>>9"
                         promoviv.provivnom label "Promocao"
                         promoviv.exportado label "Situacao"
                                             format "Ativo/Inativo"
                         promoviv.opecod label "Operadora".
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-promoviv on error undo.
                    find promoviv where
                            recid(promoviv) = recatu1 
                        exclusive.
                    
                    disp promoviv.tipviv label "Codigo" format ">>>9"
                         .
                    
                    update promoviv.provivnom label "Promocao"
                           promoviv.opecod label "Operadora"                                                promoviv.exportado label "Situacao"
                                            format "Ativo/Inativo"
                           help "[A] Ativo  [I] Inativo"
                           .
                           
                    if promoviv.exportado
                    then do: /*ativo*/
                        sresp = yes.
                        message
                        "Ativar cadastros relacionados a esta promocao? "
                                update sresp.
                        if sresp
                        then do:
                             for each proplaviv where 
                                      proplaviv.tipviv = promoviv.tipviv:

                                 for each planoviv where
                                          planoviv.codviv = proplaviv.codviv:
                                     planoviv.exportado = yes.     
                                 end.
                                           
                                 for each plaviv where
                                          plaviv.tipviv = proplaviv.tipviv
                                      and plaviv.codviv = proplaviv.codviv:
                                     
                                     plaviv.exportado = yes.
                                 end.     
                                 proplaviv.exportado = yes.
                             end.
                        end.
                    end.
                    else do: /*inativo*/
                        sresp = yes.
                        message
                        "Desativar cadastros relacionados a esta promocao? "
                                update sresp.
                        if sresp
                        then do:
                             for each proplaviv where 
                                      proplaviv.tipviv = promoviv.tipviv:

                                 for each planoviv where
                                          planoviv.codviv = proplaviv.codviv:
                                     planoviv.exportado = no.
                                 end.
                                           
                                 for each plaviv where
                                          plaviv.tipviv = proplaviv.tipviv
                                      and plaviv.codviv = proplaviv.codviv:
                                     
                                     plaviv.exportado = no.
                                 end.     
                                 proplaviv.exportado = no.
                             end.
                        end.
                    end. 
                
                end.
                
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" promoviv.provivnom
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next promoviv where true no-error.
                    if not available promoviv
                    then do:
                        find promoviv where recid(promoviv) = recatu1.
                        find prev promoviv where true no-error.
                    end.
                    recatu2 = if available promoviv
                              then recid(promoviv)
                              else ?.
                    find promoviv where recid(promoviv) = recatu1
                            exclusive.
                    delete promoviv.
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
                    then run lpromoviv.p (input 0).
                    else run lpromoviv.p (input promoviv.tipviv).
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
        recatu1 = recid(promoviv).
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
find operadoras where operadoras.opecod = promoviv.opecod no-lock no-error.
display promoviv.tipviv    column-label "Codigo" format ">>>9"
        promoviv.provivnom column-label "Promocao"
        operadoras.openom  column-label "Operadora" when avail operadoras
                format "x(10)"
        promoviv.exportado column-label "Situacao" format "Ativo/Inativo"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
find operadoras where operadoras.opecod = promoviv.opecod no-lock no-error.

color display message
        promoviv.tipviv    column-label "Codigo" format ">>>9"
        promoviv.provivnom column-label "Promocao"
        operadoras.openom  column-label "Operadora" when avail operadoras
        promoviv.exportado column-label "Situacao" format "Ativo/Inativo"
        with frame frame-a.
end procedure.

procedure color-normal.
find operadoras where operadoras.opecod = promoviv.opecod no-lock no-error.
color display normal
        promoviv.tipviv    column-label "Codigo"  format ">>>9"
        promoviv.provivnom column-label "Promocao"
        operadoras.openom  column-label "Operadora" when avail operadoras
        promoviv.exportado column-label "Situacao" format "Ativo/Inativo"
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first promoviv where true
                                                no-lock no-error.
    else  
        find last promoviv  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next promoviv  where true
                                                no-lock no-error.
    else  
        find prev promoviv   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev promoviv where true  
                                        no-lock no-error.
    else   
        find next promoviv where true 
                                        no-lock no-error.
        
end procedure.
         
