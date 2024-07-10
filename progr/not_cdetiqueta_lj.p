{admcab.i}

message "Conectando Matriz ...".

if not connected ("admmatriz")
then connect adm -H erp.lebes.com.br -S sdrebadm -N tcp -ld admmatriz no-error.
/* Homologa
     connect adm -H sv-ca-linx-h.lebes.com.br -S sdrebadm -N tcp -ld admmatriz.
*/
hide message no-pause.

if connected ("admmatriz")
then do.
    run not_cdetiqueta.p.
    disconnect admmatriz.
end.
else message "Sem conecao ao banco da matriz" view-as alert-box.

