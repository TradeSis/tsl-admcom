def input parameter p-banco as char.
def input parameter p-processo as char.
def output parameter p-ok as log.

def shared var vlog as char.

def var i as int init 0.

output to value(vlog) append.
put string(time,"HH:MM:SS") + " " + p-processo format "x(25)"            
    " - Desconectando Banco " + p-banco format "x(30)" skip.
output close.
 
if p-banco = "COM"
then do:
    if connected ("comdbrp")
    then do:
        disconnect comdbrp.
    end.    
end.
else if p-banco = "FIN"
then do:
    if connected ("findbrp")
    then do:
        disconnect findbrp.
    end.    
end.
else if p-banco = "GER"
then do:
    if connected ("gerdbrp")
    then do:
        disconnect gerdbrp.
    end.    
end.
else if p-banco = "ADM"
then do:
    if connected ("admdbrp")
    then do:
        disconnect admdbrp.
    end.
end.
else if p-banco = "DRAGAO"
then do:
    if  connected ("dradbrp")
    then do:
        disconnect dradbrp.
    end.
end.
else if p-banco = "BANFIN"
then do:
    if connected ("bandbrp")
    then do:
        disconnect bandbrp.
    end.
end.
else if p-banco = "SUPORTE"
then do:
    if connected ("supdbrp")
    then do:
        disconnect supdbrp.
    end.
end.





