{admcab.i}
def var tot-ven  like plani.platot.
def var tot-mar  like plani.platot.
def var tot-acr  like plani.platot.
def buffer bmovim for movim.
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
def var vdata like plani.pladat.

repeat:
    update vcatcod label "Departamento"
	   vdata   label "Data"
		with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.

	disp " Prepare a Impressora para Imprimir Relatorio " with frame
				f-pre centered row 16.
	pause.

	{mdadmcab.i
	    &Saida     = "printer"
	    &Page-Size = "64"
	    &Cond-Var  = "130"
	    &Page-Line = "66"
	    &Nom-Rel   = ""PROMLI""
	    &Nom-Sis   = """SISTEMA DE ESTOQUE"""
	    &Tit-Rel   = """LISTAGEM DE PRODUTOS EM PROMOCAO"""
	    &Width     = "130"
	    &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
	 categoria.catnom no-label with frame f-dep2 side-label.

    for each produ no-lock by pronom.
	    if produ.catcod <> vcatcod
	    then next.

	    find estoq where estoq.etbcod = 999 and
			     estoq.procod = produ.procod no-lock no-error.
	    if not avail estoq
	    then next.
	    if estoq.estproper = 0 or
	       estoq.estprodat <> vdata
	    then next.
	    output stream stela to terminal.
	    disp stream stela
		 produ.procod
		 produ.pronom
		  with frame fffpla centered width 80.
	    pause 0.
	    output stream stela close.

	    display produ.procod
		    produ.pronom
		    estoq.estvenda(total) format ">,>>>,>>9.99"
		    estoq.estproper(total) column-label "Promocao"
				format ">,>>>,>>9.99"
		    estoq.estprodat column-label "Dt.Prom."
				with frame f-imp width 150 down.
    end.
    output close.
end.
