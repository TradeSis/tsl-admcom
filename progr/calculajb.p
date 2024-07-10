def buffer btitulo       for titulo.
def var totalret as dec.
totalret = 0.

              def var liberamudanca as int.
for each estab no-lock.                                                      
                             message etbcod.                                 
                                                                                                          
                        for each titulo where empcod = 19 and                                                   titnat = no and                                                             modcod = "CRE" and                                
                                titdtven >= today - 130 and                                                   titdtven <= today + 31 and                                                    titulo.etbcod = estab.etbcod.                     
                        
                                   if titulo.titsit <> "LIB" then next.                                                                                                                         
                                if titpar >= 51 and tpcontrato = "L" then do:                    
                                           liberamudanca = 0.
                                           
     find first btitulo where btitulo.empcod = 19 and
                              btitulo.titnat = no and 
                              btitulo.etbcod = titulo.etbcod and
                              btitulo.titnum = titulo.titnum and
                              btitulo.titsit = titulo.titsit and
                              btitulo.clifor = titulo.clifor and 
                              btitulo.modcod = "CRE"  and
                              btitulo.titsit = titulo.titsit
                              and btitulo.titpar = 31  no-lock no-error.
                      
                   
                        if avail btitulo then do:
                                liberamudanca = 1.
                                titulo.tpcontrato = "N".
                                totalret = totalret + titulo.titvlcob.
                                end.
                                else do:
                                liberamudanca = 0.
                                end.
                        
        disp titulo.etbcod titulo.titnum titulo.titpar titulo.clifor titulo.titsit titulo.titvlcob titulo.titdtemi titulo.titdtven liberamudanca titulo.tpcontrato.            


           pause 0.                                  
                                                                
                                       
        /*                                                                      titulo.tpcontrato = "N".               
          */                                           
                                                     
                                                                      end.                                
                                                                                                                           
                                                                               
                                                                                                
                                                                                           end.                                     
               end.                                             
               message totalret.