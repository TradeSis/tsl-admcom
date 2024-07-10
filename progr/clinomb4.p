{admcab.i}
def var vesc    as   char format "x(12)" extent 2
		     initial [" Por Regiao "," Por Filial "].

display vesc
	with frame fesc no-label row 4 color white/cyan centered.

choose field vesc
       with frame fesc.

if frame-index = 1
then
    run clinomre.p.
else
    run clinomet.p.
