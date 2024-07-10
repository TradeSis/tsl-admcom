def buffer btitulo for titulo.
for each titulo where titulo.datexp >= 05/28/1996 and
		      titulo.datexp <= 05/31/1996.

    find contrato where contrato.contnum = int(titulo.titnum) no-lock no-error.
    if not avail contrato
    then do:
	display titulo.titnum
		titulo.titpar
		titulo.etbcod
		titulo.titvlcob
		titulo.titvlpag
		titulo.titdtemi
		with frame ftit down column 11 overlay no-hide
			title "Sem Contrato".
	create contrato.
	assign contrato.contnum   = int(titulo.titnum)
	       contrato.clicod    =     titulo.clifor
	       contrato.dtinicial =     titulo.titdtemi
	       contrato.etbcod    =     titulo.etbcod
	       contrato.datexp    =     titulo.datexp
	       contrato.banco     = 99.
	for each btitulo where btitulo.titnum = string(contrato.contnum) and
			       btitulo.titnat = no                       and
			       btitulo.clifor = contrato.clicod          and
			       btitulo.modcod = "CRE".
	    assign contrato.vltotal = contrato.vltotal + btitulo.titvlcob.
	    if btitulo.titpar = 0
	    then
		contrato.vlentra = btitulo.titvlcob.
	end.
	next.
    end.
    else do:
	display contrato.contnum
		with frame fcont down.
    end.                                       pause 0.
end.
