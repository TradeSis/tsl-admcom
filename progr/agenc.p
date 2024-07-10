/*
*
*    agenc.p - Cadastro de Agencias
*
*/
{admcab.i}
def var gempcod         like empre.empcod initial 1.
def var reccont         as int.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," Listagem "].
def var esqcom2         as char format "x(12)" extent 5
	    initial ["","","","",""].


def buffer bagenc       for agenc.
def var vagecod         like agenc.agecod.

def var c-munic         like cep_loc.munic.
def var c-ufed          like cep_loc.ufed.

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
    form agenc.bancod
	 agenc.agedesc
	 agenc.ageval
	 agenc.agefan
	 agenc.agecod
	 agenc.ufecod
	 agenc.agecid
	 agenc.agefone
	 agenc.agecont
	with frame f-agenc overlay row 4 centered side-label
				 color black/cyan.

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.

    if recatu1 = ?
    then
	find first agenc where
	    true no-error.
    else
	find agenc where recid(agenc) = recatu1.
    if not available agenc
    then do:
	message "Cadastro de Agˆncias Vazio".
	message "Deseja Incluir " update sresp.
	if not sresp
	then undo, leave.
	do with frame f-agenc.
		create agenc.
		update
		    agenc.bancod
		    agenc.agedesc
		    agenc.ageval
		    agenc.agefan
		    agenc.agecod
		    agenc.ufecod
		    agenc.agecid
		    agenc.agefone
		    agenc.agecont.
	end.
    end.
    clear frame frame-a all no-pause.
    display
	agenc.agecod
	agenc.bancod
	agenc.agefan
	    with frame frame-a 14 down centered color white/red.

    recatu1 = recid(agenc).
    color display message
	esqcom1[esqpos1]
	    with frame f-com1.
    repeat:
	find next agenc where
		true.
	if not available agenc
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	down
	    with frame frame-a.
	display
	    agenc.agecod
	    agenc.bancod
	    agenc.agefan
		with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

	find agenc where recid(agenc) = recatu1.

	if keyfunction(lastkey) = "end-error"
	then do:
	  display
	      agenc.agecod
	      agenc.bancod
	      agenc.agefan
		  with frame frame-a.
	  if esqregua
	  then display esqcom1[esqpos1] with frame f-com1.
	  else display esqcom2[esqpos2] with frame f-com2.
	end.
	choose field agenc.agecod
	    go-on(cursor-down cursor-up
		  cursor-left cursor-right
		  page-up     page-down
		  tab PF4 F4 ESC return) color white/black.
	color display white/red agenc.agecod.
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
		find next agenc where
		    true no-error.
		if not avail agenc
		then leave.
		recatu1 = recid(agenc).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "page-up"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find prev agenc where
		    true no-error.
		if not avail agenc
		then leave.
		recatu1 = recid(agenc).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev agenc where
		true no-error.
	    if not avail agenc
	    then next.
	    color display white/red agenc.agecod.
	    if frame-line(frame-a) = 1
	    then scroll down with frame frame-a.
	    else up with frame frame-a.
	end.
	if keyfunction(lastkey) = "end-error"
	then leave bl-princ.

	if keyfunction(lastkey) = "return"
	then do on error undo, retry:
	  hide frame frame-a no-pause.
	  clear frame f-agenc all.
	  if esqregua
	  then do:
	    display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
		with frame f-com1.

	    if esqcom1[esqpos1] = " Inclusao "
	    then do with frame f-agenc.
		create agenc.
		update agenc.bancod
		       agenc.agedesc
		       agenc.ageval
		       agenc.agefan
		       agenc.agecod
		       agenc.ufecod
		       agenc.agecid
		       agenc.agefone
		       agenc.agecont.
		recatu1 = recid(agenc).
		leave.
	    end.
	    if esqcom1[esqpos1] = " Consulta " or
	       esqcom1[esqpos1] = " Exclusao " or
	       esqcom1[esqpos1] = " Alteracao "
	    then do with frame f-agenc.
		display agenc.bancod
			agenc.agedesc
			agenc.ageval
			agenc.agefan
			agenc.agecod
			agenc.ufecod
			agenc.agecid
			agenc.agefone
			agenc.agecont.
	    end.
	    if esqcom1[esqpos1] = " Alteracao "
	    then do with frame f-agenc.
		update  agenc.bancod
			agenc.agedesc
			agenc.ageval
			agenc.agefan
			agenc.agecod
			agenc.ufecod
			agenc.agecid
			agenc.agefone
			agenc.agecont. pause.
	    end.
	    if esqcom1[esqpos1] = " Exclusao "
	    then do with frame f-exclui overlay row 4 centered.
		message "Confirma Exclusao de" agenc.agefan update sresp.
		if not sresp
		then undo, leave.
		find next agenc where true no-error.
		if not available agenc
		then do:
		    find agenc where recid(agenc) = recatu1.
		    find prev agenc where true no-error.
		end.
		recatu2 = if available agenc
			  then recid(agenc)
			  else ?.
		find agenc where recid(agenc) = recatu1.
		delete agenc.
		recatu1 = recatu2.
		leave.
	    end.
	    if esqcom1[esqpos1] = " Listagem "
	    then do with frame f-agenc.
		message "Confirma Impressao de agenc" update sresp.
		if not sresp
		then undo, leave.
		recatu2 = recatu1.
		output to printer.
		for each agenc:
		    display agenc.bancod
			agenc.agedesc
			agenc.ageval
			agenc.agefan
			agenc.agecod
			agenc.ufecod
			agenc.agecid
			agenc.agefone
			agenc.agecont.
		    down with frame f-lista.
		end.
		output close.
		recatu1 = recatu2.
		leave.
	    end.
	  end.
	  /*   R‚gua de Baixo  */
	  else do:
	    if esqcom2[esqpos2] <>  ""
	    then do:
		display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
		    with frame f-com2.
		message esqregua esqpos2 esqcom2[esqpos2].
		pause.
	    end.
	  end.
	end.
	display
	    agenc.agecod
	    agenc.bancod
	    agenc.agefan
		with frame frame-a.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	else display esqcom2[esqpos2] with frame f-com2.

	recatu1 = recid(agenc).
   end.
end.
pause 0.
