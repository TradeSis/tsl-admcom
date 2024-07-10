{admcab.i}
def var vcatcod like produ.catcod.
repeat:
    update vcatcod with frame f1 side-label width 80.
    find categoria where categoria.catcod = vcatcod no-lock no-error.
    display categoria.catnom no-label with frame f1.
    message "Confirma Listagem de fabricante" update sresp.
    if not sresp
    then leave.

    {mdadmcab.i
	&Saida     = "printer"
	&Page-Size = "64"
	&Cond-Var  = "135"
	&Page-Line = "66"
	&Nom-Rel   = ""lisfab2""
	&Nom-Sis   = """SISTEMA DE ESTOQUE"""
	&Tit-Rel   = """LISTAGEM DE FABRICANTES""
			    + "" DEPARTAMENTO : "" + categoria.catnom"
       &Width     = "135"
       &Form      = "frame f-cabcab"}
    for each fabri no-lock by fabcod.
	find first produ where produ.catcod = vcatcod and
			       produ.fabcod = fabri.fabcod no-lock no-error.
	if not avail produ
	then next.
	find forne where forne.forcod = fabri.fabcod no-lock no-error.
	if not avail forne
	then next.
	disp fabri.fabcod
	     fabri.fabnom
	     forne.forrua
	     forne.formunic
	     forne.ufecod
	     forne.forfone with frame f-forli width 140 down.
    end.
    output close.
end.
