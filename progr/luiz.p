for each proloj:
    
    
    if proloj.estatual = 1000
    then next.
    
    for each movim where movim.etbcod = proloj.etbcod and
                         movim.procod = proloj.procod and
                         movim.movtdc = 05            and
                         movim.movdat = today - 1 no-lock.
                         
        proloj.estatual = proloj.estatual - movim.movqtm.
        
        
    end.
    
end.        
                             
                         
