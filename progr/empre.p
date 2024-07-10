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
	    initial ["Inclusao","Alteracao","Consulta","Listagem",""].
def var esqcom2         as char format "x(12)" extent 5
	    initial ["Teste1","Teste2","Teste3","Teste4","Teste5"].


def buffer bempre       for empre.
def var vempcod         like empre.empcod.


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
    if recatu1 = ?
    then
	find first empre where
	    true no-error.
    else
	find empre where recid(empre) = recatu1.
	vinicio = no.
    if not available empre
    then do:
	message "Cadastro de Empresas Vazio".
	message "Deseja Incluir " update sresp.
	if not sresp
	then undo, leave.
	do with frame f-inclui1  row 5  centered .
		create empre.
		update emprazsoc.
		assign empfant = substr(emprazsoc,1,13).
		UPDATE empfant.
		UPDATE empmgoper
		       empmesbal
		       empmgluc
		       empdtcad
		       empmespro
		       empanopro
		       empdialiv
		       empdtpro.
		update empdiapag
		       empcuac
		       emptransp
		       empcude
		       empperac
		       empperde
		       empconven
		       WITH OVERLAY 2 COLUMNS SIDE-LABELS.
		find last bempre exclusive-lock no-error.
		if available bempre
		then assign vempcod = bempre.empcod.
		else assign vempcod = 0.
		{di.v 2 "vempcod"}
		assign empre.empcod = vempcod.
		vinicio = yes.
	end.
    end.
    clear frame frame-a all no-pause.
    display
	empre.empcod
	empre.emprazsoc
	empre.empfant
	    with frame frame-a 14 down centered.

    recatu1 = recid(empre).
    color display message
	esqcom1[esqpos1]
	    with frame f-com1.
    repeat:
	find next empre where
		true.
	if not available empre
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	if vinicio = no
	then
	down
	    with frame frame-a.
	display
	    empre.empcod
	    empre.emprazsoc
	    empre.empfant
		with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

	find empre where recid(empre) = recatu1.

	choose field empre.empcod
	    go-on(cursor-down cursor-up
		  page-down page-up
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

	if keyfunction(lastkey) = "page-down"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find next empre where true no-error.
		if not avail empre
		then leave.
		recatu1 = recid(empre).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "page-up"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find prev empre where true no-error.
		if not avail empre
		then leave.
		recatu1 = recid(empre).
	    end.
	    leave.
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
	    find next empre where
		true no-error.
	    if not avail empre
	    then next.
	    color display normal
		empre.empcod.
	    if frame-line(frame-a) = frame-down(frame-a)
	    then scroll with frame frame-a.
	    else down with frame frame-a.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev empre where
		true no-error.
	    if not avail empre
	    then next.
	    color display normal
		empre.empcod.
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
	    then do with frame f-inclui
			row 5  centered OVERLAY 2 COLUMNS SIDE-LABELS.
		create empre.
		update empre.emprazsoc.
		assign empre.empfant = substr(empre.emprazsoc,1,13).
		UPDATE empre.empfant.
		UPDATE empre.empmgoper
		       empre.empmesbal
		       empre.empmgluc
		       empre.empdtcad
		       empre.empmespro
		       empre.empanopro
		       empre.empdialiv
		       empre.empdtpro.
		update empre.empdiapag
		       empre.empcuac
		       empre.emptransp
		       empre.empcude
		       empre.empperac
		       empre.empperde
		       empre.empconven.

		find last bempre exclusive-lock no-error.
		if available bempre
		then assign vempcod = bempre.empcod.
		else assign vempcod = 0.
		{di.v 1 "vempcod"}
		assign empre.empcod = vempcod.
		recatu1 = recid(empre).
		leave.
	    end.
	    if esqcom1[esqpos1] = "Alteracao"
	    then do with frame f-altera
			row 5  centered OVERLAY 2 COLUMNS SIDE-LABELS.
		UPDATE empre.empfant.
		UPDATE empre.emprazsoc
		       empre.empmgoper
		       empre.empmesbal
		       empre.empmgluc
		       empre.empdtcad
		       empre.empmespro
		       empre.empanopro.
		UPDATE empre.empdialiv
		       empre.empdtpro
		       empre.empdiapag
		       empre.empcuac
		       empre.emptransp
		       empre.empcude
		       empre.empperac
		       empre.empperde
		       empre.empconven.
	    end.
	    if esqcom1[esqpos1] = "Consulta"
	    then do with frame f-consulta
			row 5  centered OVERLAY 2 COLUMNS SIDE-LABELS.
		disp empre with frame f-consulta.
	    end.
	    if esqcom1[esqpos1] = "Listagem"
	    then do with frame f-Lista overlay row 6 1 column centered.
		message "Confirma Impressao de Empresas" update sresp.
		if not sresp
		then leave.
		recatu2 = recatu1.
		output to printer.
		for each empre:
		    display empre.
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
		empre.empcod
		empre.emprazsoc
		empre.empfant
		    with frame frame-a.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	recatu1 = recid(empre).
   end.
end.
