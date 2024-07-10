/***************************************************************************
** Programa        : atudbrp-disp.p
** Objetivo        : Atualiza dados do DB para DBRP
****************************************************************************/

def new shared var dd-rep as int.
def new shared var vhoraini as dec.

dd-rep = 1.

def new shared var vlog as char.

vlog = "/usr/admcom/logs/atudbrp_log." + string(day(today)) + 
    string(month(today)).
 
def var vhorafinal as dec.
def var p-ok as log.

p-ok = no.
run /admcom/progr/atudbrp-conecta.p( input "COM", 
                                       input "atudbrp-disp.p", 
                                       output p-ok).
if p-ok = no
then do:
    output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp-disp.p " format "x(25)"
                " - Banco COM Nao Conectou " format "x(30)" skip.
    output close.
    return.
end.

p-ok = no.
run /admcom/progr/atudbrp-conecta.p( input "GER", 
                                    input "atudbrp-disp.p", 
                                    output p-ok).
if p-ok = no
then do:
    output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp-disp.p " format "x(25)"
            " - Banco GER Nao Conectou " format "x(30)" skip.
    output close.
    return.
end.

p-ok = no.
run /admcom/progr/atudbrp-conecta.p( input "FIN", 
                                    input "atudbrp-disp.p", 
                                    output p-ok).
if p-ok = no
then do:
    output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp-disp.p " format "x(25)"
            " - Banco FIN Nao Conectou " format "x(30)"  skip.
    output close.
    return.
end.
vhorafinal = vhoraini + (3600 * 2).

output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp-disp.p " format "x(25)"
            " - INICIO FASE 1  " format "x(30)"   skip.
output close.

repeat :
    
    pause 2 no-message.
    
    output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp-disp.p " format "x(25)"
                " - INICIO atudbrp.p " format "x(30)"   skip.
    output close.
    run /admcom/progr/atudbrp.p .
    /*
    if time > vhorafinal
    then do:

        output to value(vlog) append.
        put string(time,"HH:MM:SS") + " atudbrp-disp.p " format "x(25)"
                        " - FIM atudbrp.p  "  format "x(30)"  skip.
        output close.
        leave.

    end.
    else*/ do:
        output to value(vlog) append.
        put string(time,"HH:MM:SS") + " atudbrp-disp.p " format "x(25)"
                " - PARADA DE 90s  " format "x(30)"   skip.
        output close.
        pause 90 no-message.
    end.
end.

do on error undo, return:

    run /admcom/progr/atudbrp-desconecta.p( input "COM", 
                                       input "atudbrp-disp.p", 
                                       output p-ok).

    run /admcom/progr/atudbrp-desconecta.p( input "FIN", 
                                       input "atudbrp-disp.p", 
                                       output p-ok).

    run /admcom/progr/atudbrp-desconecta.p( input "GER", 
                                       input "atudbrp-disp.p", 
                                       output p-ok).
                                       
end.                                       

