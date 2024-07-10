{admcab.i}
def var vetbcod like estab.etbcod.
def var vnumero like nota.notnum.
def var vserie  like nota.notser.
repeat:
    update vetbcod label "Estab." with frame f-1.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f-1.
    update vnumero label "Numero"
	   vserie  label "Serie" with frame f-1 width 80 side-label.

    find nota where nota.movtdc = 5 and
		    nota.etbcod = vetbcod and
		    nota.notser = vserie  and
		    nota.notnum = vnumero.
    display nota.etbcod
	    nota.notnum
	    nota.notser
	    nota.notdat with frame f-nota 1 column centered.

    message "Confirma Exclusao da Nota" update sresp.
    if sresp
    then delete nota.

end.
