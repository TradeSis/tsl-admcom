/*****************************************************************************
** Programa : Listagem de Conferencia de Juros
** Autor    : Custom Busines Solution
** Data     : 02/08/95
****************************************************************************/

{ADMcab.i }

def var    wdti like titdtven label "Periodo".
def var    wdtf like titdtven.
def buffer wtitulo for titulo.
def var ndias as int format ">>9".
def var vldev   like titulo.titjuro.
def var vdif    like titulo.titjuro format "->>>,>>9.99".
def var vljur   like titulo.titjuro format ">,>>9.99".
def var vlmul   like titulo.titjuro format ">,>>9.99".
def var jucob   like titulo.titjuro format ">,>>9.99".
def var vlcob   like titulo.titjuro format ">,>>9.99".

form with down frame fdet.

form titulo.etbcobra colon 18
     estab.etbnom  no-label colon 30
     wdti          colon 18  " A"
     wdtf          colon 35  no-label
		   with side-labels width 80 frame f1.

wdti = today.
wdtf = wdti + 30.
repeat:
    prompt-for titulo.etbcobra validate(can-find(estab where estab.etbcod =
						     input titulo.etbcobra),
				      "Estabelecimento nao Cadastrado")
				      with frame f1.

    if input titulo.etbcobra <> 0 then do:
	       find estab where estab.etbcod = input titulo.etbcobra.
	       display etbnom with frame f1.
    end.

    update wdti validate(input wdti <> ?,
			"Data deve ser Informada")
			 with frame f1.

    update wdtf validate(input wdtf >= input wdti,
			 "Data Invalida")
			 with frame f1.

    {confir.i 1 "Listagem Previsao"}

    output to printer page-size 60.
    {ini17cpp.i}

    form header wempre.emprazsoc no-label
		"Administrativo Financeiro" at 46 today at 110
	  skip "Listagem De Conferencia De Juros" at 1
	  "Pag." at 73 page-number format ">>9"      skip
	  estab.etbcod " "  estab.etbnom
	  " Periodo : " at 35 wdti no-label "a" wdtf no-label
	  skip fill("-",135) format "x(135)" skip
	  with frame fcab page-top no-box width 135.
    view frame fcab.

    for each titulo use-index titdtpag where
	     titulo.empcod    = wempre.empcod and
	     titulo.titnat    = no and
	     titulo.modcod    = "CRE" AND
	     titulo.titdtpag >= input wdti        and
	     titulo.titdtpag <= input wdtf with frame fdet:
	/* titulo.etbcobra  = input titulo.etbcobra and
	     titulo.titsit    = "PAG" with frame fdet:   */
	if  titulo.etbcobra <> input titulo.etbcobra then
	    next.
	if  titulo.titsit <> "PAG" then
	    next.
	find clien where clien.clicod = titulo.clifor.
	ndias = titulo.titdtpag - titulo.titdtven.
	if  ndias <= 0 then
	    next.
	if  ndias > 0 then do:
	    assign vljur = titulo.titvlcob * (ndias * 0.5) / 100
		   vlmul = (titulo.titvlcob + vljur) * 10 / 100
		   jucob = vljur + vlmul.
	end.
	vldev = titvlcob +
		(titulo.titdtpag - titulo.titdtven) * titulo.titjuro.
	vdif = (titulo.titvlpag - (titulo.titvlcob + jucob)).
	if  ndias <> 0 then do:
	    disp
	       titulo.etbcod
	       titulo.titnum   column-label  "Contr"
	       titulo.titpar   column-label  "Pr"
	       clien.clicod    column-label  "Cod"
	       clien.clinom    column-label  "Cliente" format "x(20)"
	       titulo.titdtven column-label "Venc."    format "99/99/99"
	       titulo.titdtpag column-label "Dt.Pag"   format "99/99/99"
	       ndias           column-label "Dias"     format "->>9"
	       titulo.titvlcob column-label "Vlr.Pres."
	       titulo.titvlpag column-label "Juro!Cobrado" format ">>,>>9.99"
	       titulo.titvlcob + jucob @ vlcob
			       column-label "Juro!Calculado" format ">>,>>9.99"
	       vdif            column-label "Dif."     format "->,>>9.99"
	       with frame fdet width 140.
	    down with frame fdet.
	    accumulate titulo.titvlcob(total)
		       titulo.titvlpag(total)
		       titulo.titvlcob + jucob(total)
		       vdif(total).
	end.
    end.
    down 2 with fram fdet.
    disp accum total(titulo.titvlcob) @ titulo.titvlcob
	 accum total(titulo.titvlpag) @ titulo.titvlpag
	 accum total(titulo.titvlcob + jucob) @ vlcob
	 accum total(vdif) @ vdif
	 with frame fdet width 140.
    {fin17cpp.i}
    output close.
end.
