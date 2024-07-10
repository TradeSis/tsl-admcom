def temp-table tt-cli
    field clicod like clien.clicod.

for each estab where estab.etbcod = 12 no-lock,
    each contrato where contrato.etbcod = estab.etbcod   and
                        contrato.dtinicial >= 01/01/2001 and
                        contrato.dtinicial <= today no-lock:

    find first tt-cli where tt-cli.clicod = contrato.clicod no-error.
    if not avail tt-cli
    then do:
        create tt-cli.
        assign tt-cli.clicod = contrato.clicod.
    end.
    display contrato.clicod
            contrato.dtinicial format "99/99/9999" with 1 down. pause 0.
end.

output to l:\work\cli12.d.
for each tt-cli:
    find clien where clien.clicod = tt-cli.clicod no-lock no-error.
    if not avail clien
    then next.
    
    export clien.
end.
output close.

