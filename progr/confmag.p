{admcab.i}
def buffer btitulo for titulo.

def var wvlpri      like titulo.titvlpag.
def var wvlpag      like titulo.titvlpag.

def var vdata       like titulo.titdtemi.
DEF VAR vpago       like titulo.titvlpag.
def var vdesc       like titulo.titdesc.
def var vjuro       like titulo.titjuro.
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .

repeat with 1 down side-label width 80 row 3:
    prompt-for estab.etbcod colon 20.
    find estab using etbcod .
    display estab.etbnom no-label.
    update vdata colon 20.
    assign
	vpago = 0
	vdesc = 0
	vjuro = 0.
    if estab.etbcod <> 1
    then
	for each titulo where titulo.empcod = wempre.empcod and
			      titulo.titnat = no and
			      titulo.modcod = "CRE" and
			      titulo.titdtpag = vdata and
			      titulo.titpar > 0
			      use-index titdtpag:
	    if titulo.etbcobra <> estab.etbcod or titulo.clifor = 1
	    then
		next .
	    assign
		vpago = vpago + titulo.titvlpag
			      - titulo.titjuro + titulo.titdesc
		vjuro = vjuro + if titulo.titjuro = titulo.titdesc
				then 0
				else titulo.titjuro
		vdesc = vdesc + if titulo.titjuro = titulo.titdesc
				then 0
				else titulo.titdesc .
	end.

    if vpago = 0 and
       vdesc = 0 and
       vjuro = 0 and
       estab.etbcod <> 1
    then do:
	message "Nenhum Pagamento  efetuado".
	undo.
    end.
    if estab.etbcod <> 1
    then
	display vpago label "Valor Pago"    colon 20
		vjuro label "Valor Juro"     colon 20
		vdesc label "Valor Desconto"    colon 20
		with frame ff side-label width 80.

    message "Imprimir Resumo ou Geral ?" update sresumo.
    if sresumo and
       estab.etbcod <> 1
    then do:
	output to printer page-size 64.
	form header
	    wempre.emprazsoc
		    space(6) "PAGRE"   at 60
		    "Pag.: " at 71 page-number -1 format ">>9" skip
		    "RESUMO DE DIGITACAO DE PAGAMENTOS "   at 1
		    today format "99/99/9999" at 60
		    string(time,"hh:mm:ss") at 73
		    skip fill("-",80) format "x(80)" skip
		    with frame fcab no-label page-top no-box width 137.
	view frame fcab.
	display estab.etbcod
		estab.etbnom
		vdata column-label "Data"
		vpago column-label "Valor Pago"
		vjuro column-label "Valor Juro"
		vdesc column-label "Valor Desconto"
		with frame flin.
	output close.
    end.
    else do:
	if estab.etbcod = 1
	then do:
	    run pagmag.p ( input estab.etbcod,
			   input 1,
			   input 2,
			   input vdata,
			   input sresumo).
	end.
	else do:
	    {mdadmcab.i
		&Saida     = "printer"
		&Page-Size = "64"
		&Cond-Var  = "140"
		&Page-Line = "66"
		&Nom-Rel   = """PAGREB4"""
		&Nom-Sis   = """SISTEMA CREDIARIO"""
		&Tit-Rel   = """LISTAGEM DE DIGITACAO DE PAGAMENTOS ESTAB.: ""
			       + string(estab.etbcod) + "" - "" + estab.etbnom "
		&Width     = "140"
		&Form      = "frame f-cab"}
	for each titulo where titulo.empcod = wempre.empcod and
			      titulo.titnat = no and
			      titulo.modcod = "CRE" and
			      titulo.titdtpag = vdata and
			      titulo.titpar > 0
			      use-index titdtpag by titulo.titnum
						 by titulo.titpar :
	    find clien where clien.clicod = titulo.clifor no-error.
	    if titulo.etbcobra <> estab.etbcod or
	       titulo.clifor = 1
	    then
		next .
	    vjuro = if titulo.titjuro = titulo.titdesc
		    then 0
		    else titulo.titjuro.
	    vdesc = if titulo.titjuro = titulo.titdesc
		    then 0
		    else titulo.titdesc.
	    display titulo.etbcod   column-label "Fil."
		    titulo.etbcobra column-label "Cob."
		    titulo.titnum   column-label "Contr."
		    titulo.titpar   column-label "Pr."
		    titulo.clifor   column-label "Cliente"
		    clien.clinom    column-label "Nome" format "x(35)"
					when avail clien
		    titulo.titdtven
		    titulo.titdtpag
		    titulo.titvlpag - titulo.titjuro + titulo.titdesc
			 column-label "Valor Pago" format ">>>,>>9.99" (TOTAL)
		    vjuro                       format ">>>,>>9.99"  (TOTAL)
		    vdesc                       format "->>,>>9.99"  (TOTAL)
		    with no-box width 150 frame flin2 down.
	    down with frame flin2.

	end.
	end.
	put unformatted chr(30) "0".
	output close.
    end.
end.
