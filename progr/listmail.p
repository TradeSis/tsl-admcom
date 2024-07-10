{admcab.i}

message "Aguarde... Conectando banco CRM.".
if connected ("crm")
then disconnect crm.
    
connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm no-error.
   
hide message no-pause.
run lista_clientes.p.
        
if connected ("crm")
then disconnect crm.
