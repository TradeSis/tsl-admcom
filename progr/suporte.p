{admcab.i}
/*
find segur where segur.cntcod = 99      and
                 segur.usucod = sfuncod       no-lock no-error.
if not avail segur then leave.
*/
def var varqsai as char.         

if not connected ("suporte")
then
    connect l:\bases\suporte -1 -r.

run servico.p  .
                               
if connected ("suporte")
then
    disconnect suporte.
     
    
    

