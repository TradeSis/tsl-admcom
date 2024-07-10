{admcab.i}
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
		&Nom-Rel   = ""PARCONT""
		&Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
		&Tit-Rel   = """LISTAGEM DE PARCELAS SEM CONTRATOS"""
		&Width     = "120"
		&Form      = "frame f-cabcab"}

    for each titulo where titulo.empcod = 19 and
			  titulo.titnat = no and
			  titulo.modcod = "CRE" and
			  titulo.titdtven >= vdt1 and
			  titulo.titdtven <= vdt2 and
			  titulo.etbcod = estab.etbcod no-lock:

	find clien where clien.clicod = titulo.clifor no-lock no-error.
	if not avail clien
	then next.

	find contrato where contrato.contnum = int(titulo.titnum)
							no-lock no-error.

	if not avail contrato and
	titulo.titdtemi >= 01/01/96
	then disp clien.clicod
		  titulo.titnum
		  titulo.titdtven with frame f-cli width 115 down.
	output stream stela to terminal.
	    display stream stela clien.clicod with 1 down. pause 0.
	output stream stela close.
    end.
    output close.
end.
