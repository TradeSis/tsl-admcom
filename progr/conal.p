{admcab.i}
def var wcon        like contrato.contnum format ">>>>>>>>9".
def var vclicod     like contrato.clicod  format ">>>>>>>>9".
def var vcontnum    like contrato.contnum format ">>>>>>>>9".
l0:
repeat with frame f1:
    assign wcon = 0
	   vcontnum = 0.
    clear frame f1 all.
    do with 1 column width 80 row 4 frame f1 title " Contrato ":
	update wcon.
	display vcontnum when vcontnum > 0.
	find contrato where contrato.contnum = wcon use-index iconcon no-error.
	if not available contrato
	then do:
	    message "Contrato nao cadastrado".
	    undo,retry.
	end.
	display contrato.clicod FORMAT ">>>>>>>>9".
	find clien of contrato.
	display clien.clinom.
	display dtinicial
		etbcod .
	assign contrato.datexp = today.
    end.
    do with 1 column width 35 frame f2 title " Valores ":
	display skip(1) vltotal skip(1).
	display vlentra skip(1).
	display vltotal - vlentra label "Valor liquido" format ">>>,>>>,>>9.99"
		skip(1).
    end.
    for each titulo where titulo.titnum = string(contrato.contnum) and
			  titulo.titnat = no and
			  titulo.clifor = contrato.clicod and
			  titulo.modcod = "CRE"
		    with column 37 width 44 frame f3 5 down title " Parcelas ":
	display titulo.etbcod column-label "Est"
		titulo.titpar
		titulo.titsit
		if titulo.titdtpag <> ?
		then titulo.titdtpag
	       else titulo.titdtven @ titulo.titdtpag column-label "Vecto/Pagto"
		if titulo.titdtpag <> ?
		then titulo.titvlpag
		else titulo.titvlcob @ titulo.titvlcob column-label "Valor".
    end.
    do with frame f1:
	vclicod = contrato.clicod.
	vcontnum = contrato.contnum.
	update vcontnum     label "Contrato Novo" format ">>>>>>>>9".
	update contrato.clicod format ">>>>>>>>9".
	find clien of contrato.
	display clien.clinom.
	update  contrato.dtinicial.
	update  contrato.etbcod.
	find numcont where numcont.contnum = contrato.contnum no-error.
	if avail numcont
	then do:
	    numcont.numsit = no.
	    numcont.datexp = today.
	end.
    end.
    for each titulo where titulo.titnum = string(contrato.contnum) and
			  titulo.titnat = no and
			  titulo.clifor = vclicod and
			  titulo.modcod = "CRE".
	assign
	    titulo.clifor = contrato.clicod
	    titulo.etbcod = contrato.etbcod
	    titulo.datexp = today
	    titulo.titnum = string(vcontnum).
    end.
    contrato.contnum = vcontnum.
    find numcont where numcont.contnum = contrato.contnum no-error.
    if avail numcont
    then do:
	numcont.numsit = yes.
	numcont.datexp = today.
    end.
    message "Alteracao de Contrato encerrada.".
end.
