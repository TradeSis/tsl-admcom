/*----------------------------------------------------------------------------*/
/* /usr/admfin/recli.p                              Recebimentos  -  Listagem */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 08/12/92 Oscar   Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var wetbcod like titulo.etbcod initial 0.
def var wmodcod like titulo.modcod initial "".
def var wclifor like titulo.clifor.
def var wtitvlcob like titulo.titvlcob.
def var wdti    like titdtven label "Periodo" initial today.
def var wdtf    like titdtven.
def var wtot      as dec format ">,>>>,>>>,>>9.99" label "Total".
def var wtotcob      as dec format ">,>>>,>>>,>>9.99".
def var wtotpag      as dec format ">,>>>,>>>,>>9.99".
def var wtotjur      as dec format ">,>>>,>>>,>>9.99".
def var wtotdes      as dec format ">,>>>,>>>,>>9.99".
def var wgercob      as dec format ">,>>>,>>>,>>9.99".
def var wgerpag      as dec format ">,>>>,>>>,>>9.99".
def var wgerjur      as dec format ">,>>>,>>>,>>9.99".
def var wgerdes      as dec format ">,>>>,>>>,>>9.99".
def var i as i.
wdtf = wdti + 30.
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
			    wmodcod <> "CRE" or
			    can-find(modal where modal.modcod = wmodcod),
			    "Modalidade nao cadastrada")
			    label "Modal/Natur" colon 12.

    repeat with  frame fc:
	clear frame fc all.
	disp "" @ wclifor with frame fc.
	prompt-for wclifor label "Cliente"
				  with column 1 side-labels
					       1 down width 48 row 4 frame fc.
	if input wclifor <> ""
	   then do:
		   find clien where clien.clicod = input wclifor.
		   display clinom format "x(32)" no-label at 10 with frame fc.
	   end.
	   else disp "RECEBIMENTOS DE TODOS OS CLIENTES" @ clinom
		with frame fc.
	form wdti colon 12
	     " A"
	     wdtf colon 29 no-label with frame fdat width 80 side-label.

	update wdti
	       wdtf with frame fdat.
	{confir.i 1 "impressao Titulos Recebidos"}
	output to printer page-size 60.
	{ini17cpp.i}

	form titulo.etbcod
	     titulo.titdtpag format "99/99/99"
	     titulo.modcod
	     titulo.cobcod
	     titulo.bancod
	     space(0) "/" space(0)
	     titulo.agecod
	     titulo.clifor
	     titulo.titnum
	     titulo.titpar
	     titulo.titdtven format "99/99/99"
	     titulo.titvlcob
	     titulo.titvlcob
	     titulo.titvlpag
	     titulo.titvljur
	     titulo.titvldes
			     with frame fdet width 200 no-label no-box.

	form "Total" at 61
	     wtotcob
	     wtotpag
	     wtotjur
	     wtotdes
	     with frame ftot no-label width 140 no-box.

	form "Total Geral" at 55
	     wgercob
	     wgerpag
	     wgerjur
	     wgerdes
	     with frame fger no-label width 140 no-box.

	form header wempre.emprazsoc no-label
		    "Administrativo Financeiro" at 89 today at 130
		    skip "Titulos Pagos" at 79
		    "Pag." at 130 page-number format ">>9"
		    skip fill("-",137) format "x(137)" skip
"Est. Dt.Pagt. MT  Cb Bco.Rec. For/Cli    Titulo       PC Dt.Vcto." at  1
"   Valor Cobrado       Valor Pago      Valor Juros       Valor Desc."    at 67
"---- -------- --- -- -------- ---------- ------------ -- --------" at  1
"---------------- ---------------- ---------------- -----------------"    at 67
		    with frame fcab page-top no-box width 140.
		    view frame fcab.

	assign wtotcob = 0
	       wtotpag = 0
	       wtotjur = 0
	       wtotdes = 0.

	for each titulo where titulo.empcod = wempre.empcod and
			      titdtpag >= wdti         and
			      titdtpag <= wdtf         and
			      titnat   =  no           and
			    ( titsit   =   "PAG"        or
			      titsit   =   "PAR" )     and
			    ( if wclifor = ?
				 then true
				 else titulo.clifor = wclifor ) and
			    ( if wetbcod = 0
				 then true
				 else titulo.etbcod = wetbcod ) and
			    ( if wmodcod = ""
				 then true
				 else titulo.modcod = wmodcod )
				  use-index titdtpag
				  break by titulo.etbcod /*
					by titulo.titdtpag
					by titulo.modcod
					by titulo.cobcod
					by titulo.bancod
					by titulo.agecod
					by titulo.clifor
					by titulo.titnum
					by titulo.titpar
				     */ by titulo.titdtven:


	    display titulo.etbcod
		    titulo.titdtpag format "99/99/99"
		    titulo.modcod
		    titulo.cobcod
		    titulo.bancod     when titulo.bancod    <> 0
		    titulo.agecod     when titulo.bancod    <> 0
		    titulo.clifor
		    titulo.titnum
		    titulo.titpar
		    titulo.titvlcob
		    titulo.titdtven
		    titulo.titvlcob
		    titulo.titvlpag
		    titulo.titvljur
		    titulo.titvldes  with frame fdet.
	    down with frame fdet.

	    assign wtotcob = wtotcob + titvlcob
		   wtotpag = wtotpag + titvlpag
		   wtotjur = wtotjur + titvljur
		   wtotdes = wtotdes + titvldes.

	    if last-of(titulo.etbcod) or
	       last-of(titdtven)
	       then do:
		       put skip
			   space(60)
			   fill("-",74) format "x(74)".
		       display wtotcob
			       wtotpag
			       wtotjur
			       wtotdes with frame ftot no-box.
		       put skip
			   space(60)
			   fill("-",74) format "x(74)".
		       assign wgercob = wgercob + wtotcob
			      wgerpag = wgerpag + wtotpag
			      wgerjur = wgerjur + wtotjur
			      wgerdes = wgerdes + wtotdes
			      wtotcob = 0
			      wtotpag = 0
			      wtotjur = 0
			      wtotdes = 0.
	       end.
       end.
       put skip
	   space(54)
	   fill("-",80) format "x(80)".
       display wgercob
	       wgerpag
	       wgerjur
	       wgerdes with frame fger no-box.
       put skip
	   space(54)
	   fill("-",80) format "x(80)".
       assign wgercob = 0
	      wgerpag = 0
	      wgerjur = 0
	      wgerdes = 0.
       {fin17cpp.i}
       output close.
    end.
end.
