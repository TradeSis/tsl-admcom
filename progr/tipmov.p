/*
*
*    Esqueletao de Programacao
*
*/

def var sresp           as log format "Sim/Nao".
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
	    initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
	    initial ["","","","",""].


def buffer bTipMov       for TipMov.
def var vMovtdc         like TipMov.Movtdc.


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
	find first TipMov where
	    true no-error.
    else
	find TipMov where recid(TipMov) = recatu1.
    if not available TipMov
    then do:
	message "Cadastro de Tipos de Movimentacoes Vazio".
	message "Deseja Incluir " update sresp.
	if not sresp
	then undo.
	do with frame f-inclui1  overlay row 6 1 column centered.
		create TipMov.
		update  movtdc
			movtnom movtnat movtsig
			movtnota movttitu
			movtaut
			movtdeb
			movtcre modcod.
		next.
	end.
    end.
    clear frame frame-a all no-pause.
    display
	TipMov.Movtdc
	TipMov.movtnom movtnat movtsig
	TipMov.movtnota movttitu
	TipMov.movtaut
	tipmov.movtdeb
	tipmov.movtcre modcod
	    with frame frame-a 12 down centered no-box.

    recatu1 = recid(TipMov).
    color display message
	esqcom1[esqpos1]
	    with frame f-com1.
    repeat:
	find next TipMov where
		true.
	if not available TipMov
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	down
	    with frame frame-a.
	display
	    TipMov.Movtdc
	    TipMov.movtnom movtnat movtsig
	    TipMov.movtnota movttitu
	    TipMov.movtaut
	    tipmov.movtcre modcod
	    tipmov.movtdeb
		with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

	find TipMov where recid(TipMov) = recatu1.

	choose field TipMov.movtnom
	    go-on(cursor-down cursor-up
		  cursor-left cursor-right
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
	    find next TipMov where
		true no-error.
	    if not avail TipMov
	    then next.
	    color display normal
		TipMov.movtnom.
	    if frame-line(frame-a) = frame-down(frame-a)
	    then scroll with frame frame-a.
	    else down with frame frame-a.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev TipMov where
		true no-error.
	    if not avail TipMov
	    then next.
	    color display normal
		TipMov.movtnom.
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
	    then do with frame f-inclui overlay row 6 1 column centered.
		create TipMov.
		update  movtdc
			movtnom movtnat movtsig
			movtnota movttitu
			movtaut
			movtdeb
			movtcre modcod.
		recatu1 = recid(TipMov).
		leave.
	    end.
	    if esqcom1[esqpos1] = "Alteracao"
	    then do with frame f-altera overlay row 6 1 column centered.
		update TipMov with frame f-altera no-validate.
	    end.
	    if esqcom1[esqpos1] = "Consulta" or
	       esqcom1[esqpos1] = "Exclusao"
	    then do with frame f-consulta overlay row 6 1 column centered.
		disp TipMov with frame f-consulta no-validate.
	    end.
	    if esqcom1[esqpos1] = "Exclusao"
	    then do with frame f-exclui overlay row 6 1 column centered.
		message "Confirma Exclusao de" TipMov.MovtNom update sresp.
		if not sresp
		then undo.
		find next TipMov where true no-error.
		if not available TipMov
		then do:
		    find TipMov where recid(TipMov) = recatu1.
		    find prev TipMov where true no-error.
		end.
		recatu2 = if available TipMov
			  then recid(TipMov)
			  else ?.
		find TipMov where recid(TipMov) = recatu1.
		delete TipMov.
		recatu1 = recatu2.
		leave.
	    end.
	    if esqcom1[esqpos1] = "Listagem"
	    then do with frame f-Lista overlay row 6 1 column centered.
		message "Confirma Impressao de TipMovcante" update sresp.
		if not sresp
		then undo.
		recatu2 = recatu1.
		output to printer.
		for each TipMov:
		    display TipMov.
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
		TipMov.Movtdc
		TipMov.movtnom movtnat movtsig
		TipMov.movtnota movttitu
		TipMov.movtaut
		tipmov.movtdeb
		tipmov.movtcre modcod
		    with frame frame-a.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	else display esqcom2[esqpos2] with frame f-com2.
	recatu1 = recid(TipMov).
   end.
end.
