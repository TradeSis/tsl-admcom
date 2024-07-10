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

pause 0 before-hide.
output stream tela to terminal.
output stream log to impcri.log page-size 64.
do x = arqini to arqfin:
input from value("..\cpd\tit" + string(x,"999") + ".d") no-echo.
output  to value("..\log\log" + string(x,"999") + ".log").
put /*stream log*/ x skip.

repeat with frame ftitulo:
    prompt-for
	    titulo with no-validate
	    with frame ftitulo.
    assign
	vtitsit   = input titulo.titsit
	vtitdtpag = input titulo.titdtpag
	vtotparc  = vtotparc + 1
	vtotpag   = vtotpag  + input titulo.titvlpag
	vtitpg    = vtitpg   + (if input titulo.titsit = "PAG"
				then 1
				else 0).
    display stream tela
	    input titulo.titvlcob
	    input titulo.titvlpag
	    with frame fff column 30.

    find titulo where
	 titulo.empcod = input titulo.empcod and
	 titulo.titnat = input titulo.titnat and
	 titulo.modcod = input titulo.modcod and
	 titulo.etbcod = input titulo.etbcod and
	 titulo.clifor = input titulo.clifor and
	 titulo.titnum = input titulo.titnum and
	 titulo.titpar = input titulo.titpar no-error.
    if  not available titulo
    then do:
	create titulo.
	ASSIGN titulo.empcod    = input titulo.empcod
	       titulo.modcod    = input titulo.modcod
	       titulo.CliFor    = input titulo.CliFor
	       titulo.titnum    = input titulo.titnum
	       titulo.titpar    = input titulo.titpar
	       titulo.titnat    = input titulo.titnat
	       titulo.etbcod    = input titulo.etbcod
	       titulo.titdtemi  = input titulo.titdtemi
	       titulo.titdtven  = input titulo.titdtven
	       titulo.titvlcob  = input titulo.titvlcob
	       titulo.titdtdes  = input titulo.titdtdes
	       titulo.titvldes  = input titulo.titvldes
	       titulo.titvljur  = input titulo.titvljur
	       titulo.cobcod    = input titulo.cobcod
	       titulo.bancod    = input titulo.bancod
	       titulo.agecod    = input titulo.agecod
	       titulo.titdtpag  = input titulo.titdtpag
	       titulo.titdesc   = input titulo.titdesc
	       titulo.titjuro   = input titulo.titjuro
	       titulo.titvlpag  = input titulo.titvlpag
	       titulo.titbanpag = input titulo.titbanpag
	       titulo.titagepag = input titulo.titagepag
	       titulo.titchepag = input titulo.titchepag
	       titulo.titobs[1] = input titulo.titobs[1]
	       titulo.titobs[2] = input titulo.titobs[2]
	       titulo.titsit    = if input titulo.titsit = "IMP"
				  then "LIB"
				  else input titulo.titsit
	       titulo.titnumger = input titulo.titnumger
	       titulo.titparger = input titulo.titparger
	       titulo.cxacod    = input titulo.cxacod
	       titulo.evecod    = input titulo.evecod
	       titulo.cxmdata   = input titulo.cxmdata
	       titulo.cxmhora   = input titulo.cxmhora
	       titulo.vencod    = input titulo.vencod
	       titulo.etbCobra  = input titulo.etbCobra
	       titulo.datexp    = input titulo.datexp
	       titulo.moecod    = input titulo.moecod.
     end.
     else do:
	if  input titulo.titdtpag <> ? and
	    input titulo.titvlpag > 0 and
	    titulo.titdtpag   =  ?
	then do:
		assign
		       titulo.titdtdes  = input titulo.titdtdes
		       titulo.titvldes  = input titulo.titvldes
		       titulo.titvljur  = input titulo.titvljur
		       titulo.cobcod    = input titulo.cobcod
		       titulo.bancod    = input titulo.bancod
		       titulo.agecod    = input titulo.agecod
		       titulo.titdtpag  = input titulo.titdtpag
		       titulo.titdesc   = input titulo.titdesc
		       titulo.titjuro   = input titulo.titjuro
		       titulo.titvlpag  = input titulo.titvlpag
		       titulo.titbanpag = input titulo.titbanpag
		       titulo.titagepag = input titulo.titagepag
		       titulo.titchepag = input titulo.titchepag
		       titulo.titobs[1] = input titulo.titobs[1]
		       titulo.titobs[2] = input titulo.titobs[2]
		       titulo.titsit    = if input titulo.titsit = "IMP"
					  then "LIB"
					  else input titulo.titsit
		       titulo.titnumger = input titulo.titnumger
		       titulo.titparger = input titulo.titparger
		       titulo.cxacod    = input titulo.cxacod
		       titulo.evecod    = input titulo.evecod
		       titulo.cxmdata   = input titulo.cxmdata
		       titulo.cxmhora   = input titulo.cxmhora
		       titulo.vencod    = input titulo.vencod
		       titulo.etbCobra  = input titulo.etbCobra
		       titulo.datexp    = input titulo.datexp
		       titulo.moecod    = input titulo.moecod.
	end.
	else do:
	    if titulo.titsit   <> vtitsit or
	       titulo.titdtpag <> vtitdtpag
	    then do:
		display stream log titulo.clifor    column-label "Cliente"
				   titulo.titnum    column-label "Contrato"
				   titulo.titpar    column-label "Pc"
				   titulo.titsit    column-label "Sit"
				   titulo.titdtpag  column-label "Dt.Pagto"
				   space(4)
				   vtitsit          column-label "Sit"
				   vtitdtpag        column-label "Dt.pagto"
				   with frame flog down width 120.
		down stream log with frame flog.
	    end.
	end.
    end.
    n-conta = n-conta + 1.
    display stream tela
	    x
	    "Aguarde... " n-conta "   "
	    titulo.datexp
	    titulo.titvlcob
	    titulo.titvlpag
	    with frame messa01 row 6 no-box no-hide
			centered color blue/cyan no-label.
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
pause.
