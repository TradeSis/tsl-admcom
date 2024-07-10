{admcab.i}
/* MENU - Helio 1405 ID 63063*/
def var vtipo as char format "x(15)" extent 1
    init["   SALDO" /*,"   BAIXA"*/ ].
disp vtipo with frame ftipo 1 down no-label centered.
choose field vtipo with frame ftipo.    

if frame-index = 1
then run fin/ctsinsegsaldo_v0221.p.
/* else run ctb/ctsinsegbaixa_v0219.p.
*/


