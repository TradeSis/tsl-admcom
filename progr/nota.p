{admcab.i}
def var vdata like nota.notdat.
def var vnotser like nota.notser.
def var vetbcod like nota.etbcod.
def var vnotnum like nota.notnum.
repeat:
    update vdata label "Data Referencia" with frame f1 side-label centered.

repeat:
    update vetbcod with frame f2 centered side-label.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
	message "Estabelecimento nao Cadastrado".
	undo, retry.
    end.
    display estab.etbnom no-label with frame f2.
    update vnotser
	   vnotnum with frame f2.
    create nota.
    assign nota.etbcod = vetbcod
	   nota.notnum = vnotnum
	   nota.notser = vnotser
	   nota.movndc = nota.notnum
	   nota.notdat = vdata
	   nota.clifor = estab.etbcod
	   nota.movtdc = 5.
end.
end.
