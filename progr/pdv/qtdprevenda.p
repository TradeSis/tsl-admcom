/* helio 11052022 - Contador de Pre-vendas  */

{admcab.i}

def input param petbcod    as int.
def input param pdata as date.
def input param pdtfim as date. 

def temp-table ttpreVenda no-undo
    field rec as recid.
 
def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["","","","","csv",""].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

        
    form  
        contadorpreVendas.etbcod
        estab.etbnom format "x(15)"
        contadorpreVendas.data               
        contadorpreVendas.qtdprevendas       
        with frame frame-a 9 down centered row 7
        no-box.

empty temp-table ttprevenda.

run montatt.

bl-princ:
repeat:
    

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttprevenda where recid(ttprevenda) = recatu1 no-lock.
    if not available ttprevenda
    then do.
        message "nenhum registro encontrato".
        pause.
        return.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttprevenda).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttprevenda
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttprevenda where recid(ttprevenda) = recatu1 no-lock.
        find contadorprevenda where recid(contadorprevenda) = ttprevenda.rec no-lock.

        status default "".
        
                        
                     
        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 6.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 6.
            esqcom1[vx] = "".
        end.     
        
    hide message no-pause.
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        vhelp = "".

        
        status default vhelp.
        choose field contadorprevenda.etbcod
                      help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

        if keyfunction(lastkey) <> "return"
        then run color-normal.

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
                    if not avail ttprevenda
                    then leave.
                    recatu1 = recid(ttprevenda).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttprevenda
                    then leave.
                    recatu1 = recid(ttprevenda).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttprevenda
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttprevenda
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            
            
             if esqcom1[esqpos1] = "csv "
             then do: 
                    run geraCSV.
                end.
            

             
        end. 
        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttprevenda).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame ftit no-pause.
hide frame ftot no-pause.
return.
 
procedure frame-a.
    
    find contadorprevenda where recid(contadorprevenda) = ttprevenda.rec no-lock.
    
    find estab of contadorprevenda no-lock no-error.
    disp
        contadorpreVendas.etbcod
        estab.etbnom when avail estab
        contadorpreVendas.data               
        contadorpreVendas.qtdprevendas       

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        contadorpreVendas.etbcod
        estab.etbnom 
        contadorpreVendas.data               
        contadorpreVendas.qtdprevendas       
    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        contadorpreVendas.etbcod
        estab.etbnom 
        contadorpreVendas.data               
        contadorpreVendas.qtdprevendas       
                     
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        contadorpreVendas.etbcod
        estab.etbnom 
        contadorpreVendas.data               
        contadorpreVendas.qtdprevendas       
 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

    if par-tipo = "pri" 
    then do:
        find first ttprevenda 
            no-lock no-error.
    end.    
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find next ttprevenda 
            no-lock no-error.
    end.    
             
    if par-tipo = "up" 
    then do:
        find prev ttprevenda
            no-lock no-error.

    end.  
        
end procedure.






procedure geraCSV.
def var pordem as int.
 
def var varqcsv as char format "x(65)".
    if petbcod = ?
    then do:
        varqcsv = "/admcom/relat/contadorprevenda_" + 
                string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".csv".
    end.
    else do:
        varqcsv = "/admcom/relat/contadorprevenda_filial" + string(petbcod) + "_" + 
            string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".csv".
    
    end.

    update varqcsv no-label colon 12
                            with side-labels width 80 frame f1
                            row 15 title "csv"
                            overlay.


message "Aguarde...". 
output to value(varqcsv).
put unformatted  "filial;" 
                 "data;"
                 "qtd prevendas;"
                 skip.

    for each ttprevenda.
        find contadorprevenda where recid(contadorprevenda) = ttprevenda.rec no-lock.
    
        put unformatted
            contadorpreVendas.etbcod ";"
            contadorpreVendas.data format "99/99/9999"              ";"
            contadorpreVendas.qtdprevendas       ";"
            skip.

    end.  


output close.

        hide message no-pause.
        message "Arquivo csv gerado " varqcsv.
        hide frame f1 no-pause.
        pause.    

end procedure.




procedure montatt.
  
  if petbcod = ?
  then do:  
    if pdata = ?
    then do:
        for each contadorprevenda no-lock.
            create ttprevenda.
            ttprevenda.rec = recid(contadorprevenda).
        end.    
    end.
    else do:
        for each contadorprevenda where  contadorprevenda.data    >= pdata and
                                         contadorprevenda.data    <= pdtfim
                                      no-lock.
                create ttprevenda.
                ttprevenda.rec = recid(contadorprevenda).
        end.                                      
    end.
  end.
  else do:  
    if pdata = ?
    then do:
        for each contadorprevenda where  contadorprevenda.etbcod  = petbcod       
                no-lock.
                create ttprevenda.
                ttprevenda.rec = recid(contadorprevenda).
        end.                                                    
    end.
    else do:
        for each contadorprevenda where  contadorprevenda.etbcod  = petbcod       and
                                         contadorprevenda.data    >= pdata  and
                                         contadorprevenda.data   <= pdtfim
                no-lock.
                create ttprevenda.
                ttprevenda.rec = recid(contadorprevenda).
        end.                                                    
    end.
  end.  
end procedure.            
