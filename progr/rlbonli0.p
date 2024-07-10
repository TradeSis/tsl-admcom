{admcab.i}

connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm no-error.

hide message no-pause.
run rlbonli1.p.

if connected ("crm")
then disconnect crm.

