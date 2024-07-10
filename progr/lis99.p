{admcab.i}
DEF VAR vdia as int format ">99".
def var vimp as log format "80/132" label "Tipo de Impressao".
def var vok as log.
def var vpreco like estoq.estvenda.
def var i as i.
def var vdata like plani.pladat.
def var vqtd  as int format "->>9".
def var vclacod like produ.clacod.
def var vetb2  as int format ">>99" extent 25.
DEF VAR VDPT AS I FORMAT "99" LABEL "Departamento".
DEF VAR VQTDTOT AS INT FORMAT "->>>9" label "TOT.".
def var vcont   as int initial 0.
def var vtip    as char format "XX".
def var vcol as i format ">".
def buffer bestoq for estoq.

repeat:

    vcont = 0.

    prompt-for categoria.catcod colon 20
		with frame f1 side-label centered color white/red row 7.
    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label with frame f1.
    update skip vimp colon 20 with frame f1.

    {confir.i 1 "Livro de Preco"}


    if vimp = no
    then do:
    {mdadm080.i
	&Saida     = "printer"
	&Page-Size = "64"
	&Cond-Var  = "160"
	&Page-Line = "66"
	&Nom-Rel   = """PRECOLI4"""
	&Nom-Sis   = """SISTEMA DE ESTOQUE"""
	&Tit-Rel   = """CONTROLE DE ESTOQUE NA "" +
		    ""FILIAL "" + string(estab.etbcod)"
	&Width     = "160"
	&Form      = "frame f-cab"}
    end.
    else do:
    {mdadm132.i
	&Saida     = "printer"
	&Page-Size = "64"
	&Cond-Var  = "160"
	&Page-Line = "66"
	&Nom-Rel   = """PRECOLI4"""
	&Nom-Sis   = """SISTEMA DE ESTOQUE"""
	&Tit-Rel   = """CONTROLE DE ESTOQUE NA "" +
		    ""FILIAL "" + string(estab.etbcod)"
	&Width     = "160"
	&Form      = "frame f-cab2"}
    end.
    put "CODIGO-D DESCRICAO                                    "
	"                       "
	"CODIGO-D DESCRICAO                                  "
		"                          " skip
	fill("-",160) format "x(160)" skip.


    for each produ where produ.catcod = categoria.catcod
				 no-lock break by pronom.

	vqtd = 0.
	for each estoq where estoq.procod = produ.procod no-lock.
	    if estoq.estatual > 0
	    then vqtd = vqtd + estoq.estatual.
	    if estoq.estatual < 0
	    then vqtd = vqtd + (estoq.estatual * -1).
	end.
	if vqtd > 0
	then next.


	vcol = vcol + 1.
	if vcont = 54
	then do:
	    page.
	    put
		"CODIGO-D DESCRICAO                                    "
		"                       "
		"CODIGO-D DESCRICAO                                  "
		"                          " skip
		    fill("-",160) format "x(160)" skip.
	    vcont = 0.
	end.

	if vcol = 1
	then do:
	    put
		produ.procod space(1)
		produ.pronom format "x(45)" space(1).
	end.
	if vcol = 2
	then do:
	    put
		produ.procod at 81 space(1)
		produ.pronom format "x(45)" space(1) skip.
	    vcont = vcont + 1.
	    vcol = 0.
	end.
    end.
    output close.
end.
