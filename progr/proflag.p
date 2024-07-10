{admcab.i}
def var vprocod like produ.procod.
def var falhar1 as log format "Sim/Nao".
def var falhar2 as log format "Sim/Nao".
repeat:

    update vprocod with frame f1 side-label width 80.
    find produ where produ.procod = vprocod no-error.
    if not avail produ
    then do:
        message "Produto nao Cadastrado".
        undo, retry.
    end.
    disp produ.pronom no-label with frame f1.

           
    if substring(produ.proclafis,1,1) = "1"
    then falhar1 = yes.
    else falhar1 = no.
       
    if substring(produ.proclafis,2,1) = "1"
    then falhar2 = yes.
    else falhar2 = no.

    
    update falhar1 label "Nao deve Falhar" colon 17
           falhar2 label "Deve Falhar    " colon 17
                with frame f-car side-label centered color white/cyan.
    do transaction:
       
       if falhar1 
       then substring(produ.proclafis,1,1) = "1".
       else substring(produ.proclafis,1,1) = "0".

       if falhar2 
       then substring(produ.proclafis,2,1) = "1".
       else substring(produ.proclafis,2,1) = "0".

       produ.datexp = today.
    end.
end.
