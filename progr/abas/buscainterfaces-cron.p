{/admcom/progr/admbatch.i new}

def var par-interface as char.

def new shared temp-table ttarq no-undo
    field arq as char format "x(50)"
    field interface     as char     
    field Arquivo       as char initial ?  format "x(30)"
    field diretorio     as char
    index idx is unique primary interface asc Arquivo asc.

par-interface = "CONF".
 
run abas/buscaarquivo.p (input par-interface).

run abas/corteconfirma.p.


par-interface = "CREC".
 
run abas/buscaarquivo.p (input par-interface).

run abas/reccompraconfirma.p.

par-interface = "EBLJ".

run abas/buscaarquivo.p (input par-interface).

run abas/ebljcria.p.

par-interface = "FCGL".

run abas/buscaarquivo.p (input par-interface).

run abas/fcglcria.p.

par-interface = "XD*lin_ped_liberado".

run abas/buscaarquivoneogrid.p (input par-interface).

run abas/impneotransf.p.
 
par-interface = "XD*lin_ped_compra".

run abas/buscaarquivoneogrid.p (input par-interface).

run abas/impneocompra.p.
 

