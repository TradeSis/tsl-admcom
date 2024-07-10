for each produ where produ.pronom matches "*TV *".                                                               
/*                                                           
 if produ.pronom matches "*LCD*" or                          
    produ.pronom matches "*LED*"                             
    then next.                                               
 */                                                          
                                                             
if produ.catcod <> 31 then next.                             
                                                             
disp produ.procod produ.pronom.                              
                                                             
pause 1.                                                     
                        /*                            
  create prodatrib.                                   
    prodatrib.atribcod  = 4. /* polegadas */          
    prodatrib.procod = produ.procod.                  
    prodatrib.valor = 34.                             
                          */                          
                                                      
               /*                                     
  create procaract.                                   
    procaract.procod = produ.procod.                  
    procaract.subcod = 62.                            
                 */                                   
                                                      
   end.                                               
                                                      
                                                      





