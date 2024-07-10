{admcab.i}

def var vprocod like produ.procod.

def var vetbcod like estab.etbcod.

def var videal  like estoq.estideal.

repeat with frame f1 centered title " Estoque Ideal ":

    update vprocod.

    find first produ where produ.procod = vprocod no-lock no-error.
    if not avail produ
    then do:
        message "Produto Inexistente".
        undo,retry.
    end.
    else disp produ.pronom format "x(30)".
    update vetbcod.

    if vetbcod > 0 
    then do:
        find first estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Filial Inexistente".
            undo,retry.
        end.
        disp estab.etbnom format "x(15)" .
    end.
    else disp "Todos" @ estab.etbnom.
    
    update videal.
            
    if vetbcod > 0
    then do:
            
        find first estoq where estoq.etbcod = vetbcod and
                               estoq.procod = vprocod.
        estoq.estideal = videal.
                    
    end.
    else do:
        
        for each estoq where estoq.etbcod < 900 and
                             estoq.procod = produ.procod:
                             
             if {conv_igual.i estoq.etbcod} then next.
                
            estoq.estideal = videal.
        end.
    end.                              
                               

end.