{admcab.i}
def var varquivo as char.
def var vdtini  as date.
def var vdtfin  as date.

def var vtotetb     like titulo.titvlpag.
def var wtotal      like titulo.titvlpag.

REPEAT:
    form with frame ftot.
    prompt-for estab.etbcod colon 20
	       with frame f1 .
    find estab using estab.etbcod no-error.
    if not avail estab
    then do:
	if estab.etbcod entered
	then do:
	    message "Estabelecimento Invalido".
	    undo.
	end.
    end.
    display estab.etbnom no-label when avail estab
	    with frame f1.
    update vdtini   colon 20 label "Data Inicial"
	   vdtfin   colon 20 label "Data Final"
	   with frame f1
		row 4 width 80 side-label.
    for each pagam.
	delete pagam.
    end.

    message "Processando...".

    if estab.etbcod not entered
    THEN
	for each titulo USE-INDEX TITDTPAG
		where titulo.empcod = wempre.empcod and
			      titulo.titnat = no            and
			      titulo.modcod = "CRE"         and
			      titulo.titdtpag >= vdtini     and
			      titulo.titdtpag <= vdtfin
			      no-lock:
	    DISPLAY "Processando" TITULO.TITDTPAG
				  TITULO.ETBCOD
		    WITH CENTERED ROW 10 1 DOWN no-label. PAUSE 0.
	    find first pagam where pagam.etbcod = titulo.etbcod and
				 pagam.dtpag = titulo.titdtpag no-error.
	    if not avail pagam
	    then create pagam.
	    assign
		pagam.etbcod = titulo.etbcod
		pagam.dtpag  = titulo.titdtpag
		pagam.vtotal = pagam.vtotal + titulo.titvlpag.
	end.
    ELSE
	for each titulo USE-INDEX TITDTPAG
		where titulo.empcod = wempre.empcod and
			      titulo.titnat = no            and
			      titulo.modcod = "CRE"         and
			      titulo.titdtpag >= vdtini     and
			      titulo.titdtpag <= vdtfin     and
				titulo.etbcod = input estab.etbcod
			      no-lock:
	    DISPLAY "Processando" TITULO.TITDTPAG
		    WITH CENTERED ROW 10 1 DOWN no-label. PAUSE 0.
	    find first pagam where pagam.etbcod = titulo.etbcod and
				 pagam.dtpag = titulo.titdtpag no-error.
	    if not avail pagam
	    then create pagam.
	    assign
		pagam.etbcod = titulo.etbcod
		pagam.dtpag  = titulo.titdtpag
		pagam.vtotal = pagam.vtotal + titulo.titvlpag.
	end.
    hide message no-pause.

    varquivo = "..\relat\rpag" + STRING(TIME) + ".rel".
    {mdadmcab.i
	&Saida     = "value(varquivo)"
	&Page-Size = "64"
	&Cond-Var  = "80"
	&Page-Line = "66"
	&Nom-Rel   = """RESPAG"""
	&Nom-Sis   = """SISTEMA CREDIARIO"""
	&Tit-Rel   = """RESUMO DE PAGAMENTOS DIARIO PERIODO DE "" +
	    string(vdtini) + "" A "" + string(vdtfin) "
	&Width     = "80"
	&Form      = "frame f-cab"}

    assign
	vtotetb = 0
	wtotal  = 0.

    for each pagam
	break by pagam.etbcod
	      by pagam.dtpag
			 with frame ftot centered.

	display pagam.etbcod
		pagam.dtpag
		pagam.vtotal label "Total" FORMAT "->>>,>>>,>>>,>>>,>>9.99"
		with frame ftot down.

	down with frame ftot.

	assign
	    vtotetb = vtotetb + pagam.vtotal
	    wtotal  = wtotal  + pagam.vtotal.

	if last-of(pagam.etbcod)
	then do:
	    display "-----------------------" @ pagam.vtotal
		    with frame ftot.
	    down with frame ftot.
	    display vtotetb @ pagam.vtotal
		    with frame ftot.
	    down with frame ftot.
	    vtotetb = 0.
	    if last(pagam.etbcod)
	    then.
	    else page.
	end.
    end.
    put skip(2).
    display wtotal @ pagam.vtotal
	    with frame ftot.
    down with frame ftot.
    output close.

    message "Deseja Imprimir o arquivo " varquivo + "?" update sresp.
    if sresp
    then dos silent value("type " + varquivo + " > prn").

end.
