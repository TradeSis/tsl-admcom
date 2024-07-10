{admcab.i}

def var vsenha as char format "x(10)" .

update vsenha blank label "Senha"
       with frame f-senha centered side-labels. 
           
hide frame f-senha no-pause.

if vsenha = "crm-drebes"
then do:
    message "Aguarde... Conectando banco CRM. (TESTE SERVER NOVO)".
    if connected ("crm")
    then disconnect crm.
    
    connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm no-error.
    
    hide message no-pause.
    run geralcrm2.p.
        
    if connected ("crm")
    then disconnect crm.
end.
else leave.