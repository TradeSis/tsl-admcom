{admcab.i}
def var vprocod like produ.procod.
def var vetbcod like estab.etbcod.
update vetbcod with frame f0 side-label.
find estab where estab.etbcod = vetbcod no-lock.
disp estab.etbnom with frame f0 width 80.
repeat:
    vprocod = 0.
    update vprocod with frame f1 side-label down.
    find produ where produ.procod = vprocod no-lock no-error.
    disp produ.pronom no-label format "x(35)" with frame f1.
    find estoq where estoq.etbcod = vetbcod and
		     estoq.procod = produ.procod no-error.
    update estoq.estbalqtd label "Qtd" format "->>,>>9.99"
	with frame f1 width 80.
end.
