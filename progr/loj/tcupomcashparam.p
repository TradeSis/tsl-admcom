{admcab.i}
def buffer bcupomcashparam for cupomcashparam.
    
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" parametros "," -"," -"].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


    form  
        
        cupomcashparam
        
        with frame frame-a 8 down centered row 8
        no-box.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find cupomcashparam where recid(cupomcashparam) = recatu1 no-lock.
    if not available cupomcashparam
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(cupomcashparam).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available cupomcashparam
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find cupomcashparam where recid(cupomcashparam) = recatu1 no-lock.
        
        status default "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field cupomcashparam.tipocupom

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
                    if not avail cupomcashparam
                    then leave.
                    recatu1 = recid(cupomcashparam).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cupomcashparam
                    then leave.
                    recatu1 = recid(cupomcashparam).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cupomcashparam
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cupomcashparam
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
        recatu1 = recid(cupomcashparam).
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
        cupomcashparam
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
                        
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find last cupomcashparam  where
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find prev cupomcashparam  where
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find next cupomcashparam  where
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo:

        find current cupomcashparam exclusive.
        disp    
            cupomcashparam.tipo colon 20
            .

                    
        update
    cupomcashparam.ativo     colon 30
    cupomcashparam.ParcelasMesmoContrato  colon 30
    cupomcashparam.ParcelasQuantidadeMin  colon 30
    cupomcashparam.diasAntecipado      colon 30.
        cupomcashparam.vlrParcelasPagas = 0.
        cupomcashparam.percDescontoProxCmp.
        cupomcashparam.vlrDescontoProxCmp = 0.
    
    update cupomcashparam.percParcelasPagas   colon 30.
    if cupomcashparam.percParcelasPagas = 0
    then do:
        update cupomcashparam.vlrParcelasPagas    colon 30.
        if cupomcashparam.vlrParcelasPagas = 0
        then do: 
            update cupomcashparam.percDescontoProxCmp colon 30.
            if cupomcashparam.percDescontoProxCmp = 0
            then update cupomcashparam.vlrDescontoProxCmp  colon 30.
        end.            
    end.

    update
    cupomcashparam.diasValidade        colon 30
        with side-labels
            row 7
            centered
               overlay.

    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    create cupomcashparam.
    prec = recid(cupomcashparam).
    cupomcashparam.tipoCupom = "CASHB".    

end.


end procedure.



