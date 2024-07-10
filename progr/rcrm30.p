{admcab.i}

def var vsenha as char format "x(10)".

update vsenha blank label "Senha"
       with frame f-senha centered side-labels. 
           
hide frame f-senha no-pause.

if vsenha = "colorado"
then do:
    message "Aguarde... Conectando banco CRM. (TESTE SERVER NOVO)".
    if connected ("crm")
    then disconnect crm.
                         /*erp.lebes.com.br*/
    /*connect crm -H 192.168.0.8 -S sdrebcrm -N tcp -ld crm no-error.*/
    
    connect crm -H "192.168.0.5" -S sdrebcrm -N tcp -ld crm no-error.
    
    hide message no-pause.
    run crm20.p.
        
    if connected ("crm")
    then disconnect crm.
end.
else leave.