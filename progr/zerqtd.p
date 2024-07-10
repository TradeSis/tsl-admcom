{admcab.i}
def var vcatcod like categoria.catcod.
def var vetbcod like estab.etbcod.

repeat:
    update vetbcod with frame f-dep side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    display estab.etbnom no-label with frame f-dep.
    update vcatcod label "Departamento"
                with frame f-dep.
    
    for each coletor where coletor.etbcod = estab.etbcod.
    
        find produ where produ.procod = coletor.procod no-lock no-error.
        if avail produ and produ.catcod = vcatcod
        then delete coletor.
    end.
end.
