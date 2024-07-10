{admcab.i}

def var vesc as char extent 2 format "x(15)".
vesc[1] = "POR CODIGO".
vesc[2] = "POR CLASSE".

disp vesc with frame f-esc 1 down centered no-label.

choose field vesc with frame f-esc.

hide frame f-esc.

if frame-index = 1
then run pesco.p.
else if frame-index = 2
then run estoque-por-classe.p.


