/*{admcab.i}*/
DEF VAR ESCOLHA AS CHAR EXTENT 4
    INITIAL [
		"COPIA DE ARQUIVOS",
		"MANUTENCAO EM CAMPOS",
		"MANUTENCAO EM PROGRAMAS",
		"MANUTENCAO EM PROCESSOS"
	    ].
DEF VAR PROGRAMA AS CHAR EXTENT 4
    INITIAL [
		"admcopi.p",
		"campo.p",
		"programa.p",
		"processo.p"
	    ].

repeat with frame f-esc:
    display
	escolha[1] format "x(20)"
	escolha[2] format "x(23)"
	escolha[3] format "x(23)"
	escolha[4] format "x(23)"
	    with frame f-esc
		    centered row 8 color white/yellow
		    no-labels 1 down 1 col.
    choose
	field escolha
	    with frame f-esc.
    run value(programa[frame-index]).
end.
