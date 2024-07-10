{admcab.i}
def var vesc as log format "Sim/Nao" initial no.
repeat:              

    if connected ("banfin")
    then disconnect banfin.
                       
    vesc = yes.
                       /*
    update vesc label "Conectar LP"
        with frame f1 side-label width 80.
                         */
                         
    connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin.
    
    if connected ("banfin")
    then do:
        run exp_pagB.p(input vesc). 
        disconnect banfin.
    end.
    else do:
        message color red/with
        "Banco BANFIN não conectou."
        view-as alert-box.
    end.  
     
    leave. 
end.    

