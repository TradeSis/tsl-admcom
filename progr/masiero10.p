def var i as i.
def var a as i.
for each clien where clien.clinom = "" no-lock.
    a = a + 1.
    disp a i with 1 down. pause 0. 
    find first plani where plani.movtdc = 5 and
                           plani.desti = clien.clicod no-lock no-error.
    if avail plani
    then do:
        i = i + 1.
        disp i with 1 down. pause 0.
        next.
    end.

    find first contrato where contrato.clicod = clien.clicod no-lock no-error.
    if avail contrato
    then do:
        i = i + 1.
        disp i with 1 down. pause 0.
        next.
    end.

    find first titulo where titulo.clifor = clien.clicod no-lock no-error.
    if avail titulo
    then do:
        i = i + 1.
        disp i with 1 down. pause 0.
        next.
    end.

end.
 

