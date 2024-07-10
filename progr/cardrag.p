def input parameter p-clicod as recid.

def shared temp-table tt-titulo like fin.titulo.
    
find first tt-titulo where recid(tt-titulo) = p-clicod no-lock.

find first d.titulo where d.titulo.empcod = tt-titulo.empcod
                      and d.titulo.titnat = tt-titulo.titnat
                      and d.titulo.modcod = tt-titulo.modcod
                      and d.titulo.etbcod = tt-titulo.etbcod
                      and d.titulo.clifor = tt-titulo.clifor
                      and d.titulo.titnum = tt-titulo.titnum
                      and d.titulo.titpar = tt-titulo.titpar
                     no-error.
if avail d.titulo
then do:
    if d.titulo.titsit <> "PAG" 
    then do:
        {tt-titulo.i d.titulo tt-titulo}.
    end.
end.

else do: 

    
    find first d.titulo where d.titulo.empcod = tt-titulo.empcod
                          and d.titulo.titnat = tt-titulo.titnat
                          and d.titulo.modcod = tt-titulo.modcod
                          and d.titulo.etbcod = tt-titulo.etbcod
                          and d.titulo.clifor = tt-titulo.clifor
                          and d.titulo.titnum = tt-titulo.titnum no-error.
    if avail d.titulo
    then do:
        create d.titulo.
        {tt-titulo.i d.titulo tt-titulo}.
    end.
    else do:
        create finmatriz.titulo.
        {tt-titulo.i finmatriz.titulo tt-titulo}.
    end.
end.