	if keyfunction(lastkey) = "page-down"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find next clien where true use-index clien2 no-error.
		if not avail clien
		then leave.
		recatu1 = recid(clien).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "page-up"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find prev clien where true use-index clien2 no-error.
		if not avail clien
		then leave.
		recatu1 = recid(clien).
	    end.
	    leave.
	end.

