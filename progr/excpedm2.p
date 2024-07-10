def input parameter p-etbcod like estab.etbcod.
def input parameter p-data1 as date format "99/99/9999".

for each comloja.pedid where comloja.pedid.etbcod = p-etbcod
                         and comloja.pedid.pedtdc = 3 
                         and comloja.pedid.pednum < 100000:

    if comloja.pedid.peddat >= p-data1
    then next.

    display "Deletando pedidos manuais na Filial ..." 
            comloja.pedid.etbcod no-label 
            comloja.pedid.pednum no-label  
            with frame f2f 1 down centered.
    pause 0.
    
    for each comloja.liped of comloja.pedid:
        
        delete comloja.liped.
        
    end.
    
    delete comloja.pedid.
    
end.

hide frame f2f no-pause.
