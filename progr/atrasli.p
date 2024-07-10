/*----------------------------------------------------------------------------*/
/* /usr/admfin/atrasli.p                                  Atrasos - Listagem  */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 08/12/92 Oscar   Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var wetbcod like titulo.etbcod initial 0.
def var wmodcod like titulo.modcod initial "".
def var wtitnat like titulo.titnat.
def var wclifor like titulo.clifor.
def var wtitvljur like titulo.titvljur format ">>,>>>,>>9.99" label "Juros".
def var wdti    like titdtven label "Data Refer. " initial today.
def var wtitdat as date format "99/99/99" column-label "Cob/Pag".
def var wvltot like titulo.titvlcob.
def var wtotjur      as dec format ">>>,>>9.99".
def var wtotcob      as dec format ">,>>>,>>>,>>9.99".
def var wtotvlr      as dec format ">>>,>>>,>>9.99".
def var wgerjur      as dec format ">>>,>>9.99".
def var wgercob      as dec format ">,>>>,>>>,>>9.99".
def var wgervlr      as dec format ">>>,>>>,>>9.99".
def var wnrdias as i format ">>9" label "DD".
def var i as i.
def var wnome as char format "x(30)" label "Nome".
def var wforcli as i format "999999" label "For/Cli".
def var wcab    as c format "x(14)".
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:
    disp "" @ wetbcod colon 12.
    prompt-for wetbcod label "Estabelec." .
    if input wetbcod <> ""
       then do:
	       find estab where estab.etbcod = input wetbcod.
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
	clear frame ff all.
	if wtitnat
	   then do with column 1 side-labels 1 down width 48 row 4 frame ff:
	     disp "" @ wclifor.
	     prompt-for wclifor label "Fornecedor"
		help "Informe o codigo do Fornecedor ou <ENTER> para todos".
	     if input wclifor <> ""
		then do:
			find forne where forne.forcod = input wclifor.
			display fornom format "x(32)" no-label at 10.
		end.
		else disp "RELATORIO DE TODOS OS FORNECEDORES" @ fornom.
	   end.
	   else do with column 1 side-labels 1 down width 48 row 4 frame fc:
	     disp "" @ wclifor.
	     prompt-for wclifor label "Cliente"
		help "Informe o codigo do Cliente ou <ENTER> para todos".
	     if input wclifor <> ""
		then do:
			find clien where clien.clicod = input wclifor.
			display clinom format "x(32)" no-label at 10.
		end.
		else disp "RELATORIO DE TODOS OS CLIENTES" @ clinom.
	   end.
	form wdti colon 20 with frame fdat width 80 side-label.

	update wdti with frame fdat.

	{confir.i 1 "Listagem de Atarsos"}
	output to printer page-size 60.
	{ini17cpp.i}

	if wtitnat
	   then wcab = "de Pagamento".
	   else wcab = "de Recebimento".

	form titulo.titdtven format "99/99/99"
	     wforcli
	     space(2)
	     wnome
	     titulo.titnum
	     titulo.titpar
	     titulo.modcod
	     titulo.etbcod
	     titulo.cobcod
	     titulo.bancod
	     space(0) "/" space(0)
	     titulo.agecod
	     wnrdias
	     titulo.titvlcob format ">>,>>>,>>9.99"
	     wtitvljur       format ">>,>>>,>>9.99"
	     wvltot          format ">>>,>>>,>>9.99"
			     with frame fdet width 140 no-box no-label.

	form "Total" at 85
	     wtotcob space(4)
	     wtotjur
	     wtotvlr
	     skip (1) with frame ftot no-label width 140 no-box.

	form "Total Geral" at 79
	     wgercob space(4)
	     wgerjur
	     wgervlr  with frame fger no-label width 140 no-box.

	form header wempre.emprazsoc no-label
		    "Administrativo Financeiro" at 79 today at 130
		    skip "Titulos em Atrasos" at 69 wcab no-label
		    "Pag." at 130 page-number format ">>9"
		    "Data de Referencia : " at 70 wdti no-label
		    skip fill("-",137) format "x(137)" skip
"Dt.Vcto. For/Cli Nome                           Titulo       PC MT  Est." at 1
" Cb Bco/Agencia  N.D Valor Cobrado - Valor Juros    Valor Total"     at 73
"-------- ------- ------------------------------ ------------ -- --- ----" at  1
" -- ------------ --- ------------- ------------- --------------"     at 73
		    with frame fcab page-top no-box width 140.
		    view frame fcab.

		    assign wtotjur = 0
			   wtotcob = 0
			   wtotvlr = 0.
	for each titulo where titulo.empcod = wempre.empcod and
			      titdtven <   wdti        and
			      titnat   =   wtitnat     and
			    ( titsit   =   "LIB"        or
			      titsit   =   "BLO" )     and
			    ( if wclifor = 0
			      then true
			      else titulo.clifor = wclifor ) and
			    ( if wmodcod = ""
			      then true
			      else titulo.modcod = wmodcod ) and
			    ( if wetbcod = 0
				 then true
				 else titulo.etbcod = wetbcod )
			      break by titulo.titdtven
				    by titulo.clifor
				    by titulo.modcod
				    by titulo.titnum
				    by titulo.titpar:


	    assign wnrdias   = wdti      - titulo.titdtven
		   wtitvljur = titvljur  * wnrdias
		   wvltot    = wtitvljur + titvlcob
		   wtotjur   = wtotjur   + wtitvljur
		   wtotcob   = wtotcob   + titvlcob
		   wtotvlr   = wtotvlr   + wvltot.

	    if wtitnat
	       then do:
		       find forne where forne.forcod =  titulo.clifor.
		       assign wforcli = forne.forcod
			      wnome   = forne.fornom.
	       end.
	       else do:
		       find clien where clien.clicod = titulo.clifor.
		       assign wforcli = clien.clicod
			      wnome   = clien.clinom.
	       end.

	    display titulo.titdtven
		    wforcli
		    wnome
		    titulo.titnum
		    titulo.titpar
		    titulo.modcod
		    titulo.etbcod
		    titulo.cobcod
		    titulo.bancod
		    titulo.agecod
		    wnrdias
		    titulo.titvlcob
		    wtitvljur
		    wvltot
		    with frame fdet.
	    down with frame fdet.

	    if last-of(titdtven)
	       then do:
		       put skip
			   space(85)
			   fill("-",52) format "x(52)".
		       display wtotcob
			       wtotjur
			       wtotvlr with frame ftot no-box.
		       put skip
			   space(85)
			   fill("-",52) format "x(52)".
		       assign wgercob = wgercob + wtotcob
			      wgerjur = wgerjur + wtotjur
			      wgervlr = wgervlr + wtotvlr
			      wtotcob = 0
			      wtotjur = 0
			      wtotvlr = 0.
	       end.
	end.
	put skip
	    space(79)
	    fill("-",58) format "x(58)".
	display wgercob
		wgerjur
		wgervlr with frame fger no-box.
	put skip
	    space(79)
	    fill("-",58) format "x(58)".
	assign wgercob = 0
	       wgerjur = 0
	       wgervlr = 0.
	{fin17cpp.i}
	output close.
    end.
end.
