/*                                                            prolicl.p

									    */
{admcab.i}
repeat:
    prompt-for estab.etbcod.
    find estab using etbcod.
    display etbnom.

    form header
    wempre.emprazsoc
    "Administracao Comercial" at 65 today at 117 skip
    "Produtos - Listagem" estab.etbnom no-label at 65
    "Pag." at 117 page-number format ">>9" skip
    fill("-",125) format "x(125)" skip
    "Produto" at 5
    "Descricao" at 13
    "Ref.Ter." at 65
    "P.Custo" at 87
    "P.Venda" at 102
    "Quant." at 116 skip
    "-------" at 5
    "---------" at 13
    "--------" at 65
    "-------" at 87
    "-------" at 102
    "------" at 116 skip
    with frame fcab page-top no-box width 130.

    output to printer page-size 60.
    view frame fcab.

    for each clase by clanom:

	if clase.clatipo = no then do:

	    for each produ of clase break by produ.clacod:

		find estoq where estoq.etbcod = input estab.etbcod and
				 estoq.procod = produ.procod and
				 estoq.estatual > 0 no-error.
		if available estoq then do:
		    if first-of(produ.clacod) then
			display skip(1) clase.clanom no-label.

		    put space(5)
			    produ.procod space(1)
			    produ.pronom space(1)
			    produ.prorefter space(1)
			    estoq.estcusto space(1)
			    estoq.estvenda space(1)
			    estoq.estatual skip.
		end.
		else
		    undo,next.
	    end.
	end.
    end.
    output close.
end.
