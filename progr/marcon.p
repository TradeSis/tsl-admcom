{admcab.i}
define variable wcon like contrato.contnum.
l0:
repeat with frame f1:
    assign wcon = 0.
    do with 1 column width 80 frame f1 title " Contrato ":
	update wcon.
	find contrato where contrato.contnum = wcon
				    use-index iconcon no-error.
	if not available contrato
	then do:
	    message "Contrato nao cadastrado".
	    undo,retry.
	end.
	display contrato.clicod.
	find clien of contrato.
	display clien.clinom.
	display dtinicial etbcod banco.
	contrato.datexp = today.
	clien.datexp = today.
    end.
    do with 1 column width 39 frame f2 title " Valores ":
	display skip(1) vltotal skip(1).
	display vlentra skip(1).
	display vltotal - vlentra label "Valor liquido" format ">>>,>>>,>>9.99"
		skip(1).
    end.
    for each titulo where titulo.titnum = string(contrato.contnum) and
			  titulo.titnat = no and
			  titulo.clifor = contrato.clicod and
			  titulo.modcod = "CRE"
		with column 41 width 40 frame f3 5 down title " Parcelas ":
	display titulo.titpar
		titulo.titsit
	if titulo.titdtpag <> ?
	then titulo.titdtpag
	else titulo.titdtven  @ titulo.titdtpag column-label "Vecto/Pagto"
	if titulo.titdtpag <> ?
	then titulo.titvlpag
	else titulo.titvlcob @ titulo.titvlcob column-label "Valor".
	titulo.datexp = today.
    end.
    message "Confirma a marcacao do contrato para exportacao ?" update sresp.
    if sresp = no
    then
	undo l0, leave.
end.
