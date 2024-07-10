{admcab.i}
             
def var vsenhax as char.
             
update vsenhax blank label "Senha"
       with frame f-wms centered side-labels.

if vsenhax <> "wmscbs"
then leave.

hide frame f-wms no-pause.

/*** Conecta banco WMS ***/ 
if connected ("wms") 
then disconnect wms.  
               
connect wms -H "erp.lebes.com.br" -S sdrebwms -N tcp -ld wms no-error. 
                 
hide message no-pause. 

run /admcom/wms/menu.p.

if connected ("wms") 
then disconnect wms.
