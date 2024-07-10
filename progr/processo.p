/*
*
*    Esqueletao de PROCESSOcao
*
*/
{admcab.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," Listagem "].
def var esqcom2         as char format "x(12)" extent 5
	    initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de PROCESSO ",
	     " Alteracao da PROCESSO ",
	     " Exclusao  da PROCESSO ",
	     " Consulta  da PROCESSO ",
	     " Listagem  Geral de PROCESSO "].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
	    " ",
	    " ",
	    " ",
	    " "].


def buffer bPROCESSO       for PROCESSO.
def var vPROCESSO         like PROCESSO.PROGRAMA.


    form
	esqcom1
	    with frame f-com1
		 row 3 no-box no-labels side-labels column 1 centered.
    form
	esqcom2
	    with frame f-com2
		 row screen-lines no-box no-labels side-labels column 1
		 centered.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
	find first PROCESSO where
	    true no-error.
    else
	find PROCESSO where recid(PROCESSO) = recatu1.
    if not available PROCESSO
    then do:
	message "Cadastro de PROCESSO Vazio".
	message "Deseja Incluir " update sresp.
	if not sresp
	then undo, leave.
	do with frame f-inclui1  overlay row 4 1 column centered
				 color black/cyan
	     on error undo, leave.
		create PROCESSO.
		update PROCESSO.
	end.
    end.
    clear frame frame-a all no-pause.
    display
	processo.tipo
	PROCESSO.PROGRAMA
	PROCESSO.CAMPO
	processo.executar
	    with frame frame-a 14 down centered color white/red.

    recatu1 = recid(PROCESSO).
    find PROCESSO where recid(PROCESSO) = recatu1.
    color display message
	esqcom1[esqpos1]
	    with frame f-com1.
    repeat:
	find next PROCESSO where
		true.
	if not available PROCESSO
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	down
	    with frame frame-a.
	display
	PROCESSO.PROGRAMA
	PROCESSO.CAMPO
	processo.tipo processo.executar
		with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

	find PROCESSO where recid(PROCESSO) = recatu1.

	status default
	    if esqregua
	    then esqhel1[esqpos1] + if esqpos1 > 1 and
				       esqhel1[esqpos1] <> ""
				    then string(PROCESSO.CAMPO)
				    else ""
	    else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
				    then string(PROCESSO.CAMPO)
				    else "".

	choose field PROCESSO.tipo help ""
	    go-on(cursor-down cursor-up
		  cursor-left cursor-right
		  page-down   page-up
		  tab PF4 F4 ESC return) color white/black.

	status default "".

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
	if keyfunction(lastkey) = "page-down"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find next PROCESSO where
		    true no-error.
		if not avail PROCESSO
		then leave.
		recatu1 = recid(PROCESSO).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "page-up"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find prev PROCESSO where
		    true no-error.
		if not avail PROCESSO
		then leave.
		recatu1 = recid(PROCESSO).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "cursor-down"
	then do:
	    find next PROCESSO where
		true no-error.
	    if not avail PROCESSO
	    then next.
	    color display white/red PROCESSO.tipo.
	    if frame-line(frame-a) = frame-down(frame-a)
	    then scroll with frame frame-a.
	    else down with frame frame-a.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev PROCESSO where
		true no-error.
	    if not avail PROCESSO
	    then next.
	    color display white/red PROCESSO.tipo.
	    if frame-line(frame-a) = 1
	    then scroll down with frame frame-a.
	    else up with frame frame-a.
	end.
	if keyfunction(lastkey) = "end-error"
	then leave bl-princ.

	if keyfunction(lastkey) = "return"
	then do on error undo, retry on endkey undo, leave:
	  hide frame frame-a no-pause.
	  if esqregua
	  then do:
	    display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
		with frame f-com1.

	    if esqcom1[esqpos1] = " Inclusao "
	    then do with frame f-inclui overlay row 4 1 column centered
					color black/cyan:
		create PROCESSO.
		update PROCESSO.
		recatu1 = recid(PROCESSO).
		leave.
	    end.
	    if esqcom1[esqpos1] = " Consulta " or
	       esqcom1[esqpos1] = " Exclusao " or
	       esqcom1[esqpos1] = " Listagem " or
	       esqcom1[esqpos1] = " Alteracao "
	    then do with frame f-consulta overlay row 4 1 column centered
					  color black/cyan:
		disp PROCESSO.
	    end.
	    if esqcom1[esqpos1] = " Alteracao "
	    then do with frame f-altera overlay row 4 1 column centered
					color black/cyan:
		update PROCESSO.
	    end.
	    if esqcom1[esqpos1] = " Exclusao "
	    then do with frame f-exclui overlay row 4 1 column centered.
		message "Confirma Exclusao de" PROCESSO.CAMPO update sresp.
		if not sresp
		then undo, leave.
		find next PROCESSO where true no-error.
		if not available PROCESSO
		then do:
		    find PROCESSO where recid(PROCESSO) = recatu1.
		    find prev PROCESSO where true no-error.
		end.
		recatu2 = if available PROCESSO
			  then recid(PROCESSO)
			  else ?.
		find PROCESSO where recid(PROCESSO) = recatu1.
		delete PROCESSO.
		recatu1 = recatu2.
		leave.
	    end.
	    if esqcom1[esqpos1] = " Listagem "
	    then do with frame f-Lista overlay row 4 1 column centered.
		message "Confirma Impressao de PROCESSO" update sresp.
		if not sresp
		then undo, leave.
		recatu2 = recatu1.
		output to printer.
		for each PROCESSO:
		    display PROCESSO.
		end.
		output close.
		recatu1 = recatu2.
		leave.
	    end.
	  end.
	  else do:
	    if esqcom2[esqpos2] <> ""
	    then do:
		display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
		    with frame f-com2.
		message esqregua esqpos2 esqcom2[esqpos2].
		pause.
	    end.
	  end.
	end.
	display
	PROCESSO.PROGRAMA
	PROCESSO.CAMPO
	processo.tipo processo.executar
		    with frame frame-a.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	else display esqcom2[esqpos2] with frame f-com2.
	recatu1 = recid(PROCESSO).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
	view frame fc1.
	view frame fc2.
    end.
end.
pause 0.
