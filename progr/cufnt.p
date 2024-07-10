/*----------------------------------------------------------------------------*/
/* cuspr\cufnt.p                                  Custo por Fabricante/Classe */
/*----------------------------------------------------------------------------*/
{admcab.i}
define variable wad as logical format "Acrescimo/Desconto" initial yes
		label "Acresc/Descon".
define variable wperc as decimal decimals 2 format ">,>>9.99 %"
		label "Percentual".
repeat with side-labels 1 down width 80 title " Parametros " frame f1:
    prompt-for fabri.fabcod colon 18.
    find fabri using fabri.fabcod.
    display fabnom no-label at 30.
    prompt-for clase.clacod colon 18.
    find clase using clase.clacod.
    display clanom no-label at 30.
    disp "" @ estab.etbcod colon 18.
    prompt-for estab.etbcod validate(true,"")
	   help "Informe o Estabelecimento ou BRANCO para todos." colon 18.
    if input estab.etbcod <> ""
	then do:
	find estab using etbcod.
	display etbnom no-label at 30.
	end.
	else disp "TODOS" @ etbnom.
    update wad colon 18
	   wperc colon 18.
    {confir.i 1 "Alteracao de Custos por Fornecimento"}
    pause 0 before-hide.
    for each produ of clase where produ.fabcod = fabri.fabcod,
	each estoq of produ
	with down title " Produtos - Estoques " frame f4:
	if input estab.etbcod <> "" and
	   input estab.etbcod <> estoq.etbcod
	    then next.
	if wad
	    then assign estcusto = estcusto * (wperc / 100 + 1).
	    else assign estcusto = estcusto * (1 - wperc / 100).
	display estoq.procod
		estoq.etbcod
		estoq.pronomc
		estoq.fabfant space(2)
		estoq.estcusto
		estoq.estvenda.
	assign estdtcus = today
	       estreaj = yes.
    end.
    pause before-hide.
    message "Alteracao de Custos para" fabnom "-" clanom "encerrada.".
end.
