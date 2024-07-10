{admcab.i}

def var vcatcod     like produ.catcod.
def var vdt         as   date format "99/99/9999".
def var vetb1       like estab.etbcod.
def var vetb2       like estab.etbcod.
def var vcont-etb   as   int.
    
repeat:

    assign vcatcod   = 0
           vcont-etb = 0
           vdt       = ?
           vetb1     = 0
           vetb2     = 0.
           
    update vcatcod label "Departamento"
           with frame f-dep width 80 side-label color blue/cyan row 4.

    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.

    update skip vdt label "Data Final.."
           with frame f-dep.

    update skip vetb1 label "Etb. Inicial" skip
           vetb2 label "Etb. Final.." with frame f-dep.

    message "Confirma a impressao ?" update sresp.
    
    if not sresp
    then undo.
    
    do vcont-etb = vetb1 to vetb2:
    
        run rel-ote2.p(input vcatcod,
                       input vdt,
                       input vcont-etb).

    end.
end.