def input parameter ipcha-banco as character.

if ipcha-banco = "erp.lebes.com.br"
then do:
    
 /* connect ger -H "erp.lebes.com.br" -S sdrebger -N tcp -ld ger.    */
    connect com -H "erp.lebes.com.br" -S sdrebcom -N tcp -ld com.
    connect fin -H "erp.lebes.com.br" -S sdrebfin -N tcp -ld fin.
    connect suporte -H "erp.lebes.com.br" -S sdrebsup -N tcp -ld suporte.
 /* connect adm -H "erp.lebes.com.br" -S sadm -N tcp -ld adm.        */
    connect nfe -H "erp.lebes.com.br" -S sdrebnfe -N tcp -ld nfe.

end.
else if ipcha-banco = "dbr"
then do:
    
 /* connect ger -H "dbr" -S sdrebger_r -N tcp -ld ger.    */
    connect com -H "dbr" -S sdrebcom_r -N tcp -ld com.
    connect fin -H "dbr" -S sdrebfin_r -N tcp -ld fin.
    connect suporte -H "dbr" -S sdrebsup_r -N tcp -ld suporte.
 /* connect adm -H "dbr" -S sadm_r -N tcp -ld adm.        */
 /* connect nfe -H "dbr" -S sdrebnfe_r -N tcp -ld nfe.  */
 /* connect crm -H "dbr" -S sdrebcrm_r -N tcp -ld crm.  */

end.

