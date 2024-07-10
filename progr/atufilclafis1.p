{admcab.i}

def var vetbcod like estab.etbcod.
def var vdti    like com.plani.pladat initial today.
def var vdtf    like com.plani.pladat initial today.

def input parameter ip   as char format "x(15)".

if connected ("nfeloja")
then disconnect nfeloja.

message "Conectando...".
connect nfe -H value(ip) -S sdrebnfe -N tcp -ld nfeloja no-error.

if not connected ("nfeloja")
then do:

    message "Banco nao conectado".
        undo, retry.

end.

run atufilclafis2.p.

if connected ("nfeloja")
then disconnect nfeloja.

