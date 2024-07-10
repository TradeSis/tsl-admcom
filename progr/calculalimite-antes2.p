{/admcom/progr/admcab-batch.i new}                                       
        

connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld dragao no-error.

pause 0.                                 
run "/admcom/progr/calculalimite.p" (input "E").

pause 0.                                 
run "/admcom/progr/calculalimite.p" (input "F").

pause 0.                                 
run "/admcom/progr/calculalimite.p" (input "G").

pause 0.                                 
run "/admcom/progr/calculalimite.p" (input "H").

pause 0.                                 
run "/admcom/progr/calculalimite.p" (input "I").

pause 0.                                 
run "/admcom/progr/calculalimite.p" (input "J").




 disconnect dragao.                              