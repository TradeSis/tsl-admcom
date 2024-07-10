{/admcom/progr/admbatch.i new}


def new shared temp-table ttarq no-undo
    field arq as char format "x(50)"
    field interface     as char     
    field Arquivo       as char initial ?  format "x(30)"
    field diretorio     as char
    index idx is unique primary interface asc Arquivo asc.

message today string(time,"HH:MM:SS") "abas/buscaneogridcom.p" "abas/buscaarquivoneogrid.p" "XD*lin_ped_compras".
run abas/buscaarquivoneogrid.p (input "XD*lin_ped_compras").
message today string(time,"HH:MM:SS") "abas/buscaneogridcom.p" "abas/impneocompra.p".
    run abas/impneocompra.p.
message today string(time,"HH:MM:SS") "abas/buscaneogridcom.p" "FIM".
    
 

