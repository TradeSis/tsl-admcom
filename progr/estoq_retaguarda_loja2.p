/*{/usr/admcom/progr/admdisparo.i new}.*/

message "Aguarde, conectando os bancos...".

if connected ("commatriz")
then disconnect commatriz.
connect com -H erp.lebes.com.br -S sdrebcom -N tcp -ld commatriz.

if connected ("germatriz")
then disconnect germatriz.
connect ger -H erp.lebes.com.br -S sdrebger -N tcp -ld germatriz.

message "Bancos conectados!".

run estoq_retaguarda_loja.p.

disconnect commatriz.
disconnect germatriz.