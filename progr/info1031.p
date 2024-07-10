{/admcom/progr/admcab-batch.i}

def output parameter varqsai  as char.

    if connected ("crm")
    then disconnect crm.
    
    connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm no-error.
    
    hide message no-pause.
    run rlbon-info1031.p (output varqsai).
        
    if connected ("crm")
    then disconnect crm.
