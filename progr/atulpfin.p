{admcab.i}
repeat:              

    if connected ("banfin")
    then disconnect banfin.
                       
    connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin.
    

    run atumodlp.p.
     
    disconnect banfin.
    leave.
end.    

