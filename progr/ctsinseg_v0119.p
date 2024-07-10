{admcab.i}

def var vtipo as char format "x(15)" extent 2
    init["   SALDO","   BAIXA"].
disp vtipo with frame ftipo 1 down no-label centered.
choose field vtipo with frame ftipo.    

if frame-index = 1
then run ctsinsegsaldo_v0119.p.
else run ctsinsegbaixa_v0119.p.


