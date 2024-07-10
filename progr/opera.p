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


def buffer bOPERA       for OPERA.
def var vOPEcod         like OPERA.OPEcod.


    form
	esqcom1
	    with frame f-com1
		 row 3 no-box no-labels side-labels column 1.
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
	find first OPERA where
	    true no-error.
    else
	find OPERA where recid(OPERA) = recatu1.
	vinicio = yes.
    if not available OPERA
    then do:
	message "Cadastro de Operadores Vazio".
	message "Deseja Incluir " update sresp.
	if not sresp
	then undo.
	do with frame f-inclui1  overlay row 6 1 column centered
	    color white/cyan.
		create OPERA.
		update OPERA except opecod.

	    find last bopera exclusive-lock no-error.
	    if available bopera
	    then assign vopecod = bopera.opecod.
	    else assign vopecod = 0.
	    {di.v 1 "vopecod"}
	    assign opera.opecod = vopecod.
	    vinicio = no.
	end.
    end.
    clear frame frame-a all no-pause.
    display
  opera.opecod FORMAT ">>>9" LABEL "Operador"
  opera.openom FORMAT "x(15)" LABEL "Nome Oper."
  opera.openiv FORMAT "Operador/Supervisor" LABEL "Nivel Oper."
  opera.opesenha FORMAT "x(10)" LABEL "Senha Oper."
  opera.opatual FORMAT "sim/nao"
	    with frame frame-a 14 down centered color white/red.

    recatu1 = recid(OPERA).
    color display message
	esqcom1[esqpos1]
	    with frame f-com1.
    repeat:
	find next OPERA where
		true.
	if not available OPERA
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	if vinicio
	then
	down
	    with frame frame-a.
	display
  opera.opecod FORMAT ">>>9" LABEL "Operador"
  opera.openom FORMAT "x(15)" LABEL "Nome Oper."
  opera.openiv FORMAT "Operador/Supervisor" LABEL "Nivel Oper."
  opera.opesenha FORMAT "x(10)" LABEL "Senha Oper."
  opera.opatual FORMAT "sim/nao"
		with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

	find OPERA where recid(OPERA) = recatu1.

	choose field OPERA.OPEnom
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
		find next opera where true no-error.
		if not avail opera
		then leave.
		recatu1 = recid(opera).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "page-up"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find prev opera where true no-error.
		if not avail opera
		then leave.
		recatu1 = recid(opera).
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
	    find next OPERA where
		true no-error.
	    if not avail OPERA
	    then next.
	    color display white/red
		OPERA.OPEnom.
	    if frame-line(frame-a) = frame-down(frame-a)
	    then scroll with frame frame-a.
	    else down with frame frame-a.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev OPERA where
		true no-error.
	    if not avail OPERA
	    then next.
	    color display white/red
		OPERA.OPEnom.
	    if frame-line(frame-a) = 1
	    then scroll down with frame frame-a.
	    else up with frame frame-a.
	end.
	if keyfunction(lastkey) = "end-error"
	then leave bl-princ.

	if keyfunction(lastkey) = "return"
	then do on error undo, retry on endkey undo, leave.
	hide frame  frame-a no-pause.

	  if esqregua
	  then do:
	    display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
		with frame f-com1.

	    if esqcom1[esqpos1] = "Inclusao"
	    then do with frame f-inclui overlay row 6 1 column centered
		color white/cyan.
		create OPERA.
		update OPERA except opera.opecod.

		find last bopera exclusive-lock no-error.
		if available bopera
		then assign vopecod = bopera.opecod.
		else assign vopecod = 0.
		{di.v 2 "vopecod"}
		assign opera.opecod = vopecod
		recatu1 = recid(OPERA).
		leave.
	    end.
	    if esqcom1[esqpos1] = "Alteracao"
	    then do with frame f-altera overlay row 6 1 column centered
		color white/cyan.
		display opera.opecod.
		update  OPERA  except opera.opecod
			with frame f-altera no-validate.
	    end.
	    if esqcom1[esqpos1] = "Consulta" or
	       esqcom1[esqpos1] = "Exclusao"
	    then do with frame f-consulta overlay row 6 1 column centered
		color white/cyan.
		disp OPERA with frame f-consulta no-validate.
	    end.
	    if esqcom1[esqpos1] = "Exclusao"
	    then do with frame f-exclui overlay row 6 1 column centered.
		message "Confirma Exclusao de" OPERA.OPEnom update sresp.
		if not sresp
		then leave.
		find next OPERA where true no-error.
		if not available OPERA
		then do:
		    find OPERA where recid(OPERA) = recatu1.
		    find prev OPERA where true no-error.
		end.
		recatu2 = if available OPERA
			  then recid(OPERA)
			  else ?.
		find OPERA where recid(OPERA) = recatu1.
		delete OPERA.
		recatu1 = recatu2.
		leave.
	    end.
	    if esqcom1[esqpos1] = "Listagem"
	    then do with frame f-Lista overlay row 6 1 column centered.
		message "Confirma Impressao de Operadores" update sresp.
		if not sresp
		then leave.
		recatu2 = recatu1.
		output to printer.
		for each OPERA:
		    display OPERA.
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
  opera.opecod FORMAT ">>>9" LABEL "Operador"
  opera.openom FORMAT "x(15)" LABEL "Nome Oper."
  opera.openiv FORMAT "Operador/Supervisor" LABEL "Nivel Oper."
  opera.opesenha FORMAT "x(10)" LABEL "Senha Oper."
  opera.opatual FORMAT "sim/nao"
		    with frame frame-a.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	else display esqcom2[esqpos2] with frame f-com2.
	recatu1 = recid(OPERA).
   end.
end.
