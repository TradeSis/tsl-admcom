def input parameter vetbcod like estab.etbcod.

for each comloja.plani where comloja.plani.etbcod = vetbcod and
                             comloja.plani.movtdc = 30      and
                             comloja.plani.pladat < today:
                             
                             
    display comloja.plani.etbcod
            comloja.plani.numero format "9999999"
            comloja.plani.serie
            comloja.plani.movtdc format "99"
            comloja.plani.pladat.
    pause 0.        
            
    for each comloja.movim where 
                comloja.movim.etbcod = comloja.plani.etbcod and
                comloja.movim.placod = comloja.plani.placod and
                comloja.movim.movtdc = comloja.plani.movtdc: 
                                 
        display comloja.movim.procod
                comloja.movim.movpc
                comloja.movim.movqtm
                comloja.movim.movdat
                comloja.movim.movtdc format "99".
        pause 0.        
                
        do transaction:
            delete comloja.movim.
        end.    
    end.
    do transaction:
    
        delete comloja.plani.
        
    end.

end.
                
                                      
                                        
                                    

                       
