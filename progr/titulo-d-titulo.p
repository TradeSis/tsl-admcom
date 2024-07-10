
def input parameter vetbcod like estab.etbcod.
def input parameter vdata as date.
def shared temp-table tt-titulo like fin.titulo.
def shared temp-table d-titulo like fin.titulo.
def shared var vcaixa      like fin.titulo.cxacod.

for each d.titulo  
             where d.titulo.etbcobra = vetbcod and  
                 d.titulo.titdtpag = vdata 
                 no-lock.
    if vcaixa > 0 and
    d.titulo.cxacod <> vcaixa
    then next.
    
    find first tt-titulo where
               tt-titulo.empcod = d.titulo.empcod and
               tt-titulo.titnat = d.titulo.titnat and
               tt-titulo.modcod = d.titulo.modcod and
               tt-titulo.etbcod = d.titulo.etbcod and
               tt-titulo.clifor = d.titulo.clifor and
               tt-titulo.titnum = d.titulo.titnum and
               tt-titulo.titpar = d.titulo.titpar
               no-lock no-error.
    if avail tt-titulo then next.           
            
    create d-titulo.
    buffer-copy d.titulo to d-titulo.

    /*
    create tt-titulo.
    buffer-copy d.titulo to tt-titulo.
    */
end.
