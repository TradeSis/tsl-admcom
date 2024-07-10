
def var vetbcod-tab_box like estab.etbcod.

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

def buffer btab_box       for tab_box.


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
        find tab_box where recid(tab_box) = recatu1 no-lock.
    if not available tab_box
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tab_box).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tab_box
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
            find tab_box where recid(tab_box) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then "" /* string(tab_box.procod)*/
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then "" /*string(tab_box.procod)*/
                                        else "".

            run color-message.
            
            choose field tab_box.etbcod help ""
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
                    if not avail tab_box
                    then leave.
                    recatu1 = recid(tab_box).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tab_box
                    then leave.
                    recatu1 = recid(tab_box).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tab_box
                then next.
                
                color display white/red 
                              tab_box.etbcod with frame frame-a.
                
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tab_box
                then next.
                color display white/red tab_box.etbcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tab_box
                 with frame f-tab_box
                      centered side-label row 5 .
            
            hide frame frame-a no-pause.
            
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do:

                    run p-inclusao.

                    recatu1 = recid(tab_box).
                    leave.
                end.
                

                if esqcom1[esqpos1] = " Procura "
                then do with frame f-procura centered overlay side-labels
                        row 8
                        on error undo.

                    
                    view frame frame-a. pause 0.
                        
                    update vetbcod-tab_box label "Filial".
                    
                    find first tab_box where    
                               tab_box.etbcod = vetbcod-tab_box no-lock no-error.
                    if not avail tab_box
                    then do:
                        message "tab_box nao encontrado.". pause 1.
                        undo.
                    end.

                    hide frame f-procura.
                    recatu1 = recid(tab_box).
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
                    find tab_box where
                            recid(tab_box) = recatu1 exclusive.
                            
                    run p-alteracao.
                    
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao deste tab_box ?" 
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tab_box where true no-error.
                    if not available tab_box
                    then do:
                        find tab_box where recid(tab_box) = recatu1.
                        find prev tab_box where true no-error.
                    end.
                    recatu2 = if available tab_box
                              then recid(tab_box)
                              else ?.
                    find tab_box where recid(tab_box) = recatu1
                            exclusive.
                    delete tab_box.
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
        recatu1 = recid(tab_box).
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
    
    find estab where estab.etbcod = tab_box.etbcod no-lock no-error.
    
    display tab_box.etbcod
            estab.etbnom  when avail estab format "x(40)"
            tab_box.box
            tab_box.ordem
            with frame frame-a 11 down centered  row 5.
            
end procedure.

procedure color-message.

    find estab where estab.etbcod = tab_box.etbcod no-lock no-error.

    color display message tab_box.etbcod
                          estab.etbnom when avail estab format "x(40)"
                          tab_box.box
                          tab_box.ordem
                          with frame frame-a.
                          
end procedure.

procedure color-normal.

    find estab where estab.etbcod = tab_box.etbcod no-lock no-error.

    color display normal tab_box.etbcod
                         estab.etbnom  when avail estab format "x(40)"
                         tab_box.box
                         tab_box.ordem
                         with frame frame-a.
                         
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tab_box where true
                                                no-lock no-error.
    else  
        find last tab_box  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tab_box  where true
                                                no-lock no-error.
    else  
        find prev tab_box   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tab_box where true  
                                        no-lock no-error.
    else   
        find next tab_box where true 
                                        no-lock no-error.
        
end procedure.

procedure p-inclusao:

    def var vetbcod like estab.etbcod.
    def var vtab_box    like tab_box.box.
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
        
        update skip vtab_box validate(vtab_box < 33,
            "Numero maximo para box deve ser 32")
                label "tab_box..." with frame f-inclusao.

        if vtab_box = 0
        then do:
            message "Informe o numero do tab_box.".
            undo.
        end.
        /*
        if vtab_box > 32
        then do:
            message color red/with
            "Numero maximo para box deve ser 32"
            view-as alert-box.
            undo.
        end.
        */
    end.

    update skip vordem label "Ordem."
            with frame f-inclusao.
    
    find tab_box where tab_box.etbcod = estab.etbcod
               and tab_box.box    = vtab_box no-error.
               
    if not avail tab_box
    then do:

        create tab_box.
        assign tab_box.etbcod = estab.etbcod
               tab_box.box    = vtab_box.
        
    end.
    else do:
        message "tab_box ja cadastrado.".
        undo.
    end.
    
end procedure.

procedure p-consulta:

    disp tab_box.etbcod label "Filial"
         with frame f-consulta with centered side-labels overlay row 7.
        
    find estab where estab.etbcod = tab_box.etbcod no-lock no-error.
    
    disp estab.etbnom no-label when avail estab
         with frame f-consulta.
        
    disp skip 
         tab_box.box    label "tab_box..." skip
         tab_box.ordem  label "Ordem." format ">>9"
         with frame f-consulta.
                
end procedure.

procedure p-alteracao:

    disp tab_box.etbcod label "Filial"
         with frame f-alteracao with centered side-labels overlay
                            title " Alteracao " row 7.
        
    find estab where estab.etbcod = tab_box.etbcod no-lock no-error.
    
    disp estab.etbnom no-label when avail estab
         with frame f-alteracao.
        

    update skip 
         tab_box.box validate(tab_box.box < 33,
            "Numero maximo para box deve ser 32")
          label "tab_box..."        skip
         tab_box.ordem label "Ordem." format ">>9"
         skip with frame f-alteracao.

    
end procedure.
