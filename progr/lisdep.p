{admcab.i}
def var xx as char.
def var vdata like pedid.peddat.
repeat:
    update vdata label "Data Ped."
	    with frame f1 side-label width 80.

    {mdadmcab.i
	&Saida     = "printer"
	&Page-Size = "64"
	&Cond-Var  = "160"
	&Page-Line = "66"
	&Nom-Rel   = """LISDEP"""
	&Nom-Sis   = """SISTEMA DE ESTOQUE"""
	&Tit-Rel   = """PEDIDOS DE MERCADORIAS PARA O DEPOSITO"""
	&Width     = "160"
	&Form      = "frame f-cab"}

    for each estab no-lock:
	xx = "".
	for each liped where liped.pedtdc = 3 and
			     liped.etbcod = estab.etbcod and
			     liped.predt  = vdata no-lock break by liped.etbcod:
	    find produ where produ.procod = liped.procod no-lock no-error.
	    if not avail produ
	    then next.
	    if produ.fabcod <> 45 and
	       produ.fabcod <> 44
	    then next.

	    if xx = ""
	    then do:
		put skip(3).
		display estab.etbcod
			estab.etbnom no-label format "x(20)"
				with frame f-a side-label no-box.
		xx = "x".
	    end.
	    disp produ.procod
		 produ.pronom
		 liped.lipqtd column-label "Qtd" format ">>,>>9.99"
			with frame f2 down width 200.
	end.
    end.
    output close.
end.
