
if "{1}" = "REC"
then
message color red/with 
    "Interface WMS recebida: " 
    entry(num-entries(par-arq,"/"),par-arq,"/")
    view-as alert-box.
else
message color red/with 
    "Interface WMS gerada: " 
    entry(num-entries(par-arq,"/"),par-arq,"/")
    view-as alert-box.


 