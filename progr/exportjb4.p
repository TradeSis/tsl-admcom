
output to "/admcom/TI/joao/clientetitulo.csv".
         
def var saldodevedor as dec.
def var valorpago as dec.
def var valorlp as dec.


for each clien where clicod > 10 no-lock.


saldodevedor = 0.   
valorpago = 0.
valorlp = 0.
                                             
for each titulo                                         
         where empcod = 19 and titulo.clifor =  clien.clicod                                                        and titnat = no                                                                 and (modcod = "CRE"                                                            or modcod = "CP1" or modcod = "CP0")                   
                   and titsit  = "LIB" no-lock.                           
                                                                                            
                    saldodevedor = saldodevedor + titvlcob.
                             /*     disp titnum titsit titpar titdtven titvlcob (total) datexp.  */


        if tpcontrato = "L" then do:
                        valorlp = valorlp + titvlcob.
                                end.



end.



                                                                                
for each titulo                                                
         where empcod = 19 and titulo.clifor =  clien.clicod                                                               and titnat = no                                                     
                              and (modcod = "CRE"                                                   
                                                 or modcod = "CP1" or modcod = "CP0")                         
                   no-lock.                                 
                 
                 if titdtpag = ? then next.                                                     if titsit <> "PAG" then next.  
             if titdtpag < 08/25/2015 then next.                                                  if moecod = "NOV" then next.                                       
                                                                                                          
                                 valorpago = valorpago + titvlpag.
                                                                                             
                                      /*         disp titnum titsit titpar titdtven titvlpag (total) datexp moecod. */
                                                                                
                                                                                
end.



put clien.clicod format ">>>>>>>>>>>>>9" ";" saldodevedor ";" valorpago ";" valorlp ";" skip.

end.

output close.
