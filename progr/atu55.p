
for each gerloja.flag:
    display "deletando..." gerloja.flag.clicod with 1 down. pause 0.
    do transaction:
        delete gerloja.flag.
    end.
end.

for each ger.flag no-lock.

    display "Importando..." ger.flag.clicod with 1 down. pause 0.
        
    create gerloja.flag.
    {tt-flag.i gerloja.flag ger.flag}.
        
end.

            



        