{admcab.i new}
           
    if connected ("banfin")
    then disconnect banfin.
                       
    def var vindex as int.
    def var vsel as char extent 2 format "x(15)" 
        init["Analitico ","Sintetico  "] .
    disp vsel with frame f1.
    choose field vsel with frame f1 1 down
        centered side-label no-label.

    def var vorca as char extent 3 format "x(15)"
            init["ORCAMENTO","Limiar","Incremento"]. 
    def var vproj as char extent 3 format "x(15)"
            init["PROJETO","Investimento","Despesa"].
    def new shared var vindex-orca as int.
    def new shared var vindex-proj as int.        
    disp vorca no-label with frame f2 centered.
    disp vproj no-label with frame f3 centered.
    choose field vorca with frame f2.
    vindex-orca = frame-index.
    choose field vproj with frame f3.
    vindex-proj = frame-index.
    

    if entry(1,sparam,";") = "sv-ca-dbr.lebes.com.br"
    then connect banfin -H dbr -S sbanfin_r -N tcp -ld banfin.
    else connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin.

    if frame-index = 1
    then run rmetdes111-0.p.
    else if frame-index = 2
         then run rmetdes112-0.p.

    disconnect banfin.
         
