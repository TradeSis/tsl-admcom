{cabd.i}
def var vmovtdc  like movim.movtdc.
def var vtipmov  as char extent 2 initial ["ENTRADA","SAIDA"].
def var vinicial as date label "Data Inicial".
def var vacumqtm like movim.movqtm.
repeat:
    prompt-for vinicial
		 with frame f1 width 80 1 down side-label.
    disp vtipmov
	with frame f2 no-label centered.
    choose field vtipmov with frame f2.
    vmovtdc = frame-index.

    vacumqtm = 0.
    output to printer page-size 64.
    for each movim where movim.movdat = input vinicial and
			 movim.movtdc = vmovtdc,
	produ of movim
				   break  by produ.pronom
			with frame f3 width 130.
	FIND ESTOQ OF movim.
	vacumqtm = vacumqtm + movqtm.
	if last-of(produ.pronom)
	then do:

	    form header
		wempre.emprazsoc no-label
		space(6) "MOVRELB1"  at 93
		"Pag.: " at 102 page-number format ">>9" skip
		"RELATORIO DE MOVIMENTACOES DE " string(vtipmov[vmovtdc])
		"DO DIA"
		string(input vinicial)
		today format "99/99/9999" at 93
		string(time,"hh:mm:ss") at 104        skip
		skip fill("-",111) format "x(111)" skip
		with frame fcab page-top no-box width 111.
	    view frame fcab.
	    display
		    movim.procod
		    produ.pronom
		    vacumqtm column-label "Quant."
		    movpc column-label "Pc.Movim." (total)
		    estoq.estvenda column-label "Pc.Venda" (total)
		    (movpc - estoq.estvenda) column-label "Diferenca" (total).
	    vacumqtm = 0.
	end.
    end.
    output close.
end.
