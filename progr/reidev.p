{cabec.i}
def var vmens       as char format "x(40)".
def var vemite          like plani.emite  no-undo.
def var vserie          like plani.serie  no-undo.
def var vnumero         like plani.numero no-undo.

form vmens vnumero sresp no-label
    with frame f-mensagem no-label color message row screen-lines
	   overlay centered no-box.

repeat:
    hide frame fnota no-pause.
       update vnumero with frame fnota centered color blue/cyan
       title "Reimpressao de Nota" side-label row 5 width 30.

       find plani where PLANI.etbcod = estab.etbcod and
			PLANI.emite = estab.etbcod and
			PLANI.serie  = "U" and
			plani.movtdc = 12 and
			PLANI.numero = vnumero no-error .

       if not avail plani
       then do:
	message "Nota Fiscal nao Cadastrada".
	undo, retry.
       end.
       else do:
	    bell.
	    vmens = "CONFIRMA REEMISSAO DA NOTA DE DEVOLUCAO" .
	    disp vmens vnumero with frame f-mensagem.
	    sresp = yes.
	    update sresp with frame f-mensagem.
	    if not sresp
	    then do:
		clear frame f-mensagem all no-pause.
		undo.
	    end.
	    run impnfDEV.p(input recid(plani)).
	    hide frame fnota.
	    hide frame f-mensagem.
       end.
    end.
