{admcab.i}

    message "Aguarde... Conectando banco CRM. (TESTE SERVER NOVO)".
    if connected ("crm")
    then disconnect crm.

    connect crm -H "sv-mat-db1" -S sdrebcrm -N tcp -ld crm no-error.
    
    run conecta_d.p.
    hide message no-pause.
    run rcliultcmp.p.
        
    if connected ("crm")
    then disconnect crm.
    
    return.
