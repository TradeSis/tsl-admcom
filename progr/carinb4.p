{admcab.i}
def var inicio  as log.
def var i       as i.
repeat with row 4 width 80 color white/cyan side-label 1 down.
    prompt-for clien.clicod colon 20.
    find clien using clicod no-lock no-error.
    if not avail clien
    then do:
	message "Cliente nao Cadastrado".
	undo.
    end.
    display clien.clinom no-label.
    prompt-for contrato.contnum colon 20.
    find contrato using contnum no-lock no-error.
    if not avail contrato
    then do:
	message "Contrato Inexistente".
	undo.
    end.
    find estab where estab.etbcod = contrato.etbcod no-lock.
    display " COLOCAR O FORMULARIO NO INICIO DA FOLHA " with centered
	    row 10 color message frame fx.

    pause.

    output to printer page-size 0.

    i = 0.
    inicio = yes.
    for each titulo where titulo.empcod = wempre.empcod and
			  titulo.titnat = no            and
			  titulo.modcod = "CRE"         and
			  titulo.etbcod = estab.etbcod  and
			  titulo.clifor = clien.clicod  and
			  titulo.titnum = string(contrato.contnum) no-lock
					  break by titulo.titnum
						by titulo.titpar.
	find clien where clien.clicod = titulo.clifor no-lock no-error .
	if not available clien
	then next.
	else do:
	    if inicio = yes
	    then do:    /*
		put skip(2)
			"XXXX"
			"XXXXXXXXXXXXXXX"   at 7
			"XXXXXXXXXX"        at 26
			"XXXX"              at 43
			"XXXXXXXXXXX"   at 48
			"XXXXXXXXXX"        at 67 skip(1)
			"XXXXXX"            at 3
			"XXXXXXXXXX"        at 18
			"XXXX"              at 32
			"XXXXXX"            at 45
			"XXXXXXXXXXX"       at 60
			"XXXX"              at 73 skip(1)
			"XXXXXXXXXX"
			"XXXXXXXXXX"        at 44 skip(1)
			fill("X",30) format "x(30)" at 5
			fill("X",30) format "x(30)" at 46  skip
			fill("X",20) format "x(20)" at 5 "X"
			"XXXXX"
			 "-" "XXXXX" skip
			"XXXXXXXXXXXXXXXXXXXXXXXXXXXX / XX"
			skip(6). */
		    inicio = no.
	    end.
	    i = i + 1.
	    put skip(2)
		    etbcod
		    etbnom at 7  format "x(15)"
		    titdtven  at 26
		    etbcod  at 43
		    etbnom  at 48 format "x(15)"
		    titdtven at 67 skip(1)

		    clifor at 3 FORMAT ">>>>>>9"
		    titnum at 18    titpar at 32
		    clifor at 45 FORMAT ">>>>>>9"
		    titnum at 60    titpar at 73 skip(1)

		    titvlcob format ">>>,>>9.99"
		    titvlcob format ">>>,>>9.99" at 44 skip(1)

		    clinom          at 5  format "x(30)"
		    clinom          at 46 format "x(30)"  skip

		    clien.endereco[1] format "x(20)" at 5 ","
		    trim(string(clien.numero[1]))
			 format "99999"  "-" clien.compl[1]  format "x(5)" skip
		    clien.cidade[1]   at 5 "/" clien.ufecod[1].

	    if i = 1
	    then put skip(6).
	    else do:
		put skip(6).
		i = 0.
	    end.
	end.
    end.
    OUTPUT CLOSE.
end.
