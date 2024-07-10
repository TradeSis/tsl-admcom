/****** CRONTAB A CADA 5 MINUTOS ****/ 

output to /admcom/work/guardian.001 append.
put today skip
    "Inicio rodando DG001 " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg001.p.
put "Fim rodando DG001 " string(time,"hh:mm:ss") skip.
output close.

output to /admcom/work/guardian.002 append.
put today skip
    "Inicio rodando DG002 " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg002.p.
put "Fim rodando DG002 " string(time,"hh:mm:ss") skip.
output close.

/*
output to /admcom/work/guardian.003 append.
put today skip
    "Inicio rodando DG003 " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg003.p.
put "Fim rodando DG003 " string(time,"hh:mm:ss") skip.
output close.
*/

output to /admcom/work/guardian.004 append.
put today skip
    "Inicio rodando DG004 " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg004.p.
put "Fim rodando DG004 " string(time,"hh:mm:ss") skip.
output close.

output to /admcom/work/guardian.010 append.
put today skip
    "Inicio rodando DG010 " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg010.p.
put "Fim rodando DG010 " string(time,"hh:mm:ss") skip.
output close.

output to /admcom/work/guardian.011 append.
put today skip
    "Inicio rodando DG011 " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg011.p.
put "Fim rodando DG011 " string(time,"hh:mm:ss") skip.
output close.

output to /admcom/work/guardian.012 append.
put today skip
    "Inicio rodando DG012 " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg012.p.
put "Fim rodando DG012 " string(time,"hh:mm:ss") skip.
output close.

output to /admcom/work/guardian.013 append.
put today skip
    "Inicio rodando DG013 " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg013.p.
put "Fim rodando DG013 " string(time,"hh:mm:ss") skip.
output close.

/***
output to /admcom/work/guardian.014 append.
put "Inicio rodando DG014 " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg014.p.
put "Fim rodando DG014 " string(time,"hh:mm:ss") skip.
output close.
**/

/*** PEDIDOS MANUAIS COM MAIS DE 5 ITENS ***/
output to /admcom/work/guardian.015 append.
put today skip
    "Inicio rodando DG015 " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg015.p.
put "Fim rodando DG015 " string(time,"hh:mm:ss") skip.
output close.

/** NOTAS NAO CONFIMADAS MAIS Q 3 DIAS ***/
output to /admcom/work/guardian.016 append.
put today skip
    "Inicio rodando DG016 " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg016.p.
put "Fim rodando DG016 " string(time,"hh:mm:ss") skip.
output close.

output to /admcom/work/guardian.027 append.
put today skip
    "Inicio rodando DG027 " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg027.p.
put "Fim rodando DG027 " string(time,"hh:mm:ss") skip.
output close.

return.
