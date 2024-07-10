{admcab.i}
define variable wconini like contrato.contnum label " Inicial".
define variable wconfim like contrato.contnum label "   Final".
define variable rsp as logical format "Sim/Nao" initial yes.
do with 1 column width 80 frame f1 title " Parametros " ROW 4 COLOR WHITE/CYAN:
    update wconini
	    help "Digite o Contrato Inicial"
	   wconfim
	    help "Digite o Contrato Final".
    message "Imprimindo Bloquetos.".
    for each contrato where contnum >= wconini and
			    contnum <= wconfim:
	run impblo.p (contrato.contnum).
    end.
end.
