{admcab.i}
def temp-table wpronom
    field pronom like produ.pronom
    field procod like produ.procod
    field movtdc like movim.movtdc.

def temp-table wprocod
    field procod like produ.procod
    field movtdc like movim.movtdc.


def var vt as log format "Numerica/Alfabetica".
repeat:
    display "RELATORIO DE ACERTOS" WITH FRAME F1 CENTERED ROW 10 COLOR MESSAGE.
    update vt no-label with frame f-vt centered.
    for each plani where plani.movtdc = 7 no-lock:
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod no-lock:
            find produ where produ.procod = movim.procod.
            create wpronom.
            assign wpronom.procod = movim.procod
                   wpronom.pronom = produ.pronom
                   wpronom.movtdc = movim.movtdc.
            create wprocod.
            assign wprocod.procod = movim.procod
                   wprocod.movtdc = movim.movtdc.

        end.
    end.

    for each plani where plani.movtdc = 8 no-lock:
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod no-lock:
            find produ where produ.procod = movim.procod.
            create wpronom.
            assign wpronom.procod = movim.procod
                   wpronom.pronom = produ.pronom
                   wpronom.movtdc = movim.movtdc.
            create wprocod.
            assign wprocod.procod = movim.procod
                   wprocod.movtdc = movim.movtdc.

        end.
    end.

        {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""lis_ace""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """ACERTOS DE ESTOQUE"""
            &Width     = "130"
            &Form      = "frame f-cabcab"}




if vt
then do:
    for each wprocod break by wprocod.movtdc
                           by wprocod.procod:
        if first-of(wprocod.movtdc)
        then do:
            find tipmov where tipmov.movtdc = wprocod.movtdc no-lock.
            display tipmov.movtdc
                    tipmov.movtnom with frame f-tt width 200.
        end.
        for each movim where movim.movtdc = wprocod.movtdc and
                             movim.procod = wprocod.procod no-lock.
             find produ where produ.procod = wprocod.procod no-lock.
             display movim.movdat
                     movim.procod
                     produ.pronom
                     movim.movqtm
                     (movim.movpc * movim.movqtm) label "Total"
                          with frame frame-a down width 200.
        end.
    end.
end.
else do:
    for each wpronom break by wpronom.movtdc
                           by wpronom.pronom:
        if first-of(wpronom.movtdc)
        then do:
            find tipmov where tipmov.movtdc = wpronom.movtdc no-lock.
            display tipmov.movtdc
                    tipmov.movtnom with frame f-ttt width 200.
        end.
        for each movim where movim.movtdc = wpronom.movtdc and
                             movim.procod = wpronom.procod no-lock.
             display movim.movdat
                     movim.procod
                     wpronom.pronom
                     movim.movqtm
                     (movim.movpc * movim.movqtm) label "Total"
                          with frame frame-b down width 200.
        end.
    end.
end.
OUTPUT TO CLOSE.
end.
