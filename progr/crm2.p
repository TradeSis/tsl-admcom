{admcom_funcoes.i new}                                                      

connect dragao -H "database" -S sdragao -N tcp -ld dragao no-error.                                                                                                                      
def var providev as dec.                                                
def var limite-cred-scor as dec.                                        
    for each clien where clicod = 12250601 no-lock.                               
    providev = 0.                                                                 
limite-cred-scor = limite-cred-scor(recid(clien)).                            
                                                                            
 for each fin.contrato where contrato.clicod = clien.clicod no-lock.           
 for each fin.titulo use-index iclicod 
                where titulo.etbcod = contrato.etbcod and                     
                          titulo.clifor = contrato.clicod and                                             titulo.titnum = string(contrato.contnum) and
                          titulo.titsit = "LIB" and
                          titulo.modcod = "CRE" and
                          fin.titulo.empcod = 19 and   
                      fin.titulo.titnat = no  no-lock.                    
                                  providev = providev + titulo.titvlcob.      
                         end.
                         end.                                
  
                                                                               
                                
               for each dragao.contrato where contrato.clicod = clien.clicod no-lock. 
                 for each dragao.titulo use-index iclicod                                                                   where                 
                         titulo.clifor = contrato.clicod and            
                         titulo.titnum = string(contrato.contnum) and   
                         titulo.titsit = "LIB" and                      
                         titulo.modcod = "CRE" and                      
                         titulo.empcod = 19 and                     
                         titulo.titnat = no  no-lock.                   
                                  providev = providev + titulo.titvlcob. 
                                                          end.                                                                            end.
                                                                                             
                                
                                
                                
                                
                                
                                                                                       
                             
                                                                               
      disp clien.clicod clinom limite-cred-scor providev.       
                             
                                 end.                                                      


