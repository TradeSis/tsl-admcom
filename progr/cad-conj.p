

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," "].
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

def buffer bconjunto       for conjunto.
def var vconjunto         like conjunto.procod.


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
        find conjunto where recid(conjunto) = recatu1 no-lock.
    if not available conjunto
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(conjunto).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available conjunto
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
            find conjunto where recid(conjunto) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then "" /* string(conjunto.procod)*/
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then "" /*string(conjunto.procod)*/
                                        else "".

            run color-message.
            
            choose field conjunto.procod help ""
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
                    if not avail conjunto
                    then leave.
                    recatu1 = recid(conjunto).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail conjunto
                    then leave.
                    recatu1 = recid(conjunto).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail conjunto
                then next.
                
                color display white/red 
                              conjunto.procod with frame frame-a.
                
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail conjunto
                then next.
                color display white/red conjunto.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form conjunto
                 with frame f-conjunto
                      centered side-label row 5 .
            
            hide frame frame-a no-pause.
            
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do:

                    run p-inclusao.

                    recatu1 = recid(conjunto).
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
                    find conjunto where
                            recid(conjunto) = recatu1 exclusive.
                            
                    run p-alteracao.
                    
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao deste conjunto ?" 
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next conjunto where true no-error.
                    if not available conjunto
                    then do:
                        find conjunto where recid(conjunto) = recatu1.
                        find prev conjunto where true no-error.
                    end.
                    recatu2 = if available conjunto
                              then recid(conjunto)
                              else ?.
                    find conjunto where recid(conjunto) = recatu1
                            exclusive.
                    delete conjunto.
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
                    then run lconjunto.p (input 0).
                    else run lconjunto.p (input conjunto.procod).
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
        recatu1 = recid(conjunto).
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
    
    find produ where produ.procod = conjunto.procod no-lock no-error.
    
    display conjunto.procod
            produ.pronom     when avail produ format "x(40)"
            conjunto.proean
            conjunto.qtd
            with frame frame-a 11 down centered  row 5.
            
end procedure.

procedure color-message.

    find produ where produ.procod = conjunto.procod no-lock no-error.

    color display message conjunto.procod 
                          produ.pronom     when avail produ format "x(40)"
                          conjunto.proean 
                          conjunto.qtd  
                          with frame frame-a.
                          
end procedure.

procedure color-normal.

    find produ where produ.procod = conjunto.procod no-lock no-error.

    color display normal conjunto.procod
                         produ.pronom      when avail produ format "x(40)"
                         conjunto.proean 
                         conjunto.qtd   
                         with frame frame-a.
                         
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first conjunto where true
                                                no-lock no-error.
    else  
        find last conjunto  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next conjunto  where true
                                                no-lock no-error.
    else  
        find prev conjunto   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev conjunto where true  
                                        no-lock no-error.
    else   
        find next conjunto where true 
                                        no-lock no-error.
        
end procedure.

procedure p-inclusao:

    def var vprocod like conjunto.procod.
    def var vqtd    as   int format ">>>>>9".
    def var vproean like conjunto.proean.
    
    do on error undo:
    
        update vprocod label "Produto..."
               with frame f-inclusao with centered side-labels overlay
                            title " Inclusao " row 7.
        
        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then do:
            message "Produto nao cadastrado.".
            undo.
        end.
        else disp produ.pronom no-label with frame f-inclusao.
        
    end.
        
    do on error undo:

        update skip vproean label "Codigo EAN"
                with frame f-inclusao.
                
        /*
        if vproean = "" 
        then do:
            message "Informe o codigo EAN".
            undo.
        end.
        if length(vproean) < 13
        then do:
            message "Codigo EAN invalido".
            undo.
        end.
        */                
    end.                
            
    do on error undo:
        
        update skip vqtd    label "Quantidade"
               with frame f-inclusao.

        if vqtd = 0
        then do:
            message "Informe a quantidade.".
            undo.
        end.
        
    end.
    
    find conjunto where conjunto.procod = produ.procod
                    and conjunto.proean = vproean no-error.
    if not avail conjunto
    then do:

        create conjunto.
        assign conjunto.procod = produ.procod
               conjunto.proean = vproean
               conjunto.qtd    = vqtd.
        
    end.
    else do:
        message "Conjunto ja cadastrado.".
        undo.
    end.
    
end procedure.

procedure p-consulta:

    disp conjunto.procod label "Produto..."
         with frame f-consulta with centered side-labels overlay row 7.
        
    find produ where produ.procod = conjunto.procod no-lock no-error.
    
    disp produ.pronom no-label when avail produ 
         with frame f-consulta.
        
    disp skip 
         conjunto.proean label "Codigo EAN" skip
         conjunto.qtd    label "Quantidade"
         with frame f-consulta.
                
end procedure.

procedure p-alteracao:

    disp conjunto.procod label "Produto..."
         with frame f-alteracao with centered side-labels overlay
                            title " Alteracao " row 7.
        
    find produ where produ.procod = conjunto.procod no-lock no-error.
    
    disp produ.pronom no-label when avail produ 
         with frame f-alteracao.
        
    update skip 
         conjunto.proean label "Codigo EAN" 
         skip with frame f-alteracao.

    do on error undo:
        
        update conjunto.qtd  label "Quantidade"
               with frame f-alteracao.

        if conjunto.qtd = 0
        then do:
            message "Informe a quantidade.".
            undo.
        end.
        
    end.
 

end procedure.
