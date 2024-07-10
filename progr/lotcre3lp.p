def shared temp-table tt-titulo like fin.titulo.
def input param par-lotcretit as recid.
find lotcretit where recid(lotcretit) = par-lotcretit no-lock.

find d.titulo where d.titulo.empcod   = 19
                  and d.titulo.titnat = no
                  and d.titulo.modcod = lotcretit.modcod
                  and d.titulo.etbcod = lotcretit.etbcod
                  and d.titulo.clifor = lotcretit.clfcod
                  and d.titulo.titnum = lotcretit.titnum
                  and d.titulo.titpar = lotcretit.titpar
                  no-lock no-error.

if not avail d.titulo then next.

if avail d.titulo then do:
    create tt-titulo.
    buffer-copy d.titulo to tt-titulo.
    
end.    
