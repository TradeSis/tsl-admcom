{/admcom/progr/admcab-batch.i new}                                       
        

connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld dragao no-error.

pause 0.                                                        
run "/admcom/progr/calculalimite.p" (input "K").


pause 0.                                                        
run "/admcom/progr/calculalimite.p" (input "L").


pause 0.                                                        
run "/admcom/progr/calculalimite.p" (input "M").



pause 0.                                                        
run "/admcom/progr/calculalimite.p" (input "N").


pause 0.                                                        
run "/admcom/progr/calculalimite.p" (input "O").




 disconnect dragao.                              