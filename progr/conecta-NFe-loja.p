def input parameter p-tipo as char.
def input parameter p-etbcod as char.
def input parameter p-ip as char.
def input parameter p-serie as char.

if connected ("nfeloja")
then disconnect nfeloja.

connect nfe -H value(p-ip) -S sdrebnfe -N tcp -ld nfeloja.

message "Cinectando " p-ip.
    
if not connected ("nfeloja")
then do:
    message "FALHA NA CONEXAO COM A FILIAL".
    pause.
    return.    
end.
else run atualiza-numero-NFe.p(p-tipo, p-etbcod, p-serie).
            
if connected ("nfeloja")
then disconnect nfeloja.
