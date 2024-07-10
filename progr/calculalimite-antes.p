{/admcom/progr/admcab-batch.i new}                                       
        

connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld dragao no-error.

                                                                 
run "/admcom/progr/calculalimite.p" (input "W").


 disconnect dragao.                              