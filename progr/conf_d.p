{admcab.i }
def var vetbcod like estab.etbcod.
def var vdt1 like plani.pladat.
def var vdt2 like plani.pladat.
def var vtotal like plani.platot.
repeat:
    update vetbcod with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.

    update vdt1 label "Periodo"
           vdt2 no-label with frame f1.

    for each plani where plani.etbcod = estab.etbcod and
                         plani.movtdc = 5 and
                         plani.pladat >= vdt1 and
                         plani.pladat <= vdt2 no-lock break by plani.pladat:
        vtotal = vtotal + plani.platot.
        if last-of(plani.pladat)
        then do:
            display plani.pladat
                    vtotal label "Total Venda" with frame f2 side-label.
            vtotal = 0.
        end.
    end.
end.
