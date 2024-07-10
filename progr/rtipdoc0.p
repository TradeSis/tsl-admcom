{admcab.i}

    if connected ("banfin")
    then disconnect banfin.
                       
    connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin.

    run rtipdoc1.p .
    
    disconnect banfin.

