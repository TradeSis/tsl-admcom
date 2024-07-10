{admcab.i}
def var vprocod like produ.procod.
def var i as int.
def var vest like estoq.estatual.
def var vsenha like func.senha.
def buffer bplani for plani.
def buffer cplani for plani.
def var vplacod like plani.placod.
def var vnumero like plani.numero.
def var vserie like plani.serie.
def var vdata  like plani.pladat.
bl-1:
repeat:

    do:
	prompt-for func.funcod with frame f-senha centered row 4
			    side-label title " Seguranca ".
	find func where func.funcod = input func.funcod and
			func.etbcod = 999 no-lock no-error.
	if not avail func
	then do:
	    message "Funcionario nao Cadastrado".
	    undo, retry.
	end.
	disp func.funnom no-label with frame f-senha.
	if func.funfunc <> "ESTOQUE"
	then do:
	    bell.
	    message "Funcionario sem Permissao".
	    undo, retry.
	end.
	i = 0.
	repeat:
	    i = i + 1.
	    update vsenha blank with frame f-senha.
	    if vsenha = func.senha
	    then leave.
	    if vsenha <> func.senha
	    then do:
		bell.
		message "Senha Invalida".
	    end.
	    if i > 2
	    then leave bl-1.
	end.
    end.

    prompt-for estab.etbcod
	       with frame f1 side-labels centered color white/red row 4.

    find estab using estab.etbcod no-lock.
    disp estab.etbnom no-label with frame f1.
    update vprocod with frame f-produ.
    find produ where produ.procod = vprocod no-lock no-error.
    display produ.pronom no-label with frame f-produ.
    find estoq where estoq.etbcod = estab.etbcod and
		     estoq.procod = produ.procod no-error.
    update estoq.estatual with frame f-produ.
end.
