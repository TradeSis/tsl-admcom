{admcab.i}
           
    if connected ("banfin")
    then disconnect banfin.
                       
    if entry(1,sparam,";") = "sv-ca-dbr.lebes.com.br"
    then connect banfin -H dbr -S sbanfin_r -N tcp -ld banfin.
    else connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin.

    run rmetdes116.p.
    
    if connected ("banfin")
    then disconnect banfin.
