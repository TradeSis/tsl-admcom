{/admcom/progr/admcab-batch.i new}                                       
        

                                                             
pause 0.
/* tem cron propria 23032021 run "/admcom/progr/calculabalanco.p". */

/* desativado run "/admcom/progr/bsi-eiscob-vencimento.p".  */

/* ate 08032021 run "/admcom/progr/visao_cre_export.p". */
    run  /admcom/progr/visao_cre_export_v2.p .
    run /admcom/progr/visao_crd_export.p    .

/* tem cron propria run "/admcom/progr/bsi-eiscobreg2.p".   */




