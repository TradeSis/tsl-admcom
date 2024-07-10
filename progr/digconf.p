{admcab.i}
def var vtipo as char format "x(10)" extent 2
		initial ["Numerica","Alfabetica"].
def var vpend   as int format "->>>9".
def var vetbcod like estab.etbcod.
def var vqtd like estoq.estinvctm format "->,>>9.99".
def var vprocod like estoq.procod.
def var vdata   like estoq.estbaldat.
def var vcatcod like produ.catcod.
update  vcatcod with frame f-data.
find categoria where categoria.catcod = vcatcod no-lock.
display categoria.catnom no-label with frame f-data.
update  vdata label "Data Referencia" with frame f-data side-label centered.

repeat:
    update vetbcod with frame f-etbcod side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
	message "Estabelecimento nao cadastrado".
	undo, retry.
    end.
    display estab.etbnom no-label with frame f-etbcod.

    repeat:
	update vprocod with frame f-pro down width 80.
	find produ where produ.procod = vprocod no-lock.
	display produ.pronom format "x(30)"
		    with frame f-pro.
	vqtd = 0.
	vpend = 0.
	update vqtd column-label "Quantidade"
	       vpend column-label "Pendencia" with frame f-pro.
	find estoq where estoq.etbcod = estab.etbcod and
			 estoq.procod = produ.procod no-error.
	if vpend >= 0
	then estoq.estinvctm = estoq.estinvctm + vqtd - vpend.
	else estoq.estinvctm = estoq.estinvctm - vqtd + vpend.

	estoq.estbaldat = vdata.
	display estoq.estinvctm column-label "Qtd" format "->>,>>9"
		with frame f-pro.
	/*
	find cotac where cotac.forcod = 0 and
			 cotac.procod = produ.procod no-error.
	if not avail cotac
	then do:
	    create cotac.
	    assign cotac.comcod = vetbcod
	    cotac.forcod        = 0
	    cotac.procod        = produ.procod.
	end.
	cotac.cotpreco = cotac.cotpreco + estoq.estinvctm. */
    end.
    message "Confirma listagem" update sresp.
    if sresp
    then do:
	display vtipo no-label with frame ff centered row 10.
	choose field vtipo with frame ff.
	if frame-index = 1
	then do:
	    output to printer page-size 62.
		for each estoq where estoq.etbcod = vetbcod no-lock:
		    if estoq.estinvctm = 0
		    then next.
		    find produ where produ.procod = estoq.procod no-lock.
		    display produ.procod
			    produ.pronom
			    estoq.estinvctm column-label "Quantidade"
					    format "->>,>>9.99"
					with frame f-cotac down width 80.
		end.
	    output close.
	end.
	else do:
	    output to printer page-size 62.
	    for each produ use-index catpro where
				     produ.catcod = categoria.catcod no-lock:
		for each estoq where estoq.etbcod = vetbcod and
				     estoq.procod = produ.procod no-lock:
		    if estoq.estinvctm = 0
		    then next.
		    display produ.procod
			    produ.pronom
			    estoq.estinvctm column-label "Quantidade"
					    format "->>,>>9.99"
					with frame f-cotac2 down width 80.
		end.
	    end.
	    output close.
	end.
    end.

end.
