{admcab.i}
def var vpreco like estoq.estvenda.
def var i as i.
def var vdata like plani.pladat.
def var vqtd  as int format "->>9".
def var vclacod like produ.clacod.
def var vetb2  as int format ">>99" extent 25.
DEF VAR VDPT AS I FORMAT "99" LABEL "Departamento".
DEF VAR VQTDTOT AS INT FORMAT ">>>9" label "TOT.".
def var vcont   as int initial 0.
def var vtip    as char format "X".
def var vcol as i format ">".
def buffer bestoq for estoq.

repeat:
    assign
	 vetb2[1] = 999
	 vetb2[2] = 98
	 vetb2[3] = 997
	 vetb2[4] = 02
	 vetb2[5] = 03
	 vetb2[6] = 04
	 vetb2[7] = 07
	 vetb2[8] = 09
	 vetb2[9] = 10
	 vetb2[10] = 12
	 vetb2[11] = 13
	 vetb2[12] = 15
	 vetb2[13] = 16
	 vetb2[14] = 17
	 vetb2[15] = 18
	 vetb2[16] = 19
	 vetb2[17] = 20
	 vetb2[18] = 21
	 vetb2[19] = 24
	 vetb2[20] = 25
	 vetb2[21] = 26
	 vetb2[22] = 27
	 vetb2[23] = 28
	 vetb2[24] = 29
	 vetb2[25] = 30.

    vcont = 0.
    /*
    update vclacod label "Classe"
		with frame f1 side-label width 80.
    */

    prompt-for categoria.catcod colon 20
		with frame f1 side-label centered color white/red row 7.
    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label with frame f1.
    prompt-for estab.etbcod colon 20 with frame f1.
    find estab where estab.etbcod = input estab.etbcod no-lock.
    disp estab.etbnom no-label with frame f1.

    {confir.i 1 "Livro de Preco"}
    {mdadmcab.i
	&Saida     = "printer"
	&Page-Size = "64"
	&Cond-Var  = "160"
	&Page-Line = "66"
	&Nom-Rel   = """PRECOLI2"""
	&Nom-Sis   = """SISTEMA DE ESTOQUE"""
	&Tit-Rel   = """CONTROLE DE ESTOQUE NA "" +
		    ""FILIAL "" + string(estab.etbcod)"
	&Width     = "160"
	&Form      = "frame f-cab"}

    put
	"CODIGO-D DESCRICAO                               "
  "PR.VENDA   QTD               "
	"CODIGO-D DESCRICAO                               "
  "PR.VENDA   QTD " skip
	fill("-",160) format "x(160)" skip.


    for each produ where produ.catcod = categoria.catcod
				 no-lock break by pronom.

	assign vqtd = 0.
	vpreco = 0.
	do i = 1 to 25:
	    find bestoq where bestoq.etbcod = vetb2[i] and
			      bestoq.procod = produ.procod no-lock no-error.
	    if avail bestoq
	    then VQTDTOT = VQTDTOT + bestoq.estatual.
	end.
	/*
	IF VQTDTOT <= 0
	THEN NEXT.
	*/
	vcol = vcol + 1.
	find estoq where estoq.etbcod = estab.etbcod and
			 estoq.procod = produ.procod no-lock no-error.
	if not avail estoq
	then vqtd = 0.
	else do:
	   vqtd = estoq.estatual.
	   vpreco = estoq.estvenda.
	end.
	if vqtd >= 0
	then next.

	vtip = "".
	if vcont = 54
	then do:
	    put
		"*  NAO MOVIMENTADOS DESDE " at 20 today - 90 skip
		"P  PRODUTOS EM PROMOCAO" at 20 skip
		"E  PRODUTOS COM ENTRADAS NOS ULTIMOS 10 DIAS" at 20.
	    page.

	    put
		"CODIGO-D DESCRICAO                               "
		"PR.VENDA   QTD               "
		"CODIGO-D DESCRICAO                               "
		"PR.VENDA   QTD " skip
		    fill("-",160) format "x(160)" skip.
	    vcont = 0.
	end.

	find first movim where movim.movdat > (today - 90) and
			       movim.procod = produ.procod and
			       (movim.movtdc = 4 or
			       movim.movtdc = 5) no-lock no-error.
	if avail movim
	then vtip = "".
	else vtip = "*".

	find first movim where movim.movdat >= (today - 10) and
			       movim.procod = produ.procod and
			       movim.movtdc = 4 no-lock no-error.
	if avail movim
	then vtip = "E".

	if vcol = 1
	then do:
	    put
		produ.procod space(1)
		produ.pronom format "x(38)" space(1)
		vtip  space(1)
		vpreco format ">,>>9.99" space(2)
		vqtd.
	end.
	if vcol = 2
	then do:
	    put
		produ.procod at 80 space(1)
		produ.pronom format "x(38)" space(1)
		vtip  space(1)
		vpreco format ">,>>9.99" space(2)
		vqtd skip.
	    vcont = vcont + 1.
	    vcol = 0.
	end.
	vqtdtot = 0.
    end.
    output close.
end.
