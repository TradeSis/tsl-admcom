{admcab.i}
def var vetbcod like estab.etbcod.
def var vcatcod like categoria.catcod.
repeat on error undo, leave:
    update vetbcod colon 20 with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update vcatcod colon 20 with frame f1.
    find categoria where categoria.catcod = vcatcod no-lock.
    display categoria.catnom no-label with frame f1.
    message "Confirma emissao de Etiquetas" update sresp.
    if sresp
    then do:
	for each produ use-index catpro where produ.catcod = vcatcod no-lock.
	    find estoq where estoq.etbcod = estab.etbcod and
			     estoq.procod = produ.procod no-lock no-error.
	    if not avail estoq or estoq.estatual <= 0
	    then next.
	    display produ.procod
		    produ.pronom
		    estoq.estatual with 1 down. pause 0.
	    run eti_barl.p (input recid(produ),
			    input estoq.estatual).
	end.
    end.
end.
