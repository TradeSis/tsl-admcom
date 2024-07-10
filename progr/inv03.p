{admcab.i}
def var vcatcod like categoria.catcod.
def var vetbcod like estab.etbcod.
def var vdata   like plani.pladat.

repeat:

    update vetbcod colon 20 with frame f-dep side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    display estab.etbnom no-label with frame f-dep.
    vcatcod = 41.
    display vcatcod label "Departamento" colon 20 with frame f-dep.
    update vdata   label "Data Confronto" colon 20 with frame f-dep.
                
    
    for each coletor where coletor.etbcod = estab.etbcod and
                           coletor.coldat = vdata        and
                           coletor.catcod = vcatcod.
    
        delete coletor.

    end.
    
end.
