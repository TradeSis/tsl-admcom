    do on endkey undo , retry:
	find plani where recid(plani) = recatu1 exclusive-lock.
	vtot = 0.
	for each movim of plani.
	    vtot = vtot + movpc * movqtm.
	end.
	plani.platot = vtot.
	update plani.platot.
	plani.plades = if plani.platot <> vtot
		       then 100 - (plani.platot / vtot * 100)
		       else 0.
    end.
    display plani.plades.

    if tipmov.movttitu
    then do on endkey undo, retry:
	display tipmov.modcod colon 25.
	prompt-for tipmov.modcod colon 25.
	find nota of plani no-error.
	vtitnum = if avail nota
		  then string(nota.notnum)
		  else string(plani.movndc) .
	run geratitu.p (input plani.platot,
			input input tipmov.modcod,
			input plani.crecod,
			input tipmov.movtnat,
			input plani.clifor,
			input vtitnum,
			input plani.etbcod,
			input plani.pladat,
			input plani.pladat,
			output vpar).
    end.
