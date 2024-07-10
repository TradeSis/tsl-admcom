def input parameter vrecid  as recid.

find pedid where recid(pedid) = vrecid.

for each liped of pedid where liped.lipsit = "C" ,
    produ where produ.procod = liped.procod no-lock
			       break by itecod :
    find estoq of produ where estoq.etbcod = pedid.etbcod.
    v-i = v-i + 1.
    v-a = v-a + 1.
    if wmovimp = yes
    then do:
	V-OUTRANOTA = NO.
	if v-outranota
	then do:
	    find last nota where nota.movtdc = 2 and
			     nota.etbcod = estab.etbcod
			     use-index nota exclusive-lock no-error.
	    if available nota
	    then assign wnotnum = nota.notnum + 1
			wnotser = nota.notser.
	    else wnotnum = 1.
	end.
	IF V-INICIO
	THEN DO:
	    find last plani where plani.movtdc = 2 and
				  plani.etbcod = estab.etbcod
				  exclusive-lock no-error.
	    if available plani
	    then wmovndc = plani.movndc + 1.
	    else wmovndc = 1.
	    create nota.
	    assign notnum   = wnotnum
		   notser   = wnotser
		   notdat   = wnotdat
		   tofcod   = wnatoper
		   notviatr = wviatran.
	    create plani.
	    assign nota.etbcod  = estab.etbcod
		   nota.movtdc  = 2
		   nota.movndc  = wmovndc
		   nota.clicod  = pedid.clicod
		   plani.movtdc = 2
		   plani.movndc = wmovndc
		   plani.etbcod = nota.etbcod
		   plani.vencod = pedid.vencod
		   plani.crecod = pedid.crecod
		   plani.platot = wtotped
		   V-INICIO = NO.
	END.
	if nota.movtdc = 2
	then
	    if nota.clicod <> 0
	    then do:
		find clien of nota no-lock.
		find tofis of nota.
		find crepl of plani.
		put skip(1)
		    caps(estab.etbnom)  at 01 format "x(25)"

		    "Numero da Nota: "   at 71 nota.notnum

		    "CGC : " at 01  estab.etbcgc  "   "
		    "Ins.Est.: " estab.etbinsc

		    "Serie         : "   at 71 caps(nota.notser)
		    "End.: " at 01 estab.endereco

		    "Data Emissao  : "   at 71 nota.notdat


		    "Nat.Operacao  : "   at 71 nota.tofcod
					       "  "  tofis.tofnom skip

		    "Via Transporte: "   at 71 nota.notviatr

		    "Numero Pedido : " at 01  proen.pednum "       "
		    "Plano Credito : " crepl.crenom skip

		    "Representante: " at 01
				trim(string(plani.vencod) + " - " +
					    vennom) format "x(40)" skip(1)
		    "Cliente : "  at 01 clien.clinom  " (" clien.clicod ")" skip
		    "Endereco: "  at 01 trim(clien.endereco[1] + ", " +
					    string(clien.numero  [1]) + " - " +
					    clien.compl[1]) format "x(40)" skip
		    "Cidade  : " at 01 trim(clien.cidade[1] + " / " +
					   clien.uf[1]) format "x(40)"
		    "CEP : " clien.cep[1]  skip
		    "CGC     : " at 01 clien.ciccgc
		    "Insc.Estadual : " at 41 clien.ciinsc skip(1)

		    "Qtd"               at 03
		    "Cod. Item"         at 10
		    "Item"              at 30   format "x(35)"
		    "Pco. Unitario"     at 71
		    "   Valor Total"    at 92
		    "----"              at 02
		    "--------"          at 10
		    fill("-",35)        format "x(35)" at 30
		    "--------------"    at 70
		    "--------------"    at 92.
	    end.
	end.
	else do:
	    find nota where
		   nota.etbcod  = estab.etbcod   and
		   nota.movtdc  = 2  and
		   nota.movndc  = wmovndc        and
		   nota.notnum  = wnotnum        and
		   nota.notser  = wnotser no-lock.
	    find plani where
		   plani.movtdc = 2  and
		   plani.movndc = wmovndc        and
		   plani.etbcod = nota.etbcod    and
		   plani.vencod = vende.vencod   and
		   plani.crecod = pedid.crecod no-lock.
	end.
	/********* x4 *******/
	find last movim where movim.procod = proen.procod and
			      movim.etbcod = plani.etbcod and
			      movim.movdat = plani.pladat and
			      movim.movseq > 0 exclusive-lock no-error.
	if available movim
	then
	    wmovseq = movim.movseq + 1.
	else
	    wmovseq = 1.
	create movim.
	assign movim.movqtm = proen.preqtped
	       movim.movpc  = estoq.estvenda
	       movim.procod = proen.procod
	       movim.movtdc = 2
	       movim.movndc = plani.movndc
	       movim.movdat = plani.pladat
	       movim.movseq = wmovseq
	       movim.etbcod = plani.etbcod.
	wrecid = recid(movim).
	run es\estcro.p ("I").
	if not westcro
	then do:
	    find produ where produ.procod = proen.procod
		no-lock no-error.
	    display
		"      PRODUTO (" produ.procod ")"
		produ.pronom format "x(40)" skip(1)
		"            NAO POSSUI ESTOQUE SUFICIENTE"
		skip(1)
		"                A NOTA SERA DISFEITA"
		with frame falerta
		width 75 centered overlay row 10.
	    output close.
	    undo l-ini, retry l-ini .
	end.
	run es\himov.p  (yes).
	run es\estoca.p (yes).
	wtotal = wtotal + (movqtm * movpc).

	vqtdtot = vqtdtot + movim.movqtm .
	if last-of(PRODU.itecod)
	then do:
	    find item where item.itecod = produ.itecod .
	    put vqtdtot         at 02   format ">>>9"
		item.itecod     at 10
		item.itenom     at 30   format "x(35)"
		movim.movpc at 70
		vqtdtot * movpc format ">>>,>>>,>>9.99" at 92.
	    wtotger = wtotger + (vqtdtot * movpc) .
	    vqtdtot = 0.
	end.


	assign wmovimp = no.
	if v-a = 18 and
	   v-c > 18
	then do:
	    put skip (33 - v-i).
	    wicms = wtotal * (wpcticm / 100) .
	    find plani of movim .
	    wtotped = 0.
	    for each liped of pedid,
		each wproen of liped where wproen.lipsit = "A".
		wtotped = wtotped + lippreco * lipqtd.
	    end.


	    assign plani.platot = wtotal.

	    find crepl of plani no-lock.
	    for each propg of pedid.
		delete propg.
	    end.
	    for each titulo where titulo.empcod = wempre.empcod and
			  titulo.modcod = "PED" and
			  titulo.titnat = no and
			  titulo.clicod = pedid.clicod and
			  titulo.titnum = string(pedid.pednum):
		delete titulo.
	    end.
	    find first wproen of pedid.
	    wpredt = nota.notdat  .
	    find crepl of plani no-lock.
	    do v-i = 1 to 10:
		if crepl.credias[v-i] = ? or
		   crepl.credias[v-i] = 0
		then leave.
		else do:
		    create propg.
		    assign propg.pednum = pedid.pednum
			prpdata = wpredt + crepl.credias[v-i]
			prpvalor = ((wtotped * crepl.creperc[v-i]) / 100).
		end.
	    end.
	v-i = 0.
	for each propg where propg.pednum = pedid.pednum by prpdata:
	    v-i = v-i + 1.
	    create titulo.
	    assign titulo.empcod = 19
		   titulo.modcod = "PED"
		   titulo.clicod = pedid.clicod
		   titulo.titnum = string(pedid.pednum)
		   titulo.titpar = v-i
		   titulo.titnat = no
		   titulo.etbcod = proen.etbcod
		   titulo.titdtemi = pedid.peddat
		   titulo.titdtven = propg.prpdata
		   titulo.titvlcob = propg.prpvalor
		   titulo.cobcod = 2.
	end.
	for each wpropg.
	    delete wpropg.
	end.
	do v-i = 1 to 10:
	    if crepl.credias[v-i] = ? or
	       crepl.credias[v-i] = 0
	    then leave.
	    else do:
		create wpropg.
		assign wpropg.prpdata = wpredt + crepl.credias[v-i]
		       wpropg.prpvalor = ((wtotal * crepl.creperc[v-i]) / 100).
	    end.
	end.
	v-i = 0.
	for each wpropg by wpropg.prpdata:
	    v-i = v-i + 1.
	    find pedid where pedid.pednum = wpropg.pednum.
	    create titulo.
	    assign titulo.empcod = 19
		   titulo.modcod = "DUP"
		   titulo.clicod = pedid.clicod
		   titulo.titnum = string(nota.notnum)
		   titulo.titpar = v-i
		   titulo.titnat = no
		   titulo.etbcod = proen.etbcod
		   titulo.titdtemi = plani.pladat
		   titulo.titdtven = wpropg.prpdata
		   titulo.titvlcob = wpropg.prpvalor
		   titulo.cobcod = 2.
	end.
	find vende of plani no-lock.
	if plani.crecod = 01
	then do:
	    put     skip
		    "Transportadora : " at 01 forne.forfant
		    "End.Entrega    : " at 01 trim(clien.entendereco[1] + ", " +
					    string(clien.entnumero[1])  + "  " +
						   CLIEN.ENTCOMPL[1])
						   format "x(30)" skip
				   trim(clien.entbairro[1] + "   " +
					clien.entcidade[1] + "   " +
					clien.entufecod[1]) format "x(50)" at 17
				   "CEP : " at 16 clien.entcep[1]    .
	end.
	else do:
	    put     skip
		    "Transportadora : " at 01 forne.forfant
		    "End.Entrega    : " at 01 trim(clien.entendereco[1] + ", " +
					  string(clien.entnumero[1])  + "  " +
						CLIEN.ENTCOMPL[1])
						    format "x(30)" skip
				   trim(clien.entbairro[1] + "   " +
					clien.entcidade[1] + "   " +
					clien.entufecod[1]) format "x(50)" at 17
				   "CEP : " at 16 clien.entcep[1]    .
	end.
	put skip(4).
	wmovimp = yes.
	v-outranota = NO.
	wtotal = 0.
	v-i = 19.
	v-a = 0.
    end.
    Proen.lipsit = "E".
end.
