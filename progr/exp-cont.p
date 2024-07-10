def stream stela.
output stream stela to terminal.
output to c:\dados\cont14.d.
for each estab where estab.etbcod = 14 no-lock,
    each contrato where contrato.etbcod = estab.etbcod   and
                        contrato.dtinicial >= 01/01/2001 and
                        contrato.dtinicial <= today no-lock:

    display stream stela 
            contrato.clicod
            contrato.dtinicial format "99/99/9999" with 1 down. pause 0.
    export contrato.
end.
output close.
output stream stela close.

