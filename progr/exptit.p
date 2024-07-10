def var v-valor as char.                                                
                                                                        
output to "/admcom/TI/joao/BiCred.txt".                                 
                                                                        
for each estab where etbcod >= 1 and etbcod <= 1 no-lock.               
                                                                        
disp estab.etbcod.                                                      
                                                                        
for each titulo where titulo.etbcod = estab.etbcod and titsit = "LIB"   
no-lock.                                                                
                                                                        
if titvlcob = 0 then next.                                              
if titdtpag <> ? then next.                                             
                                                                        
assign v-valor = string(titvlcob).                                      
                                                                        
run p-converte-valor (input v-valor,                                    
output v-valor).    


                                                                             
disp etbcod ";" titnum ";" titpar ";" titsit ";" v-valor  ";" titdtven ";"   
titdtpag ";" skip.                                                           
pause 0.                                                                     
end.                                                                         
end.                                                                         
output close.      


procedure p-converte-valor:

   def input  parameter ipcha-campo as character.
   def output parameter opcha-retorno as character.

   assign opcha-retorno = trim(ipcha-campo).

   assign opcha-retorno = replace(opcha-retorno,".","@").

   assign opcha-retorno = replace(opcha-retorno,",",".").

   assign opcha-retorno = replace(opcha-retorno,"@",",").

end procedure.



                                                          
                                                                             
                          

                                                                                                      