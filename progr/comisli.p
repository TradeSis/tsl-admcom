/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/comis.p                                  Vendas por Vendedor*/
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 29/09/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var wdtven as da initial today.
def var wtotven as de format ">,>>>,>>>,>>9.99".
l1:
repeat with 1 column width 80 title " Dados para Consulta " 1 down frame f1:
    update wdtven label "Data de Venda".
    wtotven = 0.
    for each nota where (movtdc = 3 or movtdc = 4) and notdat = wdtven,
	vende of nota break by nota.vencod:
	wtotven = wtotven + notval.
	if last-of (nota.vencod)
	    then do:
	    display vende.vencod column-label "Cod."
		    vennom
		    wtotven (total) column-label "Venda"
		    with centered title " Vendas ".
	    wtotven = 0.
	    end.
    end.
    {confir.i 1 "Impressao da Venda por Vendedor"}
    message "Emitindo Venda por Vendedor.".
    output to printer.
    display "Vendas por Vendedor no Dia :"
	    wdtven no-label
	    with side-labels centered frame f2.
    for each nota where (movtdc = 3 or movtdc = 4) and notdat = wdtven,
	vende of nota break by nota.vencod:
	wtotven = wtotven + notval.
	if last-of (nota.vencod)
	    then do:
	    display vende.vencod column-label "Cod."
		    vennom
		    wtotven (total) column-label "Venda"
		    with centered.
	    wtotven = 0.
	    end.
    end.
    hide message no-pause.
    output close.
    message "Emissao de Vendas por Vendedor encerrada.".
end.
