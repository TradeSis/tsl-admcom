{admcab.i}
def var i           as   int.
def var r           as   int.
def var vqtd        as   int.
def var vclicod     like numcli.clicod.

do with side-label frame f1 1 down
	title color yellow/magenta " Numeracao  de  CLIENTES "
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
	find last numcli no-lock no-error.
	vclicod = numcli.clicod.
    end.
    output to printer page-size 0.
    r = 0.
    do i = 1 to vqtd on error undo.

	create numcli.
	ASSIGN numcli.clicod = vclicod + 1
	       numcli.etbcod = estab.etbcod
	       numcli.datexp = today
	       vclicod       = numcli.clicod.

	if r = 0
	then put "Cli " at 3 numcli.clicod space(5)
		 "Cli "      numcli.clicod space(4).
	else put "Cli "      numcli.clicod space(5)
		 "Cli "      numcli.clicod space(4).
	r = r + 1.
	if r = 4
	then do:
	    put skip(2).
	    r = 0.
	end.
    end.
    put skip(2).
    output close.
end.
