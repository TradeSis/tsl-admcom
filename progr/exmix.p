{admcab.i}

output to "/admcom/relat/relmix.csv".

def var vcodigomix as int.                                                
                                  
         
for each ger.estab where ger.estab.etbcod < 201 no-lock.                                  
                                                                          
if ger.estab.etbcod = 22 then next.                                           
                                                                          
disp ger.estab.etbcod.                                                        
                                                                          
find first tabmix where tabmix.etbcod = ger.estab.etbcod no-lock no-error.

if not avail tabmix then next.

/* disp tabmix.codmix. */                                                      
                                                                          
vcodigomix = tabmix.codmix.                                               
                                                                          
                                                                          
for each tabmix where tipomix = "P" and codmix = vcodigomix no-lock.

if not avail tabmix then next.
                                                                          
              if tabmix.mostruario = no then next.  


put ger.estab.etbcod ";" tabmix.codmix ";" tabmix.promix format ">>>>>>>>9"  
";" tabmix.qtdmix format ">>>>>>>9" skip.                                  
                                                                  
                                                                  
end.                                                              
end.         

output close.
message "Gerado Arquivo: L:/relat/relmix.csv".
pause.






