{admcab.i}
def var vqtd like estoq.estatual.
def var vind as l format "Codigo/Nome" initial yes.
def var ac  as i.
def var tot as i.
def var de  as i.
def var vdata like plani.pladat.
def var est like estoq.estatual.

repeat:

    prompt-for estab.etbcod
		with frame f1 side-label centered color white/cyan row 7.
    find estab using estab.etbcod no-lock.
    disp estab.etbnom no-label skip(1) with frame f1.

    prompt-for categoria.catcod label "Departamento"
		with frame f1.

    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label with frame f1.
    update vind label "Ordem" with frame f1.

    if vind
    then do:
	for each produ no-lock:
	    if produ.catcod <> categoria.catcod
	    then next.
	    find estoq where estoq.etbcod = estab.etbcod and
			     estoq.procod = produ.procod no-lock no-error.
	    if not avail estoq
	    then next.
	    if estoq.estatual <= 0
	    then next.
	    display produ.procod column-label "Codigo"
		    produ.pronom FORMAT "x(35)"
		    estoq.estatual (TOTAL) column-label "Qtd." format "->>>>9"
					with frame f2 down width 80. pause 0.
	    vqtd = estoq.estatual.
	    if estoq.procod = 2919 or
	       estoq.procod = 952  or
	       estoq.procod = 2920
	    then vqtd = 1.


	    run eti_barl.p (input recid(produ),
			    input vqtd).
	end.
    end.
    else do:
	for each produ no-lock by pronom:
	    if produ.catcod <> categoria.catcod
	    then next.
	    find estoq where estoq.etbcod = estab.etbcod and
			     estoq.procod = produ.procod no-lock no-error.
	    if not avail estoq
	    then next.
	    if estoq.estatual <= 0
	    then next.
	    vqtd = estoq.estatual.
	    if estoq.procod = 2919 or
	       estoq.procod = 952  or
	       estoq.procod = 2920
	    then vqtd = 1.
	    display produ.procod column-label "Codigo"
		    produ.pronom FORMAT "x(35)"
		    estoq.estatual (TOTAL) column-label "Qtd." format "->>>>9"
					with frame f3 down width 80. pause 0.
	    run eti_barl.p (input recid(produ),
			    input vqtd).
	end.
    end.
end.
