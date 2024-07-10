{/admcom/progr/admcab-batch.i new}                                       
        

connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld dragao no-error.

                                                                 
pause 0.                                                        
run "/admcom/progr/calculalimite.p" (input "P").


pause 0.                                                        
run "/admcom/progr/calculalimite.p" (input "Q").

pause 0.                                                        
run "/admcom/progr/calculalimite.p" (input "R").


pause 0.                                                        
run "/admcom/progr/calculalimite.p" (input "S").


pause 0.                                                        
run "/admcom/progr/calculalimite.p" (input "T").


pause 0.                                                        
run "/admcom/progr/calculalimite.p" (input "U").


pause 0.                                                        
run "/admcom/progr/calculalimite.p" (input "V").


pause 0.                                                        
run "/admcom/progr/calculalimite.p" (input "X").



pause 0.                                                        
run "/admcom/progr/calculalimite.p" (input "Y").

pause 0.                                                        
run "/admcom/progr/calculalimite.p" (input "Z").

pause 0.                                                        
run "/admcom/progr/calculalimite.p" (input "W").




 disconnect dragao.                              