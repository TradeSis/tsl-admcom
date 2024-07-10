{admcab.i}
def var vano as i.
def var vmes as i.
def var varquivo as char format "x(20)".
def var vcusto   like estoq.estcusto.
def var vestven  like estoq.estvenda.
def var totcusto like estoq.estcusto.
def var totvenda like estoq.estvenda.
def buffer bestoq for estoq.
def var v-ac like plani.platot.
def var v-de like plani.platot.
def buffer bcurfab for curfab.
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
	   vetbf no-label with frame f-etb centered color blue/cyan row 12
				    title " Filial ".
    totcusto = 0.
    totvenda = 0.
    for each impor where impor.desti = vcatcod      and
			 impor.data  = vdtf:
	delete impor.
    end.
    for each ctti where ctti.controle  = vcatcod       and
			ctti.funcao    = string(month(vdtf)) +
					 string(year(vdtf)):
	delete ctti.
    end.

    for each produ where produ.catcod = vcatcod or
			 produ.catcod = vcatcod2
			 no-lock:
	output stream stela to terminal.
	disp stream stela produ.procod produ.fabcod
		    with frame ffff centered
				       color white/red 1 down.
	pause 0.
	output stream stela close.
	find first bmovim where bmovim.procod = produ.procod and
				bmovim.movtdc = 5            and
				bmovim.movdat >= vdti        and
				bmovim.movdat <= vdtf no-lock no-error.
	if not avail bmovim
	then next.
	find first impor where impor.emite = produ.procod and
			       impor.desti = vcatcod      and
			       impor.data  = vdtf   no-error.
	if not avail impor
	then do:
	    create impor.
	    assign impor.emite = produ.procod
		   impor.desti = vcatcod
		   impor.data  = vdtf.
	end.



	for each movim where movim.procod = produ.procod and
			     movim.movtdc = 5 and
			     movim.movdat >= vdti and
			     movim.movdat <= vdtf no-lock:

	    find first ctti where ctti.etbcod    = movim.etbcod and
				  ctti.procod    = movim.procod and
				  ctti.controle  = vcatcod       and
				  ctti.funcao    = string(month(vdtf)) +
					       string(year(vdtf)) no-error.
	    if not avail ctti
	    then do:
		create ctti.
		assign ctti.etbcod = movim.etbcod
		       ctti.procod = movim.procod
		       ctti.controle  = vcatcod
		       ctti.funcao    = string(month(vdtf)) +
					string(year(vdtf)).
	    end.
	    v-de = 0.
	    v-ac = 0.
	    if movim.etbcod >= vetbi and
	       movim.etbcod <= vetbf
	    then do:
		find first plani where plani.etbcod = movim.etbcod and
				       plani.placod = movim.placod and
				       plani.movtdc = movim.movtdc and
				       plani.pladat = movim.movdat
					    no-lock no-error.
		if avail plani and plani.crecod = 2
		then do:
		for each contnf where contnf.etbcod = plani.etbcod and
				      contnf.placod = plani.placod no-lock.
		    find contrato where contrato.contnum = contnf.contnum
				no-lock no-error.
		    if avail contrato
		    then do:
			if contrato.vltotal > (plani.platot - plani.vlserv)
			then v-ac = contrato.vltotal /
					      (plani.platot - plani.vlserv).
			if contrato.vltotal < (plani.platot - plani.vlserv)
			then v-de = (plani.platot - plani.vlserv)
					      / contrato.vltotal.
		    end.
		end.

		if plani.platot < 1
		then assign v-de = 0
			    v-ac = 0.
		end.


		find estoq where estoq.etbcod = movim.etbcod and
				 estoq.procod = produ.procod no-lock no-error.
		if not avail estoq
		then next.


		if v-ac = 0 and v-de = 0
		then assign
			ctti.preco = ctti.preco +
				    (movim.movqtm * movim.movpc)
			impor.numnot = impor.numnot +
				    (movim.movqtm * movim.movpc).
		if v-ac > 0
		then assign ctti.preco = ctti.preco +
				    ((movim.movqtm * movim.movpc) * v-ac)
			    impor.numnot = impor.numnot +
				    ((movim.movqtm * movim.movpc) * v-ac).
		if v-de > 0
		then assign ctti.preco = ctti.preco +
				    ((movim.movqtm * movim.movpc) / v-de)
			    impor.numnot = impor.numnot +
				    ((movim.movqtm * movim.movpc) / v-de).
		ctti.quantid = ctti.quantid + movim.movqtm.
		impor.numcli = impor.numcli + movim.movqtm.
		v-ac = 0.
		v-de = 0.
	    end.
	end.
    end.
end.
