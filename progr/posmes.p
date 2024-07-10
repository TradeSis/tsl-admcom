{admcab.i}

def var vmes like hiest.hiemes.
def var vano like hiest.hieano.

repeat:

    prompt-for estab.etbcod
		with frame f1 side-label centered color white/red row 7.
    find estab using estab.etbcod no-lock.
    disp estab.etbnom no-label skip(1) with frame f1.

    prompt-for categoria.catcod
		with frame f1.
    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label skip(1) with frame f1.

    update vmes
	   vano with frame f1.

    {confir.i 1 "Posicao de Estoque"}
    {mdadmcab.i
	&Saida     = "printer"
	&Page-Size = "64"
	&Cond-Var  = "80"
	&Page-Line = "66"
	&Nom-Rel   = """POSMES"""
	&Nom-Sis   = """SISTEMA DE ESTOQUE"""
	&Tit-Rel   = """CONTROLE DE ESTOQUE - "" + estab.etbnom + ""  "" +
						   categoria.catnom  "
	&Width     = "80"
	&Form      = "frame f-cab"}

    disp vmes
	 vano.

    for each produ no-lock by pronom.

	if produ.catcod <> categoria.catcod
	then next.

	find hiest where hiest.etbcod = estab.etbcod and
			 hiest.procod = produ.procod and
			 hiest.hiemes = vmes and
			 hiest.hieano = vano no-lock no-error.
	if not avail hiest
	then next.

	if hiest.hiestf = 0
	then next.

	find estoq where estoq.etbcod = estab.etbcod and
			 estoq.procod = produ.procod no-lock no-error.
	if not avail estoq
	then next.

	display produ.procod column-label "Codigo"
		produ.pronom FORMAT "x(35)"
		hiest.hiestf (TOTAL) column-label "Qtd." format "->>>>9"
		estoq.estcusto column-label "Pc.Custo" format ">,>>9.99"
		(hiest.hiestf * estoq.estcusto) (TOTAL) column-label "Total"
						       format "->,>>>,>>9.99"
		with frame f2 down width 80.
    end.
    output close.
end.
