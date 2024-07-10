/**********************************************************    
* codreca.p - Compras p/Filial/Vendedor/Cartao Drebes          
* Autor : A.Maranghello                                        
* Data Criacao :16/07/2009                                     
* Ultima Alteracao :                                           
* Descricao Sumaria Alteracao :                                
***********************************************************/   
{admcab.i}   
                                                               
/*** Conectando Banco CRM no server CRM ***/
connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm no-error.

if not connected ("crm")
then do:
    message "Nao foi possivel conectar o banco CRM. Avise o CPD."
    view-as alert-box.
    leave.
end.

run codreca01.p.
disconnect crm.

