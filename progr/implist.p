message "Conectando aos bancos WMS e E-Commerce...".
if connected ("bswms")
then disconnect bswms.

if connected ("ecommerce")
then disconnect ecommerce.

connect bswms -N tcp -S 1922 -H server.dep93 -cache ../wms/bswms.csh.

connect ecommerce -H "erp.lebes.com.br" -S sdrebecommerce -N tcp -ld ecommerce.

run implist1.p.

if connected ("bswms")
then disconnect bswms.

if connected ("ecommerce")
then disconnect ecommerce.
