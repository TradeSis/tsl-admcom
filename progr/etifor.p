{admcab.i}
def var vetbcod like estab.etbcod.
def var vforcod like forne.forcod.
repeat on error undo, leave:
    update vetbcod colon 16
		with frame f1 side-label width 80 row 4.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    display estab.etbnom no-label with frame f1.
    update vforcod colon 16
		with frame f1 side-label width 80 row 4.
    find forne where forne.forcod = vforcod no-lock no-error.
    display forne.fornom no-label with frame f1.
    message "Confirma emissao de etiqueta ?" update sresp.
    if not sresp
    then next.
    for each produ where produ.fabcod = vforcod no-lock:
	find estoq where estoq.etbcod = estab.etbcod and
			 estoq.procod = produ.procod no-lock no-error.
	if not avail estoq
	then next.
	if estoq.estatual <= 0
	then next.
	run eti_barl.p (input recid(produ),
			input estoq.estatual).
    end.
end.
