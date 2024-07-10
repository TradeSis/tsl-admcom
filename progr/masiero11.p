def var i as i.

for each clien where clien.clinom = "":
    
    i = i + 1.
    if i mod 100 = 0
    then do:
        disp i clicod with 1 down. 
        pause 0.
    end.

    find first plani where plani.movtdc = 5 and
                           plani.desti  = clien.clicod no-lock no-error.
    if avail plani 
    then do:
        next.
    end.

    find first contrato where contrato.clicod = clien.clicod no-lock no-error.
    if avail contrato
    then do:
        next.
    end.

    find first titulo where titulo.clifor = clien.clicod no-lock no-error.
    if avail titulo
    then do:
        next.
    end.

    delete clien.

end.

