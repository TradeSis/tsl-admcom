/*
*
*    Esqueletao de Programacao
*

{admcab.i}
*/

def var sresp           as log format "Sim/Nao".
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
	    initial ["Inclusao","Alteracao","Exclusao","Consulta",""].
def var esqcom2         as char format "x(12)" extent 5
		initial [" Pagamento "," Total Geral ",""].


def buffer blabotit       for labotit.
def var vtitnum         like labotit.titnum.
def var vtot            like labotit.titvlcob.
def var vcons           as char extent 2 initial ["Cliente","Contrato"].
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
    recatu1 = ?.

bl-princ:
repeat:
    form
	labotit.clifor
	labotit.etbcod column-label "Fil."
	labotit.titnum
	labotit.titpar
	labotit.titdtemi
	labotit.titdtven
	labotit.titvlcob
	labotit.titsit
	with frame frame-a 11 down centered.
    clear frame frame-a all.
    form with frame frame-a.
    form with frame ftot.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
	find first labotit use-index labotit where
	    true no-error.
    else
	find labotit where recid(labotit) = recatu1.
	vinicio = yes.
    if not available labotit
    then do:
	clear frame frame-a all.
	repeat with frame frame-a on endkey undo, leave bl-princ.
		create labotit.
		labotit.titdtven = 06/30/1995.
		update labotit.clifor validate(labotit.clifor <> ? and
					       labotit.clifor <> 0 ,
					       "Codigo do Cliente Invalido")
		       labotit.etbcod column-label "Fil."
		       labotit.titnum
		       labotit.titdtemi
		       labotit.titdtven
		       labotit.titvlcob.
		display labo.titpar.
	down with frame frame-a.
	vinicio = no.
	end.
    end.
    clear frame frame-a all no-pause.
    display
	labotit.clifor
	labotit.etbcod column-label "Fil."
	labotit.titnum
	labotit.titpar
	labotit.titdtemi
	labotit.titdtven
	labotit.titvlcob
	labotit.titsit
	with frame frame-a 11 down centered.
    recatu1 = recid(labotit).
    color display message
	esqcom1[esqpos1]
	    with frame f-com1.
    repeat:
	find next labotit use-index labotit where
		true.
	if not available labotit
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	if vinicio
	then
	down
	    with frame frame-a.
	display
	    labotit.clifor
	    labotit.etbcod
	    labotit.titnum
	    labotit.titpar
	    labotit.titdtemi
	    labotit.titdtven
	    labotit.titvlcob
	    labotit.titsit
		with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

	find labotit where recid(labotit) = recatu1.

	choose field labotit.titnum
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
		find next labotit use-index labotit where true no-error.
		if not avail labotit
		then leave.
		recatu1 = recid(labotit).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "page-up"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find prev labotit use-index labotit where true no-error.
		if not avail labotit
		then leave.
		recatu1 = recid(labotit).
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
	    find next labotit use-index labotit where
		true no-error.
	    if not avail labotit
	    then next.
	    color display normal
		labotit.titnum.
	    if frame-line(frame-a) = frame-down(frame-a)
	    then scroll with frame frame-a.
	    else down with frame frame-a.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev labotit use-index labotit where
		true no-error.
	    if not avail labotit
	    then next.
	    color display normal
		labotit.titnum.
	    if frame-line(frame-a) = 1
	    then scroll down with frame frame-a.
	    else up with frame frame-a.
	end.
	if keyfunction(lastkey) = "end-error"
	then leave bl-princ.

	if keyfunction(lastkey) = "return"
	then do on error undo, retry on endkey undo,leave.
	/*
	hide frame frame-a no-pause. */

	  if esqregua
	  then do:
	    display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
		with frame f-com1.

		clear frame frame-a all.
	    if esqcom1[esqpos1] = "Consulta"
	    then do with frame fconsulta on endkey undo, leave.
		display vcons with no-label centered.
		choose field vcons.
		if frame-index = 1
		then do:
		    prompt-for labotit.clifor
			       with frame flabo1
				    centered row 10 color message.
		    def var vclifor like labotit.clifor.
		    vclifor = input labotit.clifor.
		    {../credi/labocli.i 1}
		    next bl-princ.
		end.
		else do:
		    prompt-for labotit.titnum
			       with frame flabo2
				    centered row 10 color message.
		    vtitnum = input labotit.titnum.
		    {../credi/labocon.i 1}
		    next bl-princ.
		end.
	    end.
	    if esqcom1[esqpos1] = "Inclusao"
	    then repeat with frame frame-a on endkey undo, leave.
		create labotit.
		labotit.titdtven = 06/30/1995.
		update labotit.clifor
		       labotit.etbcod column-label "Fil."
		       labotit.titnum
		       labotit.titdtemi
		       labotit.titdtven
		       labotit.titvlcob.
		PAUSE 0.
		display labo.titpar.
		PAUSE 0.
		down with frame frame-a.
	    end.
	    if esqcom1[esqpos1] = "Alteracao"
	    then do with frame frame-a.
		update labotit.clifor
		       labotit.etbcod column-label "Fil."
		       labotit.titnum
		       labotit.titpar
		       labotit.titdtemi
		       labotit.titdtven
		       labotit.titvlcob.
	    end.
	    if esqcom1[esqpos1] = "Exclusao"
	    then do with frame f-exclui overlay row 6 1 column centered.
		message "Confirma Exclusao de" labotit.titpar update sresp.
		if not sresp
		then leave.
		find next labotit use-index labotit where true no-error.
		if not available labotit
		then do:
		    find labotit where recid(labotit) = recatu1.
		    find prev labotit use-index labotit where true no-error.
		end.
		recatu2 = if available labotit
			  then recid(labotit)
			  else ?.
		find labotit where recid(labotit) = recatu1.
		delete labotit.
		recatu1 = recatu2.
		leave.
	    end.

	  end.
	  else do:
	    display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
		with frame f-com2.

	    if esqcom2[esqpos2] = " Total Geral "
	    then do with frame ftot side-label column 43 color white/red
		on error undo.
		vtot = 0.
		for each blabotit where blabotit.titsit = "LIB" use-index
								labotit1.
		    vtot = vtot + blabotit.titvlcob.
		end.
		display vtot label "Total Atrasado"
			with overlay width 35 row 19
			     frame ftot.
	    end.
	    if esqcom2[esqpos2] = " Pagamento "
	    then do with frame fpag side-label 2 column color white/red
			      row 18 overlay column 45 title " Pagamento ":
		update labotit.titdtpag label "Data" colon 7.
		update labotit.titvlpag label "Valor" colon 7 .
		labotit.titsit = "PAG".
	    end.
	  end.
	  view frame frame-a.
	end.
	  if keyfunction(lastkey) = "end-error"
	  then view frame frame-a.
	display
	    labotit.clifor
	    labotit.etbcod column-label "Fil."
	    labotit.titnum
	    labotit.titpar
	    labotit.titdtemi
	    labotit.titdtven
	    labotit.titvlcob
	    labotit.titsit
		    with frame frame-a.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	else display esqcom2[esqpos2] with frame f-com2.
	recatu1 = recid(labotit).
   end.
 end.
quit.
