{/admcom/progr/admbatch.i new}


def new shared temp-table ttarq no-undo
    field arq as char format "x(50)"
    field interface     as char     
    field Arquivo       as char initial ?  format "x(30)"
    field diretorio     as char
    index idx is unique primary interface asc Arquivo asc.

pause 0 before-hide.
message today string(time,"HH:MM:SS") "abas/buscaalcis.p" "abas/buscaarquivo.p" "CONF".
run abas/buscaarquivo.p (input "CONF"). 
message today string(time,"HH:MM:SS") "abas/buscaalcis.p" "abas/corteconfirma.p".
    run abas/corteconfirma.p.

/* CREC nao eh mais no novo modelo - segue no ordv-PE-cron.p
message today string(time,"HH:MM:SS") "abas/buscaalcis.p" 
        "abas/buscaarquivo.p"~  "CREC".
*run abas/buscaarquivo.p (input "CREC"). 
*message today string(time,"HH:MM:SS") "abas/buscaalcis.p" 
    "abas/reccompraconfirma.p".
*   run abas/reccompraconfirma.p.
**/    
message today string(time,"HH:MM:SS") "abas/buscaalcis.p" "FIM".



/* ficou direto no programa abas/cargamen.p
*run abas/buscaarquivo.p (input "EBLJ"). 
*    run abas/ebljcria.p.
*run abas/buscaarquivo.p (input "FCGL"). 
*    run abas/fcglcria.p.
*run abas/buscaarquivo.p (input "VEXM"). 
*    run abas/vexmcria.p.
*/

 

