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

for each d.titulo use-index iclicod where 
         d.titulo.empcod = 19        and
         d.titulo.titnat = no        and
         d.titulo.modcod = "CRE"     and
         d.titulo.clifor = p-clicod  and
         d.titulo.titsit = "LIB"    no-lock
                by d.titulo.titdtven:

    create tp-titulo.
    assign
        tp-titulo.empcod    = d.titulo.empcod
        tp-titulo.modcod    = d.titulo.modcod
        tp-titulo.Clifor    = d.titulo.clifor
        tp-titulo.titnum    = d.titulo.titnum
        tp-titulo.titpar    = d.titulo.titpar
        tp-titulo.titnat    = d.titulo.titnat
        tp-titulo.etbcod    = d.titulo.etbcod
        tp-titulo.titdtemi  = d.titulo.titdtemi
        tp-titulo.titdtven  = d.titulo.titdtven
        tp-titulo.titvlcob  = d.titulo.titvlcob
        tp-titulo.titsit    = d.titulo.titsit.
end.

                                   