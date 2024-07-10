/*----------------------------------------------------------------------------*/
/* /usr/admcom/cp/mlpro.p                        Alteracao Mg.Lucro - Produto */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 26/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
define variable wl as logical.
define variable wad as logical format "Acrescimo/Desconto" initial yes
		label "Acresc/Descon".
define variable wperc as decimal decimals 2 format ">,>>9.99 %"
		label "Percentual".
repeat with side-labels 1 down width 80 frame f1 title " Produto ":
    prompt-for produ.procod colon 18.
    find produ using produ.procod.
    find fabri of produ.
    display pronom + "-" + fabfant format "x(52)" no-label at 27.
    prompt-for estab.etbcod validate(true,"")
	   help "Informe o Estabelecimento ou BRANCO para todos." colon 18.
    if input estab.etbcod <> ""
	then do:
	find estab using etbcod.
	display etbnom no-label at 30.
	end.
    wl = no.
    for each estoq of produ:
	if input estab.etbcod = "" or
	   input estab.etbcod = estoq.etbcod
	    then do:
	    accumulate estoq.estmgoper (average maximum minimum)
		       estoq.estmgluc (average maximum minimum).
	    wl = yes.
	    end.
    end.
    if wl
	then display "          Empresa   Minimo   Maximo    Media"
		     "Mg.Oper."
		     wempre.empmgoper format ">,>>9.99"
		     accum minimum estoq.estmgoper format ">,>>9.99"
		     accum maximum estoq.estmgoper format ">,>>9.99"
		     accum average estoq.estmgoper format ">,>>9.99"
		     "Mg.Lucr."
		     wempre.empmgluc format ">,>>9.99"
		     accum minimum estoq.estmgluc format ">,>>9.99"
		     accum maximum estoq.estmgluc format ">,>>9.99"
		     accum average estoq.estmgluc format ">,>>9.99"
		     with no-labels title " Margens Produto-Estoque (%) "
		     width 46 column 35 row 10 overlay frame fmarg.
    update wad colon 18
	   wperc colon 18.
    {confir.i 1 "Alteracao de Margem Lucro por Produto"}
    hide frame fmarg.
    pause 0 before-hide.
    for each estoq of produ
	with down title " Estoques " frame f2:
	if input estab.etbcod <> "" and
	   input estab.etbcod <> estoq.etbcod
	    then next.
	if wad
	    then assign estmgluc = estmgluc * (wperc / 100 + 1).
	    else assign estmgluc = estmgluc * (1 - wperc / 100).
	display estoq.procod
		estoq.etbcod
		estoq.pronomc
		estoq.fabfant space(2)
		estoq.estcusto
		estoq.estvenda.
	assign estreaj = yes.
    end.
    pause before-hide.
    message "Alteracao de Mg.Lucro para" produ.pronomc "-"
	    fabri.fabfant "encerrada.".
end.
