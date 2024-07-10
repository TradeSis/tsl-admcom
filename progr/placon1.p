{admcab.i}
def var vetbcod like estab.etbcod.
repeat:

    update vetbcod label "Filial" with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido".
        undo, retry.
    end.
    display estab.etbnom no-label with frame f1.

    for each placon where placon.etbcod = estab.etbcod no-lock.

        display placon.numero column-label "Numero"
                placon.serie  column-label "Serie"
                placon.desti  column-label "Desti"
                placon.pladat column-label "Data"
                placon.platot column-label "Total Nota"
                placon.seguro column-label "Total Inf."
                        with frame f2 down centered.
    end.                    
end.
                    
