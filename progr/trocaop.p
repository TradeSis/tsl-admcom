/*----------------------------------------------------------------------------*/
/* /usr/admfin/trocaop.p                       Troca de Operador   - Compacto */
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
def var wresp as logical initial no label "Imprimir".
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


form  opera.opecod colon 18 opera.openom no-label colon 25
		 with frame fcab2 width 80 side-labels title " Novo Operador ".


for each opera where opera.opatual = yes:
    display opera.opecod colon 18 opera.openom no-label colon 25
		 with frame fcab1 width 80 side-labels title " Operador Atual ".

    update wopesenha colon 50 label "Senha" blank
	    with frame fcab1 width 80  side-labels.
    if opera.opesenha <> wopesenha
	then do:
	message "Senha invalida".
	pause.
	undo.
    end.

end.

if lastkey = keycode("F4") or
   lastkey = keycode("PF4") then return.

wtotal = 0.

L0:
repeat transaction:
    for each opera where opera.opatual = yes:
	wcodold = opera.opecod.
	wnomold = opera.openom.
    end.
    prompt-for opera.opecod with frame fcab2.
    wopecod = input opera.opecod.

    find opera using opera.opecod.
    display opera.openom with frame fcab2.

    output stream A to printer page-size 0.
    put stream A control "~033x0" "~017". /*draft e condensed*/
    put stream A
       "Troca de Operador e " at 1
	skip
       "Fechamento Parcial"
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

    end.   /* end da tecla f9 */

    output to printer page-size 0.
    put fill("-",48) format "x(48)"
    skip(1).
    output close.
    hide all.

    {confir.i 1 "Troca de Operador"}

    find opera using opera.opecod.
    display opera.openom with frame fcab2.
    opera.opatual = yes.
    for each opera where opera.opecod <> wopecod:
	opera.opatual = no.
    end.
    find opera where opera.opecod = wopecod.

    output to printer page-size 0.
    put "Op. " at 1
	wcodold
	"  "
	wnomold
	skip
	"Trocado por "  at 1
	skip
	"Op. " at 1
	opera.opecod
	"  "
	opera.openom
	skip
	fill("-",48) format "x(48)"
	skip(1).
    output close.
    message " Operador Trocado ".
end.
