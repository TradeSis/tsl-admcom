/* helio - 12012023 - ajuste em performance */

{admbatch.i new}

run fin/marcasic200.p.
run fin/opesicemivalid.p ("ENVIAR").
run fin/opesicpagvalid.p ("ENVIAR").


run /admcom/progr/fin/opesicemiautom.p ("ENVIAR","CONTRATO").

run /admcom/progr/fin/opesicemiautom.p ("ENVIAR","NOVACAO").
                              
run /admcom/progr/fin/opesicpagautom.p ("ENVIAR","PAGAMENTO").
run /admcom/progr/fin/opesicpagautom.p ("ENVIAR","DESENROLA"). /* helio 13112023 */


/* helio - 12012023 - ajuste em performance - identificado que operacao NOVACAO nao esta enviando os pagamentos*/
run /admcom/progr/fin/opesicpagautom.p ("ENVIAR","NOVACAO").

run /admcom/progr/fin/opesicpagautom.p ("ENVIAR","CANCELAMENTO").
run /admcom/progr/fin/opesicpagautom.p ("ENVIAR","ESTORNO").

message "FIM" today string(time,"HH:MM:SS").


