/*----------------------------------------------------------------------------*/
/* /admfin/entrada.p                          Abertura do caixa               */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 23/08/93 Daniel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}

def stream A.
def var wopecod like opera.opecod.
def var wdatapro as date.
def var wtaxado as i.
def var wfuncx like cxmov.cxmvalor.

/**/
message setbcod.
find caixa where caixa.etbcod = setbcod and caixa.cxacod = 1.
if caixa.entrada
    then do:
	bell.
	display " JA' FOI EXECUTADA A ABERTURA DE LOJA "
		skip(1)
		"            EXECUCAO NEGADA.          "
		with frame f1 row 10 centered.
	pause.
	return.
    end.

    if caixa.cxdata <> today
    then do:
	bell.
	display " DATA DO SISTEMA INCOMPATIVEL "
		skip(1)
		"       EXECUCAO NEGADA        "
		with frame f1a row 10 centered.
	pause.
	return.
    end.

/**/

repeat transaction:
    if caixa.entrada then leave.
    form wdatapro   label "Data Processo"      colon 20
	 inddt.indvalor[day(today)] label "Taxa do Dolar"
	 format ">>>,>>9.99" colon 20
	 wfuncx     label "Fundo de Caixa"     colon 20
	 credias[1] label "Che.Pre 1 Pz/Mult." colon 20
	 creperc[1] at 25 no-label
	 credias[2] label "Che.Pre 2 Pz/Mult." colon 20
	 creperc[2] at 25 no-label
	 credias[3] label "Che.Pre 3 Pz/Mult." colon 20
	 creperc[3] at 25 no-label
	 creperc[4] label "Entrada Che.Pre(%)" colon 20
	 opera.opecod colon 20 opera.openom no-label colon 30
	 estab.estcota colon 20
	 estab.vencota colon 20
	 with side-labels frame f2 width 80 title " Abertura de Loja ".

    find crepl where crepl.crecod = 99 no-error.
    if not available crepl
    then do:
	create crepl.
	assign crecod = 99.
    end.

    find indic where indic.indcod = 35 no-error.
    if not available indic
    then
	run indin.p.

    find inddt where inddt.indcod = indic.indcod and
		     inddt.indano = year(today) and
		     inddt.indmes = month(today) no-error.

    if not available inddt
    then do:
	create inddt.
	assign inddt.indcod = indic.indcod
	       inddt.indmes = month(today)
	       inddt.indano = year(today).

    end.
    wdatapro = today.
    display wdatapro with frame f2.
    update inddt.indvalor[day(today)]
	   wfuncx
	   credias[1]
	   creperc[1]
	   credias[2]
	   creperc[2]
	   credias[3]
	   creperc[3]
	   creperc[4]
	   with frame f2.
    assign credias[4] = 0.
    prompt-for opera.opecod with frame f2.
    wopecod = input opera.opecod.
    find opera using opera.opecod.
    display opera.openom with frame f2.
    opera.opatual = yes.
    for each opera where opera.opecod <> wopecod:
	opera.opatual = no.
    end.

    create cxmov.
    assign cxmov.cxmvalor = wfuncx
	   cxmov.cxacod   = 1
	   cxmov.cxmdata  = today
	   cxmov.cxmhora  = string(TIME,"hh:mm:ss")
	   cxmov.etbcod   = setbcod
	   cxmov.evecod   = 19           /* abertura de caixa */
	   cxmov.moecod   = "CRU"
	   cxmov.opecod   = wopecod.

    find estab where estab.etbcod = setbcod.
    update estab.estcota estab.vencota with frame f2.

    {confir.i 1 "Abertura de Loja"}
    find opera using opera.opecod.
    caixa.entrada = yes.
    output stream A to printer page-size 0.
    put stream A control "~033x0" "~017". /*draft e condensed*/
    put stream A skip
	"Abertura de Loja" at 1
	skip
	today
	space(2)
	string(TIME,"hh:mm:ss")
	skip
	"Op. " at 1
	opera.opecod
	space(2)
	opera.openom
	skip
	"Fundo de Caixa:" at 1
	wfuncx
	skip
	fill("-",48) format "x(48)"
	skip(1).
   output stream A close.
   hide frame f2.
end.
