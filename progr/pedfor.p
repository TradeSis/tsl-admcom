/*----------------------------------------------------------------------------*/
/* /usr/admcom/pedfor.p                       Consulta Pedidos por Fornecedor */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 16/09/92 Oscar   Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var wdiapg as char format "x(15)" label "Prazo de Pagamento".
def var wtotpg as deci format ">>>,>>>,>>>,>>9.99" label "Total do Pedido".

repeat:

    prompt-for forne.forcod with frame f1 width 80 side-label.

    find forne using input forne.forcod.

    display forne.fornom no-label with frame f1.

    for each pedid where pedid.forcod = forne.forcod by peddat descending:

	for each propg of pedid:

	if wdiapg = ""
	   then wdiapg = string(prpdata - peddat).
	   else wdiapg = wdiapg + "/" + string(prpdata - peddat).

	wtotpg = wtotpg + propg.prpvalor.

	end.

    display               space(2)
	    pedid.pednum  space(2)
	    pedid.peddat  space(2)
	    wtotpg        space(2)
	    pedid.pedsit  space(2)
	    wdiapg        space(2)
	    pedid.comcod with frame f2 width 80 down.

    down with frame f2.

    wdiapg = "".
    wtotpg =  0.

    end.

end.
