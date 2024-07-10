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


def buffer btcocod      for comis.
def var vtcocod         like comis.tcocod.
    form
     tcocom[1] label "Comis."  colon 10 tcoven[1]  label "Venda Lim." colon 30
	tcocom[2]  no-label      colon 12 tcoven[2]  no-label      colon 32
	tcocom[3]  no-label      colon 12 tcoven[3]  no-label      colon 32
	tcocom[4]  no-label      colon 12 tcoven[4]  no-label      colon 32
	tcocom[5]  no-label      colon 12 tcoven[5]  no-label      colon 32
	tcocom[6]  no-label      colon 12 tcoven[6]  no-label      colon 32
	tcocom[7]  no-label      colon 12 tcoven[7]  no-label      colon 32
	tcocom[8]  no-label      colon 12 tcoven[8]  no-label      colon 32
	tcocom[9]  no-label      colon 12 tcoven[9]  no-label      colon 32
	tcocom[10] no-label      colon 12 tcoven[10] no-label      colon 32
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
	find first comis where
	    true no-error.
    else
	find comis where recid(comis) = recatu1.
	vinicio = yes.
    if not available comis
    then do:
	message "Cadastro de Comissoes Vazio".
	message "Deseja Incluir " update sresp.
	if not sresp
	then undo.
	do with frame f-inclui1  overlay row 6 centered.
		create comis.
		update tcocod.
		update comis.tcocom[1] label "COMIS."     colon 8
		       comis.tcoven[1] label "VENDA LIM." colon 30
		       comis.tcocom[2] colon 10
		       comis.tcoven[2] colon 32
		       comis.tcocom[3] colon 10
		       comis.tcoven[3] colon 32
		       comis.tcocom[4] colon 10
		       comis.tcoven[4] colon 32
		       comis.tcocom[5] colon 10
		       comis.tcoven[5] colon 32
		       comis.tcocom[6] colon 10
		       comis.tcoven[6] colon 32
		       comis.tcocom[7] colon 10
		       comis.tcoven[7] colon 32
		       comis.tcocom[8] colon 10
		       comis.tcoven[8] colon 32
		       comis.tcocom[9] colon 10
		       comis.tcoven[9] colon 32
		     with frame f-altera1 side-labels no-labels
		     title  "TABELA"  + "-" +  string(comis.tcocod).

		       vinicio = no.
	end.
    end.
    clear frame frame-a all no-pause.
    display
	comis.tcocod
	    with frame frame-a 12 down centered.

    recatu1 = recid(comis).
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
	find next comis where
		true.
	if not available comis
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	if vinicio
	then
	down
	    with frame frame-a.
	display
	    comis.tcocod
		with frame frame-a .
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

	find comis where recid(comis) = recatu1.

	choose field comis.tcocod
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
		find next comis where true no-error.
		if not avail comis
		then leave.
		recatu1 = recid(comis).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "page-up"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find prev comis where true no-error.
		if not avail comis
		then leave.
		recatu1 = recid(comis).
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
	    find next comis where
		true no-error.
	    if not avail comis
	    then next.
	    color display normal
		comis.tcocod.
	    if frame-line(frame-a) = frame-down(frame-a)
	    then scroll with frame frame-a.
	    else down with frame frame-a.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev comis where
		true no-error.
	    if not avail comis
	    then next.
	    color display normal
		comis.tcocod.
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
		create comis.
		update comis.tcocod.
		update comis.tcocom[1] label "COMIS."     colon 8
		       comis.tcoven[1] label "VENDA LIM." colon 30
		       comis.tcocom[2] colon 10
		       comis.tcoven[2] colon 32
		       comis.tcocom[3] colon 10
		       comis.tcoven[3] colon 32
		       comis.tcocom[4] colon 10
		       comis.tcoven[4] colon 32
		       comis.tcocom[5] colon 10
		       comis.tcoven[5] colon 32
		       comis.tcocom[6] colon 10
		       comis.tcoven[6] colon 32
		       comis.tcocom[7] colon 10
		       comis.tcoven[7] colon 32
		       comis.tcocom[8] colon 10
		       comis.tcoven[8] colon 32
		       comis.tcocom[9] colon 10
		       comis.tcoven[9] colon 32
		     with frame f-altera1 side-labels no-labels
		title  "TABELA"  + "-" +  string(comis.tcocod).
		recatu1 = recid(comis).
		leave.
	      end.
	    if esqcom1[esqpos1] = "Alteracao"
	    then do with frame f-altera:
		update comis.tcocod.
		update comis.tcocom[1] comis.tcoven[1]
		       comis.tcocom[2] comis.tcoven[2]
		       comis.tcocom[3] comis.tcoven[3]
		       comis.tcocom[4] comis.tcoven[4]
		       comis.tcocom[5] comis.tcoven[5]
		       comis.tcocom[6] comis.tcoven[6]
		       comis.tcocom[7] comis.tcoven[7]
		       comis.tcocom[8] comis.tcoven[8]
		       comis.tcocom[9] comis.tcoven[9]
			with frame f-altera1.
	    end.
	    if esqcom1[esqpos1] = "Consulta" or
	       esqcom1[esqpos1] = "Exclusao"
	    then do with frame f-altera:
		disp   comis.tcocod.
		disp   comis.tcocom[1] comis.tcoven[1]
		       comis.tcocom[2] comis.tcoven[2]
		       comis.tcocom[3] comis.tcoven[3]
		       comis.tcocom[4] comis.tcoven[4]
		       comis.tcocom[5] comis.tcoven[5]
		       comis.tcocom[6] comis.tcoven[6]
		       comis.tcocom[7] comis.tcoven[7]
		       comis.tcocom[8] comis.tcoven[8]
		       comis.tcocom[9] comis.tcoven[9]
			with frame f-altera1.
	    end.
	    if esqcom1[esqpos1] = "Exclusao"
	    then do with frame f-exclui overlay row 6 1 column centered.
		message "Confirma Exclusao de" comis.tcocod update sresp.
		if not sresp
		then leave.
		find next comis where true no-error.
		if not available comis
		then do:
		    find comis where recid(comis) = recatu1.
		    find prev comis where true no-error.
		end.
		recatu2 = if available comis
			  then recid(comis)
			  else ?.
		find comis where recid(comis) = recatu1.
		delete comis.
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
		for each comis:
		    display comis.
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
		comis.tcocod
		    with frame frame-a.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	else display esqcom2[esqpos2] with frame f-com2.
	recatu1 = recid(comis).
   end.
end.
