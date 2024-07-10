{admcab.i}
def buffer bcurva for curva.
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
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.

repeat:
    update vcatcod label "Departamento"
		with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.

    update vdti no-label
	   "a"
	   vdtf no-label with frame f-dat centered color blue/cyan row 8
				    title " Periodo ".

    update vetbi no-label
	   "a"
	   vetbf no-label with frame f-etb centered color blue/cyan row 12
				    title " Filial ".
    for each curva:
	delete curva.
    end.
    for each produ where produ.catcod = categoria.catcod
			 no-lock:

	find first bmovim where bmovim.procod = produ.procod and
				bmovim.movtdc = 5 and
				bmovim.movdat >= vdti and
				bmovim.movdat <= vdtf no-lock no-error.
	if not avail bmovim
	then next.

	output stream stela to terminal.
	disp stream stela produ.procod with frame ffff centered
				       color white/red 1 down.
	pause 0.
	output stream stela close.

	find first curva where curva.cod = produ.procod no-error.
	if not avail curva
	then do:
	    create curva.
	    find last bcurva no-error.
	    if not avail bcurva
	    then curva.pos = 1000000.
	    else curva.pos = bcurva.pos + 1.
	    curva.cod = produ.procod.
	end.

	for each movim where movim.procod = produ.procod and
			     movim.movtdc = 5 and
			     movim.movdat >= vdti and
			     movim.movdat <= vdtf no-lock:
	    if movim.etbcod >= vetbi and
	       movim.etbcod <= vetbf
	    then do:

		find estoq where estoq.etbcod = estab.etbcod and
				 estoq.procod = produ.procod no-lock no-error.
		if not avail estoq
		then next.

		curva.qtdven = curva.qtdven + movim.movqtm.
		curva.valven = curva.valven + (movim.movqtm * movim.movpc).
		curva.valcus = curva.valcus + (movim.movqtm * estoq.estcusto).
	    end.
	end.
	for each estoq where estoq.procod  = produ.procod and
			     estoq.etbcod >= vetbi        and
			     estoq.etbcod <= vetbf no-lock:

	    curva.qtdest = curva.qtdest + estoq.estatual.
	    curva.estcus = curva.estcus + (estoq.estatual * estoq.estcusto).
	    curva.estven = curva.estven + (estoq.estatual * estoq.estvenda).
	end.
    end.

    i = 1.
    tot-v = 0.
    tot-c = 0.
    for each curva by curva.valven descending:
	curva.pos = i.
	tot-v = tot-v + curva.valven.
	tot-c = tot-c + (curva.valven - curva.valcus).
	i = i + 1.
    end.

    disp " Prepare a Impressora para Imprimir Relatorio " with frame
				f-pre centered row 16.
    pause.

    {mdadmcab.i
	    &Saida     = "printer"
	    &Page-Size = "64"
	    &Cond-Var  = "150"
	    &Page-Line = "66"
	    &Nom-Rel   = ""CURVAPRO""
	    &Nom-Sis   = """SISTEMA DE ESTOQUE"""
	    &Tit-Rel   = """CURVA ABC PRODUTOS EM GERAL - DA FILIAL "" +
				  string(vetbi,"">>9"") + "" A "" +
				  string(vetbf,"">>9"") +
			  "" PERIODO DE "" +
				  string(vdti,""99/99/9999"") + "" A "" +
				  string(vdtf,""99/99/9999"") "
	    &Width     = "150"
	    &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
	 categoria.catnom no-label with frame f-dep2 side-label.
    vacum = 0.
    for each curva by curva.pos:
	vacum = vacum + ((curva.valven / tot-v) * 100).
	find produ where produ.procod = curva.cod no-lock no-error.
	curva.giro = (curva.estven / curva.valven).
	disp curva.pos format "9999" column-label "Pos."
	     curva.cod format ">>>>>9" column-label "Codigo"
	     produ.pronom when avail produ format "x(40)" column-label "Nome"
	     curva.qtdven(total) format "->>>,>>9"    column-label "Qtd.Ven"
	     curva.valcus(total) format "->>>,>>9.99" column-label "Val.Cus"
	     curva.valven(total) format "->>>,>>9.99" column-label "Val.Ven"
	     ((curva.valven / tot-v) * 100)(total)
				 format "->>9.99"     column-label "%S/VEN"
	     (((curva.valven - curva.valcus) / tot-c) * 100)(total)
				 format "->>9.99"     column-label "%P/MAR"
	     vacum               format "->>9.99"     column-label "% ACUM"
	     curva.qtdest(total) format "->>>,>>9"    column-label "Qtd.Est"
	     curva.estcus(total) format "->>>,>>9.99" column-label "Est.Cus"
	     curva.estven(total) format "->>>,>>9.99" column-label "Est.Ven"
	     curva.giro when curva.giro > 0
				 format "->>9.99" column-label "Giro"
		     with frame f-imp width 200 down.
    end.
    output close.
end.
