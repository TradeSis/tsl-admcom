{admcab.i}
             
/*** Conecta banco WMS ***/ 
if connected ("wms") 
then disconnect wms.  
               
connect wms -H "erp.lebes.com.br" -S sdrebwms -N tcp -ld wms no-error. 
                 
hide message no-pause. 

if opsys = "UNIX"
then run /admcom/wms/pemieten.p.
else run l:\wms\pemieten.p.

if connected ("wms") 
then disconnect wms.
