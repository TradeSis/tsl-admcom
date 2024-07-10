{admcab.i}
def var vprocod like produ.procod.
repeat:
    update vprocod with frame f1 side-label width 80.
    find produ where produ.procod = vprocod no-error.
    display produ.pronom no-label
            produ.datexp no-label format "99/99/9999" with frame f1.

    for each estoq where estoq.procod = produ.procod:
        estoq.datexp = today.
    end.
    produ.datexp = today.
end.
