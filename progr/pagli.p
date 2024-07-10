/*----------------------------------------------------------------------------*/
/* finan/agendli.p                                          Agenda - Listagem */
/*                                                                            */
/*----------------------------------------------------------------------------*/
{ADMCAB.i}
def var wtotger like titulo.titvlpag.
def var vnome like clien.clinom.
def var recatu2 as recid.
def var vtitrel     as char format "x(50)".
def var wetbcod like titulo.etbcod initial 0.
def var wmodcod like titulo.modcod initial "".
def var wtitnat like titulo.titnat.
def var wclifor like titulo.clifor initial 0.
def var wclicod like clien.clicod initial 0.
def var wdti    like titulo.titdtven label "Periodo" initial today.
def var wdtf    like titulo.titdtven.
def var wTITVLPAG like titulo.TITVLPAG.
def var wtot      as dec format ">,>>>,>>>,>>9.99" label "Total".
def var wseq as i extent 2.
def var i as i.
def var wbar as c label "/" initial "/" format "x".
def var wclfnom as char format "x(30)" label "clfnom".
def var wforcli as i format "999999" label "For/Cli".
wdtf = wdti + 30.
wtotger = 0.
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:
    disp "" @ wetbcod colon 12.
    update wetbcod label "Estabelec." .
    if  wetbcod <> 0
       then do:
	       find estab where
			  estab.etbcod =  wetbcod.
	       display etbnom no-label format "x(10)".
       end.
       else disp "TODOS" @ etbnom.

    update wmodcod validate(wmodcod = "" or
			    can-find(modal where modal.modcod = wmodcod),
			    "Modalidade nao cadastrada")
			    label "Modal/Natur" colon 12.
    display " - ".
    if wmodcod = "CRE"
       then wtitnat = no.
    update wtitnat no-label.
    repeat:
	clear frame ff.
	clear frame fc.
	if wtitnat
	   then do with column 1 side-labels 1 down width 48 row 4 frame ff:
	     disp "" @ wclifor.
	     update wclifor label "Fornecedor"
		help "Informe o codigo do Fornecedor ou <ENTER> para todos".
	     if input wclifor <> "" and wclifor <> 0
		then do:
			find forne where forne.forcod = input wclifor.
			display fornom format "x(32)" no-label at 10.
		end.
		else disp "RELATORIO DE TODOS OS FORNECEDORES" @ fornom.
	   end.
	   else do with column 1 side-labels 1 down width 48 row 4 frame fc:
	     disp "" @ wclicod.
	     prompt-for wclicod label "Cliente"
		help "Informe o codigo do Cliente ou <ENTER> para todos".
	     if input wclicod <> ""
		then do:
			find clien where clien.clicod = input wclicod.
			display clinom format "x(32)" no-label at 10.
		end.
		else disp "RELATORIO DE TODOS OS CLIENTES" @ clinom.
	   end.
	if not wtitnat
	then wclifor = wclicod.
	else wclifor = wclifor.

	form wdti colon 12
	     " A"
	     wdtf colon 29 no-label with frame fdat width 80 side-label.

	update wdti
	       wdtf with frame fdat.

	wtot = 0.
	{confir.i 1 "impressao de Agenda Financeira"}

	vtitrel = if wtitnat
		  then "PAGAR"
		  else "RECEBER" .

	{mdadmcab.i
	    &Saida     = "printer"
	    &Page-Size = "64"
	    &Cond-Var  = "119"
	    &Page-Line = "66"
	    &Nom-Rel   = ""PAGLI""
	    &Nom-Sis   = """SISTEMA FINANCEIRO - CONTAS A "" + vtitrel "
	    &Tit-Rel   = """PAGAMENTOS - PERIODO DE "" +
				  string(wdti,""99/99/9999"") + "" A "" +
				  string(wdtf,""99/99/9999"") "
	    &Width     = "119"
	    &Form      = "frame f-cabcab"}

	for each titulo where titulo.empcod = wempre.empcod and
			      titnat   =   wtitnat     and
			    ( if wmodcod = ""
			      then true
			      else titulo.modcod = wmodcod ) and
			      titdtven >=  wdti        and
			      titdtven <=  wdtf        and
			    ( if wetbcod = 0
				 then true
				 else titulo.etbcod = wetbcod ) and
			    ( if wclicod = 0
			      then true
			      else titulo.clifor = wclicod ) and
			      titsit   =   "PAG"  no-lock
				 break by titulo.titdtven:
	    if wtitnat
	    then do:
		find forne where forne.forcod = titulo.clifor no-lock.
		vnome = forne.fornom.
	    end.
	    else do:
		find clien where clien.clicod = titulo.clifor no-lock.
		vnome = clien.clinom.
	    end.
	    find cobra of titulo no-lock.
	    form
		titulo.titdtven format "99/99/99"   COLUMN-LABEL "Dt.Vecto"
		titulo.clifor
		vnome                  column-label "Ag.Comercial"
		titulo.titnum
		titulo.titvlcob
		titulo.titvldes        column-label "Desconto"
		titulo.titvljur        column-label "Juros"
		titulo.TITVLPAG        format ">>,>>>,>>9.99"
		with frame f2 width 160 down.

	    wtot = wtot + TITVLPAG.

	    if first-of(titulo.titdtven)
	    then
		display titulo.titdtven with frame f2.


	    display titulo.clifor
		    vnome
		    titulo.modcod
		    titulo.titnum
		    titulo.titpar
		    cobra.cobnom
		    titulo.TITVLPAG
		    with frame f2.
	    down with frame f2.

	    if last-of(titulo.titdtven)
	    then do:
		display "-------------" @ titulo.TITVLPAG
			with frame f2.
		down with frame f2.
		display wtot            @ titulo.TITVLPAG
			with frame f2.
		wtotger = wtotger + wtot.
		wtot = 0.
		put skip(1).
	    end.
	end.
	display wtotger  label "Total Pago" with frame f3 side-label.
	output close.
    end.
end.
