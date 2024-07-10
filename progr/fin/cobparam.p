/*               to                   sfpl
*                                 R
*
*/

{admcab.i}
def buffer bcobparam for cobparam.
    
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


    form  
        
        cobparam.tipoOperacao
        cobparam.cobcod 
        cobra.cobnom     format "x(12)" no-label
        
        cobparam.valMinParc
        cobparam.qtdMinParc cobparam.valorMinimoAcrescimoTotal
        
        
        with frame frame-a 8 down centered row 8
        no-box.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find cobparam where recid(cobparam) = recatu1 no-lock.
    if not available cobparam
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(cobparam).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available cobparam
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find cobparam where recid(cobparam) = recatu1 no-lock.

        status default "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field cobparam.cobcod

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
                    if not avail cobparam
                    then leave.
                    recatu1 = recid(cobparam).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cobparam
                    then leave.
                    recatu1 = recid(cobparam).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cobparam
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cobparam
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
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run fin/novplano.p (recid(cobparam)).
                
            end. 
            if esqcom1[esqpos1] = " filiais "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run fin/novcobra.p (recid(cobparam)).
                
            end. 
            
            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(cobparam).
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
    find cobra of cobparam no-lock no-error. 
    display  
        cobparam.cobcod
        cobra.cobnom when avail cobra
        cobparam.tipoOperacao
        cobparam.valMinParc
        cobparam.qtdMinParc cobparam.valorMinimoAcrescimoTotal
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        cobparam.cobcod
        cobra.cobnom
        cobparam.tipoOperacao
        cobparam.valMinParc
        cobparam.qtdMinParc cobparam.valorMinimoAcrescimoTotal

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        cobparam.cobcod
        cobra.cobnom
        
        cobparam.tipoOperacao
        cobparam.valMinParc
        cobparam.qtdMinParc cobparam.valorMinimoAcrescimoTotal
        
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        cobparam.cobcod
        cobra.cobnom
        
        cobparam.tipoOperacao
        cobparam.valMinParc
        cobparam.qtdMinParc cobparam.valorMinimoAcrescimoTotal
        
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first cobparam  where
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next cobparam  where
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev cobparam  where
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo:

        find current cobparam exclusive.
        disp    
        cobparam.tipoOperacao 
        cobparam.cobcod 

        cobparam.valMinParc
        cobparam.qtdMinParc cobparam.valorMinimoAcrescimoTotal
        
        
                   with row 9 
        centered
        overlay 1 column.
                    
        update
            cobparam
                except cobcod tipooperacao.
        
    
        find cobra where cobra.cobcod = cobparam.cobcod no-lock no-error.
        if not avail cobra
        then do:
            message "carteira invalida".
            undo.
        end.
            
    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    find last bcobparam no-lock no-error.
    create cobparam.
    prec = recid(cobparam).
    disp    
        cobparam.tipoOperacao 
        cobparam.cobcod 

        cobparam.valMinParc
        cobparam.qtdMinParc cobparam.valorMinimoAcrescimoTotal
        
        
                   with row 9 
        centered
        overlay 1 column.
    
    update
        cobparam.tipoOperacao
        cobparam.cobcod
        
        with row 9 
        centered
        overlay 1 column.
        update
            cobparam
                except cobcod tipooperacao.


end.


end procedure.



procedure pexclui.
sresp = yes.
message color normal "confirma?" update sresp.
if sresp
then do on error undo:
    find current cobparam exclusive no-wait no-error.
    if avail cobparam
    then do:
        delete cobparam.    
    end.        
end.
end procedure.
