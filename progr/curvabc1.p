{admcab.i}
def var tipo as char format "x(20)" extent 3 
        initial["GERAL","CLASSE INFERIOR","  CLASSE SUPERIOR"].
display tipo no-label with frame f1 no-label row 10 centered.

choose field tipo with frame f1.
hide frame f1 no-pause.
if frame-index = 1
then run curva2.p. 

if frame-index = 2
then run curcla3.p.


if frame-index = 3
then run curcla4.p.



