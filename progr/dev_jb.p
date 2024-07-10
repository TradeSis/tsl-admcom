
def var acumulatudo as int.                                                   
acumulatudo = 0.                                                              
                                                                              
for each plani where plani.movtdc = 12                                        
                    and plani.serie = "1"                                     
                    and plani.etbcod = 110                                    
                    and pladat >= 02/01/2012                                  
                    and pladat <= 02/29/2012 no-lock.                         
                                                                              
                    for each movim where movim.placod = plani.placod          
                     and plani.etbcod = movim.etbcod                          
                     no-lock.                                                 
                                                                              
                  find first produ where produ.procod = movim.procod.         
                    if produ.catcod = 41 then next.                           
                                                                              
                    disp movim.procod movim.movqtm movim.movpc movim.movdat.  
                     acumulatudo = acumulatudo + movim.movpc.                 

                              pause 0.                        
                  /*  disp etbcod platot(total).  */          
                                                              
                                                              
    end.                                                      
end.                                                          
message acumulatudo.                                          

                            
 

Moveis 1,3% 0.6 = 
Moda 2,2% 0.6

 
55345 venda
2778 dev

55345 100
2778 x




5%

