{admcab.i}
def var vcol as int initial 5.
def var vrow as int initial 5.
def var vloop as int.
def var vmens as char format "x(80)" initial
"CUSTOM Business Solutions - A solucao para o seu negocio                   ".
status default "".
repeat with frame f:

    readkey pause 0.
    if lastkey <> -1
    then do:
	put screen row 23 column 1 fill(" ",80).
	hide frame fh no-pause.
	hide frame fdes no-pause.
	hide frame fdes1 no-pause.
	hide frame fdes2 no-pause.
	status default "CUSTOM Business Solutions".
	return.
    end.
    vloop = vloop + 1.
    put screen color yellow/blue row 23 column 1 vmens.
    if vloop = 25 or
       vloop = 50 or
       vloop = 75 or
       vloop = 100
    then vmens = substring(vmens,2,78) + substring(vmens,1,1).
    if vloop = 100
    then do:
	assign
	    vcol = if vcol > 50
		   then 5
		   else vcol + 2
	    vrow = if vrow > 14
		   then 5
		   else vrow + 2
	    vloop = 0.
	hide frame fh no-pause.
	hide frame fdes no-pause.
	hide frame fdes1 no-pause.
	hide frame fdes2 no-pause.
    end.
    pause 0 before-hide.
    disp "Custom Business Solutions"
	with frame fdes column vcol - 1 row vrow - 2 no-box no-hide. /*
	    color white/black.                                   */
    disp space(3) skip(4)
	with frame fdes1 column vcol + 20 row vrow + 1 no-box no-hide
	     color black/black.
    disp space(21)
	with frame fdes2 column vcol + 2 row vrow + 6  no-box no-hide
	     color black/black.
    disp skip(1)
	"    " today "    " skip
	"    " string(time,"HH:MM:SS") "    "  skip(1)
	with column vcol row vrow 1 down color white/red
	    frame fh no-hide overlay.
end.
