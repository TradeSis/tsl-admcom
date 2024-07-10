{admcab.i}
def var totdev  like plani.platot format ">>,>>9.99".
def var ajuacr  like plani.platot format ">>,>>9.99".
def var ajudec  like plani.platot format ">>,>>9.99".
def var trasai  like plani.platot format ">>,>>9.99".
def var traent  like plani.platot format ">>,>>9.99".
def var totsai  like plani.platot format ">>,>>9.99".
def var vdata   like plani.pladat.
def var vetbcod like estab.etbcod.
def var dt1     like plani.pladat.
def var dt2     like plani.pladat.
def var vcatcod like produ.catcod.

repeat:
    update vcatcod colon 18 with frame f1 color white/cyan width 80.
    find categoria where categoria.catcod = vcatcod no-lock.
    display categoria.catnom no-label with frame f1.
    update vetbcod colon 18 with frame f1 side-label.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update dt1 label "Periodo" colon 18
	   dt2 no-label with frame f1.
    /********************************
	if movim.movtdc = 1
	then vmovtnom = "ORCAMENTO DE ENTRADA".
	if movim.movtdc = 4
	then vmovtnom = "ENTRADA".
	if movim.movtdc = 5
	then vmovtnom = "VENDA".
	if movim.movtdc = 12
	then vmovtnom = "DEV.VENDA".
	if movim.movtdc = 13
	then vmovtnom = "DEV.FORN.".
	if movim.movtdc = 15
	then vmovtnom = "ENT.CONSERTO".
	if movim.movtdc = 16
	then vmovtnom = "REM.CONSERTO".
	if movim.movtdc = 7
	then vmovtnom = "BAL.AJUS.ACR".
	if movim.movtdc = 8
	then vmovtnom = "BAL.AJUS.DEC".
	if movim.movtdc = 6 and
	   plani.etbcod = vetbcod
	then vmovtnom = "TRANSF.SAIDA".
	if movim.movtdc = 6 and
	   plani.desti  = vetbcod
	then vmovtnom = "TRANSF.ENTRA".
	if movim.movtdc = 17
	then vmovtnom = "TROCA DE ENTRADA".
	if movim.movtdc = 18
	then vmovtnom = "TROCA DE SAIDA".

       ********************************/

    {mdadmcab.i
	    &Saida     = "printer"
	    &Page-Size = "64"
	    &Cond-Var  = "140"
	    &Page-Line = "66"
	    &Nom-Rel   = ""mov99""
	    &Nom-Sis   = """SISTEMA DE ESTOQUE"""
	    &Tit-Rel   = """MOVIMENTO DE PRODUTOS - DA FILIAL "" +
				  string(vetbcod,"">>9"") +
			  "" PERIODO DE "" +
				  string(dt1,""99/99/9999"") + "" A "" +
				  string(dt2,""99/99/9999"") "
	    &Width     = "140"
	    &Form      = "frame f-cabcab"}


    for each produ use-index catpro where produ.catcod = vcatcod no-lock:
	totsai = 0.
	traent = 0.
	trasai = 0.
	ajuacr = 0.
	ajudec = 0.
	totdev = 0.
	do vdata = dt1 to dt2:
	    for each movim where movim.procod = produ.procod and
				 movim.movdat = vdata        no-lock:

		if movim.movtdc = 6
		then do:
		    find first plani where plani.etbcod = movim.etbcod and
					   plani.placod = movim.placod and
					   plani.pladat = movim.movdat and
					   plani.movtdc = movim.movtdc
						       no-lock no-error.
		    if not avail plani
		    then next.
		    if movim.movtdc = 6 and
		       plani.etbcod = vetbcod
		    then trasai = trasai + movim.movqtm.

		    if movim.movtdc = 6 and
		       plani.desti  = vetbcod
		    then traent = traent + movim.movqtm.
		end.
		if movim.etbcod = vetbcod
		then do:
		    if movim.movtdc = 7
		    then ajuacr = ajuacr + movqtm.
		    if movim.movtdc = 17
		    then ajuacr = ajuacr + movqtm.
		    if movim.movtdc = 8
		    then ajudec = ajudec + movqtm.
		    if movim.movtdc = 18
		    then ajudec = ajudec + movqtm.
		    if movim.movtdc = 5
		    then totsai = totsai + movqtm.
		    if movim.movtdc = 12
		    then totdev = totdev + movqtm.
		end.
	    end.
	end.
	if totsai = 0 and
	   traent = 0 and
	   trasai = 0 and
	   ajuacr = 0 and
	   ajudec = 0 and
	   totdev = 0
	then next.
	find estoq where estoq.etbcod = estab.etbcod and
			 estoq.procod = produ.procod no-lock no-error.
	display produ.procod
		produ.pronom format "x(35)"
		totsai(total) column-label "Saida"
		totdev(total) column-label "Devol"
		trasai(total) column-label "Tran.Sai"
		traent(total) column-label "Tran.Ent"
		ajuacr(total) column-label "Ajus.Acr"
		ajudec(total) column-label "Ajus.Dec"
		(traent + ajuacr - totsai - ajudec - trasai)(total)
		       column-label "Saldo"
			with frame f2 down width 200.
    end.
    output close.
end.
