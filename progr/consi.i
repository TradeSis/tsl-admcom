for each produ of clase, each estoq of produ where estoq.etbcod = estab.etbcod
				       and estbalqtd <> ? break by produ.clacod:
    find last himov where himov.etbcod = wetbcod and
			  himov.procod = produ.procod and
			  himdata < date(month(estbaldat),01,year(estbaldat))
			  no-error.
    {2}.
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
	then display produ.procod
		     produ.pronomc + "-" + fabfant format "x(34)"
		     prounven
		     estbaldat format "99/99/99"
		     west
		     space(3) estbalqtd
		     estbalqtd - west format ">>,>>>,>>9.99"
		     with frame fdet{1} width 96 no-box no-label.
end.
