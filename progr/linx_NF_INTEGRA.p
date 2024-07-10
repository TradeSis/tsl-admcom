pause 0 before-hide.
/*
/admcom/work/linx_integra
*/

output to value("/admcom/logs/linx_integra." + string(today,"999999") +
                                         ".log") append.
put skip
    today format "99/99/9999" " - "
    string(time,"HH:MM:SS") " - " skip.
run /admcom/progr/linx_roda_forne.p.
run /admcom/progr/linx_roda_saida.p.
run /admcom/progr/linx_roda_entradas.p.
output close.

