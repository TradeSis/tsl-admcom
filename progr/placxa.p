def input parameter recpla  as recid.


def buffer wcxmov    for  cxmov.
def buffer ycxmov for cxmov.

def var wcxmvalor like cxmov.cxmvalor.
def var wevecod like event.evecod.
def var controle as i.
def var wplavl    like cxmov.cxmvalor.
def var wplavl1   like cxmov.cxmvalor.
def var wtroco    like cxmov.cxmvalor.
def var f as i.
def var wresp1     as   logical format "Sim/Nao" initial yes.

find plani where recid(plani) = recpla.

find caixa where caixa.etbcod = plani.etbcod and
		 caixa.cxacod = 1.   /* CAIXA FIXO */
assign wplavl1 = plani.platot
      controle = 1.

repeat on endkey undo:
	create cxmov.
	cxmov.cxmdata = today.
	cxmov.movndc = plani.movndc.
	cxmov.etbcod = plani.etbcod.
	cxmov.cxacod = caixa.cxacod.
	pause 0.
	display cxmov.cxmdata colon 14 label "Data/Hora"
		with overlay frame f20 width 80 side-label row 14 1 down
		color white/cyan.
	cxmov.cxmhora = string(TIME,"hh:mm:ss").
	display cxmov.cxmhora colon 35 no-label
		with overlay frame f20.
	prompt-for event.evecod colon 14
	       with overlay frame f20.
	wevecod = input event.evecod .
	if wevecod < 90 or wevecod > 138
	then undo.

	find event where event.evecod = wevecod.
	cxmov.nota = if plani.notnum <> 0
		     then yes
		     else no.
	display event.evenom colon 20 no-label
		with overlay frame f20.
	pause 0.     /*
	if event.evecod = 94
	then do:
	    prompt-for vende.vencod label "Cod.Func" colon 14
			with overlay frame funcio row 17
			centered side-label overlay .
	    find vende using input vende.vencod.
	    display vende.vennom no-label colon 25
		    with overlay frame funcio.
	    cxmov.vencod = input vende.vencod.
	end.         */
	if event.eveoper = yes
	then do:
	    for each opera where opera.opatual = yes:
		display opera.openom label "Op" colon 55 format "x(19)"
			with overlay frame f20 .
		cxmov.opecod = opera.opecod.
	    end.
	end.
	find opera where cxmov.opecod = opera.opecod.
	find moeda where moeda.moecod = caixa.moecod.
	cxmov.moecod = moeda.moecod.
	display cxmov.moecod colon 11
		moeda.moenom colon 19
		no-label with overlay frame f30 width 80 color blank/cyan
		row 18 side-label 1 down.
	update cxmov.moecod label "C.Moeda" colon 11 with overlay frame f30.
	find moeda of cxmov.
	display moeda.moenom colon 19 no-label with overlay frame f30.
	assign cxmov.cxmvalor = wplavl1.
	update cxmov.cxmvalor colon 40 with overlay frame f30.

	if cxmov.moecod = "CHA"
	then f = 1.
	else
	    if cxmov.moecod = "CHB"
	    then f = 2.
	    else
		if cxmov.moecod = "CHC"
		then f = 3.
		else f = 4.

	if cxmov.moecod = "DOL"
	then do:
	    find inddt where inddt.indcod = 35 and
		     inddt.indano = year(today) and
		     inddt.indmes = month(today).

	    cxmov.cxmvalor = inddt.indvalor[day(today)] * cxmov.cxmvalor.
	end.

	if controle = 1
	then do:
	    find crepl where crepl.crecod = 99.
	    if cxmov.cxmvalor < ((creperc[4] / 100) * wplavl1)
	    then undo .
	end.
	assign wplavl = cxmov.cxmvalor.
	assign wplavl1 = (wplavl1 - wplavl).
	if wplavl1 >= 0
	then
	    display wplavl1 label "Saldo" colon 62 with overlay frame f30.
	assign cxmov.evecod = event.evecod
	       cxmov.moecod = moeda.moecod.
	pause 0.

	if wplavl1 < 0
	then do:
	    if moeda.moetroco
	    then do:
		bell. bell. bell.
		assign wtroco = wplavl1 * -1.
		display "Valor do Troco - Cr$ " wtroco no-label
		       with overlay frame ftro row 18  color yellow/red
		       column 35 title " Troco " centered.

		create ycxmov.
		assign ycxmov.cxmvalor  = wtroco
		       ycxmov.cxacod    = cxmov.cxacod
		       ycxmov.cxmdata   = cxmov.cxmdata.
		pause 3 no-message.
		assign ycxmov.cxmhora   = string(TIME,"hh:mm:ss")
		       ycxmov.etbcod    = cxmov.etbcod
		       ycxmov.opecod    = cxmov.opecod
		       ycxmov.moecod    = "CRU"
		       ycxmov.evecod    = 86   /*** troco ***/
		       wplavl1 = 0.

		assign cxmov.cxmvalor = cxmov.cxmvalor - ycxmov.cxmvalor.

	    end.
	    else do:
		message "Este Tipo de Moeda nao permite Troco.".
		wplavl1 = wplavl1 + cxmov.cxmvalor.
		pause.
		undo .
	    end.
	end.
	if moeda.moecod = "CHV" or moeda.moecod = "CHA" or
	   moeda.moecod = "CHB" or moeda.moecod = "CHC" or
	   moeda.moecod = "VAL" or moeda.moecod = "CHD"
	then do:
	    message "Imprimir autenticacao ?"
	    update wresp1.
	    if wresp1
	    then do:    /*
		output stream A to printer page-size 0.
		put stream A control "~033x0" "~017". /*draft e condensed*/
		put stream A
		    opera.openom  format "x(15)" at 1
		    space(1)
		    plani.movndc
		    space(1)
		    cxmov.cxmvalor
		    space(2)
		    vende.vennom  format "x(15)"
		    cxmov.cxmhora
		    space(2)
		    cxmov.cxmdata.
		put stream A control "~015".
		output stream A close.  */
	    end.
	end.
	controle = controle + 1.
	if wplavl1 = 0
	then leave.
end.
{confir.i 2 "Inclusao de Movimento de Caixa"}
if plani.notnum <> 0
then do:
    find crepl where crepl.crecod = plani.crecod.
	    /*
	    output stream A to printer page-size 0.
	    put stream A control "~033x0" "~017". /*draft e condensed*/
	    put stream A
		"P.No: " at 1
		plani.movndc
		"           Mod: "
		crepl.crenom
		"Oper: " at 1
		opera.openom  format "x(15)"
		" Vend: "
		vende.vennom  format "x(15)"
		"Data: " at 1
		cxmov.cxmdata
		"       Hora: "
		cxmov.cxmhora
		"Valor Total: (CR$)" at 1
		plani.platot
		skip
		fill("-",48) format "x(48)"
		skip(1).
	    output stream A close. */
end.
hide frame f20 no-pause.
hide frame f30 no-pause.
hide frame ftro no-pause.
