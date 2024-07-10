/*** acesso remoto ***/
{admcab.i.ssh}

                 message "Conectando ao banco CRM...".
                 if connected ("crm")
                 then disconnect crm.

                 connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm.

                 run lisbon02-ssh.p.

                 if connected ("crm")
                 then disconnect crm.
 
