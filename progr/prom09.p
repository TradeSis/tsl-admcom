{admcab.i}
def var vperc as dec format ">9.99 %".
def var vforcod like produ.fabcod.
DEF BUFFER BESTOQ FOR ESTOQ.
def var vdata like estoq.estprodat.
def var vpreco like estoq.estproper format ">,>>9.99" label "Promocao".
def var vprocod like produ.procod.
def var x as dec.
def var vcatcod like categoria.catcod.
repeat:
    update vcatcod colon 11 with frame f1 .
    find categoria where categoria.catcod = vcatcod no-lock no-error.
    if not avail categoria
    then do:
	message "Departamento nao Cadastrada".
	undo, retry.
    end.
    disp categoria.catnom no-label with frame f1.


    UPDATE vforcod colon 11 with frame f1 side-label width 80.
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne
    then do:
	message "Fornecedor nao Cadastrada".
	undo, retry.
    end.
    disp forne.fornom no-label with frame f1.
    update vperc label "Perc." colon 11 with frame f1.


    message "Confirma Acrescimo" update sresp.
    for each produ where produ.catcod = categoria.catcod and
			 produ.fabcod = forne.forcod no-lock:
	display produ.procod
		produ.fabcod
		    with 1 down. pause 0.
	for each estoq where estoq.procod = produ.procod.
		estoq.datexp = today.

		estoq.estvenda = estoq.estvenda +
				 (estoq.estvenda * (vperc / 100)).
		estoq.estvenda = int(estoq.estvenda).

	end.
    end.
end.
