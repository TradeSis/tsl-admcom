{admcab.i}

message "Aguarde...".
connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm no-error.
connect fin -H "erp.lebes.com.br" -S sdrebfin -N tcp -ld finmatriz no-error.
connect com -H "erp.lebes.com.br" -S sdrebcom -N tcp -ld commatriz no-error.
connect dragao -H "erp.lebes.com.br" -S dragao -N tcp -lg dragao no-error.
 
hide message no-pause.

if not connected ("crm")
then do:
    message "Nao foi possivel encontrar as Acoes. Avisar CPD.".
    pause.
    leave.
end.

run lisbon04.p.

disconnect crm.
disconnect finmatriz.
disconnect commatriz.
