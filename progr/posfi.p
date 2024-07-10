/*----------------------------------------------------------------------------*/
/* /usr/admfin/posfi.p                                    Posicao  Financeira */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 08/12/92 Oscar   Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var wetbcod like titulo.etbcod initial 0.
def var wmodcod like titulo.modcod initial "".
def var wtitnat like titulo.titnat.
def var wdti    like titulo.titdtven label "Periodo" initial today.
def var wdtf    like titulo.titdtven.
def var wtitdat as date format "99/99/99" column-label "Cob/Pag".
def var wtitvlcob like titulo.titvlcob.
def var wtotpag      as dec format ">,>>>,>>>,>>9.99".
def var wtotcob      as dec format ">,>>>,>>>,>>9.99".
def var wseq as i extent 2.
def var i as i.
def var wopcao as char.
def var wclifor as i format ">>>>99" label "Cli/For".
def var c as c.
wdtf = wdti + 30.
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:
    clear frame f1 all.
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
	clear frame fc all.
	clear frame f2 all.
	clear frame f3 all.
	clear frame f4 all.
	hide frame f2.
	hide frame f3.
	hide frame f4.
	hide frame ftot.
	hide frame frod.
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
		else disp "CONSULTA DE TODOS OS FORNECEDORES" @ fornom.
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
		else disp "CONSULTA DE TODOS OS CLIENTES" @ clinom.
	   end.
	form wdti colon 12
	     " A"
	     wdtf colon 29 no-label with frame fdat width 80 side-label.

	update wdti
	       wdtf with frame fdat.
	hide frame fdat.

	form wclifor
	     titulo.titnum
	     titulo.titpar
	     titulo.etbcod
	     titulo.modcod
			 with frame f2 7 down width 34 row 8.

	form wtitdat
	     titulo.titvlcob column-label "A Pagar"
	     titulo.titvlpag column-label "Pago"
			 with frame f3 7 down width 46 row 8 column 35.
	form wtitdat
	     titulo.titvlcob column-label "A Receber"
	     titulo.titvlpag column-label "Recebido"
			 with frame f4 7 down width 46 row 8 column 35.

	display wdti colon 4
		" a "
		 wdtf with frame frod no-label row 19 width 34.

	wtotpag = 0.
	wtotcob = 0.
	wetbcod = input wetbcod.
	wclifor = input wclifor.
	for each titulo where titulo.empcod = wempre.empcod and
			      titnat   =   wtitnat          and
			    ( if wmodcod = ""
				 then true
				 else titulo.modcod = wmodcod ) and
			      titdtven >=  wdti             and
			      titdtven <=  wdtf             and
			    ( if wetbcod = 0
				 then true
				 else titulo.etbcod = wetbcod )          and
			    ( if wclifor = 0
				 then true
				 else titulo.clifor = wclifor ) no-lock:
				 /*
			      break by titulo.titdtven
				    by titulo.clifor
				    by titulo.modcod
				    by titulo.titnum
				    by titulo.titpar:  */

	     if titulo.titvlpag <> 0
		then assign wtitdat = titdtpag
			    wtotpag = wtotpag + titvlpag.
		else assign wtitdat = titdtven
			    wtotcob = wtotcob + titvlcob.

	     if wtitnat
		then display titulo.clifor @ wclifor with frame f2.
		else display titulo.clifor @ wclifor with frame f2.

	     display titulo.titnum
		     titulo.titpar
		     titulo.etbcod
		     titulo.modcod with frame f2.

	     if wtitnat
		then display wtitdat
			     titulo.titvlcob when titulo.titvlpag =  0
			     titulo.titvlpag when titulo.titvlpag <> 0
					     with frame f3.
		else display wtitdat
			     titulo.titvlcob when titulo.titvlpag =  0
			     titulo.titvlpag when titulo.titvlpag <> 0
					     with frame f4.
	     display "Totais :"
		     wtotcob
		     wtotpag
		     with frame ftot row 19 column 35 no-label width 46.

	     if wtitnat
		then if frame-line (f3) = frame-down (f3)
			then pause.
			else pause 0.
		else if frame-line (f4) = frame-down (f4)
			then pause.
			else pause 0.

	     down with frame f2.
	     down with frame f3.
	     down with frame f4.
	end.
	pause.
    end.
end.
