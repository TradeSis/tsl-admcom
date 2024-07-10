pause 0 before-hide.
for each produ of clase, each estoq of produ where estoq.etbcod = estab.etbcod
				       and estbalqtd <> ?:

    display produ.procod.

    find last himov where himov.etbcod = wetbcod and
			  himov.procod = produ.procod and
			  himdata < date(month(estbaldat),01,year(estbaldat))
			  no-error.
    if not available himov
	then west = 0.
	else west = himestfim.


    for each movim where (movim.etbcod = estoq.etbcod or
			 movim.etbdes = estoq.etbcod) and
			 movim.procod = estoq.procod and
			 movdat >= date(month(estbaldat),01,year(estbaldat)) and
			 movdat < estbaldat by movdat by movseq:
	if ((movtdc = 1 or movtdc = 9) and movim.etbcod = wetbcod) or
	   movtdc = 3 and movim.etbdes = wetbcod
	    then west = west + movqtm.
	if ((movtdc = 2 or movtdc = 0) and movim.etbcod = wetbcod) or
	   movtdc = 3 and movim.etbcod = wetbcod
	    then west = west - movqtm.
    end.

    if west <> estbalqtd
	then do:


	find last movim where movtdc = (if west < estbalqtd then 9 else 0) and
			      movim.etbcod = estoq.etbcod and
			      movim.procod = estoq.procod no-error.
	if available movim
	    then wmovndc = movndc + 1.
	    else wmovndc = 1.


	find last movim where movim.procod = produ.procod  and
			      movim.etbcod = estoq.etbcod  and
			      movim.movdat = estbaldat - 1 and
			      movim.movseq > 0 no-error.
	if available movim
	   then wmovseq = movim.movseq + 1.
	   else wmovseq = 1.
	create movim.
	assign movim.procod = estoq.procod
	       movim.movtdc = if west < estbalqtd then 9 else 0
	       movim.movndc = wmovndc
	       movim.movdat = estbaldat - 1
	       movim.movqtm = if west < estbalqtd then estbalqtd - west
						  else west - estbalqtd
	       movim.etbcod = wetbcod
	       movim.etbdes = wetbcod
	       estbalqtd    = ?
	       wrecid       = recid(movim)
	       movim.movseq = wmovseq.


	run es/estcro.p ("I").
	if not westcro
	    then do:
	    message "Impossivel ajustar estoque do Produto:" movim.procod.
	    message "Movimentacoes posteriores ficam descobertas.".
	    undo, next.
	    end.


	run es/estoca.p (yes).


	run es/himov.p (yes).
	end.
	assign estbalqtd = ?.
end.
pause before-hide.
