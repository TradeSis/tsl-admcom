{admcab.i}
def var totpar like titulo.titvlcob.
def var totcon like titulo.titvlcob.
def stream stela .
def var vdt1 like plani.pladat.
def var vdt2 like plani.pladat.
def var vetbcod like estab.etbcod.
repeat:
    update vetbcod  colon 18
	    with frame f-etb side-label width 80 color white/cyan.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if avail estab
    then display estab.etbnom no-label with frame f-etb.
    update vdt1 label "Data Inicial" colon 18
	   vdt2 label "Data Final"   colon 18 with frame f-etb.


    {mdadmcab.i &Saida     = "printer"
		&Page-Size = "63"
		&Cond-Var  = "120"
		&Page-Line = "66"
		&Nom-Rel   = ""CONTPAR""
		&Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
		&Tit-Rel   = """LISTAGEM DE CONTRATOS SEM PARCELAS """
		&Width     = "120"
		&Form      = "frame f-cabcab"}



    for each contrato where contrato.etbcod = estab.etbcod and
			    contrato.dtinicial >= vdt1      and
			    contrato.dtinicial <= vdt2 no-lock:
	if contrato.dtinicial <= 01/01/96
	then next.
	find clien where clien.clicod = contrato.clicod no-lock no-error.
	if not avail clien
	then next.
	totpar = 0.
	totcon = contrato.vltotal.
	for each titulo where titulo.empcod = 19 and
			      titulo.titnat = no and
			      titulo.modcod = "CRE" and
			      titulo.etbcod = contrato.etbcod and
			      titulo.clifor = clien.clicod and
			      titulo.titnum = string(contrato.contnum)
					no-lock.
	totpar = totpar + titulo.titvlcob.
	end.
	if totcon > totpar
	then disp clien.clicod
		  clien.clinom
		  contrato.contnum
		  contrato.dtinicial with frame f-cli width 115 down.
	output stream stela to terminal.
	    display stream stela clien.clicod with 1 down. pause 0.
	output stream stela close.
    end.
    output close.
end.
