def var vetbcod-box like estab.etbcod.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao ", " Exclusao "," Consulta "," Alteracao ", " Procura "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  ",
             " Alteracao ",
             " Exclusao  ",
             " Consulta  ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

def buffer bbox       for box.


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
        find box where recid(box) = recatu1 no-lock.
    if not available box
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(box).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available box
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
            find box where recid(box) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then "" /* string(box.procod)*/
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then "" /*string(box.procod)*/
                                        else "".

            run color-message.
            
            choose field box.etbcod help ""
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
                    if not avail box
                    then leave.
                    recatu1 = recid(box).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail box
                    then leave.
                    recatu1 = recid(box).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail box
                then next.
                
                color display white/red 
                              box.etbcod with frame frame-a.
                
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail box
                then next.
                color display white/red box.etbcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form box
                 with frame f-box
                      centered side-label row 5 .
            
            hide frame frame-a no-pause.
            
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do:

                    run p-inclusao.

                    recatu1 = recid(box).
                    leave.
                end.
                

                if esqcom1[esqpos1] = " Procura "
                then do with frame f-procura centered overlay side-labels
                        row 8
                        on error undo.

                    
                    view frame frame-a. pause 0.
                        
                    update vetbcod-box label "Filial".
                    
                    find first box where    
                               box.etbcod = vetbcod-box no-lock no-error.
                    if not avail box
                    then do:
                        message "Box nao encontrado.". pause 1.
                        undo.
                    end.

                    hide frame f-procura.
                    recatu1 = recid(box).
                    leave.

                end.
                
                
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " /*or
                   esqcom1[esqpos1] = " Alteracao "  */
                then do:
                
                    run p-consulta.
                
                end.
                
                if esqcom1[esqpos1] = " Alteracao "
                then do :
                    find box where
                            recid(box) = recatu1 exclusive.
                            
                    run p-alteracao.
                    
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao deste Box ?" 
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next box where true no-error.
                    if not available box
                    then do:
                        find box where recid(box) = recatu1.
                        find prev box where true no-error.
                    end.
                    recatu2 = if available box
                              then recid(box)
                              else ?.
                    find box where recid(box) = recatu1
                            exclusive.
                    delete box.
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
        recatu1 = recid(box).
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
    
    find estab where estab.etbcod = box.etbcod no-lock no-error.
    
    display box.etbcod
            estab.etbnom  when avail estab format "x(40)"
            box.box
            with frame frame-a 11 down centered  row 5.
            
end procedure.

procedure color-message.

    find estab where estab.etbcod = box.etbcod no-lock no-error.

    color display message box.etbcod
                          estab.etbnom when avail estab format "x(40)"
                          box.box
                          with frame frame-a.
                          
end procedure.

procedure color-normal.

    find estab where estab.etbcod = box.etbcod no-lock no-error.

    color display normal box.etbcod
                         estab.etbnom  when avail estab format "x(40)"
                         box.box
                         with frame frame-a.
                         
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first box where true
                                                no-lock no-error.
    else  
        find last box  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next box  where true
                                                no-lock no-error.
    else  
        find prev box   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev box where true  
                                        no-lock no-error.
    else   
        find next box where true 
                                        no-lock no-error.
        
end procedure.

procedure p-inclusao:

    def var vetbcod like estab.etbcod.
    def var vbox    like box.box.
    def var vordem  as int.
    
    do on error undo:
    
        update vetbcod label "Filial"
               with frame f-inclusao with centered side-labels overlay
                            title " Inclusao " row 7.
        
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Filial nao cadastrada.".
            undo.
        end.
        else disp estab.etbnom no-label with frame f-inclusao.
        
    end.
        
    do on error undo:
        
        update skip vbox  label "Box..."
               with frame f-inclusao.

        if vbox = 0
        then do:
            message "Informe o numero do Box.".
            undo.
        end.

    end.

    update skip vordem label "Ordem."
            with frame f-inclusao.
    
    find box where box.etbcod = estab.etbcod
               and box.box    = vbox no-error.
               
    if not avail box
    then do:

        create box.
        assign box.etbcod = estab.etbcod
               box.box    = vbox.
        
    end.
    else do:
        message "Box ja cadastrado.".
        undo.
    end.
    
end procedure.

procedure p-consulta:

    disp box.etbcod label "Filial"
         with frame f-consulta with centered side-labels overlay row 7.
        
    find estab where estab.etbcod = box.etbcod no-lock no-error.
    
    disp estab.etbnom no-label when avail estab
         with frame f-consulta.
        
    disp skip 
         box.box    label "Box..." skip
         box.aux    label "Ordem." format "x(5)"
         with frame f-consulta.
                
end procedure.

procedure p-alteracao:

    disp box.etbcod label "Filial"
         with frame f-alteracao with centered side-labels overlay
                            title " Alteracao " row 7.
        
    find estab where estab.etbcod = box.etbcod no-lock no-error.
    
    disp estab.etbnom no-label when avail estab
         with frame f-alteracao.
        
    update skip 
         box.box label "Box..."        skip
         box.aux label "Ordem." format "x(2)"
         skip with frame f-alteracao.

    
end procedure.
