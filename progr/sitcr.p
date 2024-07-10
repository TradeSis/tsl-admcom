{admcab.i}
def var wdtref as date label "Data Referencia".
def var wtotven like diario.vlvenda label "Total Vendas".
def var wtotent like diario.vlvenda label "Total Entradas".
def var wdiaven like diario.vlvenda label "Vendas".
def var wdiaent like diario.vlvenda label "Entradas".
def var wtotpar like diario.vlvenda label "Total Parcelas".
def var wtotpag like diario.vlvenda label "Total Pago".
def var wtotpen like diario.vlvenda label "Total Atrasado".
def var wdiapar like diario.vlvenda label "Valor Parcelas".
def var wdiapag like diario.vlvenda label "Valor Pago".
def var wventot like diario.vlvenda label "Total a Vencer".
def var wtotadi like diario.vlvenda label "Total ja Pago".
def var wtotave like diario.vlvenda label "Total Pendente".
repeat:
    update wdtref with frame f1 width 80 1 column
		       title " Posicao do Crediario ".
    assign wtotven = 0
	   wtotent = 0
	   wdiaven = 0
	   wdiaent = 0
	   wtotpar = 0
	   wtotpag = 0
	   wtotpen = 0
	   wdiapar = 0
	   wdiapag = 0
	   wventot = 0
	   wtotadi = 0
	   wtotave = 0.
    for each contrato where dtini <= wdtref and situacao <> 9:
	if dtini < wdtref
	    then do:
	    wtotven = wtotven + vltotal.
	    if vlentra <> 0
		then wtotent = wtotent + vlentra.
	    end.
	if dtini = wdtref
	    then do:
	    wdiaven = wdiaven + vltotal.
	    if vlentra <> 0
		then wdiaent = wdiaent + vlentra.
	    end.
	for each titulo  where
	    titulo.titnum = string(contrato.contnum) and
	    titulo.empcod = wempre.empcod and
	    titulo.titnat = no and
	    titulo.modcod = "CRE"
	    by titpar:
	    if titdtven < wdtref
		then do:
		wtotpar = wtotpar + titvlcob.
		if titvlpag <> 0
		    then wtotpag = wtotpag + titvlpag.
		    else wtotpen = wtotpen + titvlcob.
		end.
	    if titdtven = wdtref
		then wdiapar = wdiapar + titvlcob.
	    if titdtpag = wdtref
		then wdiapag = wdiapag + titvlpag.
	    if titdtven > wdtref
		then do:
		wventot = wventot + titvlcob.
		if titvlpag <> 0
		    then wtotadi = wtotadi + titvlpag.
		    else wtotave = wtotave + titvlcob.
		end.
	end.
    end.
    display wtotven
	    wtotent
	    wtotpar
	    wtotpag
	    wtotpen
	    with frame f2 width 80 2 column title " Valores Anteriores ".
    display wdiaven
	    wdiaent
	    wdiapar
	    wdiapag
	    with frame f3 width 80 2 column title " Valores do Dia ".
    display wventot
	    wtotadi
	    wtotave
	    with frame f4 width 80 2 column title " Valores Posteriores ".
end.
