/* helio 112022 - campanha seguro prestamista gratis */
/* helio 20012022 - [UNIFICAÇÃO ZURICH - FASE 2] NOVO CÁLCULO PARA SEGURO PRESTAMISTA MÓVEIS NA PRÉ-VENDA */

{admcab.i}
def buffer bsegprestpar for segprestpar.

def var vtpseguro as int init 1 . /* seguro prestamista */
    
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" parametros "," inclusao "," exclusao"," -"].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.
find segtipo where segtipo.tpseguro = vtpseguro no-lock.

    form  
      segprestpar.categoria
      segprestpar.etbcod
      
      segprestpar.valMinParc
      segprestpar.qtdMinParc
      segprestpar.considerarEntrada
      
      segprestpar.percentualSeguro
      segprestpar.valorPorParcela
      segprestpar.codigoSeguro

       with frame frame-a 8 down centered row 8
       title segtipo.descricao.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find segprestpar where recid(segprestpar) = recatu1 no-lock.
    if not available segprestpar
    then do.
        run pinclui (output recatu1).
        run pparametros.
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(segprestpar).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available segprestpar
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find segprestpar where recid(segprestpar) = recatu1 no-lock.

        status default "".
        
        if false
        then esqcom1[5] = " exclusao".
        else esqcom1[5] = "".
        
        if segprestpar.etbcod = 0
        then esqcom1[4] = "campanhas".
        else esqcom1[4] = "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field segprestpar.etbcod

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
                    if not avail segprestpar
                    then leave.
                    recatu1 = recid(segprestpar).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail segprestpar
                    then leave.
                    recatu1 = recid(segprestpar).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail segprestpar
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail segprestpar
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
            
            if esqcom1[esqpos1] = "campanhas"
            then do:
                run seg/segprescamp.p (input vtpseguro, segprestpar.categoria).
            end.    
            
            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(segprestpar).
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
    display  
      segprestpar.categoria
      segprestpar.etbcod
      
      segprestpar.valMinParc
      segprestpar.qtdMinParc
      segprestpar.considerarEntrada
      
      segprestpar.percentualSeguro
      segprestpar.valorPorParcela
      segprestpar.codigoSeguro

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
      segprestpar.categoria
      segprestpar.etbcod
      
      segprestpar.valMinParc
      segprestpar.qtdMinParc
      segprestpar.considerarEntrada
      
      segprestpar.percentualSeguro
      segprestpar.valorPorParcela
      segprestpar.codigoSeguro

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
      segprestpar.categoria
      segprestpar.etbcod
      
      segprestpar.valMinParc
      segprestpar.qtdMinParc
      segprestpar.considerarEntrada
      
      segprestpar.percentualSeguro
      segprestpar.valorPorParcela
      segprestpar.codigoSeguro

        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
      segprestpar.categoria
      segprestpar.etbcod
      
      segprestpar.valMinParc
      segprestpar.qtdMinParc
      segprestpar.considerarEntrada
      
      segprestpar.percentualSeguro
      segprestpar.valorPorParcela
      segprestpar.codigoSeguro

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first segprestpar  where segprestpar.tpseguro = vtpseguro
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next segprestpar  where segprestpar.tpseguro = vtpseguro
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev segprestpar  where  segprestpar.tpseguro = vtpseguro
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo
     with 1 col
                 row 7
                             centered
                                            overlay
                                            title segtipo.descricao.
                                            

        find current segprestpar exclusive.

        update      
              segprestpar.valMinParc
              segprestpar.qtdMinParc
              segprestpar.considerarEntrada.
              
        update  segprestpar.percentualSeguro.
        if segprestpar.percentualSeguro = 0 
        then segprestpar.percentualSeguro = ?.
        disp segprestpar.percentualSeguro.
        if segprestpar.percentualSeguro = ? 
        then update  segprestpar.valorPorParcela.
        else segprestpar.valorPorParcela = ?.
        if segprestpar.valorPorParcela = 0
        then segprestpar.valorPorParcela = ? . 
        disp segprestpar.valorPorParcela.
        if segprestpar.percentualSeguro = ? and segprestpar.valorPorParcela = ?
                then do:
                    message "Escolha percentualSeguro ou valorPorParcela".
                    undo.
                end.    
        update segprestpar.codigoSeguro.
        find produ where produ.procod = segprestpar.codigoSeguro no-lock no-error.
        if not avail produ        
        then do:
            message "produto nao cadastrado".
            undo.
        end.    

    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    find last bsegprestpar no-lock no-error.
    create segprestpar.
    segprestpar.tpseguro = vtpseguro.
    prec = recid(segprestpar).
    
    update
        segprestpar.categoria
        segprestpar.etbcod
        with row 9 
        centered
        overlay 1 column
        title segtipo.descricao.
    


end.


end procedure.



procedure pexclui.
sresp = yes.
message color normal "confirma?" update sresp.
if sresp
then do on error undo:
    find current segprestpar exclusive no-wait no-error.
    if avail segprestpar
    then delete segprestpar.
end.
end procedure.
