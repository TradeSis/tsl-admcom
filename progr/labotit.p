/**    Esqueletao de Programacao                          labotit.p */
{admcab.i}
def var vinicio         as  log initial no.
def var reccont         as  int.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(14)" extent 5
	    initial ["Inclusao","Alteracao","Exclusao","Consulta",""].
def var esqcom2         as char format "x(22)" extent 3
	    initial ["Pagamento/Cancelamento", "Bloqueio/Liberacao",
			"Data Exportacao"].
def buffer btitulo      for labotit.
def buffer ctitulo      for labotit.
def buffer b-titu       for labotit.
def var vempcod         like labotit.empcod.
def var vetbcod         like labotit.etbcod.
def var vmodcod         like labotit.modcod.
def var vtitnat         like labotit.titnat.
def var vcliforlab      as char format "x(12)".
def var vclifornom      as char format "x(30)".
def var vclifor         like labotit.clifor.
def var wperdes         as dec format ">9.99 %" label "Perc. Desc.".
def var wperjur         as dec format ">9.99 %" label "Perc. Juros".
def var vtitvlpag       like labotit.titvlpag.
def var vtitvlcob       like labotit.titvlcob.
def var vdtpag          like labotit.titdtpag.
def var vdate           as   date.
def var vetbcobra       like labotit.etbcobra initial 0.
def var vcontrola       as   log initial no.
form esqcom1
    with frame f-com1
    row 5 no-box no-labels side-labels column 1.
form esqcom2
    with frame f-com2
	row screen-lines - 2 title " OPERACOES " no-labels side-labels column 1
	centered.
{titfrm1.i}
repeat:
    clear frame ff1 all.
    assign
	esqregua = yes
	esqpos1  = 1
	esqpos2  = 1
	recatu1  = ?.
    hide frame f-com1 no-pause.
    hide frame f-com2 no-pause.
    update vetbcod validate(can-find(estab where estab.etbcod = vetbcod),
			    "Estabelecimento Invalido") colon 18
	   with frame ff1.
    find estab where estab.etbcod = vetbcod .
    display estab.etbnom no-label with frame ff1.
    update vmodcod validate(can-find(modal where modal.modcod = vmodcod),
			    "Modalidade Invalida") colon 18
	   with frame ff1.
    find modal where modal.modcod = vmodcod.
    display modal.modnom no-label with frame ff1.
    update vtitnat colon 18
	   with frame ff1 side-labels row 5 width 80 color white/cyan.
    hide frame ff1 no-pause.
    display vetbcod vmodcod vtitnat
	    with frame ff no-box row 4 side-labels color white/red width 81.
    vcliforlab = if vtitnat
		 then "Fornecedor:"
		 else "   Cliente:".
    lclifor = if vtitnat
	      then no
	      else yes .

    display vcliforlab no-labels to 19 with frame ff1.
    prompt-for labotit.clifor no-label with frame ff1.
    if vtitnat
    then find forne where forne.forcod = input labotit.clifor.
    else find clien where clien.clicod = input labotit.clifor no-error.
    vclifor = input frame ff1 labotit.clifor .
    if avail clien
    then
    vclifornom = if vtitnat
		 then forne.fornom
		 else clien.clinom.
    hide frame ff1 no-pause.
bl-princ:
repeat :
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if  recatu1 = ? then
	find first titulo where
	    labotit.empcod   = wempre.empcod and
	    labotit.titnat   = vtitnat       and
	    labotit.modcod   = vmodcod       and
	    labotit.etbcod   = vetbcod       and
	    labotit.clifor   = vclifor  no-error.
    else
	find titulo where recid(titulo) = recatu1.
    vinicio = no.
    if  not available titulo then do:
	message "Cadastro de Titulos Vazio".
	message "Deseja Incluir " update sresp.
	if not sresp then undo.
	do with frame ftitulo:
		create labotit.
		assign
		    labotit.empcod = wempre.empcod
		    labotit.titnat = vtitnat
		    labotit.modcod = vmodcod
		    labotit.etbcod = vetbcod
		    labotit.datexp = today.
		assign
		    labotit.clifor = vclifor.
		update labotit.titnum
		       labotit.titpar
		       labotit.titdtemi
		       labotit.titdtven
		       labotit.titvlcob
		       labotit.cobcod.
		find cobra where cobra.cobcod = labotit.cobcod.
		display cobra.cobnom  no-label.
		if  cobra.cobban then do with frame fbanco.
		    update labotit.bancod colon 15.
		    find banco where banco.bancod = labotit.bancod.
		    display banco.bandesc .
		    update labotit.agecod.
		    find agenc of banco where agenc.agecod = labotit.agecod.
		    display agedesc.
		end.
		wperjur = 0 .
		update wperjur with frame fjurdes.
		labotit.titvljur = labotit.titvlcob * (wperjur / 100).
		update labotit.titvljur with frame fjurdes .
		wperdes = 0.
		update labotit.titdtdes
		       wperdes
		       with frame fjurdes.
		labotit.titvldes = labotit.titvlcob * (wperdes / 100).
		update labotit.titvldes
		       with frame fjurdes.
		update text(titobs)
		       with frame fobs .
		pause 0.
		vinicio = yes.
	end.
    end.
    clear frame frame-a all no-pause.
    display
	labotit.titnum
	labotit.titpar   format ">>9"
	labotit.titdtemi format "99/99/99"   column-label "Dt.Emis"
	labotit.titvlcob format ">>,>>>,>>9.99" column-label "Valor Cobrado"
	labotit.titdtven format "99/99/99"   column-label "Dt.Vecto"
	labotit.titdtpag format "99/99/99"   column-label "Dt.Pagto"
	labotit.titvlpag when labotit.titvlpag > 0 format ">>,>>>,>>9.99"
					    column-label "Valor Pago"
	labotit.titsit
	    with frame frame-a 10 down centered color white/red
	    title " " + vcliforlab + " " + vclifornom + " "
		    + " Cod.: " + string(vclifor) + " " width 80.

    recatu1 = recid(titulo).
    if  esqregua then do:
	display esqcom1[esqpos1] with frame f-com1.
	color  display message esqcom1[esqpos1] with frame f-com1.
    end.
    else do:
	display esqcom2[esqpos2] with frame f-com2.
	color display message esqcom2[esqpos2] with frame f-com2.
    end.
    repeat:
	find next titulo where
	    labotit.empcod   = wempre.empcod and
	    labotit.titnat   = vtitnat       and
	    labotit.modcod   = vmodcod       and
	    labotit.etbcod   = vetbcod       and
	    labotit.clifor   = vclifor no-error.
	if not available titulo
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	if not vinicio
	then down with frame frame-a.
	display
	    labotit.titnum
	    labotit.titpar
	    labotit.titdtemi
	    labotit.titvlcob
	    labotit.titdtven
	    labotit.titdtpag
	    labotit.titvlpag when labotit.titvlpag > 0
	    labotit.titsit
		with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.
    repeat with frame frame-a:
	find titulo where recid(titulo) = recatu1.
	color display messages labotit.titpar.
	on f7 recall.
	choose field labotit.titnum
	    go-on(cursor-down cursor-up cursor-left cursor-right F7 PF7
		  page-up       page-down
		  tab PF4 F4 ESC return).
	{pagtit.i}
	if  keyfunction(lastkey) = "RECALL"
	then do with frame fproc centered row 5 overlay color message
			    side-label:
	    prompt-for labotit.titnum colon 10.
	    find first titulo where
			labotit.empcod   = wempre.empcod and
			labotit.titnat   = vtitnat       and
			labotit.modcod   = vmodcod       and
			labotit.etbcod   = vetbcod       and
			labotit.clifor   = vclifor       and
			labotit.titnum  >= input labotit.titnum
			no-error.
	    recatu1 = if avail titulo
		      then recid(titulo) else ?. leave.
	end.
	on f7 help.
	if  keyfunction(lastkey) = "TAB" then do:
	    if  esqregua then do:
		color display normal
		    esqcom1[esqpos1]
		    with frame f-com1.
		color display message
		    esqcom2[esqpos2]
		    with frame f-com2.
	    end.
	    else do:
		color display normal
		    esqcom2[esqpos2]
		    with frame f-com2.
		color display message
		    esqcom1[esqpos1]
		    with frame f-com1.
	    end.
	    esqregua = not esqregua.
	end.
	if keyfunction(lastkey) = "cursor-right" then do:
	    if  esqregua then do:
		color display normal
		    esqcom1[esqpos1]
		    with frame f-com1.
		esqpos1 = if esqpos1 = 5
			  then 5
			  else esqpos1 + 1.
		color display messages
		    esqcom1[esqpos1]
		    with frame f-com1.
	    end.
	    else do:
		color display normal
		    esqcom2[esqpos2]
		    with frame f-com2.
		esqpos2 = if esqpos2 = 3
			  then 3
			  else esqpos2 + 1.
		color display messages
		    esqcom2[esqpos2]
		    with frame f-com2.
	    end.
	    next.
	end.
	if keyfunction(lastkey) = "cursor-left" then do:
	    if esqregua then do:
		color display normal
		    esqcom1[esqpos1]
		    with frame f-com1.
		esqpos1 = if esqpos1 = 1
			  then 1
			  else esqpos1 - 1.
		color display messages
		    esqcom1[esqpos1]
		    with frame f-com1.
	    end.
	    else do:
		color display normal
		    esqcom2[esqpos2]
		    with frame f-com2.
		esqpos2 = if esqpos2 = 1
			  then 1
			  else esqpos2 - 1.
		color display messages
		    esqcom2[esqpos2]
		    with frame f-com2.
	    end.
	    next.
	end.
	if keyfunction(lastkey) = "cursor-down" then do:
	    find next titulo where
	    labotit.empcod   = wempre.empcod and
	    labotit.titnat   = vtitnat       and
	    labotit.modcod   = vmodcod       and
	    labotit.etbcod   = vetbcod   and
	    labotit.clifor   = vclifor no-error.
	    if  not avail titulo then
		next.
	    color display white/red
		labotit.titnum labotit.titpar.
	    if frame-line(frame-a) = frame-down(frame-a)
	    then scroll with frame frame-a.
	    else down with frame frame-a.
	end.
	if  keyfunction(lastkey) = "cursor-up" then do:
	    find prev titulo where
	    labotit.empcod   = wempre.empcod and
	    labotit.titnat   = vtitnat       and
	    labotit.modcod   = vmodcod       and
	    labotit.etbcod   = vetbcod       and
	    labotit.clifor   = vclifor no-error.
	    if not avail titulo
	    then next.
	    color display white/red
		labotit.titnum labotit.titpar.
	    if frame-line(frame-a) = 1
	    then scroll down with frame frame-a.
	    else up with frame frame-a.
	end.
	if keyfunction(lastkey) = "end-error"
	then leave bl-princ.

	if keyfunction(lastkey) = "return"
	then do on error undo, retry on endkey undo, leave.

	  if esqcom2[esqpos2] <> "Pagamento/Cancelamento" or
	     esqcom2[esqpos2] <> "Bloqueio/Liberacao"
	  then
	    hide frame frame-a no-pause.
	  display vcliforlab at 6 vclifornom
		with frame frame-b 1 down centered color blue/gray
		width 81 no-box no-label row 5 overlay.
	  if  esqregua then do:
	    if  esqcom1[esqpos1] = "Inclusao" then do with frame ftitulo:
		create labotit.
		assign
		    labotit.empcod = wempre.empcod
		    labotit.titnat = vtitnat
		    labotit.modcod = vmodcod
		    labotit.etbcod = vetbcod
		    labotit.datexp = today.
		assign
		    labotit.clifor = vclifor.
		update labotit.titnum
		       labotit.titpar
		       labotit.titdtemi
		       labotit.titdtven
		       labotit.titvlcob
		       labotit.cobcod.
		find cobra where cobra.cobcod = labotit.cobcod.
		display cobra.cobnom .
		if  cobra.cobban then do with frame fbanco:
		    update labotit.bancod.
		    find banco where banco.bancod = labotit.bancod.
		    display banco.bandesc .
		    update labotit.agecod.
		    find agenc of banco where agenc.agecod = labotit.agecod.
		    display agedesc.
		end.
		wperjur = 0 .
		update wperjur
		       with frame fjurdes.
		labotit.titvljur = labotit.titvlcob * (wperjur / 100).
		update labotit.titvljur with frame fjurdes .
		wperdes = 0.
		update labotit.titdtdes
		       wperdes
		       with frame fjurdes.
		labotit.titvldes = labotit.titvlcob * (wperdes / 100).
		update labotit.titvldes
			with frame fjurdes.
		update text(titobs)
		       with frame fobs .
		pause 0.
		recatu1 = recid(titulo).
		leave.
	    end.
	    if esqcom1[esqpos1] = "Alteracao"
	    then do with frame ftitulo:
		{segur.i 1}
		vtitvlcob = labotit.titvlcob .
		labotit.datexp = today.
		update labotit.titnum
		       labotit.titpar
		       labotit.titdtemi
		       labotit.titdtven
		       labotit.titvlcob
		       labotit.cobcod.
		find cobra where cobra.cobcod = labotit.cobcod.
		display cobra.cobnom .
		if cobra.cobban
		then do with frame fbanco:
		    update labotit.bancod.
		    find banco where banco.bancod = labotit.bancod.
		    display banco.bandesc .
		    update labotit.agecod.
		    find agenc of banco where agenc.agecod = labotit.agecod.
		    display agedesc.
		end.
		update labotit.titvljur with frame fjurdes .
		update labotit.titdtdes
		       with frame fjurdes.
		update labotit.titvldes
			with frame fjurdes.
		update text(titobs)
		       with frame fobs.
		if  labotit.titvlcob <> vtitvlcob then do:
		   if  labotit.titvlcob < vtitvlcob then do:
		    assign sresp = yes.
		    display "  Confirma GERACAO DE NOVO TITULO ?"
				with frame fGERT color messages
				width 60 overlay row 10 centered.
		    update sresp no-label with frame fGERT.
		    if  sresp then do:
			find last btitulo where
			    blabotit.empcod   = wempre.empcod and
			    blabotit.titnat   = vtitnat       and
			    blabotit.modcod   = vmodcod       and
			    blabotit.etbcod   = vetbcod       and
			    blabotit.clifor   = vclifor       and
			    blabotit.titnum   = labotit.titnum.
			    create clabotit.
			    assign
				clabotit.empcod = blabotit.empcod
				clabotit.modcod = blabotit.modcod
				clabotit.clifor = blabotit.clifor
				clabotit.titnat = blabotit.titnat
				clabotit.etbcod = blabotit.etbcod
				clabotit.titnum = blabotit.titnum
				clabotit.cobcod = labotit.cobcod
				clabotit.titpar   = blabotit.titpar + 1
				clabotit.titdtemi = today
				clabotit.titdtven = labotit.titdtven
				clabotit.titvlcob = vtitvlcob - labotit.titvlcob
				clabotit.titnumger = labotit.titnum
				clabotit.titparger = labotit.titpar
				clabotit.datexp    = today.
			    display
				    clabotit.titnum
				    clabotit.titpar
				    clabotit.titdtemi
				    clabotit.titdtven
				    clabotit.titvlcob
				    with frame fmos width 40 1 column
					      title " Titulo Gerado " overlay
					      centered row 10.
			    recatu1 = recid(ctitulo).
			    leave.
			end.
		     end.
		     else do:
			display "  Confirma AUMENTO NO VALOR DO TITULO?"
				with frame faum color messages
				width 60 overlay row 10 centered.
			update sresp no-label with frame faum.
			if not sresp
			then undo, leave.
		    end.
		end.
	    end.
	    if esqcom1[esqpos1] = "Consulta" or
	       esqcom1[esqpos1] = "Exclusao"
	    then do:
		disp
		    labotit.titnum
		    labotit.titpar
		    labotit.titdtemi
		    labotit.titdtven
		    labotit.titvlcob
		    labotit.cobcod
			with frame flabotit.

		disp
		    labotit.titvljur
		    labotit.titdtdes
		    labotit.titvldes
			with frame fjurdes.
		disp
		    labotit.titobs[1] at 1
		    labotit.titobs[2] at 1
		    with frame fobs.
	    end.
	    if esqcom1[esqpos1] = "Exclusao"
	    then do with frame f-exclui overlay row 6 1 column centered.
		{segur.i 2}
		message "Confirma Exclusao de Titulo"
			    labotit.titnum ",Parcela" labotit.titpar
		    update sresp.
		if not sresp
		then leave.
		find next titulo where
	    labotit.empcod   = wempre.empcod and
	    labotit.titnat   = vtitnat       and
	    labotit.modcod   = vmodcod       and
	    labotit.etbcod   = vetbcod       and
	    labotit.clifor   = vclifor no-error.
		if not available titulo
		then do:
		    find titulo where recid(titulo) = recatu1.
		    find prev titulo where
	    labotit.empcod   = wempre.empcod and
	    labotit.titnat   = vtitnat       and
	    labotit.modcod   = vmodcod       and
	    labotit.etbcod   = vetbcod       and
	    labotit.clifor   = vclifor no-error.
		end.
		recatu2 = if available titulo
			  then recid(titulo)
			  else ?.
		find titulo where recid(titulo) = recatu1.
		delete labotit.
		recatu1 = recatu2.
		leave.
	    end.
	    if esqcom1[esqpos1] = "Listagem"
	    then do with frame f-Lista overlay row 6 1 column centered.
		message "Confirma Impressao de Titulos" update sresp.
		if not sresp
		then leave.
		recatu2 = recatu1.
		output to printer.
		for each titulo:
		    display labotit.
		end.
		output close.
		recatu1 = recatu2.
		leave.
	    end.

	  end.
	  else do:
	    hide frame f-com2 no-pause.
	    if  esqcom2[esqpos2] = "Pagamento/Cancelamento"
	    then
	      if  labotit.titsit = "LIB"
	      then do with frame f-Paga overlay row 6 1 column centered.
		 display labotit.titnum    colon 13
			labotit.titpar    colon 33 label "Pr"
			labotit.titdtemi  colon 13
			labotit.titdtven  colon 13
			labotit.titvlcob  colon 13 label "Vl.Cobr."
			with frame fdadpg side-label
			overlay row 6 color white/cyan width 40
			title " Titulo ".
		if labotit.titsit <> "LIB"
		then do:
		    bell.
		    message "Titulo com situacao ilegal para Pagamento,"
			    labotit.titsit.
		    pause.
		    leave.
		end.
	       labotit.datexp = today.
	       if  labotit.modcod = "CRE" then do:
		   {titpagb4.i}
	       end.
	       else do:
		assign labotit.titdtpag = today.
		display labotit.titdtdes colon 13 label "Dt.Desc"
			    labotit.titvldes colon 13 label "Desc Diario"
			    labotit.titvljur colon 13
			    with frame fdadpg.
		update labotit.titdtpag
			   with frame fpag1.
		if  labotit.titdtpag > labotit.titdtven then do:
			assign labotit.titvlpag = labotit.titvlcob
			       + (labotit.titvljur *
				    (labotit.titdtpag - labotit.titdtven)).
		end.
		else
		    if labotit.titdtpag <= labotit.titdtdes
		    then do:
			    labotit.titvlpag = labotit.titvlcob -
					  (labotit.titvldes *
				     ((titulo.titdtdes - titulo.titdtpag) + 1)).
		    end.
		    else
			    labotit.titvlpag = labotit.titvlcob .
		assign vtitvlpag = labotit.titvlpag.
		update labotit.titvlpag
		       with frame fpag1.
		update labotit.cobcod
		       with frame fpag1 .
		if labotit.titvlpag >= labotit.titvlcob
		then labotit.titjuro = labotit.titvlpag - labotit.titvlcob.
		else do:
			assign sresp = no.
			display "  Confirma PAGAMENTO PARCIAL ?"
				with frame fpag color messages
				width 40 overlay row 10 centered.
		    update sresp no-label with frame fpag.
		    if  sresp then do:
			find last btitulo where
			    blabotit.empcod   = wempre.empcod and
			    blabotit.titnat   = vtitnat       and
			    blabotit.modcod   = vmodcod       and
			    blabotit.etbcod   = vetbcod       and
			    blabotit.clifor   = vclifor       and
			    blabotit.titnum   = labotit.titnum.
			    create clabotit.
			    assign
				clabotit.empcod = blabotit.empcod
				clabotit.modcod = blabotit.modcod
				clabotit.clifor = blabotit.clifor
				clabotit.titnat = blabotit.titnat
				clabotit.etbcod = blabotit.etbcod
				clabotit.titnum = blabotit.titnum
				clabotit.cobcod = labotit.cobcod
				clabotit.titpar   = blabotit.titpar + 1
				clabotit.titdtemi = labotit.titdtemi

				clabotit.titdtven = if labotit.titdtpag <
						      labotit.titdtven
						   then labotit.titdtven
						   else labotit.titdtpag


				clabotit.titvlcob = vtitvlpag - labotit.titvlpag
				clabotit.titnumger = labotit.titnum
				clabotit.titparger = labotit.titpar
				clabotit.datexp    = today
				 labotit.titnumger = clabotit.titnum
				 labotit.titparger = clabotit.titpar.
			    display
				    clabotit.titnum
				    clabotit.titpar
				    clabotit.titdtemi
				    clabotit.titdtven
				    clabotit.titvlcob
				    with frame fmos width 40 1 column
					      title " Titulo Gerado " overlay
					      centered row 10.
			end.
			else
			    labotit.titdesc = titulo.titvlcob - titulo.titvlpag.
		end.
		find cobra of labotit.
		if cobra.cobban
		then do with frame fbancpg :
			update labotit.titbanpag .
			find banco where banco.bancod = labotit.titbanpag.
			display bandesc .
			update labotit.titagepag .
			find agenc of banco
			    where agenc.agecod = labotit.titagepag.
			display agedesc no-label.
			update labotit.titchepag.
		end.
		assign labotit.titsit = "PAG".
	       end.
	       recatu1 = recid(titulo).
	       leave.
	      end.
	      else
		if  labotit.titsit = "PAG" then do:
		    {segur.i 3}
		    display labotit.titnum
			    labotit.titpar
			    labotit.titdtemi
			    labotit.titdtven
			    labotit.titvlcob
			    labotit.cobcod
			    with frame flabotit.
		    labotit.datexp = today.
		    display labotit.titdtpag labotit.titvlpag labotit.cobcod
			    with frame fpag1.
		    message "Confirma o Cancelamento do Pagamento ?"
			    update sresp.
		    if  sresp then do:
			message "Parcela deve ser Impressa ?"
				update sresp.
			assign labotit.titsit    = if  sresp then
						      "IMP"
						  else
						      "LIB"
			       labotit.titdtpag  = ?
			       labotit.titvlpag  = 0
			       labotit.titbanpag = 0
			       labotit.titagepag = ""
			       labotit.titchepag = ""
			       labotit.datexp    = today.
			find first b-titu where
				   b-titu.empcod    =  labotit.empcod and
				   b-titu.titnat    =  labotit.titnat and
				   b-titu.modcod    =  labotit.modcod and
				   b-titu.etbcod    =  labotit.etbcod and
				   b-titu.clifor    =  labotit.clifor and
				   b-titu.titnum    =  labotit.titnum and
				   b-titu.titpar    <> labotit.titpar and
				   b-titu.titparger =  labotit.titpar
				   no-lock no-error.
			if  avail b-titu then do:
			display "Verifique Titulo Gerado do Pagamento Parcial"
				with frame fver color messages
				width 50 overlay row 10 centered.
			    pause.
			end.
		   end.
		   recatu1 = recid(titulo).
		   next bl-princ.
		end.

	    if esqcom2[esqpos2]  = "Data Exportacao"
	    then do:
		display labotit.datexp
			with side-label centered row 10 color white/cyan
			     frame fexpo.
		bell.
		message "Deseja marcar para exportar ?" update sresp.
		if sresp
		then do:
		    find titulo where recid(titulo) = recatu1.
		    labotit.datexp = today.
		end.
	    end.
	    if esqcom2[esqpos2]  = "Bloqueio/Liberacao" and
	       labotit.titsit    <> "PAG"
	    then do:
		if labotit.titsit <> "BLO"
		then do:
		    message "Confirma o Bloqueio do Titulo ?" update sresp.
		    if  sresp then do:
			labotit.titsit = "BLO".
			labotit.datexp = today.
		    end.
		end.
		else
		    if labotit.titsit = "BLO"
		    then do:
			message "Confirma a Liberacao do Titulo ?" update sresp.
			if  sresp then do:
			    labotit.titsit = "IMP".
			    labotit.datexp = today.
			end.
		     end.
	    end.
	  end.
	  view frame frame-a.
	  view frame f-com2 .
	end.
	  if keyfunction(lastkey) = "end-error"
	  then view frame frame-a.
	display
	    labotit.titnum
	    labotit.titpar
	    labotit.titdtemi
	    labotit.titvlcob
	    labotit.titdtven
	    labotit.titdtpag
	    labotit.titvlpag when labotit.titvlpag > 0
	    labotit.titsit
		    with frame frame-a.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	else display esqcom2[esqpos2] with frame f-com2.
	recatu1 = recid(titulo).
   end.
end.
end.
