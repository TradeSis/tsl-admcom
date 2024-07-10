

def var varquivo2 as character.    

varquivo2 = "/admcom/import/cdlpoa/limitesmudar.csv".



 display "Gerando clientes...". 
  
output to value(varquivo2).
		 
		 

        for each neuclien where neuclien.VctoLimite >= today - 60 and neuclien.VlrLimite > 0 no-lock.


                           pause 0.
                                                                        
                                                     
                                                                                   
       
     put neuclien.Clicod ";"
         neuclien.VlrLimite  format ">>>>9"

                   
            skip.                                                                   
                    
                   
           
                    
                    
                                    
                      
 

end.
output close.

