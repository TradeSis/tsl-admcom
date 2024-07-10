{admcab.i}
           
def var vesc as log format "Sim/Nao" initial no.
repeat:
              
    if connected ("banfin")
    then disconnect banfin.
                       
    update vesc label "Conectar LP"
        with frame f0 side-label width 80.
    
    connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin.
    def var vindex as int.
    def var vsel as char extent 2 format "x(15)"
        init["Analitico ","Sintetico  "] .
    disp vsel with frame f1.
    choose field vsel with frame f1 1 down
        centered side-label no-label.
    if frame-index = 1
    then do:    
        run rmetdesemi9a.p (input vesc). 
    end.
    else if frame-index = 2
         then do:
            run rmetdesemi19.p(input vesc).
         end.
/*         else run metdesemi13.p(input vesc).*/

    disconnect banfin.
    leave.
end.    
         
