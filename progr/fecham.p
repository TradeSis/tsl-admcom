/*----------------------------------------------------------------------------*/
/* admfin/fecham.p                            Fechamento Caixa     - Compacto */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 20/08/93 Daniel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}

def stream A.
def var wopecod like opera.opecod.
def var wtotal like cxmov.cxmvalor.
def var wcxvalor like cxmov.cxmvalor.
def var wvalor like cxmov.cxmvalor label "Valor Contado".
def var wdifer like cxmov.cxmvalor label "Dif.Fechamento"
    format "->>>,>>>,>>>,>>9.99".
def var wtotge like cxmov.cxmvalor label "Total Geral".
def var wtotge1 like cxmov.cxmvalor label "Total Geral".
def var wopesenha like opera.opesenha.
def var wplanot as logical.
def buffer ycxmov for cxmov.

/**/

find caixa where caixa.etbcod = setbcod and caixa.cxacod = 1.
if not caixa.entrada
    then do:
	bell.
	display " NAO FOI EXECUTADA A ABERTURA DE LOJA "
		skip(1)
		"            EXECUCAO NEGADA.          "
		with frame fent row 10 centered.
	pause.
	return.
    end.

/**/

L0:
repeat transaction:
    for each opera where opera.opatual = yes:
	wopecod = opera.opecod.
    end.
    find opera where opera.opecod = wopecod.
    display opera.openom colon 18 with frame fsenha.
    update wopesenha colon 50 label "Senha" blank
	    with frame fsenha width 80  side-labels.
    if opera.opesenha <> wopesenha
	then do:
	message "Senha invalida".
	pause.
	hide frame fsenha.
	undo.
    end.
    hide frame fsenha.

    find FIRST inddt.

    output stream A to printer page-size 0.
    put stream A control "~033x0" "~017". /*draft e condensed*/
    put stream A
       "Fechamento do Caixa. " at 1
	skip
	today at 1
	space(2)
	string(TIME,"hh:mm:ss")
	"Op. " at 1
	opera.opecod
	space(2)
	opera.openom
	skip
	"Cotacao Dolar:" at 1
	inddt.indvalor[day(today)]
	skip(1)
	"Moeda" at 1
	"CR$"   at 29
	"Dif.Cx." at 42
	skip
	fill("-",48) format "x(48)"
	skip.
    output stream A close.


    for each moeda on endkey undo L0, return:
	display skip(1) moeda.moenom no-label colon 5 with frame f1.
	update wvalor colon 45 with frame f1 side-labels
			    width 80 title " Fechamento do Caixa ".
	L1:
	for each cxmov where cxmov.cxmdata = today and
			     cxmov.moecod = moeda.moecod and
			     cxmov.nota = yes:

	    find event where event.evecod = cxmov.evecod.
	    if evezer then next L1.
	    wcxvalor = cxmov.cxmvalor.
	    if moecod = "DOL"
	      then
	      wcxvalor = wcxvalor / inddt.indvalor[day(today)].

	    if event.evenat then do:
		if moecod = "DOL" then
		    wtotal = wtotal - (wcxvalor * inddt.indvalor[day(today)]).
		else
		    wtotal = wtotal - wcxvalor. /* deb */
	    end.
	    else do:
		if moecod = "DOL" then
		    wtotal = wtotal + (wcxvalor * inddt.indvalor[day(today)]).
		else
		    wtotal = wtotal + wcxvalor. /* cre */
	    end.
	end.
	wdifer = wtotal - wvalor.
	display moeda.moenom               space(5)
		wtotal label "CR$" (total) space(5)
		wdifer             (total)
		with frame f3 width 80 down.

	output stream A to printer page-size 0.
	put stream A control "~033x0" "~017". /*draft e condensed*/
	put stream A
	    moeda.moenom
	    space(1)
	    wtotal
	    space(2)
	    wdifer
	    skip.
	output stream A close.

	create cxmov.
	assign cxmov.cxmvalor = wdifer
	       cxmov.cxacod   = 1
	       cxmov.cxmdata  = today
	       cxmov.cxmhora  = string(TIME,"hh:mm:ss")
	       cxmov.etbcod   = setbcod
	       cxmov.evecod   = 51
	       cxmov.moecod   = moeda.moecod
	       cxmov.opecod   = wopecod.
	pause(2).

	if moeda.moecod = "DOL"
	  then
	  wtotal = wtotal * inddt.indvalor[day(today)].

	create ycxmov.
	assign ycxmov.cxmvalor = wtotal
	       ycxmov.cxacod   = 1
	       ycxmov.cxmdata  = today
	       ycxmov.cxmhora  = string(TIME,"hh:mm:ss")
	       ycxmov.etbcod   = setbcod
	       ycxmov.evecod   = 27
	       ycxmov.moecod   = moeda.moecod
	       ycxmov.opecod   = wopecod.

	assign  wtotge  = wtotge  + wtotal
		wtotge1 = wtotge1 + wtotal
		wcxvalor = 0
		wtotal = 0
		wvalor = 0.
    end.

    output stream A to printer page-size 0.
    put stream A control "~033x0" "~017". /*draft e condensed*/
    put stream A
	fill("-",48) format "x(48)"
	"Totais:" at 1
	wtotge at 17
	wtotge1 at 34
	skip.
    output stream A close.
    wtotge = 0.
    wtotge1 = 0.
    pause.
    hide frame f1.
    hide frame f3.
    if lastkey = keycode("F9") or
       lastkey = keycode("PF9") then do:

    output stream A to printer page-size 0.
    put stream A control "~033x0" "~017". /*draft e condensed*/
    put stream A
	skip(1)
	"Moeda" at 1
	"CR$"   at 29
	"Dif.Cx." at 42
	skip
	fill("-",48) format "x(48)"
	skip.
    output stream A close.
    for each moeda on endkey undo L0, return:
	display skip(1) moeda.moenom no-label colon 5 with frame f1a.
	update wvalor colon 45 with frame f1a side-labels
			       width 80 title " Fechamento do Caixa sem Nota ".
	L2:
	for each cxmov where cxmov.cxmdata = today and
			     cxmov.moecod = moeda.moecod and
			     cxmov.nota = no:

	    find event where event.evecod = cxmov.evecod.
	    if evezer then next L2.
	    wcxvalor = cxmov.cxmvalor.
	    if moecod = "DOL"
	      then
	      wcxvalor = wcxvalor / inddt.indvalor[day(today)].


	    if event.evenat then do:
		if moecod = "DOL" then
		    wtotal = wtotal - (wcxvalor * inddt.indvalor[day(today)]).
		else
		    wtotal = wtotal - wcxvalor. /* deb */
	    end.
	    else do:
		if moecod = "DOL" then
		    wtotal = wtotal + (wcxvalor * inddt.indvalor[day(today)]).
		else
		    wtotal = wtotal + wcxvalor. /* cre */
	    end.

	end.
	wdifer = wtotal - wvalor.
	display moeda.moenom               space(5)
		wtotal label "CR$" (total) space(5)
		wdifer             (total)
		with frame f3a width 80 down.

	output stream A to printer page-size 0.
	put stream A control "~033x0" "~017". /*draft e condensed*/
	put stream A
	    moeda.moenom
	    space(1)
	    wtotal
	    space(2)
	    wdifer
	    skip.
	output stream A close.

	create cxmov.
	assign cxmov.cxmvalor = wdifer
	       cxmov.cxacod   = 1
	       cxmov.cxmdata  = today
	       cxmov.cxmhora  = string(TIME,"hh:mm:ss")
	       cxmov.etbcod   = setbcod
	       cxmov.evecod   = 60
	       cxmov.moecod   = moeda.moecod
	       cxmov.opecod   = wopecod.
	pause(2).

	if moeda.moecod = "DOL"
	  then
	  wtotal = wtotal * inddt.indvalor[day(today)].

	create ycxmov.
	assign ycxmov.cxmvalor = wtotal
	       ycxmov.cxacod   = 1
	       ycxmov.cxmdata  = today
	       ycxmov.cxmhora  = string(TIME,"hh:mm:ss")
	       ycxmov.etbcod   = setbcod
	       ycxmov.evecod   = 35
	       ycxmov.moecod   = moeda.moecod
	       ycxmov.opecod   = wopecod.

	assign  wtotge  = wtotge  + wtotal
		wtotge1 = wtotge1 + wtotal
		wcxvalor = 0
		wtotal = 0
		wvalor = 0.
    end.

    output stream A to printer page-size 0.
    put stream A control "~033x0" "~017". /*draft e condensed*/
    put stream A
	fill("-",48) format "x(48)"
	"Totais:" at 1
	wtotge at 17
	wtotge1 at 34
	skip.
    output stream A close.
    wtotge = 0.
    wtotge1 = 0.
    pause.
    hide frame f1a.
    hide frame f3a.
    output stream A to printer page-size 0.
    put stream A control "~033x0" "~017". /*draft e condensed*/
    put stream A
	skip(1)
	"Moeda" at 1
	"CR$"   at 29
	"Dif.Cx." at 42
	skip
	fill("-",48) format "x(48)"
	skip.
    output stream A close.
    for each moeda on endkey undo L0, return:
	display skip(1) moeda.moenom no-label colon 5 with frame f1b.
	update wvalor colon 45 with frame f1b side-labels
			       width 80 title " Fechamento do Caixa Total ".
	L3:
	for each cxmov where cxmov.cxmdata = today and
			     cxmov.moecod = moeda.moecod:

	    find event where event.evecod = cxmov.evecod.
	    if evezer then next L3.
	    wcxvalor = cxmov.cxmvalor.
	    if moecod = "DOL"
	      then
	      wcxvalor = wcxvalor / inddt.indvalor[day(today)].


	    if event.evenat then do:
		if moecod = "DOL" then
		    wtotal = wtotal - (wcxvalor * inddt.indvalor[day(today)]).
		else
		    wtotal = wtotal - wcxvalor. /* deb */
	    end.
	    else do:
		if moecod = "DOL" then
		    wtotal = wtotal + (wcxvalor * inddt.indvalor[day(today)]).
		else
		    wtotal = wtotal + wcxvalor. /* cre */
	    end.


	end.
	wdifer = wtotal - wvalor.
	display moeda.moenom               space(5)
		wtotal label "CR$" (total) space(5)
		wdifer             (total)
		with frame f3b width 80 down.

	output stream A to printer page-size 0.
	put stream A control "~033x0" "~017". /*draft e condensed*/
	put stream A
	    moeda.moenom
	    space(1)
	    wtotal
	    space(2)
	    wdifer
	    skip.
	output stream A close.

	create cxmov.
	assign cxmov.cxmvalor = wdifer
	       cxmov.cxacod   = 1
	       cxmov.cxmdata  = today
	       cxmov.cxmhora  = string(TIME,"hh:mm:ss")
	       cxmov.etbcod   = setbcod
	       cxmov.evecod   = 78
	       cxmov.moecod   = moeda.moecod
	       cxmov.opecod   = wopecod.
	pause(2).

	if moeda.moecod = "DOL"
	  then
	  wtotal = wtotal * inddt.indvalor[day(today)].

	create ycxmov.
	assign ycxmov.cxmvalor = wtotal
	       ycxmov.cxacod   = 1
	       ycxmov.cxmdata  = today
	       ycxmov.cxmhora  = string(TIME,"hh:mm:ss")
	       ycxmov.etbcod   = setbcod
	       ycxmov.evecod   = 43
	       ycxmov.moecod   = moeda.moecod
	       ycxmov.opecod   = wopecod.

	assign  wtotge = wtotge + wtotal
		wtotge1 = wtotge1 + wtotal
		wcxvalor = 0
		wtotal = 0
		wvalor = 0.
    end.


    output stream A to printer page-size 0.
    put stream A control "~033x0" "~017". /*draft e condensed*/
    put stream A
	fill("-",48) format "x(48)"
	"Totais:" at 1
	wtotge at 17
	wtotge1 at 34
	skip.
    output stream A close.
    wtotge = 0.
    wtotge1 = 0.
    output to printer page-size 0.
    put fill("-",48) format "x(48)"
    skip(1).
    wtotal = 0.
    wtotge = 0.
    put "Totais dos Eventos:" at 1
	skip(1).
    for each event where event.evecod > 90:
	for each cxmov where cxmov.evecod = event.evecod and cxmdata = today:
	    if event.evecod > 90 and event.evecod < 135
		then wtotge = wtotge + cxmov.cxmvalor.
	    wtotal = wtotal + cxmov.cxmvalor.
	end.
	put event.evenom
	    " "
	    wtotal
	    skip.
	wtotal = 0.
    end.
    put skip(1)
	"Faturamento Total "
	wtotge
	skip(1)
	fill("-",48) format "x(48)"
	skip(1)
	"Relacao de Cheques a Vista"
	skip(1).
    for each cxmov where cxmov.cxmdata = today and
			 cxmov.moecod = "CHV"  and
			 cxmov.evecod > 90 and cxmov.evecod < 135:
	put "Pla.No: " at 1
	    cxmov.movndc
	    space(5)
	    "CHV"
	    cxmov.cxmvalor
	    skip.
    end.
    put skip(1)
	"Relacao de Cheques Pre-Datados"
	skip(1).
    for each titulo where titulo.titdtemi = today and
			  titulo.modcod = "CHE" by titdtven:
	find banco of titulo.
	put "No: " at 1
	    titulo.titnum
	    space(2)
	    banco.bandesc
	    skip
	    "Valor: "
	    titulo.titvlcob
	    space(5)
	    "Venc: "
	    titdtven
	    skip.
    end.
    put fill("-",48) format "x(48)"
	skip(1).
    output close.

    end.   /* end da tecla f9 */

    {confir.i 1 "Fechamento do Caixa"}
    caixa.entrada = no.

/**/

    def var wdt as date.
    find caixa where caixa.etbcod = setbcod and caixa.cxacod = 1.
    wdt = today.
    for each dtextra:
      do while (wdt = caixa.cxdata or weekday(wdt) = 1 or wdt = dtextra.exdata):
	wdt = wdt + 1.
      end.
    end.
    caixa.cxdata = wdt.

/* transferencia de dados */

/**/
    message " Caixa Fechado ".
end.
