
for each movim where movim.datexp >= today - 3 no-lock 
                                               break by movim.procod.

    disp procod with 1 down. pause 0.
    
    if first-of(movim.procod)
    then do:
        find estpro where estpro.procod = movim.procod no-error.
        if not avail estpro
        then do transaction:
            create estpro.
            assign estpro.procod = movim.procod.
        end.
        for each estoq where estoq.procod = movim.procod no-lock.
            do transaction:
                assign estpro.estatual[estoq.etbcod] = estoq.estatual
                       estpro.estcusto[estoq.etbcod] = estoq.estcusto
                       estpro.estvenda[estoq.etbcod] = estoq.estvenda.
            end.
        end.           
    end.
end.