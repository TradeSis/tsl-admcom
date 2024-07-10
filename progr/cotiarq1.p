
{admcab.i}


disconnect mov no-error. 


message "Conectando......". 

connect mov -H sincro -S smov -N tcp -ld mov no-error.
 
run cotiarqm.p.

disconnect mov no-error.

connect /usr/admcom/bases/mov 
         -H servidor -S sdrebmov -N tcp -ld mov no-error.
         
         
