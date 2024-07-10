/*******************************************************************************
 Programa       : ExpMi.p
 Programador    : Cristiano Borges Brasil
 Criacao        : 12/08/1996
 Alteracao      : 12/08/1996
 Objetivo       : Consultar as datas de Exportacoes.
*******************************************************************************/

{admcab.i}
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(15)" extent 5
	    initial ["    Regiao","","",""].
def var esqcom2         as char format "x(15)" extent 5
	    initial ["","","","",""].

def buffer bexporta       for exporta.
def var vregcod           like regiao.regcod.
def var vetbcod           like estab.etbcod.

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

    form vregcod        colon 30
	 regiao.regnom  colon 40 no-label format "x(20)"

	 with color yelow/white width 80 row 5 side-label no-box
	 frame fetb.

pause 0 before-hide.

if setbcod = 999
then do on error undo, retry with frame fetb:
	update  vregcod.
	find regiao where regiao.regcod = vregcod no-lock no-error.
	if not avail regiao
	then do:
	    bell.
	    message "Regiao nao Existe !!".
	    undo, retry.
	end.
	find first estab where estab.regcod = vregcod no-lock.
	display vregcod
		regiao.regnom.
	vetbcod = estab.etbcod.
end.
else do with frame fetb:
     find estab where estab.etbcod = setbcod no-lock.
     find regiao of estab no-lock.
     display vregcod
	     regiao.regnom.
     vetbcod = setbcod.
end.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.

    if recatu1 = ?
    then find first exporta where exporta.etbcod = vetbcod no-error.
    else find exporta where recid(exporta) = recatu1.
	 vinicio = yes.

    if not available exporta
    then do:
	message "Micro sem Atualizacao ".
	pause.
	leave.
    end.

    clear frame frame-a all no-pause.
    display exporta.exporta label "Data exportacao"
	    with frame frame-a 12 down centered row 7 color white/cyan.

    recatu1 = recid(exporta).
    color display message
	esqcom1[esqpos1]
	    with frame f-com1.
    repeat:
	find next exporta where exporta.etbcod = vetbcod.
	if not available exporta
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	if vinicio
	then
	down
	    with frame frame-a.
	display
	    exporta.exporta
		with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

	find exporta where recid(exporta) = recatu1.

	choose field exporta.exporta
	    go-on(cursor-down cursor-up
		  cursor-left cursor-right
		  page-down page-up
		  PF4 F4 ESC return).
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
		find next exporta where exporta.etbcod = vetbcod no-error.
		if not avail exporta
		then leave.
		recatu1 = recid(exporta).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "page-up"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find prev exporta where exporta.etbcod = vetbcod no-error.
		if not avail exporta
		then leave.
		recatu1 = recid(exporta).
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
	    find next exporta where exporta.etbcod = vetbcod
		 no-error.
	    if not avail exporta
	    then next.
	    color display white/cyan
		exporta.exporta.
	    if frame-line(frame-a) = frame-down(frame-a)
	    then scroll with frame frame-a.
	    else down with frame frame-a.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev exporta where exporta.etbcod = vetbcod
		 no-error.
	    if not avail exporta
	    then next.
	    color display white/cyan
		exporta.exporta.
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

	    if esqcom1[esqpos1] = "    Regiao"
	    then do on error undo, retry with frame fetb:
		    update  vregcod.
		    find regiao where regiao.regcod = vregcod no-lock no-error.
		    if not avail regiao
		    then do:
			bell.
			message "Regiao nao Existe !!".
			undo, retry.
		    end.
		    find first estab where estab.regcod = vregcod no-lock.
		    display vregcod
			    regiao.regnom.
		    vetbcod = estab.etbcod.
		    recatu1 = ?.
		    leave.
	    end.
	  end.
	  else do:
	    display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
		with frame f-com2.
	  end.
	  view frame frame-a.
	end.
	  if keyfunction(lastkey) = "end-error"
	  then view frame frame-a.
	display exporta.exporta with frame frame-a.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	else display esqcom2[esqpos2] with frame f-com2.
	recatu1 = recid(exporta).
   end.
end.
