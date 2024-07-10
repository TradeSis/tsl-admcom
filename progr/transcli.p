pause 0 before-hide.
def stream tela.
def var lidos as i.
def var gravados as i.

output to clien.d.
output stream tela to terminal.

for each estab where estab.etbcod = 1 or
		     estab.etbcod = 6 or
		     estab.etbcod = 7  or
		     estab.etbcod = 15 or
		     estab.etbcod = 17,
    each contrato use-index est where contrato.etbcod = estab.etbcod
	    break by clicod:
    lidos = lidos + 1.
    disp stream tela lidos with frame f centered.
    if last-of(clicod)
    then do:
	find clien of contrato no-error.
	if avail clien
	then do:
	    gravados = gravados + 1.
	    disp stream tela gravados with frame f centered.
	    export clien.
	end.
    end.
end.
output close.
