/*                                                                  conta.p
*
*    Esqueletao de Programacao
	Manutencao em CONTA CONTABIL
*
*/
{admcab.i}
def var reccont         as int.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
	    initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(20)" extent 3
	    initial ["Inclui Filho","Inclui Irmao",""].


def buffer contasup     for conta.
def buffer bconta       for conta.
def var vconsusep         like conta.consusep.
def var vconsup         like conta.consup.


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
	find first conta use-index icntsup where
	    true no-error.
    else
	find conta where recid(conta) = recatu1.
    if not available conta
    then do:
	message "Cadastro de CONTA CONTABIL Vazio".
	message "Deseja Incluir " update sresp.
	if not sresp
	then undo.
	do with frame f-inclui1  overlay row 6 1 column centered
	    color black/cyan.
		create conta.
		update conta.
		next.
	end.
    end.
    clear frame frame-a all no-pause.
    find contasup where contasup.concod = conta.consup no-error.
    display
	contasup.consusep when avail contasup column-label "Superiora"
	contasup.condesc  when avail contasup
	conta.consusep
	conta.condesc
	    with frame frame-a 13 down centered color white/red.

    recatu1 = recid(conta).
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
	find next conta  use-index icntsup where
		true.
	if not available conta
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	down
	    with frame frame-a.
	find contasup where contasup.concod = conta.consup no-error.
	display
	    contasup.consusep when avail contasup
	    contasup.condesc  when avail contasup
	    conta.consusep
	    conta.condesc
		with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

	find conta where recid(conta) = recatu1.

	choose field conta.consusep
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
		esqpos2 = if esqpos2 = 3
			  then 3
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
		find next conta where true no-error.
		if not avail conta
		then leave.
		recatu1 = recid(conta).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "page-up"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find prev conta where true no-error.
		if not avail conta
		then leave.
		recatu1 = recid(conta).
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
	    find next conta  use-index icntsup where
		true no-error.
	    if not avail conta
	    then next.
	    color display white/red
		conta.consusep.
	    if frame-line(frame-a) = frame-down(frame-a)
	    then scroll with frame frame-a.
	    else down with frame frame-a.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev conta  use-index icntsup where
		true no-error.
	    if not avail conta
	    then next.
	    color display white/red
		conta.consusep.
	    if frame-line(frame-a) = 1
	    then scroll down with frame frame-a.
	    else up with frame frame-a.
	end.
	if keyfunction(lastkey) = "end-error"
	then leave bl-princ.

	if keyfunction(lastkey) = "return"
	then do on error undo, retry on endkey undo, leave.
	    hide frame frame-a no-pause.
	  form with frame f-altera color black/cyan.
	  if esqregua
	  then do:
	    display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
		with frame f-com1.

	    if esqcom1[esqpos1] = "Inclusao"
	    then do with frame f-altera overlay row 6 1 column centered.
		create conta.
		update conta.
		recatu1 = recid(conta).
		leave.
	    end.
	    if esqcom1[esqpos1] = "Alteracao"
	    then do with frame f-altera.
		update conta.
	    end.
	    if esqcom1[esqpos1] = "Consulta" or
	       esqcom1[esqpos1] = "Exclusao"
	    then do with frame f-altera:
		disp conta.
	    end.
	    if esqcom1[esqpos1] = "Exclusao"
	    then do with frame f-altera:
		message "Confirma Exclusao de" conta.condesc update sresp.
		if not sresp
		then undo.
		find next conta  use-index icntsup where true no-error.
		if not available conta
		then do:
		    find conta where recid(conta) = recatu1.
		    find prev conta use-index icntsup where true no-error.
		end.
		recatu2 = if available conta
			  then recid(conta)
			  else ?.
		find conta where recid(conta) = recatu1.
		delete conta.
		recatu1 = recatu2.
		leave.
	    end.
	    if esqcom1[esqpos1] = "Listagem"
	    then do with frame f-Lista overlay row 6 1 column centered.
		message "Confirma Impressao de CONTA CONTABIL" update sresp.
		if not sresp
		then undo.
		recatu2 = recatu1.
		output to printer.
		for each conta:
		    display conta.
		end.
		output close.
		recatu1 = recatu2.
		leave.
	    end.

	  end.
	  else do:
	    display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
		with frame f-com2.
	    if esqcom2[esqpos2] = "Inclui Filho"
	    then do with frame f-altera.
		vconsup = conta.consup.
		create conta.
		conta.consup = vconsup.
		update conta.condesc.
		recatu1 = recid(conta).
		leave.
	    end.
	    if esqcom2[esqpos2] = "Inclui Irmao"
	    then do with frame f-altera.
		vconsup = conta.consup.
		create conta.
		conta.consup = vconsup.
		update conta.
		recatu1 = recid(conta).
		leave.
	    end.
	  end.
	  view frame frame-a.
	end.
	 if keyfunction(lastkey) = "end-error"
	 then view frame frame-a.
	find contasup where contasup.concod = conta.consup no-error.
	display
	    contasup.consusep when avail contasup
	    contasup.condesc  when avail contasup
	    conta.consusep
	    conta.condesc
		    with frame frame-a.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	else display esqcom2[esqpos2] with frame f-com2.
	recatu1 = recid(conta).
   end.
end.
