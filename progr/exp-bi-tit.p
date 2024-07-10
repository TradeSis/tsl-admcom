output to "/admcom/TI/joao/BiCred.txt".                                      
                                                                             
for each estab where etbcod >= 1 and etbcod <= 999 no-lock.                    
                                                                             
/* disp estab.etbcod. */                                                           
                                                                             
for each titulo where titulo.etbcod = estab.etbcod and titsit = "LIB" and modcod = "CRE" no-lock.                                                                     
                                                                             
if titvlcob = 0 then next.
if titdtpag <> ? then next.
                                                                             
disp etbcod ";" titnum ";" titpar ";" titsit ";" titvlcob ";" titdtven ";"   
titdtpag ";" no-label skip.                                                           
pause 0.                                                                     
end.                                                                         
end.                                                                         
output close.                                                                                               