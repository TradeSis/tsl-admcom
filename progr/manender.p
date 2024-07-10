/*
 *    Manutencao Enderecamento
 */

def var vprocod         like produ.procod.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

def var vop as char format "x(15)" extent 2
    initial [" PRODUTO "," ENDERECO "].


def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta ","Procura"].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de Enderecamento ",
             " Alteracao de Enderecamento ",
             " Exclusao  de Enderecamento ",
             " Consulta  de Enderecamento ",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].


{admcab.i}


form
    vop[1]
    vop[2]
    with frame f-opcao  col 40 overlay color cyan/black no-labels 
                        1 down title " Opcoes " side-labels.
   
def var vpavilhao like ender.pavilhao.
def var vrua      like ender.rua.
def var vnumero   like ender.numero.
def var vandar    like ender.andar.
    
def buffer bender       for ender.
def var vender         like ender.procod.


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
    clear frame f-opcao all.
    hide frame f-opcao no-pause.

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find ender where recid(ender) = recatu1 no-lock.
        
    find produ where produ.procod = ender.procod no-lock no-error.
    
    if not available ender
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(ender).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ender
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
            find ender where recid(ender) = recatu1 no-lock.
            find produ where produ.procod = ender.procod no-lock no-error.
            
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(produ.pronom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(produ.pronom)
                                        else "".
            run color-message.
            choose field ender.procod produ.pronom help ""
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
                    if not avail ender
                    then leave.
                    recatu1 = recid(ender).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ender
                    then leave.
                    recatu1 = recid(ender).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ender
                then next.
                color display white/blue ender.procod 
                                         produ.pronom with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ender
                then next.
                color display white/blue 
                    ender.procod produ.pronom with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form 
            
                ender.procod    label "Produto" at 2
                produ.pronom     no-label skip
                ender.pavilhao  label "Pavilhao" skip
                ender.rua       label "Rua"         at 6
                ender.numero    label "Numero"
                ender.andar     label "Andar"

                 with frame f-ender /*color black/cyan*/
                      centered side-label row 5 .
                      
            form 
            
                vprocod    label "Produto" at 2
                produ.pronom     no-label skip
                vpavilhao  label "Pavilhao" skip
                vrua       label "Rua"         at 6
                vnumero    label "Numero"
                vandar     label "Andar"

                 with frame f-enderi /*color black/cyan*/
                      centered side-label row 5 .

                      
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-enderi on error undo.
                    
                    do on error undo:

                        update vprocod.
                               
                        find produ where produ.procod = vprocod 
                                                        no-lock no-error.

                        if not avail produ
                        then do:
                            message "Produto nao Cadastrao".
                            undo.
                        end.
                        else disp produ.pronom.
                    
                    end.
                    update vpavilhao
                           vrua
                           vnumero
                           vandar.
                        
                        create ender.    
                        assign ender.procod = vprocod   
                               ender.pavilhao = vpavilhao 
                               ender.rua = vrua      
                               ender.numero = vnumero
                               ender.andar = vandar.


                    recatu1 = recid(ender).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-ender.
                    find produ where produ.procod = ender.procod 
                            no-lock no-error.
                    disp ender.procod
                         produ.pronom
                         ender.pavilhao
                         ender.rua
                         ender.numero
                         ender.andar.


                
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-ender on error undo.
                    
                    find ender where recid(ender) = recatu1 exclusive.
                    
                    update ender except ender.procod.
                    
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" produ.pronom
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next ender where true no-error.
                    if not available ender
                    then do:
                        find ender where recid(ender) = recatu1.
                        find prev ender where true no-error.
                    end.
                    recatu2 = if available ender
                              then recid(ender)
                              else ?.
                    find ender where recid(ender) = recatu1
                            exclusive.
                    delete ender.
                    recatu1 = recatu2.
                    leave.
                end.
                
                if esqcom1[esqpos1] = "Procura"
                then do:
                    
                    disp vop with frame f-opcao.
                    choose field vop with frame f-opcao overlay.
                
                    if frame-index = 1
                    then do:
                        vprocod = 0.
                        update vprocod label "Produto" 
                               with frame f-procura centered side-label.
                               
                        find first ender where ender.procod = vprocod 
                                            no-lock no-error.

                    end.
                    else do:

                        def var v-pavilhao like ender.pavilhao.
                        def var v-rua      like ender.rua.
                        def var v-numero   like ender.numero.
                        def var v-andar    like ender.andar.
                        
                        update v-pavilhao label "Pavilhao" skip
                               v-rua      label "Rua....." skip
                               v-numero   label "Numero.." skip
                               v-andar    label "Andar..."
                               with frame f-procura2 centered side-label.

                        
                        find first ender where ender.pavilhao = v-pavilhao
                                           and ender.rua      = v-rua
                                           and ender.numero   = v-numero
                                           and ender.andar    = v-andar  
                                           no-lock no-error.
                    
                    end.
                    
                    if avail ender
                    then recatu1 = recid(ender).
                                        
                    leave.
                end.
                
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered 
                                /*color black/cyan*/
                                 no-label.
                    if sresp
                    then run lender.p (input 0).
                    else run lender.p (input ender.procod).
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
        recatu1 = recid(ender).
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
    find produ where produ.procod = ender.procod no-lock no-error.
    
    display ender.procod
            produ.pronom
            with frame frame-a 11 down centered /*color white/red*/ row 5.

end procedure.

procedure color-message.
    
    color display message
        ender.procod
        produ.pronom
        with frame frame-a.
        
end procedure.

procedure color-normal.

    color display normal
            ender.procod
            with frame frame-a.
            
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first ender where true
                                                no-lock no-error.
    else  
        find last ender  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next ender  where true
                                                no-lock no-error.
    else  
        find prev ender   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev ender where true  
                                        no-lock no-error.
    else   
        find next ender where true 
                                        no-lock no-error.
find produ where produ.procod = ender.procod no-lock no-error.        
end procedure.
         
