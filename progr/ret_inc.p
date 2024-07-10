{admcab.i}

def var vsel as char extent 2 format "x(20)".

vsel[1] = "DREBES LOJAS".
vsel[2] = "DREBES FINANCEIRA".
/*
DISP vsel with frame fsel no-label centered.

choose field vsel with frame fsel.

if frame-index = 1
then*/ run retinc_l.p.
/*else run retinc_f.p.*/


 