def input parameter p-del-tipviv as integer.
def input parameter p-del-codviv as integer.
def input parameter p-del-procod as integer.
def input parameter p-del-etbcod as integer.

def buffer bf_plaviv_filial for plaviv_filial.
    
find first bf_plaviv_filial
     where bf_plaviv_filial.tipviv = p-del-tipviv
       and bf_plaviv_filial.codviv = p-del-codviv
       and bf_plaviv_filial.procod = p-del-procod
       and bf_plaviv_filial.etbcod = p-del-etbcod  exclusive-lock no-error.

if avail bf_plaviv_filial
then delete bf_plaviv_filial.





