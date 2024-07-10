{/admcom/progr/admcab-batch.i new}                                       
        

connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld dragao no-error.

pause 0.                                                                
run "/admcom/progr/calculalimite.p" (input "A").

pause 0.                                                                
run "/admcom/progr/calculalimite.p" (input "B").

pause 0.                                                                
run "/admcom/progr/calculalimite.p" (input "C").

pause 0.                                                                
run "/admcom/progr/calculalimite.p" (input "D").


 disconnect dragao.                              