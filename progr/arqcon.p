{ADMCAB.I}
def var vdtemiini as date format "99/99/9999".
def var vdtemifim as date format "99/99/9999".
def var vsubtot  like titulo.titvlcob.
def var vetbcod like estab.etbcod.
def var vcont-cli  as char format "x(15)" extent 2
      initial ["  Alfabetica  ","  Emissao  "].
def var valfa  as log.

update vetbcod                          colon 20.
find estab where estab.etbcod = vetbcod no-error.
if not avail estab
then do:
    message "Estabelecimento Invalido" .
    undo.
end.
display estab.etbnom no-label.
update
       vdtemiini label "Emissao Inicial" colon 20
       vdtemifim label "Final"
       with row 4 side-labels width 80 .

    disp vcont-cli no-label with frame f1 centered.
    choose field vcont-cli with frame f1.
    if frame-index = 1
    then valfa = yes.
    else valfa = no.

output to printer page-size 62  .
PUT UNFORMATTED CHR(15)  .
VSUBTOT = 0.
PAGE.
if valfa
then
FOR EACH ESTAB where estab.etbcod = vetbcod,
    each contrato where
	contrato.etbcod     = estab.etbcod and
	contrato.dtinicial >= vdtemiini and
	contrato.dtinicial <= vdtemifim
			    break by contrato.clicod
				  by contrato.contnum .

    find clien where clien.clicod = contrato.clicod no-lock no-error.
    if not avail clien
    then
	next.
	form header
	    wempre.emprazsoc
		    space(6) "ARQCON"   at 117
		    "Pag.: " at 128 page-number format ">>9" skip
		    "POSICAO FINANCEIRA GERAL P/FILIAL-CLIENTE-"
		    " Periodo" vdtemiini " A " vdtemifim
		    today format "99/99/9999" at 117
		    string(time,"hh:mm:ss") at 130
		    skip fill("-",137) format "x(137)" skip
		    with frame fcab no-label page-top no-box width 137.
	view frame fcab.
    find last titulo where titulo.empcod = wempre.empcod and
			   titulo.titnat = no and
			   titulo.modcod = "CRE" and
			   titulo.clifor = clien.clicod and
			   titulo.etbcod = contrato.etbcod and
			   titulo.titnum = string(contrato.contnum)
		     no-lock no-error.
    if not avail titulo then next.
    if avail titulo and titulo.titdtpag <> ? then next.
    display
	contrato.etbcod    column-label "Fil."         space(3)
	clien.clinom     column-label "Nome do Cliente" space(1)
	clien.clicod     column-label "Cod."            space(3)
	contrato.contnum      column-label "Contr."        space(3)
	contrato.dtinicial    column-label "Dt.Venda"   space(4)
	contrato.vltotal    column-label "Valor" (TOTAL)
	with width 180 .
end.
else
FOR EACH ESTAB where estab.etbcod = vetbcod.
    FOR each contrato where
	contrato.etbcod     = estab.etbcod and
	contrato.dtinicial >= vdtemiini and
	contrato.dtinicial <= vdtemifim
			    break by contrato.dtinicial
				  by contrato.contnum .
	find clien where clien.clicod = contrato.clicod no-lock no-error.
	if not avail clien
	then next.
	form header
	    wempre.emprazsoc
		    space(6) "POCLI"   at 117
		    "Pag.: " at 128 page-number format ">>9" skip
		    "POSICAO FINANCEIRA GERAL P/FILIAL-CLIENTE-"
		    " Periodo" vdtemiini " A " vdtemifim
		    today format "99/99/9999" at 117
		    string(time,"hh:mm:ss") at 130
		    skip fill("-",137) format "x(137)" skip
		    with frame fcabb no-label page-top no-box width 137.
	view frame fcabb.

    find last titulo where titulo.empcod = wempre.empcod and
			   titulo.titnat = no and
			   titulo.modcod = "CRE" and
			   titulo.clifor = clien.clicod and
			   titulo.etbcod = contrato.etbcod and
			   titulo.titnum = string(contrato.contnum)
		     no-lock no-error.
    if not avail titulo then next.
    if avail titulo and titulo.titdtpag <> ? then next.


    display
	contrato.etbcod    column-label "Fil."         space(3)
	clien.clinom     column-label "Nome do Cliente" space(1)
	clien.clicod     column-label "Cod."            space(3)
	contrato.contnum      column-label "Contr."        space(3)
	contrato.dtinicial    column-label "Dt.Venda"   space(4)
	contrato.vltotal    column-label "Valor" (TOTAL)
	with width 180 .
    end.
END.
output close.
