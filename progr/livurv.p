{admcab.i}
def var i as i.
def var wcod like estoq.procod extent 4.
def var wurv like estoq.estven format ">,>>9.99" extent 4.
form header
    "IRMAOS MASIERO & CIA. LTDA." "Livro Preco de" at 40 today page-number at 71
    fill("-",80) format "x(80)" skip(1)
    with frame fcab page-top no-box no-attr-space.
do:
{confir.i 1 "Emissao do Livro de Preco em URV" ,leave}
output to printer page-size 65.
view frame fcab.
for each estoq where estoq.etbcod = 1 by estoq.procod:
    find urv where urv.urvdt = today.
    do:
	i = i + 1.
	assign wcod[i] = estoq.procod
	       wurv[i] = estoq.estvenda / urv.urvvl.

	if i = 4 then do:
	    display wcod[1] "-" wurv[1] space(4)
		    wcod[2] "-" wurv[2] space(4)
		    wcod[3] "-" wurv[3] space(4)
		    wcod[4] "-" wurv[4] with no-labels no-box frame f1 down.
	    i = 0.
	end.
    end.
end.
output close.
end.
