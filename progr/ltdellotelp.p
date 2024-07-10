/* Programa busca os d.titulos lp do lote */
{admcab.i}

def input param par-recid as recid.
find lotcre where recid(lotcre) = par-recid no-lock.
find lotcretp of lotcre no-lock.

for each lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod.
    
    find d.titulo where d.titulo.empcod = 19
                  and d.titulo.titnat = lotcretp.titnat
                  and d.titulo.modcod = lotcretit.modcod
                  and d.titulo.etbcod = lotcretit.etbcod
                  and d.titulo.clifor = lotcretit.clfcod
                  and d.titulo.titnum = lotcretit.titnum
                  and d.titulo.titpar = lotcretit.titpar
                  and 
                  (d.titulo.cobcod   = 11 /* ACCESS */
                  or d.titulo.cobcod = 12) /* GLOBAL */
                  no-lock no-error.
    
    if not avail d.titulo then next.

    if avail d.titulo 
    then do:
    
        message "Lote não pode ser excluido. " 
        + d.titulo.titnum + 
        " em cobranca na assessoria" view-as alert-box.
        return. /*sai do programa*/
    end.
end.


