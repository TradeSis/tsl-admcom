/*                                                              setor.p
*
*    Esqueletao de Programacao
	    Manutencao em Setores e Atendimento de Classes
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
def var esqcom1         as char format "x(14)" extent 5
	    initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(14)" extent 5
	    initial ["Atendimento","Exclui","","",""].


def buffer bsetor       for setor.
def var vetbcod         like setor.etbcod.


    form
	esqcom1
	    with frame f-com1
		 row 4 no-box no-labels side-labels column 1.
    form
	esqcom2
	    with frame f-com2
		 row screen-lines - 3 title " Atendimento "
		 no-labels side-labels column 1 width 80.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
	find first setor where
	    true no-error.
    else
	find setor where recid(setor) = recatu1.
	vinicio = no.
    if not available setor
    then do:
	message "Cadastro de Setores Vazio".
	message "Deseja Incluir " update sresp.
	if not sresp
	then undo.
	do with frame f-inclui1  overlay row 6 1 column centered.
		create setor.
		update setor.
		vinicio = yes.
	end.
    end.
    clear frame frame-a all no-pause.
    display
	setor.etbcod
	setor.setcod
	setor.setnom
	setor.setger
	    with frame frame-a 10 down centered.

    recatu1 = recid(setor).
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
	find next setor where
		true.
	if not available setor
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	if vinicio = no
	then
	    down with frame frame-a.
	display
	    setor.etbcod
	    setor.setcod
	    setor.setnom
	    setor.setger
		with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

	find setor where recid(setor) = recatu1.

	choose field setor.etbcod
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
		find next setor where true no-error.
		if not avail setor
		then leave.
		recatu1 = recid(setor).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "page-up"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find prev setor where true no-error.
		if not avail setor
		then leave.
		recatu1 = recid(setor).
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
	    find next setor where
		true no-error.
	    if not avail setor
	    then next.
	    color display normal
		setor.etbcod.
	    if frame-line(frame-a) = frame-down(frame-a)
	    then scroll with frame frame-a.
	    else down with frame frame-a.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev setor where
		true no-error.
	    if not avail setor
	    then next.
	    color display normal
		setor.etbcod.
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
		create setor.
		update setor.
		recatu1 = recid(setor).
		leave.
	    end.
	    if esqcom1[esqpos1] = "Alteracao"
	    then do with frame f-altera overlay row 6 1 column centered.
		update setor with frame f-altera.
	    end.
	    if esqcom1[esqpos1] = "Consulta"
	    then do with frame f-consulta overlay row 6 1 column column 1.
		disp setor with frame f-consulta centered.
		for each atend of setor:
		    find clase of atend.
		    display clase.clacod clase.clanom
			    with row 6  1 column overlay  title setor.setnom.
		end.
	    end.
	    if esqcom1[esqpos1] = "Exclusao"
	    then do with frame f-exclui overlay row 6 1 column centered.
		message "Confirma Exclusao de" setor.setnom update sresp.
		if not sresp
		then leave.
		find next setor where true no-error.
		if not available setor
		then do:
		    find setor where recid(setor) = recatu1.
		    find prev setor where true no-error.
		end.
		recatu2 = if available setor
			  then recid(setor)
			  else ?.
		find setor where recid(setor) = recatu1.
		delete setor.
		recatu1 = recatu2.
		leave.
	    end.
	    if esqcom1[esqpos1] = "Listagem"
	    then do with frame f-Lista overlay row 6 1 column centered.
		message "Confirma Impressao de Setores" update sresp.
		if not sresp
		then leave.
		recatu2 = recatu1.
		output to printer.
		for each setor:
		    display setor.
		end.
		output close.
		recatu1 = recatu2.
		leave.
	    end.

	  end.
	  else do with frame f-clase:
	    display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
		with frame f-com2.
	    find estab of setor.
	    pause 0.
	    {clasem.i 2}
	    display
		    estab.etbcod estab.etbnom no-label skip
		    setor.setcod  colon 18 setor.setnom no-label
		with side-labels centered.
	    for each wfast with centered:
		find clase where recid(clase) = wfast.rec.
		display clase.clacod
			    clase.clanom.
	    end.
	    if esqcom2[esqpos2] = "Atendimento"
	    then do with frame f-estoq 1 column centered:
		message "Confirma Criacao de Atendimento para Classes"
		    update sresp.
		if sresp
		then
		  for each wfast:
		    find clase where recid(clase) = wfast.rec.
		    find atend where atend.setcod = setor.setcod and
			     atend.etbcod = estab.etbcod and
			     atend.clacod = clase.clacod no-error.
		    if not available atend
		    then create atend.
		    assign
			atend.setcod = setor.setcod
			atend.etbcod = estab.etbcod
			atend.clacod = clase.clacod.
		end.
	    end.
	    if esqcom2[esqpos2] = "Exclui"
	    then do with frame f-estoqe 1 column centered:
		message "Confirma Exclusao de Atendimento para Classes"
		    update sresp.
		if sresp
		then
		  for each wfast:
		    find clase where recid(clase) = wfast.rec.
		    find atend where atend.setcod = setor.setcod and
			     atend.etbcod = estab.etbcod and
			     atend.clacod = clase.clacod no-error.
		    if available atend
		    then delete atend.
		end.
	    end.
	    hide frame f-clase no-pause.
	  end.
	  view frame frame-a .
	end.
	  if keyfunction(lastkey) = "end-error"
	  then view frame frame-a.
	display
		setor.etbcod
		setor.setcod
		setor.setnom
		setor.setger
		    with frame frame-a.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	else display esqcom2[esqpos2] with frame f-com2.
	recatu1 = recid(setor).
   end.
end.
