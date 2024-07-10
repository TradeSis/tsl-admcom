{admcab.i}
def var vmodcod like titulo.modcod.
def var vdtin like titulo.titdtemi.
def var vdtfi like titulo.titdtemi.
repeat:
    update vmodcod with frame f1 side-label width 80.
    find modal where modal.modcod = vmodcod no-lock no-error.
    if not avail modal
    then do:
        message "Modalidade nao cadastrato".
        undo, retry.
    end.
    disp modal.modnom no-label with frame f1 width 80.
    update vdtin label "Periodo"
           vdtfi label "A" with frame f1.
    for each titulo where titulo.empcod = wempre.empcod and
                          titulo.titnat = yes and
                          titulo.modcod = vmodcod and
                          titulo.titdtven >= vdtin and
                          titulo.titdtven <= vdtfi no-lock
                                break by titulo.titdtven:
        find forne where forne.forcod = titulo.clifor no-lock.

        display
                forne.fornom format "x(14)"
                titulo.titnum format "x(8)"
                titulo.titpar
                titulo.titdtemi
                titulo.titdtven
                titulo.titvlcob(total by titdtven) column-label "Vl.Cobrado"
                        format ">>,>>>,>>9.99"
                titulo.titsit
                titulo.etbcod column-label "Est"
                        with frame f2 down color white~\red width 80.
    end.
    pause.
end.
