{admcab.i}
def shared var vdti as date.
def shared var vdtf as date.

def new shared var vlog as char.

vlog = "/admcom/logs/atualiza1-dbrp_log." + string(day(today)) + 
    string(month(today)).
 
def var p-ok as log.

p-ok = no.
run /admcom/progr/atudbrp-conecta.p( input "COM", 
                                       input "atualiza1-dbrp.p", 
                                       output p-ok).
if p-ok = no
then do:
    output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atualiza1-dbrp.p " format "x(25)"
                " - Banco COM Nao Conectou " format "x(30)" skip.
    output close.
    return.
end.

p-ok = no.
run /admcom/progr/atudbrp-conecta.p( input "FIN", 
                                       input "atualiza1-dbrp.p", 
                                       output p-ok).
if p-ok = no
then do:
    output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atualiza1-dbrp.p " format "x(25)"
                " - Banco FIN Nao Conectou " format "x(30)" skip.
    output close.
    return.
end.

p-ok = no.
run /admcom/progr/atudbrp-conecta.p( input "SUPORTE", 
                                       input "atualiza1-dbrp.p", 
                                       output p-ok).
if p-ok = no
then do:
    output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atualiza1-dbrp.p " format "x(25)"
                " - Banco SUPORTE Nao Conectou " format "x(30)" skip.
    output close.
    return.
end.

run atualiza2-dbrp.p.


do on error undo, return:

    run /admcom/progr/atudbrp-desconecta.p( input "COM", 
                                       input "atualiza1-dbrp.p", 
                                       output p-ok).

    run /admcom/progr/atudbrp-desconecta.p( input "FIN", 
                                       input "atualiza1-dbrp.p", 
                                       output p-ok).

    run /admcom/progr/atudbrp-desconecta.p( input "SUPORTE", 
                                       input "atualiza1-dbrp.p", 
                                       output p-ok).

end.