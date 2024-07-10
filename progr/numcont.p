{admcab.i}
def var i           as   int.
def var r           as   int.
def var vqtd        as   int.
def var vcontnum     like numcont.contnum.

do with side-label frame f1 1 down
	title color yellow/magenta " Numeracao  de  CONTRATOS "
		      width 80 row 4.
    prompt-for skip(1) estab.etbcod colon 20.
    find estab using estab.etbcod no-lock no-error.
    if not avail estab
    then do:
	bell.
	message "Estabelecimento Invalido".
	undo.
    end.
    display estab.etbnom no-label.
    update vqtd label "Qtd de Numeros" help "Quantidade de Etiquetas"
				    colon 20 skip(1).
    do on error undo:
	find last numcont no-lock no-error.
	vcontnum = numcont.contnum.
    end.
    output to ../relat/numcont.rel page-size 0.
    r = 0.
    do i = 1 to vqtd on error undo.
	create numcont.
	ASSIGN numcont.contnum = vcontnum + 1
	       numcont.etbcod = estab.etbcod
	       numcont.datexp = today
	       vcontnum       = numcont.contnum.
	if r = 0
	then put "Ctr " at 3 numcont.contnum space(4).
	else put "Ctr "      numcont.contnum space(5).
	r = r + 1.
	if r = 8
	then do:
	    put skip(2).
	    r = 0.
	end.
    end.
    put skip(2).
    output close.
end.
