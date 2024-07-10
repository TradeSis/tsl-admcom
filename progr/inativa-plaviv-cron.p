{/admcom/progr/admcab-batch.i new}

/*************************************************************************
Programa que roda diariamente para inativar os planos de telefonia (plaviv) em que a data de finalização do plano já passou.
**************************************************************************/


def var vsp as char initial ";".

/*
def stream debug.

output stream debug to "/admcom/work/lista-planos-inativos.csv".

put stream debug unformatted
"Plano" vsp
"procod" vsp
"produ.pronom"   vsp
"pretab" vsp
"modelo" vsp
"dtini"  vsp
"dtfin"  vsp
"Pc.Prom." vsp
"Serviço" vsp
"Situacao"  vsp
skip.
*/

 /*************************************************************
 **************************************************************
 *********************** INATIVA PLAVIV ***********************
 **************************************************************
 **************** Data de Fim menor que hoje ******************
 **************** exportado = true           ******************
 **************************************************************
 **************************************************************/
 
for each plaviv where plaviv.exportado = true /* false = inativo*/
                  and plaviv.dtfin < today
                   no-lock.

    run p-inativa-plaviv (input rowid(plaviv)).

end.


 /*************************************************************
 **************************************************************
 *********************** INATIVA PLAVIV ***********************
 **************************************************************
 **************** Data de Fim inválida       ******************
 **************** exportado = false          ******************
 **************************************************************
 **************************************************************/
 
for each plaviv where plaviv.exportado = false /* false = inativo*/
                  and plaviv.dtfin = ?
                   no-lock.

    run p-inativa-plaviv (input rowid(plaviv)).

end.





 /*************************************************************
 **************************************************************
 *********************** INATIVA PLAVIV ***********************
 **************************************************************
 **************** Data de Fim maior que hoje ******************
 **************** exportado = false          ******************
 **************************************************************
 **************************************************************/
 
for each plaviv where plaviv.exportado = false /* false = inativo*/
                  and plaviv.dtfin > today
                   no-lock.

    run p-inativa-plaviv (input rowid(plaviv)).

end.






 /*************************************************************
 **************************************************************
 *********************** INATIVA PLAVIV ***********************
 **************************************************************
 **************** Data de Fim menor que hoje ******************
 **************** exportado = ?              ******************
 **************************************************************
 **************************************************************/
 
for each plaviv where plaviv.exportado = ? /* false = inativo*/
                  and plaviv.dtfin < today
                   no-lock.

    run p-inativa-plaviv (input rowid(plaviv)).

end.



 /*************************************************************
 **************************************************************
 *********************** INATIVA PLAVIV ***********************
 **************************************************************
 **************** Data de Fim maior que hoje ******************
 **************** exportado = ?              ******************
 **************************************************************
 **************************************************************/
 
for each plaviv where plaviv.exportado = ? /* false = inativo*/
                  and plaviv.dtfin > today
                   no-lock.

    run p-inativa-plaviv (input rowid(plaviv)).

end.



procedure p-inativa-plaviv:

    def input parameter p-row-id as rowid.

    def buffer bplaviv for plaviv.

    find first bplaviv where rowid(bplaviv) = p-row-id
    exclusive-lock no-error.
    /**********************************************************
    Trocar para exclusive-lock
    ******************************************************/
    
    if avail bplaviv
    then do:
             /*
    find first produ where produ.procod = bplaviv.procod no-lock no-error.
             
put stream debug unformatted
bplaviv.codviv   vsp
bplaviv.procod   vsp
if avail produ then produ.pronom else ""
vsp
bplaviv.pretab   vsp
bplaviv.modelo   vsp
bplaviv.dtini    vsp
bplaviv.dtfin    vsp
bplaviv.prepro   vsp
bplaviv.tipviv    vsp
bplaviv.exportado  vsp skip.
               */


        assign bplaviv.exportado = false.

        if bplaviv.dtfin = ?
            or bplaviv.dtfin > today
        then assign bplaviv.dtfin = today - 1.
        
    end.

end procedure.


