{admcab.i}
def var vtip as char format "x(10)" extent 5
    initial ["Cliente"," Prestacao ","  Contrato","   Nota","Produto"].
def var vdata like plani.datexp.
def var vregcod like estab.regcod.
repeat:
    update vregcod with frame f1.
    find regiao where regiao.regcod = vregcod no-lock.
    display regiao.regnom no-label with frame f1.
    update vdata label "Data Exportacao" with frame f1 side-label width 80.
    disp vtip no-label with frame f2 centered color white/cyan.
    choose field vtip with frame f2.
    if frame-index = 1
    then do:
	for each clien where clien.datexp = vdata no-lock by clinom:
	    display clien.clicod
		    clien.clinom with frame f-cli down width 80.
	end.
    end.
    if frame-index = 2
    then do:
	for each estab where estab.regcod = vregcod no-lock:
	    for each titulo where titulo.datexp = vdata no-lock:
		if titulo.etbcod <> estab.etbcod
		then next.
		display titulo.etbcod
			titulo.etbcobra
			titulo.clifor
			titulo.titpar
			titulo.titnum
			titulo.titsit
			titulo.titdtpag with frame f-tit down centered.
	    end.
	end.
    end.
    if frame-index = 3
    then do:
	for each estab where estab.regcod = vregcod no-lock:
	    for each contrato where contrato.datexp = vdata no-lock:
		if contrato.etbcod <> estab.etbcod
		then next.
		display contrato.etbcod
			contrato.clicod
			contrato.contnum
			contrato.dtinicial
			contrato.vltotal with frame f-con down centered.
	    end.
	end.
    end.
    if frame-index = 4
    then do:
	for each estab where estab.regcod = vregcod no-lock:
	    for each plani where plani.datexp = vdata no-lock:
		if plani.etbcod <> estab.etbcod
		then next.
		display plani.etbcod
			plani.numero
			plani.serie
			plani.pladat
			plani.platot
			plani.vlserv with frame f-pla down centered.
	    end.
	end.
    end.
    if frame-index = 5
    then do:
	for each produ where produ.datexp = vdata:
	    display produ.procod
		    produ.pronom
		    produ.catcod with frame f-pro down.
	end.

    end.
end.
