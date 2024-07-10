	    if keyfunction(lastkey) = "TAB"
	    then do:
		if esqregua
		then do:
		    color display normal esqcom1[esqpos1] with frame f-com1.
		    color display message esqcom2[esqpos2] with frame f-com2.
		end.
		else do:
		    color display normal esqcom2[esqpos2] with frame f-com2.
		    color display message esqcom1[esqpos1] with frame f-com1.
		end.
		esqregua = not esqregua.
	    end.
	    if keyfunction(lastkey) = "cursor-right"
	    then do:
		if esqregua
		then do:
		    color display normal esqcom1[esqpos1] with frame f-com1.
		    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
		    color display messages esqcom1[esqpos1] with frame f-com1.
		end.
		else do:
		    color display normal esqcom2[esqpos2] with frame f-com2.
		    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
		    color display messages esqcom2[esqpos2] with frame f-com2.
		end.
		next.
	    end.
	    if keyfunction(lastkey) = "cursor-left"
	    then do:
		if esqregua
		then do:
		    color display normal esqcom1[esqpos1] with frame f-com1.
		    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
		    color display messages esqcom1[esqpos1] with frame f-com1.
		end.
		else do:
		    color display normal esqcom2[esqpos2] with frame f-com2.
		    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
		    color display messages esqcom2[esqpos2] with frame f-com2.
		end.
		next.
	    end.
	    if keyfunction(lastkey) = "page-down"
	    then do:
		do reccont = 1 to frame-down({&frame}):
		    if esqascend
		    then
			find next {&tabela} {&indice} where {&where}
					    no-lock no-error.
		    else
			find prev {&tabela} {&indice} where {&where}
					    no-lock no-error.
		    if not avail {&tabela}
		    then leave.
		    recatu1 = recid({&tabela}).
		end.
		leave.
	    end.
	    if keyfunction(lastkey) = "page-up"
	    then do:
		do reccont = 1 to frame-down({&frame}):
		    if esqascend
		    then
			find prev {&tabela} {&indice} where {&where}
					no-lock no-error.
		    else
			find next {&tabela} {&indice} where {&where}
					no-lock no-error.
		    if not avail {&tabela}
		    then leave.
		    recatu1 = recid({&tabela}).
		end.
		leave.
	    end.
	    if keyfunction(lastkey) = "cursor-down"
	    then do:
		if esqascend
		then
		    find next {&tabela} {&indice} where {&where}
				    no-lock no-error.
		else
		    find prev {&tabela} {&indice} where {&where}
				    no-lock no-error.
		if not avail {&tabela}
		then next.
		color display normal {&campo} with frame {&frame}.
		if frame-line({&frame}) = frame-down({&frame})
		then scroll with frame {&frame}.
		else down with frame {&frame}.
	    end.
	    if keyfunction(lastkey) = "cursor-up"
	    then do:
		if esqascend
		then
		    find prev {&tabela} {&indice} where {&where}
				    no-lock no-error.
		else
		    find next {&tabela} {&indice} where {&where}
				    no-lock no-error.
		if not avail {&tabela}
		then next.
		color display normal {&campo} with frame {&frame}.
		if frame-line({&frame}) = 1
		then scroll down with frame {&frame}.
		else up with frame {&frame}.
	    end.

