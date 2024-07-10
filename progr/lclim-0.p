{admcab.i}

if connected ("crm")
then disconnect crm.

connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm no-error.

run lclmaila-0.p.

if connected ("crm")
then disconnect crm.
