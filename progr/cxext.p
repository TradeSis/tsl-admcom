/*----------------------------------------------------------------------------*/
/* admfin/cxext.p                             Movimento de caixa              */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 19/03/93 Daniel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}

define stream A.
define variab wclicod   like clien.clicod.
define buffer wclien    for  clien.
define buffer wcxmov    for  cxmov.
define variab wcxmvalor like cxmov.cxmvalor.
define variab wplavl    like cxmov.cxmvalor.
define variab wplavl1   like cxmov.cxmvalor.
define variab wtroco    like cxmov.cxmvalor.
define variab wevecod   like event.evecod.
define variab f as i.
define variab wresp1     as   logical format "Sim/Nao" initial yes.
define variab wopesenha like opera.opesenha.
define buffer ycxmov for cxmov.

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

repeat:
    prompt-for estab.etbcod colon 18 with frame f20.
    find estab using input estab.etbcod.
    assign estab.etbcod.
    find caixa where caixa.etbcod = estab.etbcod and
		     caixa.cxacod = 1.   /* CAIXA FIXO */

	create cxmov.
	cxmov.cxmdata = today.
	cxmov.etbcod = estab.etbcod.
	cxmov.cxacod = caixa.cxacod.
	display  cxmov.cxmdata colon 52 label "Data/Hora" with frame f20
				     width 80 side-label row 4 overlay.
	cxmov.cxmhora = string(TIME,"hh:mm:ss").
	display space(2) cxmov.cxmhora no-label with frame f20.
	update wevecod colon 18 with frame f20.

	if wevecod < 138 then undo .
	/*** SOMENTE OS EVENTOS EXTRAS */

	find event where event.evecod = wevecod.
	display event.evenom colon 25 no-label with frame f20.

	if event.eveoper = yes
	    then do:
	    for each opera where opera.opatual = yes:
		display opera.openom label "Operador" colon 18 format "x(19)"
			  with frame f20 side-labels.
		cxmov.opecod = opera.opecod.
	    end.
	end.
	find opera where cxmov.opecod = opera.opecod.
	if event.eveseg = yes
	    then do:
	    update wopesenha colon 52 label "Senha" blank with frame f20.
	    if opera.opesenha <> wopesenha
		then do:
		message "Senha invalida".
		pause.
		undo.
	    end.
	end.
	find moeda where moeda.moecod = caixa.moecod.
	cxmov.moecod = moeda.moecod.
	display cxmov.moecod colon 11
		moeda.moenom colon 19
		no-label with frame f30 width 80
		row 9 side-label no-hide down.
	update cxmov.moecod label "C.Moeda" colon 11 with frame f30.
	find moeda of cxmov.
	display moeda.moenom colon 19 no-label with frame f30.
	assign cxmov.cxmvalor = wplavl1.
	update cxmov.cxmvalor colon 40 with frame f30.
	if cxmov.moecod = "DOL"
	    then do:
	    find inddt where inddt.indcod = 35 and
		     inddt.indano = year(today) and
		     inddt.indmes = month(today).

	    cxmov.cxmvalor = inddt.indvalor[day(today)] * cxmov.cxmvalor.
	end.
	assign cxmov.evecod = event.evecod
	       cxmov.moecod = moeda.moecod.
	update cxmov.cxmobs colon 11 label "Obs" format "x(65)" with frame f30.
	if moeda.moetit
	    then
	    if event.evetit = yes
	    then do:
	    prompt-for clien.clicod validate(clien.clicod = 0 or
		       can-find(clien using input clien.clicod),
				       "Cliente nao Cadastrado")
					colon 10 label "Cliente"
					 with frame f55 row 16 width 78
					side-label overlay centered.
	    if input clien.clicod <> 0
		then do:
		find clien using input clien.clicod.
		display clien.clinom colon 23 no-label with frame f55.
	    end.
	    else do:
		create clien.
		prompt-for clien.clinom with frame f55.
		find last wclien.
		wclicod = wclien.clicod.
		{di.v 1 wclicod}
		assign clien.clicod = wclicod
		       clien.clinom.
		display clien.clicod with frame f55.
	    end.
	    create titulo.
	    assign titulo.titdtemi = cxmov.cxmdata
		   titulo.titdtven = today.
	    update titulo.titnum   colon 10
		titulo.titdtven validate(titdtven >= titdtemi,
					"Data de Vcto Invalida")
					  colon 32 label "Vencto"
		titulo.cobcod          colon 55 with frame f55.
	    find cobra of titulo.
	    display cobra.cobnom colon 62 no-label with frame f55.
	    if titulo.cobcod = 1
		then do:
		update titulo.bancod colon 10 label "Banco" with frame f55.
		find banco of titulo.
		display banco.bandesc colon 23 no-label with frame f55.
		update titulo.agecod
			    validate(titulo.agecod = "" or
			    can-find(agenc where
			    agenc.bancod = banco.bancod and
			    agenc.agecod = titulo.agecod),
			    "Agencia nao Cadastrada")
			    colon 10 label "Agencia" with frame f55.
		find agenc where agenc.bancod = banco.bancod and
				 agenc.agecod = input titulo.agecod no-error.
		if available agenc
		    then display agenc.agedesc colon 23 no-label with frame f55.
	    end.
	    assign  titulo.empcod    = wempre.empcod
		    titulo.titnat    = event.evenat
		    titulo.modcod    = event.modcod
		    titulo.titvlcob  = cxmov.cxmvalor
		    titulo.clifor    = clien.clicod
		    titulo.etbcod    = cxmov.etbcod
		    titulo.cxmdata   = cxmov.cxmdata
		    titulo.cxmhora   = cxmov.cxmhora
		    titulo.evecod    = cxmov.evecod
		    titulo.titobs[1] = cxmov.cxmobs.
	end.
	{confir.i 2 "Inclusao de Movimento de Caixa"}
	output stream A to printer page-size 0.
	put stream A control "~033x0" "~017". /*draft e condensed*/
	put stream A
	    event.evenom at 1
	    "OBS:" at 1
	    cxmov.cxmobs
	    "Oper: " at 1
	    opera.openom  format "x(15)"
	    "Data: " at 1
	    cxmov.cxmdata
	    "       Hora: "
	    cxmov.cxmhora
	    "Valor: (CR$)" at 1
	    cxmov.cxmvalor
	    skip
	    fill("-",48) format "x(48)"
	    skip(1).
	output stream A close.
	message  "Movimento do Caixa Incluido.".
end.
