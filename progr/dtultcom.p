{admcab.i}
repeat:
    prompt-for produ.procod with frame ff down color red/white no-validate.
    find produ using produ.procod no-lock.
    disp produ.pronom format "x(40)" with frame ff.

    find estoq where estoq.etbcod = 999 and
		     estoq.procod = produ.procod .

    find last movim where movim.movtdc = 4 and
			  movim.procod = produ.procod no-lock no-error.
    if avail movim
    then assign estoq.estinvdat = movim.movdat
		estoq.estinvqtd  = movim.movqtm.

    update estoq.estinvdat column-label "Dt.Ult.Compra"
	   estoq.estinvqtd with frame ff.
end.
