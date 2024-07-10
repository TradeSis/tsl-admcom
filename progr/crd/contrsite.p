/*               to                   sfpl
*                                 R
*
*/

{admcab.i}

    
def input param par-clicod like clien.clicod .
def input param par-codigoPedido as char.

/**def var vhostname as char.
input through hostname.
import vhostname.
input close.**/

def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" pedido"," "," ","  "," "," "].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

    form  
        contrsite.dataTransacao column-label "DtVen" format "999999"
        contrsite.clicod        column-label "Clien"
            format ">>>>>>>>>9"
        contrsite.etbcod        column-label "Fil"
        contrsite.codigoPedido  
        contrsite.contnum format ">>>>>>>>9"
        contrsite.valorTotal
        contrsite.saldoCredito
        with frame frame-a 8 down centered row 8
        no-box.


if par-clicod = 0
then do:
    find contrsite where contrsite.etbcod = 200 and contrsite.codigoPedido = par-codigoPedido no-lock no-error.
    if not avail contrsite
    then do:
        message "Pedido " par-codigoPedido "nao localizado".
        pause.
        return.
    end.
    par-clicod = contrsite.clicod.
    recatu1 = recid(contrsite).
end. 


bl-princ:
repeat:

find clien where clien.clicod = par-clicod no-lock.

    pause 0.          
    disp clien.clicod label "Cli" clien.clinom no-label format "x(36)"
         clien.dtcad no-label format "99/99/9999"
         clien.etbcad label "Fil Cad "
            with frame fcli row 3 side-labels width 80 
        title " CREDIARIO DIGITAL "  1 down.



    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find contrsite where recid(contrsite) = recatu1 no-lock.
    if not available contrsite
    then do.
        message "nenhum registro encontrato".
        pause.
        return.
        /*
        if pfiltro = ""
        then do: 
            return.
        end.    
        pfiltro = "".
        recatu1 = ?.
        next.
        */
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(contrsite).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available contrsite
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find contrsite where recid(contrsite) = recatu1 no-lock.

        status default "".
        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field contrsite.contnum

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
                    if not avail contrsite
                    then leave.
                    recatu1 = recid(contrsite).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail contrsite
                    then leave.
                    recatu1 = recid(contrsite).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail contrsite
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail contrsite
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            
            if esqcom1[esqpos1] = " Pedido "
            then do:
                hide frame frame-a no-pause.
                hide frame f-com1 no-pause.  
                run crd/contrsiteman.p(input contrsite.codigoPedido).
                leave.
            end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(contrsite).
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
       disp 
       contrsite.dataTransacao
        contrsite.clicod
        contrsite.etbcod
        contrsite.codigoPedido
        contrsite.contnum
        contrsite.valorTotal
        contrsite.saldoCredito

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
       contrsite.dataTransacao
        contrsite.clicod
        contrsite.etbcod
        contrsite.codigoPedido
        contrsite.contnum
        contrsite.valorTotal
        contrsite.saldoCredito

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
       contrsite.dataTransacao
        contrsite.clicod
        contrsite.etbcod
        contrsite.codigoPedido
        contrsite.contnum
        contrsite.valorTotal
        contrsite.saldoCredito

        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
       contrsite.dataTransacao
        contrsite.clicod
        contrsite.etbcod
        contrsite.codigoPedido
        contrsite.contnum
        contrsite.valorTotal
        contrsite.saldoCredito

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find last contrsite  where contrsite.clicod = clien.clicod
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find prev contrsite  where contrsite.clicod = clien.clicod
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find next contrsite  where contrsite.clicod = clien.clicod
                no-lock no-error.

end.    
        
end procedure.

