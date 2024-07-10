output to "/admcom/lebesintel/ocorrencias/dg9003.csv".
def var vjuro as dec.                       

for each titulo where titulo.titnat = yes          
             and titulo.empcod = 19             
             and titulo.titdtpag >= today - 10  
             and titulo.modcod <> "BON"         
             and titulo.modcod <> "CHP"         
             and titulo.modcod <> "DEV"         
                                    no-lock.          
                                                                                         if titulo.titvljur = 0 or titulo.titvlpag <= titulo.titvlcob 
        then next. 
    
         vjuro = titulo.titvljur.                            
                                                                                                             
        if vjuro = 0                                        
        then do :                                           
           if titulo.titvlpag > titulo.titvlcob            
                then do :                                       
                         vjuro = titulo.titvlpag - titulo.titvlcob.  
                end.                                            
           end.                                                
        
         find first forne where forne.forcod = titulo.clifor no-lock no-error.
        
                
         put titulo.titnum ";" clifor ";" titvlcob ";" titvlpag ";" vjuro ";" titobs ";" forne.fornom ";" skip.                               
                                                          
    end.

   
output close.