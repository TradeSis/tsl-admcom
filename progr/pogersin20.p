{admcab.i new}
/*
    if connected ("banfin")
    then disconnect banfin.
    connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin.
*/
if connected ("d")
then disconnect d.
run conecta_d.p.

if connected ("d")
then do.
    run pogersin22.p.
/*
    disconnect banfin.
    */
    disconnect d.
end.
