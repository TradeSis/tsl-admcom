/* medico na tela 042022 - helio */
{admcab.i }
def buffer bmedprodu for medprodu.

    
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" parametros "," planos" , " inclusao "," exclusao"," -"].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

    form  
      medprodu.procod
      medprodu.idmedico
      
      medprodu.valorServico medprodu.valorRepasseMes label "Repasse Mes"
      medprodu.idPerfil

       with frame frame-a 8 down centered row 8.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find medprodu where recid(medprodu) = recatu1 no-lock.
    if not available medprodu
    then do.
        run pinclui (output recatu1).
        run pparametros.
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(medprodu).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available medprodu
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find medprodu where recid(medprodu) = recatu1 no-lock.

        status default "".
        
        if false
        then esqcom1[5] = " exclusao".
        else esqcom1[5] = "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field medprodu.idmedico

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

                run color-normal.
        hide message no-pause.
                 
        pause 0. 

                                                                
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail medprodu
                    then leave.
                    recatu1 = recid(medprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail medprodu
                    then leave.
                    recatu1 = recid(medprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail medprodu
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail medprodu
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            

            if esqcom1[esqpos1] = " parametros "
            then do:
                hide frame f-com1 no-pause.

                run pparametros.    
                leave.
            end.
            if esqcom1[esqpos1] = " inclusao "
            then do:
                hide frame f-com1 no-pause.
                run pinclui (output recatu1).
                run pparametros.
                leave.
                
            end. 
            if esqcom1[esqpos1] = " exclusao "
            then do:
                run color-message.

                run pexclui.
                recatu1 = ?.
                leave.
            end. 
            if esqcom1[esqpos1] = " planos "
            then do:
            
                run med/medplan.p (input medprodu.procod).
            
            end.        
            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(medprodu).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    find produ of medprodu no-lock no-error.
    
    display  
      medprodu.procod
      medprodu.idmedico
      
      medprodu.valorServico medprodu.valorRepassemes
      medprodu.idPerfil

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
      medprodu.procod
      medprodu.idmedico
      
      medprodu.valorServico medprodu.valorRepassemes

      medprodu.idPerfil

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
      medprodu.procod
      medprodu.idmedico
      
      medprodu.valorServico medprodu.valorRepassemes

      medprodu.idPerfil

        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
      medprodu.procod
      medprodu.idmedico
      
      medprodu.valorServico medprodu.valorRepassemes

      medprodu.idPerfil

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first medprodu  
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next medprodu  
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev medprodu  
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo
     with 1 col
                 row 8
                             centered
                                            overlay.
                                            

        find current medprodu exclusive.
        
        update medprodu.idmedico.
        
        update  medprodu.valorServico.
        disp medprodu.valorServico.
        if medprodu.valorServico = ?
                then do:
                    message "Escolha Preco".
                    undo.
                end.    

        update  medprodu.valorRepassemes.
        disp medprodu.valorrepassemes.
        if medprodu.valorrepassemes = ?
                then do:
                    message "Escolha valor do repasse mes".
                    undo.
                end.    
                
        medprodu.idPerfil = 1 /* versao 0 sem tela de ajuste */ .
        disp medprodu.idPerfil.

    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    find last bmedprodu no-lock no-error.
    create medprodu.
    medprodu.idPerfil = 1 /* versao 0 sem tela de ajuste */ .

    prec = recid(medprodu).
    
    update
        medprodu.procod
        medprodu.idmedico
        with row 9 
        centered
        overlay 1 column.

        find produ where produ.procod = medprodu.procod no-lock no-error.
        if not avail produ        
        then do:
            message "produto nao cadastrado".
            undo.
        end.    
    


end.


end procedure.



procedure pexclui.
sresp = yes.
message color normal "confirma?" update sresp.
if sresp
then do on error undo:
    find current medprodu exclusive no-wait no-error.
    if avail medprodu
    then delete medprodu.
end.
end procedure.
