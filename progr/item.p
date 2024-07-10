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


def buffer bitem        for item.
def buffer witem        for item.
def var vitecod         like item.itecod.
def var witecod         like item.itecod.


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
	find first item where
	    true no-error.
    else
	find item where recid(item) = recatu1.
	vinicio = yes.
    if not available item
    then do:
	message "Tabela de Itens Vazia".
	message "Deseja Incluir " update sresp.
	if not sresp
	then undo.
	do with frame f-inclui1  overlay row 6 1 column centered.
	    create item.
	    update item.itenom
		   item.clacod .
	    find last witem exclusive-lock no-error.
	    if available witem
	    then assign witecod = witem.itecod.
	    else assign witecod = 0.
	    {di.v 1 "witecod"}
	    assign item.itecod = witecod.
	vinicio = no.
	end.
    end.
    clear frame frame-a all no-pause.
    find clase where clase.clacod = item.clacod no-error.
    display
	item.itecod
	item.itenom
	item.clacod
	clase.clanom format "x(20)" column-label "Denominacao" when avail clase
	    with frame frame-a 14 down centered.

    recatu1 = recid(item).
    color display message
	esqcom1[esqpos1]
	    with frame f-com1.
    repeat:
	find next item where
		true.
	if not available item
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	if vinicio
	then
	down
	    with frame frame-a.
	find clase where clase.clacod = item.clacod no-error.
	display
	    item.itecod
	    item.itenom
	    item.clacod
	    clase.clanom when avail clase
		with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

	find item where recid(item) = recatu1.

	choose field item.itecod
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
		find next item where true no-error.
		if not avail item
		then leave.
		recatu1 = recid(item).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "page-up"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find prev item where true no-error.
		if not avail item
		then leave.
		recatu1 = recid(item).
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
	    find next item where
		true no-error.
	    if not avail item
	    then next.
	    color display normal
		item.itecod.
	    if frame-line(frame-a) = frame-down(frame-a)
	    then scroll with frame frame-a.
	    else down with frame frame-a.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev item where
		true no-error.
	    if not avail item
	    then next.
	    color display normal
		item.itecod.
	    if frame-line(frame-a) = 1
	    then scroll down with frame frame-a.
	    else up with frame frame-a.
	end.
	if keyfunction(lastkey) = "end-error"
	then leave bl-princ.

	if keyfunction(lastkey) = "return"
	then do on error undo, retry on endkey undo,leave.
	hide frame frame-a no-pause.

	  if esqregua
	  then do:
	    display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
		with frame f-com1.

	    if esqcom1[esqpos1] = "Inclusao"
	    then do with frame f-inclui overlay row 6 1 column centered.
		create item.
		update item.itenom
		       item.clacod.
		item.itenom = caps(item.itenom).
		find last witem exclusive-lock no-error.
		if available witem
		then assign witecod = witem.itecod.
		else assign witecod = 0.
		{di.v 2 "witecod"}
		assign item.itecod = witecod.
		recatu1 = recid(item) .
		leave.
	    end.
	    if esqcom1[esqpos1] = "Alteracao"
	    then do with frame f-altera overlay row 6 1 column centered.
		update item.itenom
		       item.clacod
		       with frame f-altera .
		item.itenom = caps(item.itenom).
	    end.
	    if esqcom1[esqpos1] = "Consulta"
	    then do with frame f-consulta overlay row 6 1 column centered.
		disp item with frame f-consulta .
	    end.
	    if esqcom1[esqpos1] = "Exclusao"
	    then do with frame f-exclui overlay row 6 1 column centered.
		message "Confirma Exclusao de" item.itenom update sresp.
		if not sresp
		then leave.
		find next item where true no-error.
		if not available item
		then do:
		    find item where recid(item) = recatu1.
		    find prev item where true no-error.
		end.
		recatu2 = if available item
			  then recid(item)
			  else ?.
		find item where recid(item) = recatu1.
		delete item.
		recatu1 = recatu2.
		leave.
	    end.
	    if esqcom1[esqpos1] = "Listagem"
	    then do with frame f-Lista overlay row 6 1 column centered.
		message "Confirma Impressao - Tab. de Itens" update sresp.
		if not sresp
		then leave.
		recatu2 = recatu1.
		output to printer.
		for each item:
		    display item.
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
	find clase where clase.clacod = item.clacod no-error.
	display
		item.itecod
		item.itenom
		item.clacod
		clase.clanom when avail clase
		    with frame frame-a.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	else display esqcom2[esqpos2] with frame f-com2.
	recatu1 = recid(item).
   end.
end.
