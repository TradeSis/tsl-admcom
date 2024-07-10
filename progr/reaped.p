{admcab.i}

message "Conectando ao banco ECommerce...".
if connected ("ecommerce")
then disconnect ecommerce.

connect ecommerce -H "erp.lebes.com.br" -S sdrebecommerce -N tcp -ld ecommerce no-error.

run reaped1.p.

if connected ("ecommerce")
then disconnect ecommerce.
