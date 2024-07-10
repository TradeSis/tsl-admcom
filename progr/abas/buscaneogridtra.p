{/admcom/progr/admbatch.i new}


def new shared temp-table ttarq no-undo
    field arq as char format "x(50)"
    field interface     as char     
    field Arquivo       as char initial ?  format "x(30)"
    field diretorio     as char
    index idx is unique primary interface asc Arquivo asc.

pause 0 before-hide.
message today string(time,"HH:MM:SS") "abas/buscaneogridtra.p" "abas/buscaarquivoneogrid.p" "XD*lin_ped_liberado".
run abas/buscaarquivoneogrid.p (input "XD*lin_ped_liberado").
message today string(time,"HH:MM:SS") "abas/buscaneogridtra.p" "abas/impneotransf.p".
    run abas/impneotransf.p.
message today string(time,"HH:MM:SS") "abas/buscaneogridtra.p" "FIM".


    
 

