for each titulo where                       
         titulo.empcod = 19      and   
         titulo.titnat = no      and      
         titulo.modcod = "CHQ"   and        
         titulo.etbcod >= 1      and        
         titulo.titdtemi <= today  and        
         titulo.titdtemi >= today - 60   no-lock ,
   first plani where  plani.pladat = titulo.titdtemi and
                      plani.etbcod = titulo.etbcod   and
                      plani.desti  = titulo.clifor    
                      no-lock:           

disp titulo.titnum
     titulo.titpar
     titulo.titdtemi
     titulo.titvlpag
     plani.numero
     plani.serie
     plani.platot
     plani.platot - titulo.titvlpag with frame fa down width 100.  
     

/*    each plani where                         
         plani.etbcod = titulo.etbcod and    
         plani.placod = titulo.placod and    
         plani.vendcod =                   */  
                                                            