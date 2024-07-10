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


def buffer bdepfil       for depfil.
def var vetbcod         like depfil.etbcod.


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
	find first depfil where
	    true no-error.
    else
	find depfil where recid(depfil) = recatu1.
    vinicio = yes.
    if not available depfil
    then do:
	message "Cadastro de Bancos Vazio".
	message "Deseja Incluir " update sresp.
	if not sresp
	then undo.
	do with frame f-inclui1  overlay row 6 1 column centered.
		create depfil.
		update etbcod
		       bancod
		       agecod
		       conta.
	  vinicio = no.
	end.
    end.
    clear frame frame-a all no-pause.
    find banco where banco.bancod = depfil.bancod no-lock no-error.
    display
	depfil.etbcod
	depfil.bancod
	banco.banfan when avail banco
	depfil.agecod
	depfil.conta
	    with frame frame-a 14 down centered.

    recatu1 = recid(depfil).
    color display message
	esqcom1[esqpos1]
	    with frame f-com1.
    repeat:
	find next depfil where
		true.
	if not available depfil
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	if vinicio
	then down
	    with frame frame-a.
	find banco where banco.bancod = depfil.bancod no-lock no-error.
	display depfil.etbcod
		depfil.bancod
		banco.banfan when avail banco
		depfil.agecod
		depfil.conta with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

	find depfil where recid(depfil) = recatu1.

	choose field depfil.etbcod
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
		find next depfil where true no-error.
		if not avail depfil
		then leave.
		recatu1 = recid(depfil).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "page-up"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find prev depfil where true no-error.
		if not avail depfil
		then leave.
		recatu1 = recid(depfil).
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
	    find next depfil where
		true no-error.
	    if not avail depfil
	    then next.
	    color display normal
		depfil.etbcod.
	    if frame-line(frame-a) = frame-down(frame-a)
	    then scroll with frame frame-a.
	    else down with frame frame-a.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev depfil where
		true no-error.
	    if not avail depfil
	    then next.
	    color display normal
		depfil.etbcod.
	    if frame-line(frame-a) = 1
	    then scroll down with frame frame-a.
	    else up with frame frame-a.
	end.
	if keyfunction(lastkey) = "end-error"
	then leave bl-princ.

	if keyfunction(lastkey) = "return"
	then do on error undo, retry on endkey undo, leave.
	hide frame frame-a no-pause.

	  if esqregua
	  then do:
	    display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
		with frame f-com1.

	    if esqcom1[esqpos1] = "Inclusao"
	    then do with frame f-inclui overlay row 6 1 column centered.
		create depfil.
		update depfil.etbcod
		       depfil.bancod
		       depfil.agecod
		       depfil.conta.
		recatu1 = recid(depfil).
		leave.
	    end.
	    if esqcom1[esqpos1] = "Alteracao"
	    then do with frame f-altera overlay row 6 1 column centered.
		update depfil with frame f-altera no-validate.
	    end.
	    if esqcom1[esqpos1] = "Consulta"
	    then do with frame f-consulta overlay row 6 1 column centered.
		disp depfil with frame f-consulta no-validate.
	    end.
	    if esqcom1[esqpos1] = "Exclusao"
	    then do with frame f-exclui overlay row 6 1 column centered.
		message "Confirma Exclusao de" depfil.bancod update sresp.
		if not sresp
		then leave.
		find next depfil where true no-error.
		if not available depfil
		then do:
		    find depfil where recid(depfil) = recatu1.
		    find prev depfil where true no-error.
		end.
		recatu2 = if available depfil
			  then recid(depfil)
			  else ?.
		find depfil where recid(depfil) = recatu1.
		delete depfil.
		recatu1 = recatu2.
		leave.
	    end.
	    if esqcom1[esqpos1] = "Listagem"
	    then do with frame f-Lista overlay row 6 1 column centered.
		message "Confirma Impressao de depfilidades " update sresp.
		if not sresp
		then leave.
		recatu2 = recatu1.
		output to printer.
		for each depfil:
		    display depfil.
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
	  view frame frame-a .
	end.
	if keyfunction(lastkey) = "end-error"
	then view frame frame-a.
	find banco where banco.bancod = depfil.bancod no-lock no-error.
	display depfil.etbcod
		depfil.bancod
		banco.banfan when avail banco
		depfil.agecod
		depfil.conta with frame frame-a.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	else display esqcom2[esqpos2] with frame f-com2.
	recatu1 = recid(depfil).
   end.
end.
