{admcab.i}
def var totglo like globa.gloval.
def var vvenda like estoq.estvenda.
def var    vqtdcon    as i label "QTD".
def var    vvalcon    as dec label "VALOR".
def var    vqtdconesp as i label "QTD".
def var    vvalconesp as dec label "VALOR".
def buffer btitulo for titulo.
def buffer bcontrato for contrato.
def buffer bmovim for movim.
def var wpla like contrato.crecod.
def var vlpres      like plani.platot.
def var vdata       like titulo.titdtemi.
def var vpago       like titulo.titvlpag.
def var vdesc       like titulo.titdesc.
def var vjuro       like titulo.titjuro.
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .
def var vcxacod     like titulo.cxacod.
def var vmodcod     like titulo.modcod.
def var conta1      as integer.
def var conta2      as integer.
def var conta4      as integer.

def stream stela.

do with 1 down side-label width 80 row 4 color blue/white:
    prompt-for estab.etbcod colon 20.
    find estab using etbcod .
    display estab.etbnom no-label.
    update vdata colon 20.

    find first bmovim where bmovim.movdat = vdata no-lock no-error.
    if not avail bmovim
    then leave.
    {mdadmcab.i &Saida     = "printer"
		&Page-Size = "64"
		&Cond-Var  = "160"
		&Page-Line = "66"
		&Nom-Rel   = ""CONFF""
		&Nom-Sis   = """SISTEMA ESTOQUE"""
		&Tit-Rel   = """LISTAGEM DE DIVERGENCIAS DE PLANOS NO DIA "" +
			     STRING(VDATA) +
			      "" NA LOJA "" + string(estab.etbcod) + "" - "" +
					       estab.etbnom "
		&Width     = "160"
		&Form      = "frame f-cabcab2"}

    for each plani where plani.movtdc = 5 and
			 plani.etbcod = estab.etbcod and
			 plani.pladat = vdata no-lock:

	for each movim where movim.etbcod = plani.etbcod and
			     movim.placod = plani.placod no-lock :

	    output stream stela to terminal.
	    disp stream stela movim.procod with 1 down frame ffff. pause 0.
	    output stream stela close.

	    wpla = 0.

	    find first estoq where estoq.procod = movim.procod no-lock no-error.
	    if not avail estoq
	    then next.

	    vvenda = ESTOQ.ESTVENDA.
	    if estprodat <> ?
	    then if estprodat >= today
		 then vvenda = estoq.estproper.
		 else vvenda = estoq.estvenda.

	    /*
	    if vvenda = movim.movpc
	    then next.
	    */

	    find produ of movim no-lock no-error.
	    if not avail produ
	    then next.

	    find first contnf where contnf.etbcod = plani.etbcod and
				contnf.placod = plani.placod no-lock no-error.

	    if avail contnf
	    then do:
		find contrato of contnf no-lock no-error.
		if not avail contrato
		then next.
		wpla = contrato.crecod.
	    end.
	    else next.

	    find clafin where clafin.clacod = produ.clacod and
			      clafin.fincod = contrato.crecod no-lock no-error.
	    if avail clafin
	    then next.

	    display plani.etbcod   column-label "Fil."
		plani.numero   column-label "Numero"
		plani.serie    column-label "Ser"
		plani.vencod   column-label "Vend." format ">>>9"
		movim.procod
		produ.pronom   format "x(30)"
		movim.movpc    column-label "Pc.Nota"
		vvenda         column-label "Pc.Venda"
		(movim.movpc - vvenda) column-label "Vl.Difer."
		((movim.movpc / vvenda) - 1) * 100 format "->>9.99 %"
			       column-label " % Difer."
		plani.protot column-label "Tot.Nota"
		wpla column-label "Plano"
		plani.platot column-label "Tot.Finan"
		((plani.protot / plani.platot) - 1) * 100 format "->>9.99 %"
			       column-label " % Finan."
		    with no-box width 150.

	end.
    end.
    output close.
end.
