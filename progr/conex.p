{admcab.i}
define variable wcon like contrato.contnum.
define variable wcnt as logical initial no.
define variable rsp as logical format "Sim/Nao" initial yes.
/*
{segur.in}
*/
l0:
repeat:
    assign wcon = 0.
    do with 1 column width 80 frame f1 title " Contrato ":
	update wcon.
	find contrato where contrato.contnum = wcon use-index iconcon no-error.
	if not available contrato
	then do:
	    message "Contrato nao cadastrado".
	    undo,retry.
	end.
	display contrato.clicod.
	find clien of contrato no-error.
	display clien.clinom when avail clien.
	display dtinicial etbcod banco.
    end.
    do with 1 column width 39 frame f2 title " Valores ":
	display skip(1) vltotal skip(1).
	display vlentra skip(1).
	display vltotal - vlentra label "Valor liquido" format ">>>,>>>,>>9.99"
		skip(1).
    end.
    assign wcnt = no.
    for each titulo where titulo.titnum = string(contrato.contnum) and
			  titulo.titnat = no and
			  titulo.clifor = contrato.clicod and
			  titulo.modcod = "CRE"
		    with column 41 width 40 frame f3 5 down title " Parcelas ":
	display titulo.titpar label "Parc." space(4)
		titulo.titdtven space(4)
		titulo.titvlcob.
	if titulo.titsit = "PAG" and
	   titulo.titpar <> 0
	then assign wcnt = yes.
    end.
    if wcnt
    then do:
	message "Contrato com Parcelas pagas, exclusao negada.".
	undo,retry.
    end.
    if contrato.datexp <> today
    then do:
	message "Contrato nao foi digitado hoje, exclusao negada.".
	undo,retry.
    end.
    message "Confirme exclusao do Contrato ? " update rsp.
    if not rsp
    then do:
	message "Exclusao nao efetuada.".
	undo,retry.
    end.
    for each titulo where titulo.titnum = string(contrato.contnum) and
			  titulo.titnat = no and
			  titulo.clifor = contrato.clicod and
			  titulo.modcod = "CRE".
	delete titulo.
    end.
    find numcont where numcont.contnum = contrato.contnum no-error.
    if avail numcont
    then do:
	numcont.numsit = no.
	numcont.datexp = today.
    end.
    delete contrato.
    message "Contrato excluido.".
end.
