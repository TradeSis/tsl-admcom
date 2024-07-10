/*
*
*    Esqueletao de Programacao
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
    initial [" Inclusao  de Programa ",
	     " Alteracao da Programa ",
	     " Exclusao  da Programa ",
	     " Consulta  da Programa ",
	     " Listagem  Geral de Programa "].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
	    " ",
	    " ",
	    " ",
	    " "].


def buffer bPrograma       for Programa.
def var vPrograma         like Programa.Programa.
def var vhrcria           as char format "99:99".
def var vhralter          as char format "99:99".


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
    form programa.programa      at 7            skip
	 programa.prognom       at 6            skip
	 programa.progdir       at 6            skip
	 programa.dtcria        at 3            space(02)
	 vhrcria                label "Hora"    skip
	 programa.dtalter                       space(02)
	 vhralter               label "Hora"    skip
	 programa.usuario       at 8
	 with frame f-prog color black/cyan centered row 4 side-label.
    form programa.texto
	 with frame f-texto color black/cyan centered title " Help " no-label.

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
	find first Programa where
	    true no-error.
    else
	find Programa where recid(Programa) = recatu1.
    if not available Programa
    then do:
	message "Cadastro de Programa Vazio".
	message "Deseja Incluir " update sresp.
	if not sresp
	then undo, leave.
	do with frame f-prog on error undo, leave.
		create Programa.
		vhrcria = substr(string(time,"hh:mm"),1,2) +
			  substr(string(time,"hh:mm"),4,2).
		vhralter = substr(string(time,"hh:mm"),1,2) +
			   substr(string(time,"hh:mm"),4,2).
		update programa.programa
		       programa.prognom
		       programa.progdir
		       programa.dtcria
		       vhrcria
		       programa.dtalter
		       vhralter
		       programa.usuario with frame f-prog.
		assign programa.hrcria = (int(substr(vhrcria,1,2)) * 3600) +
					 (int(substr(vhrcria,3,2)) * 60)
		       programa.hralter = (int(substr(vhralter,1,2)) * 3600) +
					  (int(substr(vhralter,3,2)) * 60).
		update programa.texto with frame f-texto.
	end.
    end.
    clear frame frame-a all no-pause.
    display
	Programa.PROGRAMA
	PROGRAMA.PROGNOM
	    with frame frame-a 14 down centered color white/red.

    recatu1 = recid(Programa).
    find Programa where recid(Programa) = recatu1.
    color display message
	esqcom1[esqpos1]
	    with frame f-com1.
    repeat:
	find next Programa where
		true.
	if not available Programa
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	down
	    with frame frame-a.
	display
	Programa.PROGRAMA
	PROGRAMA.PROGNOM
		with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

	find Programa where recid(Programa) = recatu1.

	status default
	    if esqregua
	    then esqhel1[esqpos1] + if esqpos1 > 1 and
				       esqhel1[esqpos1] <> ""
				    then string(Programa.Prognom)
				    else ""
	    else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
				    then string(Programa.Prognom)
				    else "".

	choose field Programa.Programa help ""
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
		find next Programa where
		    true no-error.
		if not avail Programa
		then leave.
		recatu1 = recid(Programa).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "page-up"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find prev Programa where
		    true no-error.
		if not avail Programa
		then leave.
		recatu1 = recid(Programa).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "cursor-down"
	then do:
	    find next Programa where
		true no-error.
	    if not avail Programa
	    then next.
	    color display white/red Programa.Programa.
	    if frame-line(frame-a) = frame-down(frame-a)
	    then scroll with frame frame-a.
	    else down with frame frame-a.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev Programa where
		true no-error.
	    if not avail Programa
	    then next.
	    color display white/red Programa.Programa.
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
	    then do with frame f-prog.
		create Programa.
		vhrcria = substr(string(time,"hh:mm"),1,2) +
			  substr(string(time,"hh:mm"),4,2).
		vhralter = substr(string(time,"hh:mm"),1,2) +
			   substr(string(time,"hh:mm"),4,2).
		update programa.programa
		       programa.prognom
		       programa.progdir
		       programa.dtcria
		       vhrcria
		       programa.dtalter
		       vhralter
		       programa.usuario with frame f-prog.
		assign programa.hrcria = (int(substr(vhrcria,1,2)) * 3600) +
					 (int(substr(vhrcria,3,2)) * 60)
		       programa.hralter = (int(substr(vhralter,1,2)) * 3600) +
					  (int(substr(vhralter,3,2)) * 60).
		update programa.texto with frame f-texto.
		recatu1 = recid(Programa).
		leave.
	    end.
	    if esqcom1[esqpos1] = " Consulta " or
	       esqcom1[esqpos1] = " Exclusao " or
	       esqcom1[esqpos1] = " Listagem " or
	       esqcom1[esqpos1] = " Alteracao "
	    then do with frame f-prog.
		vhrcria = substr(string(programa.hrcria,"hh:mm"),1,2) +
			  substr(string(programa.hrcria,"hh:mm"),4,2).
		vhralter = substr(string(programa.hralter,"hh:mm"),1,2) +
			   substr(string(programa.hralter,"hh:mm"),4,2).
		disp Programa.programa
		     programa.prognom
		     programa.progdir
		     programa.dtcria
		     vhrcria
		     programa.dtalter
		     vhralter
		     programa.usuario with frame f-prog.
		disp programa.texto with frame f-texto.
	    end.
	    if esqcom1[esqpos1] = " Alteracao "
	    then do with frame f-prog.
		vhralter = substr(string(time,"hh:mm"),1,2) +
			   substr(string(time,"hh:mm"),4,2).
		update Programa.programa
		       programa.prognom
		       programa.progdir
		       programa.dtalter
		       vhralter
		       programa.usuario with frame f-prog.
		update programa.texto with frame f-texto.
	    end.
	    if esqcom1[esqpos1] = " Exclusao "
	    then do with frame f-exclui overlay row 4 1 column centered.
		message "Confirma Exclusao de" Programa.Prognom update sresp.
		if not sresp
		then undo, leave.
		find next Programa where true no-error.
		if not available Programa
		then do:
		    find Programa where recid(Programa) = recatu1.
		    find prev Programa where true no-error.
		end.
		recatu2 = if available Programa
			  then recid(Programa)
			  else ?.
		find Programa where recid(Programa) = recatu1.
		delete Programa.
		recatu1 = recatu2.
		leave.
	    end.
	    if esqcom1[esqpos1] = " Listagem "
	    then do with frame f-Lista overlay row 4 1 column centered.
		message "Confirma Impressao de Programa" update sresp.
		if not sresp
		then undo, leave.
		recatu2 = recatu1.
		output to printer.
		for each Programa:
		    display Programa.
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
	Programa.PROGRAMA
	PROGRAMA.PROGNOM
		    with frame frame-a.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	else display esqcom2[esqpos2] with frame f-com2.
	recatu1 = recid(Programa).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
	view frame fc1.
	view frame fc2.
    end.
end.
pause 0.
