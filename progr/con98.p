{admcab.i}
def var varquivo as char format "x(20)".
def var vdt as date.
def var vperc    like estoq.estvenda.
def var totcusto like estoq.estcusto.
def var totvenda like estoq.estcusto.
def buffer bestoq for estoq.
def var v-ac like plani.platot.
def var v-de like plani.platot.
def buffer bcurpro for curpro.
def buffer bmovim for movim.
def var i as i.
def var tot-c like plani.platot.
def var tot-v like plani.platot format "->>9.99".
def var tot-m like plani.platot.
def var vacum like plani.platot format "->>9.99".
def var wnp as i.
def var vvltotal as dec.
def var vvlcont  as dec.
def var wacr     as dec.
def var wper     as dec.
def var valortot as dec.
def var vval     as dec.
def var vval1    as dec.
def var vsal     as dec.
def var vlfinan  as dec.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vvlcusto    like plani.platot column-label "Vl.Custo".
def var vvlvenda    like plani.platot column-label "Vl.Venda".
def var vvlmarg     like plani.platot column-label "Margem".
def var vvlperc     as dec format ">>9.99 %" column-label "Perc".
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def var vacrepre    like plani.acfprod column-label "Acr.Previsto".
def var vcatcod     like produ.catcod.
def var vcatcod2    like produ.catcod.
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.

repeat:
    update vcatcod label "Departamento"
		with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.
    if vcatcod = 31
    then vcatcod2 = 35.
    if vcatcod = 41
    then vcatcod2 = 45.

    update vdti no-label
	   "a"
	   vdtf no-label with frame f-dat centered color blue/cyan row 8
				    title " Periodo ".

    update vetbi no-label
	   "a"
	   vetbf no-label with frame f-etb
	   centered color blue/cyan row 12 title " Filial ".

    update vperc label "Perc" format ">>9.99%" with frame f-perc
	   centered color blue/cyan row 16 side-label.
    for each curpro:
	delete curpro.
    end.
    totcusto = 0.
    totvenda = 0.

    for each produ where produ.catcod = vcatcod
			 no-lock:
	/*
	for each estab no-lock:
	    find bestoq where bestoq.etbcod = estab.etbcod and
			      bestoq.procod = produ.procod no-lock no-error.
	    if avail bestoq
	    then assign totcusto = totcusto +
			(bestoq.estcusto * bestoq.estatual)
			totvenda = totvenda +
			(bestoq.estvenda * bestoq.estatual).
	end.
	*/
	find first bmovim where bmovim.procod = produ.procod and
				bmovim.movtdc = 5 and
				bmovim.movdat >= vdti and
				bmovim.movdat <= vdtf no-lock no-error.
	if not avail bmovim
	then next.

	output stream stela to terminal.
	disp stream stela produ.procod produ.fabcod
		    with frame ffff centered
				       color white/red 1 down.
	pause 0.
	output stream stela close.

	find first curpro where curpro.cod = produ.fabcod no-error.
	if not avail curpro
	then do:
	    create curpro.
	    find last bcurpro no-error.
	    if not avail bcurpro
	    then curpro.pos = 1000000.
	    else curpro.pos = bcurpro.pos + 1.
	    curpro.cod = produ.procod.
	end.
	for each estab where estab.etbcod >= vetbi and
			     estab.etbcod <= vetbf no-lock:
	    do vdt = vdti to vdtf:

	    for each movim where movim.etbcod = estab.etbcod and
				 movim.movtdc = 5 and
				 movim.procod = produ.procod and
				 movim.movdat = vdt
				 no-lock:
		find first plani where plani.etbcod = movim.etbcod and
				       plani.placod = movim.placod
					    no-lock no-error.
		if avail plani and plani.crecod = 2
		then do:
		for each contnf where contnf.etbcod = plani.etbcod and
				      contnf.placod = plani.placod no-lock.
		    find contrato where contrato.contnum = contnf.contnum
				no-lock no-error.
		    if avail contrato
		    then do:
			if contrato.vltotal > plani.platot
			then v-ac = contrato.vltotal / plani.platot.
			if contrato.vltotal < plani.platot
			then v-de = plani.platot / contrato.vltotal.
		    end.
		end.
		end.

		find estoq where estoq.etbcod = movim.etbcod and
				 estoq.procod = produ.procod no-lock no-error.
		if not avail estoq
		then next.

		curpro.qtdven = curpro.qtdven + movim.movqtm.
		if v-ac = 0 and v-de = 0
		then curpro.valven = curpro.valven +
			(movim.movqtm * movim.movpc).
		if v-ac > 0
		then curpro.valven = curpro.valven +
				    ((movim.movqtm * movim.movpc) * v-ac).
		if v-de > 0
		then curpro.valven = curpro.valven +
				    ((movim.movqtm * movim.movpc) / v-de).
		curpro.valcus = curpro.valcus + (movim.movqtm * estoq.estcusto).
		v-ac = 0.
		v-de = 0.
	    end.
	    end.
	end.
	for each estab where estab.etbcod >= vetbi and
			     estab.etbcod <= vetbf no-lock:
	    for each estoq where estoq.procod  = produ.procod and
				 estoq.etbcod  = estab.etbcod no-lock:
	    curpro.qtdest = curpro.qtdest + estoq.estatual.
	    curpro.estcus = curpro.estcus + (estoq.estatual * estoq.estcusto).
	    curpro.estven = curpro.estven + (estoq.estatual * estoq.estvenda).
	    end.
	end.
    end.


    for each produ where produ.catcod = vcatcod2
			 no-lock:
	/*
	for each estab no-lock:
	    find bestoq where bestoq.etbcod = estab.etbcod and
			      bestoq.procod = produ.procod no-lock no-error.
	    if avail bestoq
	    then assign totcusto = totcusto +
			(bestoq.estcusto * bestoq.estatual)
			totvenda = totvenda +
			(bestoq.estvenda * bestoq.estatual).
	end.
	*/
	find first bmovim where bmovim.procod = produ.procod and
				bmovim.movtdc = 5 and
				bmovim.movdat >= vdti and
				bmovim.movdat <= vdtf no-lock no-error.
	if not avail bmovim
	then next.

	output stream stela to terminal.
	disp stream stela produ.procod produ.fabcod
		    with frame ffff2 centered
				       color white/red 1 down.
	pause 0.
	output stream stela close.

	find first curpro where curpro.cod = produ.fabcod no-error.
	if not avail curpro
	then do:
	    create curpro.
	    find last bcurpro no-error.
	    if not avail bcurpro
	    then curpro.pos = 1000000.
	    else curpro.pos = bcurpro.pos + 1.
	    curpro.cod = produ.procod.
	end.
	for each estab where estab.etbcod >= vetbi and
			     estab.etbcod <= vetbf no-lock:
	    do vdt = vdti to vdtf:

	    for each movim where movim.etbcod = estab.etbcod and
				 movim.movtdc = 5 and
				 movim.procod = produ.procod and
				 movim.movdat = vdt
				 no-lock:
		find first plani where plani.etbcod = movim.etbcod and
				       plani.placod = movim.placod
					    no-lock no-error.
		if avail plani and plani.crecod = 2
		then do:
		for each contnf where contnf.etbcod = plani.etbcod and
				      contnf.placod = plani.placod no-lock.
		    find contrato where contrato.contnum = contnf.contnum
				no-lock no-error.
		    if avail contrato
		    then do:
			if contrato.vltotal > plani.platot
			then v-ac = contrato.vltotal / plani.platot.
			if contrato.vltotal < plani.platot
			then v-de = plani.platot / contrato.vltotal.
		    end.
		end.
		end.

		find estoq where estoq.etbcod = movim.etbcod and
				 estoq.procod = produ.procod no-lock no-error.
		if not avail estoq
		then next.

		curpro.qtdven = curpro.qtdven + movim.movqtm.
		if v-ac = 0 and v-de = 0
		then curpro.valven = curpro.valven +
			    (movim.movqtm * movim.movpc).
		if v-ac > 0
		then curpro.valven = curpro.valven +
				    ((movim.movqtm * movim.movpc) * v-ac).
		if v-de > 0
		then curpro.valven = curpro.valven +
				    ((movim.movqtm * movim.movpc) / v-de).
		curpro.valcus = curpro.valcus + (movim.movqtm * estoq.estcusto).
		v-ac = 0.
		v-de = 0.
	    end.
	    end.
	end.
	for each estab where estab.etbcod >= vetbi and
			     estab.etbcod <= vetbf no-lock:
	    for each estoq where estoq.procod  = produ.procod and
				 estoq.etbcod  = estab.etbcod no-lock:
	    curpro.qtdest = curpro.qtdest + estoq.estatual.
	    curpro.estcus = curpro.estcus + (estoq.estatual * estoq.estcusto).
	    curpro.estven = curpro.estven + (estoq.estatual * estoq.estvenda).
	    end.
	end.
    end.

    i = 1.
    tot-v = 0.
    tot-c = 0.
    for each curpro by curpro.valven descending:
	curpro.pos = i.
	tot-v = tot-v + curpro.valven.
	tot-c = tot-c + (curpro.valven - curpro.valcus).
	i = i + 1.
    end.

    disp categoria.catcod label "Depart."
	 catnom no-label
		with frame f-dep2 side-label row 4 color white/red no-box.
    vacum = 0.
    for each curpro by curpro.pos:
	vacum = vacum + ((curpro.valven / tot-v) * 100).
	if vacum >= vperc
	then leave.
	find produ where produ.procod = curpro.cod no-lock no-error.
	curpro.giro = (curpro.estven / curpro.valven).
	disp curpro.pos format "999" column-label "Pos"
	     curpro.cod format ">>>>>9" column-label "Codigo"
	     produ.pronom when avail produ format "x(20)" column-label "Nome"
	     curpro.qtdven(total) format ">>>,>>9"    column-label "Qtd.Ven"
	     curpro.valcus(total) format ">>>,>>9" column-label "Val.Cus"
	     curpro.valven(total) format ">>>,>>9" column-label "Val.Ven"
	     curpro.qtdest(total) format ">>>,>>9"    column-label "Qtd.Est"
	     curpro.giro when curpro.giro > 0
				 format ">>9.9" column-label "Giro"
		     with frame f-imp width 80 down row 4.
       down with frame f-imp.
    end.
end.
