{admcab.i}
def var Valor       as dec format ">>9.99".
def var vqtd        as int label "Qtd".
def var i as int.
def var r as int.

update valor colon 14
	with frame f1 side-label color white/cyan row 4
	    title " ETIQUETAS DE OFERTA ".
update vqtd colon 14
	with frame f1 width 80.

output to printer page-size 0.
r = 0.
do i = 1 to vqtd.
    put "Oferta " valor format ">>9.99" space(3).
    r = r + 1.
    if r = 8
    then do:
	put skip(2).
	r = 0.
    end.
end.
put skip(2).
output close.
