message "Conectando aos bancos BANFIN...".
if connected ("banfin")
then disconnect banfin.

connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin.

run result0.p.

if connected ("banfin")
then disconnect banfin.
