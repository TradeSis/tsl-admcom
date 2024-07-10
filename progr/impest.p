pause 0 before-hide.
def stream stela.
output stream stela to terminal.
    input from ..\work\estoq.d no-echo.
    repeat:
	prompt-for
	      estoq.etbcod
	      estoq.procod
	      ^
	      ^
	      estoq.estatual
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^
	      ^  with no-validate.

	find estoq where estoq.etbcod = input estoq.etbcod and
			 estoq.procod = input estoq.procod no-error.
	if not avail estoq
	then create estoq.

	ASSIGN
	      estoq.etbcod    = input estoq.etbcod
	      estoq.procod    = input estoq.procod
	      estoq.estatual  = input estoq.estatual.
	display stream stela estoq.procod with 1 down. pause 0.
    end.
    input close.
    output stream stela close.

    for each movim where movim.datexp = today no-lock:
	if movim.movtdc <> 5
	then next.
	run atuest.p (input recid(movim),
		      input "I",
		      input 0).
    end.
    quit.
