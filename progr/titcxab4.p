/****************************************************************************
**  Programa        : titcxab4.p
**  Ultima Alteracao: 26/09/95
**                    Richard - Autenticacao dos pagamentos
****************************************************************************/
{admcab.i}
def buffer htitulo for titulo.
def input parameter vrecag as char.
def var co as int.
def var reccont         as  int.
def var vinicio         as  log initial no.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var de-vlpri        as dec.
def var de-vltit        as dec.
def var esqcom1         as char format "x(12)" extent 6
	    initial [" Pagamento "," "," Cliente ","","","Extrato"] .
def var esqcom2         as char format "x(23)" extent 2
	    initial [" Altera Dados Clientes ",""].
def buffer bmoeda       for moeda.
def buffer btitulo      for titulo.
def buffer ctitulo      for titulo.
def buffer bevent       for event.
def var vclicodlab      as char format "x(12)".
def var vclicodnom      as char format "x(30)".
def var wperdes         as dec format ">9.99 %" label "Perc. Desc.".
def var wperjur         as dec format ">9.99 %" label "Perc. Juros".
def var vtitvlpag       like titulo.titvlpag.
def var vtitvlcob       like titulo.titvlcob.
def var vvldevido       like titulo.titvlpag.
def var vdivida         like titulo.titvlcob.
def var vclicod         like clien.clicod.
def var i-dia           as int format ">>>9"                        no-undo.
def var de-desc         as dec                                      no-undo.
def var vrec as recid.

def var totalizador like titulo.titvlcob.

form esqcom1
    with frame f-com1
    row 3 no-box no-labels side-labels column 1.
form esqcom2
    with frame f-com2
	row 14 no-labels no-box .
FORM
    titulo.modcod   colon 15
    modal.modnom     no-label
    titulo.titnum     colon 15
    titulo.titpar     label "Parc"
    titulo.titvlcob   colon 15
    with frame ftitulo
	overlay row 7 color
	white/cyan side-label width 39.

form
    clien.clinom      label "Nome"             colon 7
    clien.endereco[1]  label "Rua"             colon 7
    space(0) ", " space(0)
    clien.numero[1]    no-label
    clien.compl[1]     label "Comp."           colon 7
    clien.bairro[1]    label "Bairro"          colon 7
    clien.cep[1]       label "CEP"             colon 7
    clien.fone           label "Fone"            colon 7
    with frame fres overlay side-label row 14 no-hide
	 title " Dados do Cliente " color white/cyan.

form
    titulo.titdtpag     colon 13 label "Dt.Pagam"
    moeda.moecod       colon 13 label "Moeda"
    moeda.moenom    no-label
    titulo.titvlcob     colon 13 label "Vl. Cobrado"
    titulo.titjuro     colon 13
    vtitvlpag           colon 13 label "Valor"
    with frame fpag1 side-label
	 row 7 color white/cyan
	 overlay column 42 width 39 title " Pagamento " .
l-1:
REPEAT:
hide frame fres no-pause.
/* run evench.p (output vrec). if vrec = 0 then do: pause 0. LEAVE. end. */
find event where evecod = 108 no-lock. /*recid(event) = vrec*/ .
find caixa where caixa.etbcod = setbcod and
		 caixa.cxacod = scxacod no-lock.
if caixa.cxdata > today then do on endkey undo:
    message "Data da Maquina Incorreta".
    pause.
    return.
end.
if caixa.cxdata  < today and caixa.situacao = yes
then do on endkey undo:
    bell.
    message "Caixa Nao Foi Fechada no dia Anterior".
    pause.
    return.
end.
if caixa.cxdata <= today and caixa.situacao = no then do:
    message "Caixa Fechado. Deseja Abrir ?" update sresp.
    if sresp
    then run abrecxa.p.
    else return.
end.
if  caixa.cxdata  <= today and caixa.situacao = no    then return.
find bmoeda of caixa no-lock.
    vclicodlab = if event.evenat
		 then "Fornecedor:"
		 else "   Cliente:".
    if vrecag = ?
    then do with frame ff1 side-labels row 5 width 80 color white/cyan.
	display vclicodlab no-labels to 19 with frame ff1.
	prompt-for clien.clicod no-label with frame ff1.
	find first clien where clien.clicod = input clien.clicod.
    end.
    else
	find clien where recid(clien) = int(vrecag).

    vclicod = clien.clicod .
    vclicodnom = clien.clinom.
vdivida = 0.
if vclicod <> 1
then do:
    for each titulo use-index iclicod where
			titulo.clifor     = vclicod no-lock.
	if titulo.titsit = "LIB"
	then vdivida = vdivida + titulo.titvlcob.
    end.
    if  vdivida = 0
    then do:
	hide frame frame-a no-pause.
	hide frame f-com1  no-pause.
	hide frame f-com2  no-pause.
	hide frame fpag1   no-pause.
	hide frame fres    no-pause.
	hide frame fdivida no-pause.
	hide frame faut    no-pause.
	return.
    end.
end.
display
	vdivida         label "Divida" when vclicod <> 1
	with frame fdivida
	     row screen-lines - 5 column 60
	     color white/cyan.
form    totalizador label "Total"
	with frame ftotal no-box
	     row screen-lines - 7 column 55
	     color white/cyan side-label.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1
    recatu1  = ?.
hide frame f-com1 no-pause.
hide frame f-com2 no-pause.
bl-princ:
repeat :
    display clien.clinom
	    clien.endereco[1]
	    clien.numero[1]
	    clien.compl[1]
	    clien.bairro[1]
	    clien.cep[1]
	    clien.fone
	    with frame fres.

    disp esqcom1 with frame f-com1.
    if  recatu1 = ? then
	find first titulo where
			    titulo.clifor   = vclicod       and
			    titulo.titsit   = "LIB"
				no-error.
    else
	find titulo where recid(titulo) = recatu1.
    vinicio = no.
    if not available titulo
    then do:
	message "Cliente nao Possui Titulos Cadastrados".
	pause.
	next l-1.
    end .
    clear frame frame-a all no-pause.
    display
	 titulo.titnum
	 titulo.titpar
	 titulo.etbcod column-label "Est" format ">>9"
    /*   titulo.modcod  */
	 titulo.titdtemi format "99/99/99"   column-label "Dt.Emis"
	 titulo.titvlcob format ">>,>>>,>>9.99" column-label "Valor Cobrado"
	 titulo.titdtven format "99/99/99"   column-label "Dt.Venc"
	 titulo.titdtpag format "99/99/99"   column-label "Dt.Pagto"
	 titulo.titvlpag when titulo.titvlpag > 0 format ">>,>>>,>>9.99"
					       column-label "Valor Pago"
	 titulo.titsit
	 with frame frame-a 4 down centered
	      color white/red row 5 width 80 title event.evenom.

    recatu1 = recid(titulo).
    if esqregua
    then do:
	display esqcom1[esqpos1] with frame f-com1.
	color  display message esqcom1[esqpos1] with frame f-com1.
    end.
    else do:
	display esqcom2[esqpos2] with frame f-com2.
	color display message esqcom2[esqpos2] with frame f-com2.
    end.
    repeat:
	find next titulo
		use-index iclicod where
		titulo.clifor     = vclicod and
		titulo.titsit     = "LIB"
		no-error.
	if  not available titulo then
	    leave.
	if  frame-line(frame-a) = frame-down(frame-a) then
	    leave.
	if  not vinicio then down with frame frame-a.
	    display
		titulo.titnum
		titulo.titpar
		titulo.etbcod column-label "Est" format ">>9"
	  /*    titulo.modcod   */
		titulo.titdtemi
		titulo.titvlcob
		titulo.titdtven
		titulo.titdtpag
		titulo.titvlpag when titulo.titvlpag > 0
		titulo.titsit
		with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

	find titulo where recid(titulo) = recatu1.

	color display messages
	    titulo.titpar.
	choose field titulo.titnum PAUSE 20
	    go-on(cursor-down cursor-up
		  page-down page-up
		  cursor-left cursor-right
		  PF4 F4 ESC return).
	if  lastkey = -1 then do:
	    recatu1 = ?.
	    leave.
	end.

	if keyfunction(lastkey) = "TAB"
	then do:
	    if esqregua
	    then do:
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
	if keyfunction(lastkey) = "cursor-right"
	then do:
	    if esqregua
	    then do:
		color display normal
		    esqcom1[esqpos1]
		    with frame f-com1.
		esqpos1 = if esqpos1 = 6
			  then 6
			  else esqpos1 + 1.
		color display messages
		    esqcom1[esqpos1]
		    with frame f-com1.
	    end.
	    else do:
		color display normal
		    esqcom2[esqpos2]
		    with frame f-com2.
		esqpos2 = if esqpos2 = 2
			  then 2
			  else esqpos2 + 1.
		color display messages
		    esqcom2[esqpos2]
		    with frame f-com2.
	    end.
	    next.
	end.
	if keyfunction(lastkey) = "cursor-left"
	then do:
	    if esqregua
	    then do:
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
	if keyfunction(lastkey) = "cursor-down"
	then do:
	    find next titulo where
			    titulo.clifor   = vclicod       and
			    titulo.titsit   = "LIB"
		no-error.
	    if not avail titulo
	    then next.
	    color display white/red
		titulo.titnum titulo.titpar.
	    if frame-line(frame-a) = frame-down(frame-a)
	    then scroll with frame frame-a.
	    else down with frame frame-a.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev titulo where
			    titulo.clifor   = vclicod       and
			    titulo.titsit   = "LIB"
		no-error.
	    if not avail titulo
	    then next.
	    color display white/red
		titulo.titnum titulo.titpar.
	    if frame-line(frame-a) = 1
	    then scroll down with frame frame-a.
	    else up with frame frame-a.
	end.
	if keyfunction(lastkey) = "page-down"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find next titulo where
			    titulo.clifor   = vclicod       and
			    titulo.titsit   = "LIB"
			no-error.
		if not avail titulo
		then leave.
		recatu1 = recid(titulo).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "page-up"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find prev titulo where
			    titulo.clifor   = vclicod       and
			    titulo.titsit   = "LIB"
			no-error.
		if not avail titulo
		then leave.
		recatu1 = recid(titulo).
	    end.
	    leave.
	end.

	if keyfunction(lastkey) = "end-error"
	then do:
	    co = 0.
	    for each  btitulo where btitulo.clifor     = vclicod no-lock.
		if btitulo.titsit = "LIB" and
		   btitulo.titpar = 0
		then do:
		    co = co  + 1.  leave. end.
	    end.
	    if co > 1
	    then do:
		message "Entrada nao foi paga".
		recatu1 = recid(btitulo). clear frame frame-a all.
		next bl-princ.
	    end.
	    if event.evepag
	    then do:
		if vdivida > 0
		then do:
		    message event.evenom " com titulos nao PAGOS ".
		    pause 3 no-message.
		end.
	    end.
	    hide frame frame-a no-pause.
	    hide frame f-com1  no-pause.
	    hide frame f-com2  no-pause.
	    hide frame fpag1   no-pause.
	    hide frame fres    no-pause.
	    hide frame fdivida no-pause.
	    hide frame faut    no-pause.
	    return.
	end.

	if keyfunction(lastkey) = "return"
	then do on error undo, retry on endkey undo, leave.
	  if esqcom1[esqpos1] <> " Cliente "
	  then do:
	    clear frame ftitulo all.
	    clear frame fpag1 all.
	    hide  frame frame-a no-pause.

	    display vclicodlab at 6 vclicodnom
		    with frame frame-b 1 down centered color blue/gray
		    width 81 no-box no-label row 5 overlay.
	  end.
	  if esqregua
	  then do:

	    if  esqcom1[esqpos1] = " Inclusao " then do with frame ftitulo:
		create titulo.
		assign
		    titulo.etbcod = setbcod
		    titulo.titnat = event.evenat
		    titulo.etbcod = setbcod
		    titulo.cxacod = scxacod.
		assign
		    titulo.clifor = vclicod
		    titulo.titdtemi = today
		    titulo.titdtven = today
		    titulo.datexp   = today.
		update titulo.modcod.
		find modal of titulo no-lock.
		display modal.modnom.
		update titulo.titnum
		       titulo.titpar
		       titulo.titvlcob.
		find first cobra where cobra.cobban = no no-lock.
		titulo.cobcod = cobra.cobcod.
		update text(titobs) with frame fobs .
		pause 0.
		vdivida = vdivida + titvlcob.
		disp vdivida  when vclicod <> 1
		with frame fdivida.
		recatu1 = recid(titulo).
		leave.
	    end.
	    if  esqcom1[esqpos1] = "Extrato"
	    then do:
		run extrato.p (input recid(clien)).
		recatu1 = ?.
		leave.
		pause 0.
	    end.
	    if  esqcom1[esqpos1] = " Pagamento " or
		esqcom1[esqpos1] = " Inclusao " then do
		with frame fpag11 with column 45 side-labels row 8
		     color white/cyan .
		find modal of titulo no-lock no-error.
		display titulo.modcod    colon 13
			modal.modnom    no-label when avail modal
			titulo.titnum    colon 13
			titulo.titpar    colon 33 label "Pc"
			titulo.titvlcob  colon 13 label "Vl.Cobr."
			with frame fdadpg side-label
			overlay row 7 color white/red width 40
			title " Titulo ".
		if  titulo.titsit <> "LIB" and titulo.titsit <> "IMP" then do:
		    bell.
		    message "Titulo com situacao ilegal para Pagamento,"
			    titulo.titsit.
		    pause.
		    leave.
		end.
		assign titulo.titdtpag = today
		       titulo.etbcobra = setbcod
		       titulo.datexp   = today
		       titulo.cxmdata  = today
		       titulo.cxacod   = scxacod.
		update titulo.titdtpag with frame fpag1.
		/*
		find first htitulo where htitulo.empcod = titulo.empcod and
					 htitulo.titnat = titulo.titnat and
					 htitulo.modcod = titulo.modcod and
					 htitulo.titdtven < titulo.titdtven and
					 htitulo.etbcod = titulo.etbcod and
					 htitulo.clifor = titulo.clifor and
					 htitulo.titsit = "LIB" no-error.
		if avail htitulo then do:
		    message "Cliente possui Titulos atrasados antes deste.".
		    pause.
		    undo,retry.
		end.
		*/
		if  titulo.titdtpag > titulo.titdtven then do:
		    find tabjur where
			 tabjur.numdia = titulo.titdtpag - titulo.titdtven
			 no-lock no-error.
		    if  not avail tabjur then do:
			message "Fator para" titulo.titdtpag - titulo.titdtven
				"dias de atraso, nao cadastrado".
			pause.
			undo.
		    end.
		    assign titulo.titvlpag = titulo.titvlcob * tabjur.fator
			   titulo.titjuro = titulo.titvlpag - titulo.titvlcob.
		end.
		else
		/*  if  titulo.titdtpag <= titulo.titdtdes then do:
			titulo.titvlpag = titulo.titvlcob - (titulo.titvldes *
				    ((titulo.titdtdes - titulo.titdtpag) + 1)).
		    end.
		    else      */
		       titulo.titvlpag = titulo.titvlcob .
		assign vtitvlpag = titulo.titvlpag
		       vvldevido = titulo.titvlpag.
		display bmoeda.moecod @ moeda.moecod
			with frame fpag1.
		prompt-for moeda.moecod
			   with frame fpag1.
		find moeda using moeda.moecod.
		disp moeda.moenom no-label
		     with frame fpag1.
		titulo.moecod = moeda.moecod.
		disp titulo.titvlcob
		     titulo.titjuro
		     with frame fpag1.
		update vtitvlpag
		       with frame fpag1.
		find first cobra where cobra.cobban = no.
		titulo.cobcod = cobra.cobcod.
		if  vtitvlpag > vvldevido then do:
		    find first bevent where bevent.troco = yes no-lock.
		    find salcxa where
			salcxa.etbcod = setbcod and
			salcxa.etbcod = caixa.etbcod  and
			salcxa.cxacod = caixa.cxacod  and
			salcxa.saldt  = today         and
			salcxa.evecod = bevent.evecod and
			salcxa.moecod = caixa.moecod
		    no-error.
		    if not available salcxa
		    then do:
			create salcxa.
			assign
			    salcxa.etbcod = setbcod
			    salcxa.etbcod = caixa.etbcod
			    salcxa.cxacod = caixa.cxacod
			    salcxa.saldt  = today
			    salcxa.evecod = bevent.evecod
			    salcxa.moecod = Bmoeda.moecod.
		    end.
		    salcxa.saldo = salcxa.saldo + vtitvlpag -
						  titulo.titvlpag.
		    bell.
		    display "Valor do Troco - Cr$ "
			vtitvlpag - titulo.titvlpag no-label
		       with overlay frame ftro row 18  color white/red
		       column 35 title " Troco " centered.
		    do on endkey undo:
		       pause.
		    end.
		    vtitvlpag = vtitvlpag - (vtitvlpag - titulo.titvlpag).
		end.
		else
		  if  vtitvlpag <  vvldevido then do:
		      assign sresp = no.
		      display "  Confirma PAGAMENTO PARCIAL ?"
			      with frame fpag color messages
			      width 40 overlay row 10 centered.
		    update sresp no-label with frame fpag.
		    if  sresp then do:
			if  titulo.titdtven < today then do:
			    assign i-dia = today - titulo.titdtven.
			    find tabjur where
				 tabjur.numdia = i-dia no-lock no-error.
			    assign de-vlpri = vtitvlpag / tabjur.fator
				   de-vltit = titulo.titvlcob - de-vlpri.
			    find last btitulo where
				      btitulo.empcod   = 19             and
				      btitulo.titnat   = event.evenat   and
				      btitulo.modcod   = "CRE"          and
				      btitulo.etbcod   = setbcod        and
				      btitulo.clifor   = vclicod        and
				      btitulo.titnum   = titulo.titnum.
			    pause.
			    create ctitulo.
			    assign
				ctitulo.empcod = btitulo.empcod
				ctitulo.cxacod = scxacod
				ctitulo.titnat = btitulo.titnat
				ctitulo.modcod = btitulo.modcod
				ctitulo.etbcod = btitulo.etbcod
				ctitulo.clifor = btitulo.clifor
				ctitulo.titnum = btitulo.titnum
				ctitulo.titpar = btitulo.titpar + 1
				ctitulo.cobcod = titulo.cobcod
				ctitulo.titdtemi = titulo.titdtemi
				ctitulo.titdtven = titulo.titdtven
				ctitulo.datexp   = today
				ctitulo.titvlcob = de-vltit
				ctitulo.titnumger = titulo.titnum
				ctitulo.titparger = titulo.titpar
				vdivida = vdivida + ctitulo.titvlcob.
			    disp vdivida when vclicod <> 1
				    with frame fdivida.
			    display
				    ctitulo.titnum
				    ctitulo.titpar
				    ctitulo.titdtemi
				    ctitulo.titdtven
				    ctitulo.titvlcob
				    with frame fmos width 40 1 column
					      title " Titulo Gerado " overlay
					      centered row 10.
			end.
			else do:
			    find last btitulo where
				      btitulo.etbcod   = setbcod        and
				      btitulo.titnat   = event.evenat   and
				      btitulo.etbcod   = setbcod        and
				      btitulo.clifor   = vclicod        and
				      btitulo.titnum   = titulo.titnum.
			    create ctitulo.
			    assign
				ctitulo.empcod = btitulo.empcod
				ctitulo.etbcod = btitulo.etbcod
				ctitulo.cxacod = scxacod
				ctitulo.modcod = btitulo.modcod
				ctitulo.clifor = btitulo.clifor
				ctitulo.titnat = btitulo.titnat
				ctitulo.etbcod = btitulo.etbcod
				ctitulo.titnum = btitulo.titnum
				ctitulo.cobcod = titulo.cobcod
				ctitulo.titpar   = btitulo.titpar + 1
				ctitulo.titdtemi = titulo.titdtemi
				ctitulo.titdtven = titulo.titdtven
				ctitulo.datexp   = today.
			    if  titulo.titdtpag > titulo.titdtven then
				ctitulo.titvlcob = titulo.titvlcob -
						(vtitvlpag / tabjur.fator).
			    else
				ctitulo.titvlcob = titulo.titvlcob - vtitvlpag.
			    assign
				ctitulo.titnumger = titulo.titnum
				ctitulo.titparger = titulo.titpar.
			end.
			vdivida = vdivida + ctitulo.titvlcob.
			disp vdivida when vclicod <> 1
				with frame fdivida.
			display ctitulo.titnum
				ctitulo.titpar
				ctitulo.titdtemi
				ctitulo.titdtven
				ctitulo.titvlcob
				with frame fmos width 40 1 column
				title " Titulo Gerado " overlay
					      centered row 10.
		    end.
		    if  not sresp then do:
			assign
			    de-desc = vtitvlpag - vvldevido.
			    if  de-desc < 0 then
				de-desc = de-desc * -1.
			    titulo.titdesc = de-desc.
		    end.
		end.
		assign titulo.titsit = "PAG"
		       titulo.titvlpag = vtitvlpag
		       titulo.datexp   = today.
		totalizador = totalizador + titulo.titvlpag.
		vdivida = vdivida - titulo.titvlpag.
		display totalizador
			with frame ftotal.
		disp vdivida when vclicod <> 1
			with frame fdivida.
		recatu1 = recid(titulo).
		find salcxa where
			salcxa.etbcod = setbcod and
			salcxa.etbcod = caixa.etbcod and
			salcxa.cxacod = caixa.cxacod and
			salcxa.saldt  = today        and
			salcxa.evecod = event.evecod and
			salcxa.moecod = Bmoeda.moecod
		    no-error.
		if not available salcxa
		then do:
		    create salcxa.
		    assign
			salcxa.etbcod = setbcod
			salcxa.etbcod = caixa.etbcod
			salcxa.cxacod = caixa.cxacod
			salcxa.saldt  = today
			salcxa.evecod = event.evecod
			salcxa.moecod = Bmoeda.moecod.
		end.
		salcxa.saldo = salcxa.saldo + titulo.titvlpag.
		hide frame frame-a no-pause.
		hide frame fpag1   no-pause.
		hide frame fdadpg  no-pause.
		hide frame ftro    no-pause.
		repeat on endkey undo,retry:
		    disp "  Emite Recibo ?  "
			 with frame frec color messages
			 width 40 overlay row 10 centered.
		    update sresp no-label with frame frec.
		    if  sresp then do:
			run recibb4.p (input(recid(titulo))).
		    end.
		    assign sresp = yes.
		    bell.
		    display "  Confirma Autenticacao ?"
			 with frame faut color messages
				 width 40 overlay row 10 centered.
		    update sresp no-label with frame faut.
		    if  sresp then do:
			output to printer page-size 0.
			put unformatted chr(15)
			    "*"
			    today                         space(1)
			    trim(string(titulo.etbcobra)) space(1)
			    trim(string(titulo.titvlpag,">>>,>>9.99"))
			    "******".
			if titulo.moecod = "PRE"
			then put "  Pagto c/ Pre ***".
			put
			    chr(18) skip(10).
			output close.
		     leave.
		    end.
		end.
		leave.
	    end.
	    if esqcom1[esqpos1] = " Cliente "
	    then do on error undo:
		find clien where clien.clicod  = vclicod.
		update clien.clinom
		       clien.endereco[1]
		       clien.numero[1]
		       clien.compl[1]
		       clien.bairro[1]
		       clien.cep[1]
		       clien.fone
		       with frame fres no-validate.
	    end.
	  end.
	  else do:
	    hide frame f-com2 no-pause.
	  end.
	  view frame frame-a.
	  view frame fres.
	end.
	if keyfunction(lastkey) = "end-error"
	then view frame frame-a.
	display
	    titulo.titnum titulo.titpar
      /*    titulo.modcod  */ titulo.etbcod column-label "Est" format ">>9"
	    titulo.titdtemi
	    titulo.titvlcob titulo.titdtven
	    titulo.titdtpag titulo.titvlpag when titulo.titvlpag > 0
	    titulo.titsit
		    with frame frame-a.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	recatu1 = recid(titulo).
   end.
end.
    hide frame f-com1 no-pause.
END.
