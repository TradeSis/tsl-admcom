
{ADMcab.i}
def var wetbcod like titulo.etbcod.
def var wmodcod like titulo.modcod.
def var wtitnat like titulo.titnat.
def var wclifor like titulo.clifor.
def var wtitnum like titulo.titnum.
def var wtitpar like titulo.titpar.
def buffer  b-titu  for titulo.
{segur.in}
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:
    update wetbcod label "Estabelec." colon 12.
    find estab where estab.etbcod = wetbcod.
    display etbnom no-label format "x(10)".
    wmodcod = "CRE".
    wtitnat = no.
    display wmodcod " - " wtitnat.
    assign wclifor = 0
	   wclifor = 0
	   wtitnum = "".
    repeat:
	if wtitnat
	    then do with column 1 side-labels 1 down width 48 row 4 frame f2:
	    wclifor = 0.
	    update wclifor colon 12.
	    find forne where forne.forcod = wclifor.
	    display fornom format "x(32)" no-label at 14.
	    end.
	    else do with column 1 side-labels 1 down width 48 row 4 frame f3:
	    wclifor = 0.
	    update wclifor colon 12.
	    find clien where clien.clicod = wclifor.
	    display clinom format "x(32)" no-label at 14.
	    end.
	update wtitnum colon 15
	       wtitpar colon 57
	       with side-labels 1 down width 80 frame f4.
	find titulo where titulo.empcod = wempre.empcod and
			  titulo.etbcod = estab.etbcod and
			  titulo.modcod = wmodcod and
			  titulo.titnat = no and
			  titulo.clifor = wclifor and
			  titulo.titnum = wtitnum and
			  titulo.titpar = wtitpar no-error.
	if not available titulo
	    then do:
	    message "Titulo nao cadastrado.".
	    undo.
	    end.
	if titsit = "BLO" or
	   titsit = "LIB"
	    then do:
	    message "Titulo ainda nao pago, cancelamento impossivel.".
	    undo.
	    end.
	form titdtemi format "99/99/99" label "Emiss./Vencim." colon 15
	     "-"
	     titdtven format "99/99/99" no-label
	     titvlcob colon 15
	     titvljur colon 15
	     titdtdes colon 15
	     titvldes colon 15
	     with side-labels 1 down width 40 title " Cobranca " frame f5.
	find cobra of titulo.
	display titdtemi
		titdtven
		titvlcob
		titvljur
		titdtdes
		titvldes with frame f5.
	display titobs with no-labels width 80 title " Observacoes " frame f7.
	form titdtpag colon 15
	     titvlpag colon 15
	     titdesc  colon 15
	     titjuro  colon 15
	     skip(1)
	     with side-labels 1 down width 40 column 41
		  title " Pagamento " frame f8.
	display titdtpag
		titvlpag
		titdesc
		titjuro with frame f8.
	{confir.i 1 "Cancelamento de Pagamento"}
	message "Parcela deve ser Impressa ?"
	update sresp.
	assign
	    titulo.titdtpag = ?
	    titulo.titvlpag = 0
	    titulo.titjuro = 0
	    titulo.titdesc = 0
	    titulo.titsit = if  sresp then
				"IMP"
			    else
				"LIB"
	    titulo.datexp = today
	    titulo.cxacod = 0
	    titulo.cxmdat = ?.
	find first b-titu where
		   b-titu.empcod    =  titulo.empcod and
		   b-titu.titnat    =  titulo.titnat and
		   b-titu.modcod    =  titulo.modcod and
		   b-titu.etbcod    =  titulo.etbcod and
		   b-titu.clifor    =  titulo.clifor and
		   b-titu.titnum    =  titulo.titnum and
		   b-titu.titpar    <> titulo.titpar and
		   b-titu.titparger =  titulo.titpar no-lock no-error.
	if  avail b-titu then do:
	    display "Verifique Titulo Gerado do Pagamento Parcial"
		     with frame fver color messages
		     width 50 overlay row 10 centered.
	    pause.
	end.
    end.
end.
