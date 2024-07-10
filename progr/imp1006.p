/***************************************************************************
** Programa        : impmatb4.p
** Objetivo        : Importacao de Dados para a matriz
** Ultima Alteracao: 19/09/95
****************************************************************************/


def stream log.
def stream tela.
def var n-conta as integer.
def var vmiccod     like micro.miccod.
def var v-dtini as date init today                                 no-undo.
def var v-dtfin as date init today                                 no-undo.
def var vdata       as date                                      no-undo.


def var vtotcli     as   int.
def var vtotcont    as   int.
def var vtotparc    as   int.
def var x as int.
def var vtotpag     like titulo.titvlpag.
def var vtotvl      like contrato.vltotal.
def var vtitpg      as   int.
DEF VAR ARQini AS INT.
DEF VAR ARQfin AS INT.

UPDATE ARQini LABEL "Informe o numero do arquivo inicial"
	with side-label .
UPDATE ARQfin LABEL "Informe o numero do arquivo final".
def var vtitsit     like titulo.titsit.
def var vtitdtpag   like titulo.titdtpag.
def var valt as log.

display " Favor nao desligar. Acertando valores "  at 20
	with frame favi centered row 2 color
			blink-red/cyan width 81 no-box.


pause 0 before-hide.
output stream tela to terminal.
output stream log to impcri.log page-size 64.
do x = arqini to arqfin:
input from value("..\cpd\tit" + string(x,"999") + ".d") no-echo.
output  to value("..\log\lg" + string(x,"999") + ".log").
put /*stream log*/ x skip.

repeat with frame ftitulo:

	prompt-for
	    titulo.empcod
	    titulo.modcod
	    titulo.CliFor
	    titulo.titnum
	    titulo.titpar
	    titulo.titnat
	    titulo.etbcod
	    ^
	    ^
	    titulo.titvlcob
	    ^
	    ^
	    ^
	    ^
	    ^
	    ^
	    titulo.titdtpag
	    ^
	    titulo.titjuro
	    titulo.titvlpag
	    ^
	    ^
	    ^
	    ^
	    ^
	    titulo.titsit
	    ^
	    ^
	    ^
	    ^
	    ^
	    ^
	    ^
	    ^
	    titulo.datexp
	    ^
	    WITH FRAME ftitulo NO-LABELS no-validate.

    find titulo where
	 titulo.empcod = input frame ftitulo titulo.empcod and
	 titulo.titnat = input frame ftitulo titulo.titnat and
	 titulo.modcod = input frame ftitulo titulo.modcod and
	 titulo.etbcod = input frame ftitulo titulo.etbcod and
	 titulo.clifor = input frame ftitulo titulo.clifor and
	 titulo.titnum = input frame ftitulo titulo.titnum and
	 titulo.titpar = input frame ftitulo titulo.titpar no-error.
    if  not available titulo
    then do:
	create titulo.
	ASSIGN titulo.empcod    = input frame ftitulo titulo.empcod
	       titulo.modcod    = input frame ftitulo titulo.modcod
	       titulo.CliFor    = input frame ftitulo titulo.CliFor
	       titulo.titnum    = input frame ftitulo titulo.titnum
	       titulo.titpar    = input frame ftitulo titulo.titpar
	       titulo.titnat    = input frame ftitulo titulo.titnat
	       titulo.etbcod    = input frame ftitulo titulo.etbcod
	       titulo.titvlcob  = input frame ftitulo titulo.titvlcob
	       titulo.titdtpag  = input frame ftitulo titulo.titdtpag
	       titulo.titjuro   = input frame ftitulo titulo.titjuro
	       titulo.titvlpag  = input frame ftitulo titulo.titvlpag
	       titulo.titsit    = input frame ftitulo titulo.titsit
	       titulo.datexp    = input frame ftitulo titulo.datexp.
     end.
     else do:
     def buffer btitulo for titulo.
    display stream tela
	    x label "Arq"             n-conta label "Qtd"        colon 60
	    titulo.datexp                                        colon 15
	    titulo.titvlcob @ btitulo.titvlcob label "Cob Antes" colon 15
	    titulo.titvlpag @ btitulo.titvlpag label "pag Antes" colon 50
	    with frame messa01 row 6 no-box no-hide side-label
			centered color blue/cyan .
	titulo.titvlcob = input frame ftitulo titulo.titvlcob.
	valt = no.
	if titulo.titvlpag <> input frame ftitulo titulo.titvlpag and
	   titulo.titsit   =  "PAG"
	then
	    assign
		titulo.titdtpag  = input frame ftitulo titulo.titdtpag
		titulo.titvlpag  = input frame ftitulo titulo.titvlpag
		titulo.titjuro   = input frame ftitulo titulo.titjuro
		titulo.titsit    = input frame ftitulo titulo.titsit
		titulo.datexp    = input frame ftitulo titulo.datexp
		valt = yes.

	if  input frame ftitulo titulo.titdtpag <> ? and
	    input frame ftitulo titulo.titvlpag > 0 and
	    titulo.titdtpag   =  ?
	then do:
		assign
		       titulo.titdtpag  = input frame ftitulo titulo.titdtpag
		       titulo.titjuro   = input frame ftitulo titulo.titjuro
		       titulo.titvlpag  = input frame ftitulo titulo.titvlpag
		       titulo.titsit    = input frame ftitulo titulo.titsit
		       titulo.datexp    = input frame ftitulo titulo.datexp.
	end.
    end.
    n-conta = n-conta + 1.
    display stream tela
	    x            n-conta
	    titulo.datexp
	    titulo.titvlcob label "Cob Depois" colon 15
	    titulo.titvlpag label "Pag Depois" colon 50
	    with frame messa01 row 6 no-box no-hide
			centered color blue/cyan .
end.
input close.



do:
    input from value("f:..\cpd\ctr" + string(x,"999") + ".d") no-echo.
    n-conta = 0.
    repeat:
	prompt-for contrato with no-validate.
	find contrato where
	     contrato.contnum = input contrato.contnum no-error.

	if  not available contrato
	then create contrato.
	    ASSIGN
		contrato.contnum   = input contrato.contnum
		contrato.clicod    = input contrato.clicod
		contrato.autoriza  = input contrato.autoriza
		contrato.dtinicial = input contrato.dtinicial
		contrato.etbcod    = input contrato.etbcod
		contrato.banco     = input contrato.banco
		contrato.vltotal   = input contrato.vltotal
		contrato.vlentra   = input contrato.vlentra
		contrato.situacao  = input contrato.situacao
		contrato.indimp    = input contrato.indimp
		contrato.lotcod    = input contrato.lotcod
		contrato.crecod    = input contrato.crecod
		contrato.datexp    = input contrato.datexp
		contrato.vlfrete   = input contrato.vlfrete.
	assign
	    vtotcont = vtotcont + 1
	    vtotvl   = vtotvl   + contrato.vltotal.
	n-conta = n-conta + 1.
	display stream tela "Aguarde... Importando Contratos... " n-conta "   "
		contrato.datexp
		with frame messa02 centered color blue/cyan no-label
			    no-box row 10.
    end.
    input close.
end.
n-conta = 0.
end.
bell.
bell.
pause 0.
