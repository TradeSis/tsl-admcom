{admcab.i}
def var vfor1 like forne.forcod.
def var vfor2 like forne.forcod.
def var vpreco like estoq.estvenda.
def var i as i.
def var vdata like plani.pladat.
def var vetb  as CHAR format "x(4)" extent 22.
def var vqtd  as int format ">>>9" extent 22.
def var vcatcod like produ.catcod.
repeat:
    assign
	 vetb[1] = "JAN"
	 vetb[2] = "FEV"
	 vetb[3] = "MAR"
	 vetb[4] = "ABR"
	 vetb[5] = "MAI"
	 vetb[6] = "JUN"
	 vetb[7] = "JUL"
	 vetb[8] = "AGO"
	 vetb[9] = "SET"
	 vetb[10] = "OUT"
	 vetb[11] = "NOV"
	 vetb[12] = "DEZ".

    update vdata   label "Data Referencia"
/*           vfor1   label "Fornecedor Inicial"
	   vfor2   label "Fornecedor Final"  */
		with frame f1 side-label width 80.

    {confir.i 1 "Livro de Preco"}
    {mdadmcab.i
	&Saida     = "printer"
	&Page-Size = "64"
	&Cond-Var  = "160"
	&Page-Line = "66"
	&Nom-Rel   = """REL2"""
	&Nom-Sis   = """SISTEMA DE ESTOQUE"""
	&Tit-Rel   = """INFORMACOES PARA COMPRA "" +
			STRING(VDATA)"
	&Width     = "160"
	&Form      = "frame f-cab"}

    put
	"CODIGO-D DESCRICAO                               "
  "PR.VENDA            C O M P R A  M E S E S  A N T E R I O R E S        "
   skip
  " " space(58) vetb skip
	fill("-",160) format "x(160)" skip.
    /*
    for each forne where forne.forcod >= vfor1 and
			 forne.forcod <= vfor2 no-lock break by forcod:
	if first-of(forne.forcod)
	then display forne.forcod
		     forne.fornom with frame f-forne side-label.  */

    for each produ where no-lock by pronom.

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
	       vqtd[12] = 0.

	for each himov where himov.etbcod = 999 and
			     himov.procod = produ.procod and
			     himov.movtdc = 4 no-lock:
	    vqtd[himov.himmes] = vqtd[himov.himmes] + himov.himqtm.
	end.

	find estoq where estoq.etbcod = 999 and
			 estoq.procod = produ.procod no-lock no-error.

	/*
	do i = 1 to 12:
	    if not avail estoq
	    then vqtd[i] = 0.
	    else vqtd[i] = estoq.estatual.
	    vpreco = estoq.estvenda.
	end.  */
	if vqtd[1] = 0 and
	   vqtd[3] = 0 and
	   vqtd[4] = 0 and
	   vqtd[5] = 0 and
	   vqtd[6] = 0 and
	   vqtd[7] = 0 and
	   vqtd[8] = 0 and
	   vqtd[9] = 0 and
	   vqtd[10] = 0 and
	   vqtd[11] = 0 and
	   vqtd[12] = 0
	then next.

	display produ.procod
		produ.pronom format "x(40)"
		estoq.estvenda format ">,>>9.99" space(2)
		vqtd[1] space(0) vqtd[2] space(0) vqtd[3] space(0)
		vqtd[4] space(0) vqtd[5] space(0) vqtd[6] space(0)
		vqtd[7] space(0) vqtd[8] space(0) vqtd[9] space(0)
		vqtd[10] space(0) vqtd[11] space(0) vqtd[12] space(0)
		 with frame f2 down no-label no-box width 160.
    end.
    /* end. */
    output close.
end.
