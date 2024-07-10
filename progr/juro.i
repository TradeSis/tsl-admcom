
    /***** Inicio *****/
    vvltotal = 0.
    vvlcont = 0.
    wacr = 0.
    if plani.crecod > 1
    then do:
	find first contnf where contnf.etbcod = plani.etbcod and
				contnf.placod = plani.placod no-lock no-error.
	if avail contnf
	then do:
	    for each bcontnf where bcontnf.etbcod  = contnf.etbcod and
				   bcontnf.contnum = contnf.contnum no-lock:
		find first bplani where bplani.etbcod = bcontnf.etbcod and
				  bplani.placod = bcontnf.placod no-lock.
		vvltotal = vvltotal + (bplani.platot - bplani.vlserv).
	    end.
	    find contrato where contrato.contnum = contnf.contnum
					    no-lock no-error.
	    if avail contrato
	    then do:
		vvlcont = contrato.vltotal.
		valortot = contrato.vltotal.
	    end.
	    wacr = vvlcont  - vvltotal.  /*plani.platot.*/
	    wper = plani.platot / vvltotal.
	    wacr = wacr * wper.
	end.
    end.
    else do:
	wacr = plani.acfprod.
	valortot = plani.platot.
    end.
    valortot = plani.platot - plani.vlserv.
    valortot = valortot + wacr.
    if wacr < 0
    then wacr = 0.
    vacfprod = wacr.
    /***** Final *****/
