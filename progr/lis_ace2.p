{admcab.i}
repeat:
    display "RELATORIO DE ACERTOS" WITH FRAME F1 CENTERED ROW 10 COLOR MESSAGE.
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

    display "AJUSTE DE ENTRADA" SKIP(3).
    for each movim where movim.movtdc = 7 no-lock break by movim.etbcod
							by movim.procod:
	 if first-of(movim.etbcod)
	 then do:
	    find estab where estab.etbcod = movim.etbcod no-lock.
	    display estab.etbcod
		    estab.etbnom with frame f1 side-label width 80.
	 end.
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

    display "AJUSTE DE SAIDAS" SKIP(3).
    for each movim where movim.movtdc = 8 no-lock break by movim.etbcod
							by movim.procod:
	 if first-of(movim.etbcod)
	 then do:
	    find estab where estab.etbcod = movim.etbcod no-lock.
	    display estab.etbcod
		    estab.etbnom with frame f2 side-label width 80.
	 end.
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
    OUTPUT TO CLOSE.
end.
