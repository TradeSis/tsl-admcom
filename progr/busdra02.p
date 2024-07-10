
def input parameter p-clicod like ger.clien.clicod.

def shared temp-table tp-contrato like fin.contrato
            field exportado as log.
def shared temp-table tp-titulo like fin.titulo
    index iclicod clifor
    index dt-ven titdtven
    index titnum empcod 
                 titnat 
                 modcod 
                 etbcod 
                 clifor 
                 titnum 
                 titpar.

for each d.titulo use-index iclicod where 
         d.titulo.clifor = p-clicod 
         no-lock  :

    find first tp-contrato where 
                tp-contrato.contnum = int(d.titulo.titnum)
                no-error.
    if not avail tp-contrato
    then do:
        find d.contrato where
             d.contrato.contnum = int(d.titulo.titnum)
             no-lock no-error.
        if avail d.contrato
        then do:
            create tp-contrato.
            buffer-copy d.contrato to tp-contrato.
        end.     
    end. 
    create tp-titulo.
    buffer-copy d.titulo to tp-titulo. 
end.

                                   