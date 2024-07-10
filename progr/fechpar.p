/*----------------------------------------------------------------------------*/
/* /admfin/fechpar.p                           Fechamento Parcial  - Compacto */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 20/08/93 daniel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}

def stream A.
def var wvalor like cxmov.cxmvalor label "Valor Contado".
def var wdifer like cxmov.cxmvalor label "Dif.Fechamento".
def var wtotge like cxmov.cxmvalor label "Total Geral".
def var wtotge1 like cxmov.cxmvalor label "Total Geral".
def buffer ycxmov for cxmov.
def var wopecod like opera.opecod.
def var wtotal like cxmov.cxmvalor.
def var wcxvalor like cxmov.cxmvalor.
def var wplanot as logical.
def var wcodold like opera.opecod.
def var wnomold like opera.openom.
def var wopesenha like opera.opesenha.
def var wresp as logical initial no label "Imprimir" format "Sim/Nao".
/**/
L0:
repeat:
    message "Deseja Imprimir o Fechamento Parcial? " update wresp.
    if wresp then do:
    output stream A to printer page-size 0.
    put stream A control "~033x0" "~017". /*draft e condensed*/
    put stream A
       "Fechamento Parcial at 1"
	skip
	today at 1
	space(2)
	string(TIME,"hh:mm:ss")
	skip(1)
	"Moeda" at 1
	"CR$"   at 29
	"Dif.Cx." at 42
	skip
	fill("-",48) format "x(48)"
	skip.
    output stream A close.
    end.

    find inddt where inddt.indcod = 35 and
		     inddt.indano = year(today) and
		     inddt.indmes = month(today).

    for each moeda on endkey undo L0, return:
	display skip(1) moeda.moenom no-label colon 5 with frame f1.
	update wvalor colon 45 with frame f1 side-labels
			    width 80 title " Fechamento Parcial do Caixa ".
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
	    if event.evenat
		then wtotal = wtotal - wcxvalor. /* deb */
		else wtotal = wtotal + wcxvalor. /* cre */
	end.
	wdifer = wtotal - wvalor.
	display moeda.moenom               space(5)
		wtotal label "CR$" (total) space(5)
		wdifer             (total)
		with frame f3 width 80 down.
	if wresp then do:
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
	end.
	assign  wtotge  = wtotge  + wtotal
		wtotge1 = wtotge1 + wtotal
		wcxvalor = 0
		wtotal = 0
		wvalor = 0.
    end.
    if wresp then do:
    output stream A to printer page-size 0.
    put stream A control "~033x0" "~017". /*draft e condensed*/
    put stream A
	fill("-",48) format "x(48)"
	"Totais:" at 1
	wtotge at 17
	wtotge1 at 34
	skip.
    output stream A close.
    end.
    pause.
    hide frame f1.
    hide frame f3.
    if lastkey = keycode("F9") or
       lastkey = keycode("PF9") then do:

    if wresp then do:
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
    end.
    for each moeda on endkey undo L0, return:
	display skip(1) moeda.moenom no-label colon 5 with frame f1a.
	update wvalor colon 45 with frame f1a side-labels
		      width 80 title " Fechamento Parcial do Caixa sem Nota ".
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
	    if event.evenat
		then wtotal = wtotal - wcxvalor. /* deb */
		else wtotal = wtotal + wcxvalor. /* cre */
	end.
	wdifer = wtotal - wvalor.
	display moeda.moenom               space(5)
		wtotal label "CR$" (total) space(5)
		wdifer             (total)
		with frame f3a width 80 down.

	if wresp then do:
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
	end.
	assign  wtotge  = wtotge  + wtotal
		wtotge1 = wtotge1 + wtotal
		wcxvalor = 0
		wtotal = 0
		wvalor = 0.
    end.

    if wresp then do:
    output stream A to printer page-size 0.
    put stream A control "~033x0" "~017". /*draft e condensed*/
    put stream A
	fill("-",48) format "x(48)"
	"Totais:" at 1
	wtotge at 17
	wtotge1 at 34
	skip.
    output stream A close.
    end.
    pause.
    hide frame f1a.
    hide frame f3a.

    if wresp then do:
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
    end.
    for each moeda on endkey undo L0, return:
	display skip(1) moeda.moenom no-label colon 5 with frame f1b.
	update wvalor colon 45 with frame f1b side-labels
			  width 80 title " Fechamento Parcial do Caixa Total ".
	L3:
	for each cxmov where cxmov.cxmdata = today and
			     cxmov.moecod = moeda.moecod:

	    find event where event.evecod = cxmov.evecod.
	    if evezer then next L3.
	    wcxvalor = cxmov.cxmvalor.
	    if moecod = "DOL"
	      then
	      wcxvalor = wcxvalor / inddt.indvalor[day(today)].
	    if event.evenat
		then wtotal = wtotal - wcxvalor. /* deb */
		else wtotal = wtotal + wcxvalor. /* cre */
	end.
	wdifer = wtotal - wvalor.
	display moeda.moenom               space(5)
		wtotal label "CR$" (total) space(5)
		wdifer             (total)
		with frame f3b width 80 down.

	if wresp then do:
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
	end.
	assign  wtotge = wtotge + wtotal
		wtotge1 = wtotge1 + wtotal
		wcxvalor = 0
		wtotal = 0
		wvalor = 0.
    end.

    if wresp then do:
    output stream A to printer page-size 0.
    put stream A control "~033x0" "~017". /*draft e condensed*/
    put stream A
	fill("-",48) format "x(48)"
	"Totais:" at 1
	wtotge at 17
	wtotge1 at 34
	skip.
    output stream A close.
    end.
    end.   /* end da tecla f9 */
end.
