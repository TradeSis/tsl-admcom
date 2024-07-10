{admcab.i}

def var esc-fil as char format "x(27)" extent 3
    initial ["  Consumo de Clientes CRM  ",
             "  Resumo de Notas da Acao  ",
             "  Ranking de Vendedores    "].

def var vsenha as char format "x(10)".

update vsenha blank label "Senha"
       with frame f-senha centered side-labels. 
           
hide frame f-senha no-pause.

if vsenha = "crm-drebes"
then do:
    message "Aguarde... Conectando banco CRM. (TESTE SERVER NOVO)".
    if connected ("crm")
    then disconnect crm.
                         /*erp.lebes.com.br*/
    /*connect crm -H 192.168.0.8 -S sdrebcrm -N tcp -ld crm no-error.*/
    
    connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm no-error.
    
    hide message no-pause.
    
    disp  skip(1)
          esc-fil[1] skip 
          esc-fil[2] skip
          esc-fil[3] skip(1)
          with frame f-esc-fil title " MENU RELATORIOS CRM " row 7
               centered color with/black no-label overlay. 
    
    choose field esc-fil auto-return with frame f-esc-fil.
                    
    clear frame f-esc-fil no-pause.
    hide frame f-esc-fil no-pause.
                    
    if frame-index = 1
    then run crm20-rel01.p.
    /*    
    if frame-index = 2
    then run crm20-notaca.p.     
    */
    if frame-index = 3
    then run rlbonve1.p.
                
    if connected ("crm")
    then disconnect crm.
    
end.
else leave.