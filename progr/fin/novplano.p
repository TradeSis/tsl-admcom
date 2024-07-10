/*               to                   sfpl
*                                 R
*
*/

{admcab.i}

def input param par-rec as recid. 
def buffer bnovplanos for novplanos.
    
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" parametros "," inclusao"," exclusao "," "," "].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


find novcampanha where recid(novcampanha) = par-rec no-lock.

    form  
        
        novplanos.planom 
        
        with frame frame-a 8 down centered row 8
            title novcampanha.camnom.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find novplanos where recid(novplanos) = recatu1 no-lock.
    if not available novplanos
    then do.
        run pinclui (output recatu1).
        run pparametros.
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(novplanos).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available novplanos
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find novplanos where recid(novplanos) = recatu1 no-lock.

        status default "".
        
                        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field novplanos.planom

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
                    if not avail novplanos
                    then leave.
                    recatu1 = recid(novplanos).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail novplanos
                    then leave.
                    recatu1 = recid(novplanos).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail novplanos
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail novplanos
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
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(novplanos).
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
        novplanos.planom
    novplanos.planom
    novplanos.calc_juro_titulo
    novplanos.com_entrada
    novplanos.perc_min_entrada
    novplanos.dias_max_primeira
    novplanos.qtd_vezes
    novplanos.perc_desconto column-label "desc"
    novplanos.perc_acres     column-label "% acres"
    novplanos.valor_acres column-label "vlr acres"
    novplanos.plaord
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        novplanos.planom
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        novplanos.planom
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        novplanos.planom
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first novplanos  of novcampanha
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next novplanos  of novcampanha
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev novplanos of novcampanha
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo:

        find current novplanos exclusive.

    /* update novplanos.planom. */
    
    update
        novplanos.plaord colon 16 label "ordem".
    update     
        novplanos.calc_juro_titulo  colon 46
        novplanos.com_entrada       colon 16 .
    update 
        novplanos.perc_min_entrada when novplanos.com_entrada colon 46
        novplanos.dias_max_primeira colon 16 label "dias primeira"
        novplanos.perc_desconto     colon 16.

    if novplanos.perc_desconto <> 0
    then novplanos.valor_desc    = 0.
    else update novplanos.valor_desc label "valor desc" colon 46.
         
    update  novplanos.perc_acres   colon 16.
    if novplanos.perc_acres <> 0
    then novplanos.valor_acres    = 0.
    else update novplanos.valor_acres label "valor acres" colon 46.
    update        
        novplanos.qtd_vezes colon 16
        novplanos.permite_alt_vezes label "permite alteracao?"
        with side-labels
            row 9
            centered
               overlay
               title novplanos.planom.
    end.
    
    run pparcelas.
    
end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    find last bnovplanos no-lock no-error.
    create novplanos.
    prec = recid(novplanos).
    novplanos.camcod = novcampanha.camcod.
    
    update
        novplanos.planom
        with row 9 
        centered
        overlay.


end.


end procedure.



procedure pexclui.
sresp = yes.
message color normal "confirma?" update sresp.
if sresp
then do on error undo:
    find current novplanos exclusive no-wait no-error.
    if avail novplanos
    then do:
        for each novplanparcel of novplanos.
            delete novplanparcel.
        end.
        delete novplanos.
    end.        
end.
end procedure.


procedure pparcelas.

    run fin/novplanparcel.p (recid(novplanos)).

end procedure.

