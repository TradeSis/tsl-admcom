/* helio #24102022 ID 154210 */
/* helio 13072022 - projeto Criar Produtos - ADM */

{admcab.i}
def buffer bsicred_param for sicred_param.
    
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" parametros "," planos "," inclusao "," -"," -"].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


    form  
        
        sicred_param.dtini
        sicred_param.dtfim
        
        dias_retroativo 
        codigoLojista
        tfc_minimo
        tfc_maximo
        valor_min_acrescimo
        permitePJ column-label "PJ"
        permiteIOFzero column-label "IOFz"
        
        with frame frame-a 8 down centered row 8
        no-box.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find sicred_param where recid(sicred_param) = recatu1 no-lock.
    if not available sicred_param
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(sicred_param).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available sicred_param
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find sicred_param where recid(sicred_param) = recatu1 no-lock.
        
        if sicred_param.dtfim <> ?
        then do:
            esqcom1[1] = "".
            esqcom1[2] = "".
        end.    
        else do:
             esqcom1[1] = " parametros".
             esqcom1[2] = " planos".
        end.     
        
        status default "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field sicred_param.dtini

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
                    if not avail sicred_param
                    then leave.
                    recatu1 = recid(sicred_param).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail sicred_param
                    then leave.
                    recatu1 = recid(sicred_param).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail sicred_param
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail sicred_param
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
            
            
            if esqcom1[esqpos1] = " planos "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run fin/opesicplanos.p.
                
            end. 
            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(sicred_param).
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
        sicred_param.dtini
        sicred_param.dtfim
        dias_retroativo 
        codigoLojista
        tfc_minimo
        tfc_maximo
        valor_min_acrescimo
        permitePJ
        permiteIOFzero
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        sicred_param.dtini
        sicred_param.dtfim
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        sicred_param.dtini
        sicred_param.dtfim
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
                sicred_param.dtini
                        sicred_param.dtfim
                        
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find last sicred_param  where
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find prev sicred_param  where
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find next sicred_param  where
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo:

        find current sicred_param exclusive.
        disp    
            sicred_param.dtini colon 20
            sicred_param.dtfim
            .

                    
        update
        dias_retroativo colon 20
        codigoLojista colon 20
        tfc_minimo colon 20
        tfc_maximo
        valor_min_acrescimo colon 20
        codProdutoecom colon 20
        permitePJ colon 20
        cpnsemacrescimo colon 20
        permiteIOFzero colon 20
        with side-labels
            row 7
            centered
               overlay.

    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    find last bsicred_param where bsicred_param.dtfim = ?  no-error.
    if avail bsicred_param
    then do:
        bsicred_param.dtfim = today.
    end.    
    create sicred_param.
    prec = recid(sicred_param).
    sicred_param.dtini = today.
    
    if avail bsicred_param
    then buffer-copy bsicred_param except dtini dtfim to sicred_param.

end.


end procedure.



