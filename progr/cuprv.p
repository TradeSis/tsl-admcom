{admcab.i}
def var wurv like estoq.estcusto label "Valor em URV".
repeat with side-labels 1 down width 80 frame f1 title " Produto - Valor ":
    prompt-for produ.procod colon 18.
    find produ using produ.procod.
    find estoq of produ where estoq.etbcod = 1.
    display estoq.pronomc + "-" + estoq.fabfant format "x(40)" no-label at 27
	    skip(1).
    update estcusto colon 18 skip(1).
    find urv where urv.urvdt = today.
    update wurv colon 18.
    assign estcusto = wurv * urvvl.
    update estcusto.
    assign estdtcus = today
	    estreaj = yes.
end.
