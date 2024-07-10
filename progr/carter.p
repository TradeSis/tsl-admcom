/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
	    initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
	    initial ["","","","",""].


def buffer bcarano      for carteira.
def var vcarano         like carteira.carano.
    form
     carval[1] label "Comis."
	carval[2]  no-label
	carval[3]  no-label
	carval[4]  no-label      colon 12
	carval[5]  no-label      colon 12
	carval[6]  no-label      colon 12
	carval[7]  no-label      colon 12
	carval[8]  no-label      colon 12
	carval[9]  no-label      colon 12
	carval[10] no-label      colon 12
	carval[11]  no-label      colon 12
	carval[12] no-label      colon 12
	with frame inclu2 overlay side-label .
    form
	esqcom1
	    with frame f-com1
		 row 4 no-box no-labels side-labels column 1.
    form
	esqcom2
	    with frame f-com2
		 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
	find first carteira where
	    true no-error.
    else
	find carteira where recid(carteira) = recatu1.
	vinicio = yes.
    if not available carteira
    then do:
	message "Cadastro de carteiras Vazio".
	message "Deseja Incluir " update sresp.
	if not sresp
	then undo.
	do with frame f-inclui1  overlay row 6 centered.
		create carteira.
		update etbcod carano titnat modcod.
		update carteira.carval[1] label "Jan"
		       carteira.carval[2] label "Fev"
		       carteira.carval[3] label "Mar"
		       carteira.carval[4] label "Abr"
		       carteira.carval[5] label "Mai"
		       carteira.carval[6] label "Jun"
		       carteira.carval[7] label "Jul"
		       carteira.carval[8] label "Ago"
		       carteira.carval[9] label "Set"
		       carteira.carval[10] label "Out"
		       carteira.carval[11] label "Nov"
		       carteira.carval[12] label "Dez"
		     with frame f-altera1 side-labels
		     title  " Carteira"  + " - " +  string(carteira.carano).

		       vinicio = no.
	end.
    end.
    clear frame frame-a all no-pause.
    display
	carteira.carano
	carteira.etbcod
	carteira.modcod
	carteira.titnat
	    with frame frame-a 12 down centered.

    recatu1 = recid(carteira).
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
	find next carteira where
		true.
	if not available carteira
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	if vinicio
	then
	down
	    with frame frame-a.
	display
	carteira.carano
	carteira.etbcod
	carteira.modcod
	carteira.titnat
		with frame frame-a .
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

	find carteira where recid(carteira) = recatu1.

	choose field carteira.carano
	    go-on(cursor-down cursor-up
		  cursor-left cursor-right
		  page-down page-up
		  tab PF4 F4 ESC return).
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
		esqpos2 = if esqpos2 = 5
			  then 5
			  else esqpos2 + 1.
		color display messages
		    esqcom2[esqpos2]
		    with frame f-com2.
	    end.
	    next.
	end.

	if keyfunction(lastkey) = "page-down"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find next carteira where true no-error.
		if not avail carteira
		then leave.
		recatu1 = recid(carteira).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "page-up"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find prev carteira where true no-error.
		if not avail carteira
		then leave.
		recatu1 = recid(carteira).
	    end.
	    leave.
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
	    find next carteira where
		true no-error.
	    if not avail carteira
	    then next.
	    color display normal
		carteira.carano.
	    if frame-line(frame-a) = frame-down(frame-a)
	    then scroll with frame frame-a.
	    else down with frame frame-a.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev carteira where
		true no-error.
	    if not avail carteira
	    then next.
	    color display normal
		carteira.carano.
	    if frame-line(frame-a) = 1
	    then scroll down with frame frame-a.
	    else up with frame frame-a.
	end.
	if keyfunction(lastkey) = "end-error"
	then leave bl-princ.

	if keyfunction(lastkey) = "return"
	then do on error undo, retry on endkey undo, leave.
	hide frame frame-a no-pause.
	  form with frame f-altera.
	  form with frame f-altera1 centered.
	  if esqregua
	  then do:
	    display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
		with frame f-com1.

	    if esqcom1[esqpos1] = "Inclusao"
	    then do with frame f-altera overlay row 6 2 col centered:
		create carteira.
		update etbcod carano titnat modcod.
		update carteira.carval[1]
		       carteira.carval[2]
		       carteira.carval[3]
		       carteira.carval[4]
		       carteira.carval[5]
		       carteira.carval[6]
		       carteira.carval[7]
		       carteira.carval[8]
		       carteira.carval[9]
		       carteira.carval[10]
		       carteira.carval[11]
		       carteira.carval[12]
		     with frame f-altera1 side-labels no-labels.
		recatu1 = recid(carteira).
		leave.
	      end.
	    if esqcom1[esqpos1] = "Alteracao"
	    then do with frame f-altera:
		update etbcod  carano titnat modcod.
		update carteira.carval[1]
		       carteira.carval[2]
		       carteira.carval[3]
		       carteira.carval[4]
		       carteira.carval[5]
		       carteira.carval[6]
		       carteira.carval[7]
		       carteira.carval[8]
		       carteira.carval[9]
		       carteira.carval[10]
		       carteira.carval[11]
		       carteira.carval[12]
			with frame f-altera1.
	    end.
	    if esqcom1[esqpos1] = "Consulta" or
	       esqcom1[esqpos1] = "Exclusao"
	    then do with frame f-altera:
		disp etbcod  carano titnat modcod.
		disp   carteira.carval[1]
		       carteira.carval[2]
		       carteira.carval[3]
		       carteira.carval[4]
		       carteira.carval[5]
		       carteira.carval[6]
		       carteira.carval[7]
		       carteira.carval[8]
		       carteira.carval[9]
		       carteira.carval[10]
		       carteira.carval[11]
		       carteira.carval[12]
			with frame f-altera1.
	    end.
	    if esqcom1[esqpos1] = "Exclusao"
	    then do with frame f-exclui overlay row 6 1 column centered.
		message "Confirma Exclusao de" carteira.carano update sresp.
		if not sresp
		then leave.
		find next carteira where true no-error.
		if not available carteira
		then do:
		    find carteira where recid(carteira) = recatu1.
		    find prev carteira where true no-error.
		end.
		recatu2 = if available carteira
			  then recid(carteira)
			  else ?.
		find carteira where recid(carteira) = recatu1.
		delete carteira.
		recatu1 = recatu2.
		leave.
	    end.
	    if esqcom1[esqpos1] = "Listagem"
	    then do with frame f-Lista overlay row 6 1 column centered.
		message "Confirma Impressao - Tab. de Comissoes" update sresp.
		if not sresp
		then leave.
		recatu2 = recatu1.
		output to printer.
		for each carteira:
		    display carteira.
		end.
		output close.
		recatu1 = recatu2.
		leave.
	    end.

	  end.
	  else do:
	    display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
		with frame f-com2.
	    message esqregua esqpos2 esqcom2[esqpos2].
	    pause.
	  end.
	  view frame frame-a.
	end.
	  if keyfunction(lastkey) = "end-error"
	  then view frame frame-a.
	display
	carteira.carano
	carteira.etbcod
	carteira.modcod
	carteira.titnat
		    with frame frame-a.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	else display esqcom2[esqpos2] with frame f-com2.
	recatu1 = recid(carteira).
   end.
end.
