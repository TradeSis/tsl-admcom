def var vaplicod like aplicativo.aplicod.
def buffer bmenu for menu.
repeat with centered side-labels 1 down:
    update vaplicod.
    find aplicativo where aplicativo.aplicod = vaplicod no-error.
    if available aplicativo
    then
	display aplinom no-label.
    else do:
	display "COMPLETO" @ aplinom.
	vaplicod = "gener".
    end.

    output to value("..\" + vaplicod + "~\" + vaplicod + ".con").

    for each aplicativo where
			if input aplinom = "COMPLETO"
			then true
			else aplicativo.aplicod = vaplicod:
	for each menu of aplicativo where menniv = 1:
	    export menu.
	    for each bmenu of aplicativo where
			bmenu.ordsup = menu.menord and bmenu.menniv = 2:
		export bmenu.
	    end.
	end.
    end.
    output close.
end.
