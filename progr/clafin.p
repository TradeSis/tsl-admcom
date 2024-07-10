/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def var vclase          like clase.clacod.
def var vfinan          like finan.fincod.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
	    initial ["Inclusao","Alteracao","Exclusao","Consulta","Procura"].
def var esqcom2         as char format "x(12)" extent 5
	    initial ["","","","",""].


def buffer bclafin       for clafin.


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
	find first clafin where
	    true no-error.
    else
	find clafin where recid(clafin) = recatu1.
    vinicio = yes.
    if not available clafin
    then do:
	message "Cadastro de clafinidades de Tit. Vazio".
	message "Deseja Incluir " update sresp.
	if not sresp
	then undo.
	do with frame f-inclui1 overlay row 6 side-labels
		      centered color white/red.
		create clafin.
		update clafin.clacod colon 10.
		find clase where clase.clacod = clafin.clacod no-lock.
		disp clase.clanom colon 20 no-label.
		update clafin.fincod colon 10.
		find finan where finan.fincod = clafin.fincod no-lock.
		disp finan.finnom colon 20 no-label.
	  vinicio = no.
	end.
    end.
    clear frame frame-a all no-pause.
    find clase where clase.clacod = clafin.clacod no-lock.
    find finan where finan.fincod = clafin.fincod no-lock.
    disp clafin.clacod
	 clase.clanom
	 clafin.fincod
	 finan.finnom
	    with frame frame-a 14 down centered color white/red.

    recatu1 = recid(clafin).
    color display message
	esqcom1[esqpos1]
	    with frame f-com1.
    repeat:
	find next clafin where
		true.
	if not available clafin
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	if vinicio
	then down
	    with frame frame-a.
	find clase where clase.clacod = clafin.clacod no-lock.
	find finan where finan.fincod = clafin.fincod no-lock.
	disp clafin.clacod
	     clase.clanom
	     clafin.fincod
	     finan.finnom
		with frame frame-a 14 down centered color white/red.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

	find clafin where recid(clafin) = recatu1.

	choose field clafin.clacod
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
		find next clafin where true no-error.
		if not avail clafin
		then leave.
		recatu1 = recid(clafin).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "page-up"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find prev clafin where true no-error.
		if not avail clafin
		then leave.
		recatu1 = recid(clafin).
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
	    find next clafin where
		true no-error.
	    if not avail clafin
	    then next.
	    color display normal
		clafin.clacod.
	    if frame-line(frame-a) = frame-down(frame-a)
	    then scroll with frame frame-a.
	    else down with frame frame-a.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev clafin where
		true no-error.
	    if not avail clafin
	    then next.
	    color display normal
		clafin.clacod.
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
	    then do with frame f-inclui overlay row 6 side-labels
		      centered color white/red.
		create clafin.
		update clafin.clacod colon 10.
		find clase where clase.clacod = clafin.clacod no-lock.
		disp clase.clanom colon 20 no-label.
		update clafin.fincod colon 10.
		find finan where finan.fincod = clafin.fincod no-lock.
		disp finan.finnom colon 20 no-label.
		recatu1 = recid(clafin).
		leave.
	    end.
	    if esqcom1[esqpos1] = "Alteracao"
	    then do with frame f-altera overlay row 6 1 column centered.
		update clafin with frame f-altera no-validate.
	    end.
	    if esqcom1[esqpos1] = "Consulta"
	    then do with frame f-consulta overlay row 6 1 column centered.
		find clase where clase.clacod = clafin.clacod no-lock.
		find finan where finan.fincod = clafin.fincod no-lock.
		disp clafin.clacod
		     clase.clanom
		     clafin.fincod
		     finan.finnom
		with frame frame-a 14 down centered color white/red.
	    end.
	    if esqcom1[esqpos1] = "Exclusao"
	    then do with frame f-exclui overlay row 6 1 column centered.
		message "Confirma Exclusao de" clafin.clacod clafin.fincod
		update sresp.
		if not sresp
		then leave.
		find next clafin where true no-error.
		if not available clafin
		then do:
		    find clafin where recid(clafin) = recatu1.
		    find prev clafin where true no-error.
		end.
		recatu2 = if available clafin
			  then recid(clafin)
			  else ?.
		find clafin where recid(clafin) = recatu1.
		delete clafin.
		recatu1 = recatu2.
		leave.
	    end.
	    if esqcom1[esqpos1] = "Procura"
	    then do with frame f-Lista overlay row 6 1 column centered.
		update vclase label "Clase"
		       vfinan label "Finan." with frame f-clafin centered
					side-label row 15 overlay.
		find clafin where clafin.clacod = vclase and
				  clafin.fincod = vfinan no-lock no-error.
		if not avail clafin
		then do:
		    message "Registro nao Cadastrado".
		    undo, leave.
		end.
		/* recatu2 = recatu1. */
		recatu1 = recid(clafin). /* recatu2. */
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
	find clase where clase.clacod = clafin.clacod no-lock.
	find finan where finan.fincod = clafin.fincod no-lock.
	disp clafin.clacod
	     clase.clanom
	     clafin.fincod
	     finan.finnom
		with frame frame-a 14 down centered color white/red.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	else display esqcom2[esqpos2] with frame f-com2.
	recatu1 = recid(clafin).
   end.
end.
