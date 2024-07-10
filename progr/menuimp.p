PAUSE 0 BEFORE-HIDE.
def var vaplicod like aplicativo.aplicod.
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
    input from value("..\" + vaplicod + "~\" + vaplicod + ".con").
    repeat:
	create menu.
	import menu.
    end.
end.
