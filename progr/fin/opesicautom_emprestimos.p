
{admbatch.i new}

run fin/marcasic200.p.
run fin/opesicemivalid.p ("ENVIAR").


run /admcom/progr/fin/opesicemiautom.p ("ENVIAR","EMPRESTIMO").


message "FIM" today string(time,"HH:MM:SS").


