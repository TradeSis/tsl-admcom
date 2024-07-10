
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta ","  "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de Promotoras ",
             " Alteracao da Promotoras ",
             " Exclusao  da Promotoras ",
             " Consulta  da Promotoras ",
             " Listagem  Geral de Promotoras "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

def buffer bpromot       for  promot.
def var    vpromot       like promot.pmtcod.


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
        find promot where recid(promot) = recatu1 no-lock.
    if not available promot
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(promot).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available promot
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
            find promot where recid(promot) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(promot.pmtnom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(promot.pmtnom)
                                        else "".
            run color-message.
            choose field promot.pmtcod help ""
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
                    if not avail promot
                    then leave.
                    recatu1 = recid(promot).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail promot
                    then leave.
                    recatu1 = recid(promot).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail promot
                then next.
                color display white/red promot.pmtcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail promot
                then next.
                color display white/red promot.pmtcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form promot.pmtcod label "Codigo...." skip
                 promot.pmtnom label "Promotora." skip
                 promot.opecod label "Operadora." skip
                 with frame f-promot color black/cyan overlay
                      centered side-label row 9 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-promot on error undo.
                    view frame frame-a . pause 0.
                    create promot.
                    update promot.pmtcod
                           promot.pmtnom
                           promot.opecod.
                           
                    recatu1 = recid(promot).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " /*or
                   esqcom1[esqpos1] = " Alteracao "  */
                then do with frame f-promot.

                    view frame frame-a. pause 0.
                    
                    disp promot.pmtcod
                         promot.pmtnom
                         promot.opecod.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-promot on error undo.
                    view frame frame-a . pause 0.
                    find promot where
                            recid(promot) = recatu1 
                        exclusive.
                    update promot.pmtcod
                           promot.pmtnom
                           promot.opecod.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" promot.pmtnom
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next promot where true no-error.
                    if not available promot
                    then do:
                        find promot where recid(promot) = recatu1.
                        find prev promot where true no-error.
                    end.
                    recatu2 = if available promot
                              then recid(promot)
                              else ?.
                    find promot where recid(promot) = recatu1
                            exclusive.
                    delete promot.
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
                    then run lpromot.p (input 0).
                    else run lpromot.p (input promot.pmtcod).
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
        recatu1 = recid(promot).
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

    find operadoras where
         operadoras.opecod = promot.opecod no-lock no-error.

    display promot.pmtcod column-label "Codigo"
            promot.pmtnom column-label "Promotora"
            operadoras.openom Column-label "Operadora" format "x(10)"
                                            when avail operadoras
            with frame frame-a 11 down centered color white/red row 5.
            
end procedure.

procedure color-message.
    find operadoras where
         operadoras.opecod = promot.opecod no-lock no-error.

    color display message
            promot.pmtcod column-label "Codigo"
            promot.pmtnom column-label "Promotora"
            operadoras.openom Column-label "Operadora" when avail operadoras
            with frame frame-a.
end procedure.

procedure color-normal.
    find operadoras where
         operadoras.opecod = promot.opecod no-lock no-error.

    color display normal
        promot.pmtcod column-label "Codigo"
        promot.pmtnom column-label "Promotora"
        operadoras.openom Column-label "Operadora" when avail operadoras
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first promot where true
                                                no-lock no-error.
    else  
        find last promot  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next promot  where true
                                                no-lock no-error.
    else  
        find prev promot   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev promot where true  
                                        no-lock no-error.
    else   
        find next promot where true 
                                        no-lock no-error.
        
end procedure.
         
