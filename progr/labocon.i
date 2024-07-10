/*
*
*    Esqueletao de Programacao
*
*/

def var recmarc         as recid.
def var vmarc            as char format "x".
def workfile wfast2
    field rec2       as recid.
for each wfast2:
    delete wfast2.
end.

    if recmarc = ?
    then
	find first blabotit where blabotit.titnum = vtitnum
	    no-error.
    else
	find blabotit where recid(blabotit) = recmarc.
    if not available blabotit
    then  leave.
    clear frame fescolha all no-pause.
    display
	vmarc no-label
	blabotit.titnum
	blabotit.titdtemi
	blabotit.titvlcob
	blabotit.titdtpag
	blabotit.titvlpag
	blabotit.titsit
	    with frame fescolha 10 down centered row 5
			title " Selecione uma Opcao ".

    recmarc = recid(blabotit).

    repeat:
	find next blabotit where
		blabotit.titnum = vtitnum.
	if not available blabotit
	then leave.
	if frame-line(fescolha) = frame-down(fescolha)
	then leave.
	down
	    with frame fescolha.
	display
	    blabotit.titnum
	    blabotit.titdtemi
	    blabotit.titvlcob
	    blabotit.titdtpag
	    blabotit.titvlpag
	    blabotit.titsit
		with frame fescolha.
    end.
    up frame-line(fescolha) - 1 with frame fescolha.

    repeat with frame fescolha:

	find blabotit where recid(blabotit) = recmarc.

	choose field blabotit.titnum
	    go-on(cursor-down cursor-up
		  cursor-left cursor-right
		   PF4 F4 ESC ).
	if keyfunction(lastkey) = "cursor-down"
	then do:
	    find next blabotit where
		blabotit.titnum = vtitnum no-error.
	    if not avail blabotit
	    then next.
	    color display normal
		blabotit.titnum.
	    if frame-line(fescolha) = frame-down(fescolha)
	    then scroll with frame fescolha.
	    else down with frame fescolha.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev blabotit where
		blabotit.titnum = vtitnum no-error.
	    if not avail blabotit
	    then next.
	    color display normal
		blabotit.titnum.
	    if frame-line(fescolha) = 1
	    then scroll down with frame fescolha.
	    else up with frame fescolha.
	end.
	if keyfunction(lastkey) = "end-error"
	then do:
	    leave.
	end.
	if keyfunction(lastkey) = "return"
	then do on error undo, retry on endkey undo, leave.
	    find first wfast2 where wfast2.rec2 =
				recid(blabotit) no-error.
	    if available wfast2
	    then do:
		display " " @ vmarc.
		delete wfast2.
	    end.
	    else do:
		display "*" @ vmarc.
		create wfast2.
		wfast2.rec2 = recid(blabotit).
		recatu1 = recid(blabotit).
	    end.
	    pause 0.
	    if "{1}" = "1"
	    then leave.
	end.
	display
	    blabotit.titnum
	    blabotit.titdtemi
	    blabotit.titvlcob
	    blabotit.titdtpag
	    blabotit.titvlpag
	    blabotit.titsit
		    with frame fescolha.
	recmarc = recid(blabotit).
   end.
   if "{1}" = "1"
   then
	if keyfunction(lastkey) = "end-error"
	then leave.
