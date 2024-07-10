def input parameter p-cria-tipviv as integer.
def input parameter p-cria-codviv as integer.
def input parameter p-cria-procod as integer.
def input parameter p-cria-etbcod as integer.

    
create plaviv_filial.
assign plaviv_filial.tipviv = p-cria-tipviv
       plaviv_filial.codviv = p-cria-codviv
       plaviv_filial.procod = p-cria-procod
       plaviv_filial.etbcod = p-cria-etbcod.

release plaviv_filial.




