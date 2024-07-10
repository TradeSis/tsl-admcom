/*
*
*    planprod.p    -    Esqueleto de Programacao    com esqvazio


            substituir    planprod
                          card
*
*/

{admcab.i}

def input parameter ipint-cardcod as integer no-undo.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Inclusao "," Exclusao "," Excluir Todos "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao ",
             " Exclusao ",
             " Excluir Todos ",
             "  ",
             "  "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def buffer bplanprod       for planprod.
def var vplanprod         like planprod.cardcod.


define variable vcha-tip-inclusao as character format "x(15)" extent 2 initial ["  Por Produto  ","  Por Classe  "].

define variable vint-prodecom   as integer no-undo.
define variable vint-clasecom   as integer no-undo.
define variable vlog-achou-prod as logical no-undo.



form
    planprod.cardcod label "Plano"
    vint-prodecom    label "Produto"
        with frame f-planprod-1
                 row 08 overlay side-labels centered 1 column color black/cyan.
                 
form
    planprod.cardcod label "Plano"
    planprod.procod  label "Produto"
         with frame f-planprod
                 row 05 overlay side-labels centered 1 column color black/cyan.
                 
form
    ipint-cardcod    label "Plano"
    vint-clasecom    label "Classe"
          with frame f-planprod-2
                 row 08 overlay side-labels centered 1 column color black/cyan.

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
    else do:
        find planprod where recid(planprod) = recatu1 no-lock.
        find first prodecom where prodecom.procod = planprod.procod no-lock.
    end.
    
    if not available planprod
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(planprod).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available planprod
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
            find planprod where recid(planprod) = recatu1 no-lock.
            
            find first prodecom where prodecom.procod = planprod.procod no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(prodecom.nome)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(prodecom.nome)
                                        else "".
            run color-message.
            choose field planprod.cardcod help ""
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
                    if not avail planprod
                    then leave.
                    recatu1 = recid(planprod).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail planprod
                    then leave.
                    recatu1 = recid(planprod).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail planprod
                then next.
                color display white/red planprod.cardcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail planprod
                then next.
                color display white/red planprod.cardcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave  bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:

            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-planprod-1 on error undo.
                    
                    disp vcha-tip-inclusao no-label with frame f11
                            centered row 05  overlay title " Tipo Inclusao ".
 
                    choose field vcha-tip-inclusao with frame f11.
                    
                    if frame-index = 1 /* Por produtos */
                    then do:
                    
                        assign vint-prodecom = 0.
                        do on error undo, retry:
                           create planprod.                   
                           assign planprod.cardcod = ipint-cardcod.
                         
                           display planprod.cardcod with frame f-planprod-1.
                           update  vint-prodecom    with frame f-planprod-1.
                        
                           if not can-find(first prodecom where                                                 prodecom.procod = vint-prodecom)
                           then do: 
                                message "Codigo informado Invalido.".          
                                undo, retry . 
                           end.
                           if can-find(first planprod where
                                             planprod.cardcod = ipint-cardcod 
                                         and planprod.procod  = vint-prodecom) 
                           then do:
                                message "Este Produto ja foi inserido.".
                                undo, retry .
                           end.
                        
                           assign planprod.procod = vint-prodecom.
                        end.
                    end.
                    else do: /* por Classes */
                        
                        assign vint-clasecom = 0.
                        
                        do on error undo, retry:

                        display ipint-cardcod    with frame f-planprod-2.
                        update  vint-clasecom    with frame f-planprod-2.

                        if can-find(first clasecom
                                    where clasecom.clacod = vint-clasecom
                                      and clasecom.clatipo)
                        then do:
                                      
                            message "Classe Superior nao pode ser informada.".
                            undo, retry.          
                                      
                        end.              

                        assign vlog-achou-prod = no.

                        for each prodecom where prodecom.clacod =                                                                          vint-clasecom no-lock:
                            create planprod.
                            assign planprod.cardcod = ipint-cardcod
                                   planprod.procod  = prodecom.procod.         
                                                                                                           assign vlog-achou-prod = yes.
                            
                        end.
                        
                        if not vlog-achou-prod
                        then do:
                                                     
                            message "Não existem produtos para a classe informada.".
                          undo, retry.
                                                     
                        end.
                        end.
                    end.
                    
                    recatu1 = recid(planprod).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-planprod.
                
                    find first prodecom where prodecom.procod = planprod.procod
                                                        no-lock no-error.
                                                        
                    disp planprod.cardcod label "Plano"
                         planprod.procod
                         prodecom.nome when avail prodecom format "x(45)"
                                     with frame f-exclui.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-planprod on error undo.
                    find planprod where
                            recid(planprod) = recatu1 
                        exclusive.
                    update planprod.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" prodecom.nome
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next planprod where true no-error.
                    if not available planprod
                    then do:
                        find planprod where recid(planprod) = recatu1.
                        find prev planprod where true no-error.
                    end.
                    recatu2 = if available planprod
                              then recid(planprod)
                              else ?.
                    find planprod where recid(planprod) = recatu1
                            exclusive.
                    delete planprod.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Excluir Todos " 
                then do with frame f-exclui  row 5 1 column centered
                     on error undo.
                     message "Confirma Exclusao de todo os Produtos do Plano."                        update sresp.
                   
                     if not sresp                                                                    then undo, leave.
                     
                     run p-exclui-todos.
                     
                     leave bl-princ.
                                          
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run lplanprod.p (input 0).
                    else run lplanprod.p (input planprod.cardcod).
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
        recatu1 = recid(planprod).
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
display planprod.cardcod
        planprod.procod
        prodecom.nome  format "x(40)"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        planprod.cardcod
        planprod.procod
        prodecom.nome format "x(40)"
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        planprod.cardcod
        planprod.procod
        prodecom.nome format "x(40)"
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do: 
    if esqascend  
    then do: 
        find first planprod where cardcod = ipint-cardcod    no-lock no-error.
                                                       
        find first prodecom where prodecom.procod = planprod.procod
                                                       no-lock no-error.
                                                       
    end.                                            
    else do: 
        find last planprod  where cardcod = ipint-cardcod    no-lock no-error.
                                      
        find first prodecom where prodecom.procod = planprod.procod
                                                       no-lock no-error.
    end.                                         
end.    
if par-tipo = "seg" or par-tipo = "down" 
then do:  
    if esqascend  
    then do: 
        find next planprod  where cardcod = ipint-cardcod   no-lock no-error.
    
        find first prodecom where prodecom.procod = planprod.procod
                                                no-lock no-error.
    end.                                            
    else do: 
        find prev planprod  where cardcod = ipint-cardcod   no-lock no-error.
                                                
        find first prodecom where prodecom.procod = planprod.procod
                                                no-lock no-error.
                
    end.         
end.    
if par-tipo = "up" 
then                  
    if esqascend   
    then do:  
        find prev planprod where cardcod = ipint-cardcod no-lock no-error.
        
        find first prodecom where prodecom.procod = planprod.procod
                                                       no-lock no-error.
                                                        
    end.
    else do:   
        find next planprod where cardcod = ipint-cardcod no-lock no-error.
         
        find first prodecom where prodecom.procod = planprod.procod
                                                       no-lock no-error.
        
        
    end.    
end procedure.
         

procedure p-exclui-todos:

    define buffer bf-planprod for planprod.

    for each bf-planprod where  bf-planprod.cardcod = planprod.cardcod
                                                      exclusive-lock:
                                 
        delete bf-planprod.
                                                                                   end.

end.
