message "Conectando ao banco ECommerce...".
if connected ("ecommerce")
then disconnect ecommerce.

connect ecommerce -H "erp.lebes.com.br" -S sdrebecommerce -N tcp -ld ecommerce no-error.

run alt-end.p.

if connected ("ecommerce")
then disconnect ecommerce.
