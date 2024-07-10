{admcab.i}
def var vcatcod like categoria.catcod.
def var vetbcod like estab.etbcod.

repeat:
    update vetbcod with frame f-dep.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    display estab.etbnom no-label with frame f-dep.
    for each coletor where coletor.etbcod = estab.etbcod.
        delete coletor.
    end.
end.
