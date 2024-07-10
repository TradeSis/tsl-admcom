{admcab.i}
repeat:
    display "RELATORIO DE ACERTOS" WITH FRAME FF1 CENTERED ROW 10 COLOR MESSAGE.
    message "Confirma listagem de acertos" update sresp.
    if not sresp
    then leave.

    {mdadmcab.i
	&Saida     = "printer"
	&Page-Size = "64"
	&Cond-Var  = "130"
	&Page-Line = "66"
	&Nom-Rel   = ""lis_ace""
	&Nom-Sis   = """SISTEMA DE ESTOQUE"""
	&Tit-Rel   = """ACERTOS DE ESTOQUE"""
	&Width     = "130"
	&Form      = "frame f-cabcab"}

    for each estab no-lock break by estab.etbcod:
	if first-of(estab.etbcod)
	then do:
	    display estab.etbcod
		    estab.etbnom no-label with frame f1 side-label width 200.
	end.
    for each movim where movim.etbcod = estab.etbcod and
			 movim.movtdc = 7 no-lock break by movim.movtdc:
	 if first-of(movim.movtdc)
	 then display "AJUSTE DE ENTRADA" skip.
	 find first plani where plani.etbcod = movim.etbcod and
				plani.placod = movim.placod no-lock.

	 find produ where produ.procod = movim.procod.
	 display movim.movdat
		 plani.numero
		 movim.procod
		 produ.pronom
		 movim.movqtm
		 (movim.movpc * movim.movqtm) label "Total"
			  with frame frame-a down width 200.
    end.


    for each movim where movim.etbcod = estab.etbcod and
			 movim.movtdc = 8 no-lock BREAK BY MOVIM.MOVTDC:
	 if first-of(movim.movtdc)
	 then display "AJUSTE DE SAIDA" skip.
	 find first plani where plani.etbcod = movim.etbcod and
				plani.placod = movim.placod no-lock.

	 find produ where produ.procod = movim.procod.
	 display movim.movdat
		 plani.numero
		 movim.procod
		 produ.pronom
		 movim.movqtm
		 (movim.movpc * movim.movqtm) label "Total"
			  with frame frame-B down width 200.
    end.
    end.
    OUTPUT TO CLOSE.
end.
