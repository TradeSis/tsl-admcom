{admcab.i}

def var vetbcod like estab.etbcod.
def var vdti    like com.plani.pladat initial today.
def var vdtf    like com.plani.pladat initial today.

def input parameter ip   as char format "x(15)".

if connected ("gerloja")
then disconnect gerloja.
    
message "Conectando...".
connect ger -H value(ip) -S sdrebger -N tcp -ld gerloja no-error.
    
if not connected ("gerloja")
then do:
        
    message "Banco nao conectado".
    undo, retry.    
   
end.

run atu66.p.
     
if connected ("gerloja")
then disconnect gerloja.
    
    
    
