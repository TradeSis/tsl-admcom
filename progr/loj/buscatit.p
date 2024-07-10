def input parameter p-clicod like ger.clien.clicod.


def shared temp-table tp-titulo like fin.titulo
    index dt-ven titdtven
    index titnum empcod
                 titnat 
                 modcod 
                 etbcod 
                 clifor 
                 titnum 
                 titpar.

for each finmatriz.titulo use-index iclicod 
    where finmatriz.titulo.clifor = p-clicod no-lock:
    
    if finmatriz.titulo.titnat <> no
    then next.
    if finmatriz.titulo.modcod <> "CRE"
    then next.
 
    create tp-titulo.
    
    assign
        tp-titulo.empcod    = finmatriz.titulo.empcod
        tp-titulo.modcod    = finmatriz.titulo.modcod
        tp-titulo.Clifor    = finmatriz.titulo.clifor
        tp-titulo.titnum    = finmatriz.titulo.titnum
        tp-titulo.titpar    = finmatriz.titulo.titpar
        tp-titulo.titnat    = finmatriz.titulo.titnat
        tp-titulo.etbcod    = finmatriz.titulo.etbcod
        tp-titulo.titdtemi  = finmatriz.titulo.titdtemi
        tp-titulo.titdtven  = finmatriz.titulo.titdtven
        tp-titulo.titvlcob  = finmatriz.titulo.titvlcob
        tp-titulo.titsit    = finmatriz.titulo.titsit
        tp-titulo.titobs[1] = finmatriz.titulo.titobs[1].

end.

                      