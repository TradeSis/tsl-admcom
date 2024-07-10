{admcab.i}
           
/***
def var vesc as log format "Sim/Nao" initial no.
***/
    if connected ("banfin")
    then disconnect banfin.
                       
/***
    update vesc label "Conectar LP"
        with frame f0 side-label width 80.
***/
    def var vindex as int.
    def var vsel as char extent 2 format "x(15)" 
        init["Analitico ","Sintetico  "] .
    disp vsel with frame f1.
    choose field vsel with frame f1 1 down
        centered side-label no-label.

    connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin.

    if frame-index = 1
    then run rmetdes221.p.
    else if frame-index = 2
         then run rmetdes222.p.

    disconnect banfin.
         
