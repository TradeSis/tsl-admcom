/*----------------------------------------------------------------------------*/
/* finan/posfili.p                               Posicao Financeira Listagem  */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vforcod like forne.forcod.
repeat:
    update vforcod label "Transportadora" with frame f1 side-label.
    find first frete where frete.forcod = vforcod no-lock no-error.
    disp frete.frenom no-label with frame f1.
    update vdti label "Periodo"
	   vdtf no-label with frame f1 width 80.

    {confir.i 1 "impressao Posicao Financeira"}

    {mdadmcab.i
	&Saida     = "printer"
	&Page-Size = "62"
	&Cond-Var  = "157"
	&Page-Line = "66"
	&Nom-Rel   = ""fre01""
	&Nom-Sis   = """SISTEMA FINANCEIRO - CONTAS A PAGAR"""
	&Tit-Rel   = """PAGAMENTOS DE TRANSPORTADORAS - PERIODO DE "" +
			string(vdti) + "" A "" + string(vdtf) "
	&Width     = "157"
	&Form      = "frame f-cabcab"}


    for each titulo where titulo.empcod = 19 and
			  titulo.titnat = yes and
			  titulo.modcod = "FRE" and
			  titulo.clifor = frete.forcod no-lock.
	if titulo.titdtemi < vdti or
	   titulo.titdtemi > vdtf
	then next.
	find first plani where plani.etbcod = titulo.etbcod and
			       plani.movtdc = 4             and
			       plani.emite  = titulo.cxacod and
			       plani.serie  = "U"           and
			       plani.numero = int(titulo.titnumger)
							    no-lock no-error.
	if avail plani
	then find forne where forne.forcod = plani.emite no-lock no-error.
	else find forne where forne.forcod = titulo.clifor no-lock no-error.
	if not avail forne
	then next.
	display titulo.titdtven
		titulo.titdtpag
		frete.frenom
		titulo.titvlcob column-label "Vl.Cobrado"
		forne.fornom
		plani.platot when avail plani column-label "Vl.NFiscal"
		plani.numero when avail plani
		((titulo.titvlcob / plani.platot) * 100) when avail plani
			    column-label "Perc" format "->>9.99 %"
		    with frame f2 down width 200.
    end.
    output close.
end.
