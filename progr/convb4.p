def var vsexo as char.
def var vnota as int.
def var vtitnum     as dec.
DEF VAR VDTNASC AS CHAR FORMAT "X(14)".
DEF VAR TOT-CLIEN AS INT.
DEF VAR TOT-CONTR AS INT.
DEF VAR TOT-TITUL AS INT.
DEF stream tela.
output stream tela to terminal.
output to error.
form
	clien.clicod with frame f1 with 1 down centered side-labels.
form
	 with frame f2 with 1 down centered side-labels.
input from ..\dbf\clien.d no-echo.
repeat with no-validate on error undo, next on endkey undo, next:
create clien.
set
  clien.clicod format "9999999.99"
  clien.clinom format "x(30)"
  clien.endereco[1] format "x(30)"
  clien.cep[1]      format "x(10)"
  clien.bairro[1] format "x(20)"
  clien.cidade[1] format "x(25)"
  clien.ufecod[1] format "x(2)"
  ^
  vsexo           format "x(2)"
  clien.ccivil    format "x"
  clien.ciccgc    format "x(14)"
  clien.ciinsc    format "x(15)"
  ^
  vdtnasc
  ^
  ^
  clien.zona.
  do on error undo, leave.
    clien.dtnasc = date(int(substring(vdtnasc,4,2)),
		      int(substring(vdtnasc,1,2)),
		      int(substring(vdtnasc,7,2)) + 1900).
    END.
  clien.sexo = if vsexo = "F"
	       then no
	       else yes.
    disp stream tela
	clien.clicod with frame f1 with 1 down centered side-labels.
    TOT-CLIEN = TOT-CLIEN + 1.
    disp stream tela
	TOT-CLIEN    with frame f2 with 1 down centered side-labels.
    pause 0.
    put unformat string(clien.clicod) + "/".
end.
input close.
input from ..\dbf\contrato.d no-echo.
repeat with no-validate on error undo, next.
    create contrato.
    set
	contrato.clicod    format "99999999.99"
	^
	contrato.etbcod    format "9999"
	contrato.contnum   format "99999999.99"
	^
	^
	^
	^
	contrato.dtinicial
	^
	^
	^
	vnota   format "99999999.99"
	^
	contrato.vltotal
	contrato.vlentra
	^
	^
	contrato.vlfrete
	^
	^.
    assign
	contrato.etbcod = int(substring(string(contrato.etbcod,"9999"),3,2)).
    if vnota > 0
    then do:
	create contnf.
	ASSIGN
	    contnf.contnum = contrato.contnum
	    contnf.notanum = vnota.
    end.
    disp stream tela
	contrato.contnum
	with frame f1 with 1 down centered side-labels.
    TOT-CONTR = TOT-CONTR + 1.
    disp stream tela
	TOT-CONTR    with frame f2 with 1 down centered side-labels.
    pause 0.
    put unformat string(contrato.contnum) + "/".
end.
input close.
input from ..\dbf\titulo.d no-echo.
repeat with no-validate on error undo, next.
    create titulo.
    assign
	titulo.empcod    = 19
	titulo.modcod    = "CRE"
	titulo.titnat    = no.
    set
	vtitnum          format "99999999.99"
	titulo.titpar
	titulo.etbcod    format "9999"
	titulo.etbCobra  format "9999"
	^
	^
	^
	^
	^
	titulo.CliFor    format "99999999.99"
	^
	titulo.titdtemi
	titulo.titdtven
	^
	titulo.titdtpag
	^
	^
	^
	titulo.titvlcob
	titulo.titvlpag
	titulo.titvljur
	^.

	titulo.titnum   = string(truncate(vtitnum,0)).
	titulo.etbcod   = int(substring(string(titulo.etbcod,"9999"),3,2)).
	titulo.etbcobra = int(substring(string(titulo.etbcobra,"9999"),3,2)).
	titulo.titsit   = if titdtpag <> ?
			  then "PAG"
			  else "LIB".
    disp stream tela
	titulo.titnum titulo.titpar
	with frame f1 with 1 down centered side-labels.
    TOT-TITUL = TOT-TITUL + 1.
    disp stream tela
	TOT-TITUL    with frame f2 with 1 down centered side-labels.
    put unformat string(titulo.titnum) + "-" string(titulo.titpar) + "/".
    pause 0.
end.
input close.
output close.
