{admcab.i}
def var vprocod like produ.procod.
repeat:
    UPDATE vprocod with frame f1 side-label width 80.
    find produ where produ.procod = vprocod no-error.
    if not avail produ
    then do:
        message "Produto nao Cadastrado".
        undo, retry.
    end.
    disp produ.pronom no-label with frame f1.
    do transaction:
        update produ.proabc label "Brinde" with frame f1 side-label.
        if produ.proabc = "B"
        then produ.datexp = today.
    end.

end.
