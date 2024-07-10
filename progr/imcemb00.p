{admcab.i}

def var vsenha as char format "x(10)".

update vsenha blank label "Senha"
       with frame f-senha centered side-labels. 
           
hide frame f-senha no-pause.

if vsenha = "crm-drebes"
then do:
    message "Aguarde... Conectando banco CRM.".
    if connected ("crm")
    then disconnect crm.
    
    connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm no-error.
    
    hide message no-pause.
    run imcemb01.p.
        
    if connected ("crm")
    then disconnect crm.
    return.
end.          
else leave.