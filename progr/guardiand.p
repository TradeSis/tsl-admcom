/***** CRONTAB AS 14:30HS ******/
output to /admcom/work/guardian.005 append.
put "Inicio rodando DG005 " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg005.p.
put "Fim rodando DG005 " string(time,"hh:mm:ss") skip.
output close.

/*
output to /admcom/work/guardian.006 append.
put "Inicio rodando DG006 " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg006.p.
put "Fim rodando DG006 " string(time,"hh:mm:ss") skip.
output close.
*/
/*
output to /admcom/work/guardian.007 append.
put "Inicio rodando DG007 " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg007.p.
put "Fim rodando DG007 " string(time,"hh:mm:ss") skip.
output close.
*/

output to /admcom/work/guardian.008 append.
put "Inicio rodando DG008 " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg008.p.
put "Fim rodando DG008 " string(time,"hh:mm:ss") skip.
output close.

output to /admcom/work/guardian.009 append.
put "Inicio rodando DG009 " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg009.p.
put "Fim rodando DG009 " string(time,"hh:mm:ss") skip.
output close.

output to /admcom/work/guardian.028 append.
put "Inicio rodando DG028 " string(today) " " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg028.p.
put "Fim rodando DG028 " string(time,"hh:mm:ss") skip.
output close.

output to /admcom/work/guardian.029 append.
put "Inicio rodando DG029 " string(today) " " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg029.p.
put "Fim rodando DG029 " string(time,"hh:mm:ss") skip.
output close.

output to /admcom/work/guardian.030 append.
put "Inicio rodando DG030 " string(today) " " string(time,"hh:mm:ss") skip.
run /admcom/progr/dg030.p.
put "Fim rodando DG030 " string(time,"hh:mm:ss") skip.
output close.

pause 5 no-message.

return.

