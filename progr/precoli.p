{admcab.i}
def var vimp as log format "80/132" label "Tipo de Impressao".
def var vok as log.
def var vpreco like estoq.estvenda.
def var i as i.
def var vdata like plani.pladat.
def var vetb  as int format ">>99" extent 25.
def var vqtd  as int format "->>9" extent 25.
def var vclacod like produ.clacod.
DEF VAR VDPT AS I FORMAT "99" LABEL "Departamento".
DEF VAR VQTDTOT AS INT FORMAT "->>>9" label "TOT.".
def var vcont   as int initial 0.
def var vtip    as char format "X".
repeat:
    assign
	 vetb[1] = 999
	 vetb[2] = 98
	 vetb[3] = 997
	 vetb[4] = 02
	 vetb[5] = 03
	 vetb[6] = 04
	 vetb[7] = 07
	 vetb[8] = 09
	 vetb[9] = 10
	 vetb[10] = 12
	 vetb[11] = 13
	 vetb[12] = 15
	 vetb[13] = 16
	 vetb[14] = 17
	 vetb[15] = 18
	 vetb[16] = 19
	 vetb[17] = 20
	 vetb[18] = 21
	 vetb[19] = 24
	 vetb[20] = 25
	 vetb[21] = 26
	 vetb[22] = 27
	 vetb[23] = 28
	 vetb[24] = 29
	 vetb[25] = 30.
    /*
    update vclacod label "Classe"
		with frame f1 side-label width 80.
    */

    prompt-for categoria.catcod
		with frame f1 side-label centered color white/red row 7.
    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label with frame f1.

    update skip(1) vimp colon 20 with frame f1.

    {confir.i 1 "Livro de Preco"}


    if vimp = no
    then do:
    {mdadm080.i
	&Saida     = "printer"
	&Page-Size = "64"
	&Cond-Var  = "160"
	&Page-Line = "66"
	&Nom-Rel   = """PRECOLI"""
	&Nom-Sis   = """SISTEMA DE ESTOQUE"""
	&Tit-Rel   = """CONTROLE DE ESTOQUE"""
	&Width     = "160"
	&Form      = "frame f-cab"}
    end.
    else do:
    {mdadm132.i
	&Saida     = "printer"
	&Page-Size = "64"
	&Cond-Var  = "160"
	&Page-Line = "66"
	&Nom-Rel   = """PRECOLI"""
	&Nom-Sis   = """SISTEMA DE ESTOQUE"""
	&Tit-Rel   = """CONTROLE DE ESTOQUE""" +
	&Width     = "160"
	&Form      = "frame f-cab2"}
    END.
    put
	"CODIGO-D DESCRICAO                               "
  "PR.VENDA            S A L D O  E M  E S T O Q U E  N A S  F I L I A I S"
   skip
  " " space(52) vetb " TOT." skip
	fill("-",160) format "x(160)" skip.


    for each produ /*where produ.clacod = vclacod*/ no-lock by pronom.

	if produ.catcod <> categoria.catcod
	then next.

	ASSIGN VQTDTOT = 0.
	assign vqtd[1] = 0
	       vqtd[2] = 0
	       vqtd[3] = 0
	       vqtd[4] = 0
	       vqtd[5] = 0
	       vqtd[6] = 0
	       vqtd[7] = 0
	       vqtd[8] = 0
	       vqtd[9] = 0
	       vqtd[10] = 0
	       vqtd[11] = 0
	       vqtd[12] = 0
	       vqtd[13] = 0
	       vqtd[14] = 0
	       vqtd[15] = 0
	       vqtd[16] = 0
	       vqtd[17] = 0
	       vqtd[18] = 0
	       vqtd[19] = 0
	       vqtd[20] = 0
	       vqtd[21] = 0
	       vqtd[22] = 0
	       vqtd[23] = 0
	       vqtd[24] = 0
	       vqtd[25] = 0.


	vpreco = 0.
	VOK = no.
	do i = 1 to 25:
	    find estoq where estoq.etbcod = vetb[i] and
			     estoq.procod = produ.procod no-lock no-error.
	    if not avail estoq
	    then vqtd[i] = 0.
	    else do:
		vqtd[i] = estoq.estatual.
		if estoq.estvenda > 0
		then vpreco = estoq.estvenda.
	    end.
	    VQTDTOT = VQTDTOT + VQTD[I].
	    if avail estoq and estoq.estatual <> 0
	    then vok = yes.
	end.

	IF VOK = NO
	THEN NEXT.
	/*
	IF VQTDTOT <= 0
	THEN NEXT.
	*/
	vtip = "".
	vcont = vcont + 1.

	if vcont = 54
	then do:
	    put
		"*  NAO MOVIMENTADOS DESDE " at 20 today - 90 skip
		"P  PRODUTOS EM PROMOCAO" at 20 skip
		"E  PRODUTOS COM ENTRADAS NOS ULTIMOS 10 DIAS" at 20.
	    page.
	    put
		"CODIGO-D DESCRICAO                               "
  "PR.VENDA                S A L D O  E M  E S T O Q U E  N A S  F I L I A I S"
	    skip
	    " " space(52) vetb " TOT." skip
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
	if estoq.estprodat <> ?
	then do:
	    if estoq.estprodat >= today
	    then vtip = "P" + string(vtip).
	end.


	display produ.procod
		produ.pronom format "x(33)"
		vtip no-label
		vpreco format ">,>>9.99" space(2)
		vqtd[1] space(0) vqtd[2] space(0) vqtd[3] space(0)
		vqtd[4] space(0) vqtd[5] space(0) vqtd[6] space(0)
		vqtd[7] space(0) vqtd[8] space(0) vqtd[9] space(0)
		vqtd[10] space(0) vqtd[11] space(0) vqtd[12] space(0)
		vqtd[13] space(0) vqtd[14] space(0) vqtd[15] space(0)
		vqtd[16] space(0) vqtd[17] space(0) vqtd[18] space(0)
		vqtd[19] space(0) vqtd[20] space(0) vqtd[21] space(0)
		vqtd[22] space(0) vqtd[23] space(0) vqtd[24] space(0)
		vqtd[25] space(0) vqtdtot
		with frame f2 down no-label no-box width 160.
    end.
    output close.
end.
