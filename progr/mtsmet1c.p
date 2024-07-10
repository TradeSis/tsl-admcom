/* *****************************************************************
*  Programa.......: mtsmet1a.p
*  Funcao.........: Carrega banco metas
*  Data...........: 17/04/2007
***************************************************************** */
{admcab.i new}

def var vsenha as char format "x(11)".

update vsenha blank label "Senha"
       with frame f-senha centered side-labels. 
       vsenha = "meta-drebes".    
hide frame f-senha no-pause.

if vsenha = "meta-drebes"
then do:
    message "Aguarde... Conectando banco METAS. (METAS DE VENDAS)".
    if connected ("metas")
    then disconnect metas.

    connect /admcom/gerson/banco/metas.db -1 no-error.
    
    hide message no-pause.
    run mtspar1a.p.
        
    if connected ("metas")
    then disconnect metas.
end.
else leave.    