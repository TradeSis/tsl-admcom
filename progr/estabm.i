/*
*
*    Esqueletao de Programacao
*
*/

def var recmar{2}         as recid.
def var vast{2}            as char format "x".
def workfile wfast{2}
    field rec{2}       as recid.
for each wfast{2}:
    delete wfast{2}.
end.

    if recmar{2} = ?
    then
	find first estab where
	    true no-error.
    else
	find estab where recid(estab) = recmar{2}.
    if not available estab
    then  leave.
    clear frame f-escolha all no-pause.
    display
	vast{2} no-label
	estab.etbcod
	estab.etbnom
	    with frame f-escolha 10 down centered row 5.

    recmar{2} = recid(estab).

    repeat:
	find next estab where
		true.
	if not available estab
	then leave.
	if frame-line(f-escolha) = frame-down(f-escolha)
	then leave.
	down
	    with frame f-escolha.
	display
	    estab.etbcod
	    estab.etbnom
		with frame f-escolha.
    end.
    up frame-line(f-escolha) - 1 with frame f-escolha.

    repeat with frame f-escolha:

	find estab where recid(estab) = recmar{2}.

	choose field estab.etbcod
	    go-on(cursor-down cursor-up
		  cursor-left cursor-right
		   PF4 F4 ESC ).
	if keyfunction(lastkey) = "cursor-down"
	then do:
	    find next estab where
		true no-error.
	    if not avail estab
	    then next.
	    color display normal
		estab.etbcod.
	    if frame-line(f-escolha) = frame-down(f-escolha)
	    then scroll with frame f-escolha.
	    else down with frame f-escolha.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev estab where
		true no-error.
	    if not avail estab
	    then next.
	    color display normal
		estab.etbcod.
	    if frame-line(f-escolha) = 1
	    then scroll down with frame f-escolha.
	    else up with frame f-escolha.
	end.
	if keyfunction(lastkey) = "end-error"
	then do:
	    leave.
	end.
	if keyfunction(lastkey) = "return"
	then do on error undo, retry on endkey undo, leave.
	    find first wfast{2} where wfast{2}.rec{2} = recid(estab) no-error.
	    if available wfast{2}
	    then do:
		display " " @ vast{2}.
		delete wfast{2}.
	    end.
	    else do:
		display "*" @ vast{2}.
		create wfast{2}.
		wfast{2}.rec{2} = recid(estab).
	    end.
	    pause 0.
	    if "{1}" = "1"
	    then leave.
	end.
	display
		estab.etbcod
		estab.etbnom
		    with frame f-escolha.
	recmar{2} = recid(estab).
   end.
   if "{1}" = "1"
   then
	if keyfunction(lastkey) = "end-error"
	then leave.
