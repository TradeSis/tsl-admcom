/* cyber/lotcliente_cria.p                                          */
def input parameter  par-lotcre         as recid.
def input parameter  par-clien          as recid.

find lotcre where recid(lotcre)   = par-lotcre no-lock.
find clien  where recid(clien)    = par-clien no-lock.
do on error undo.
    find lotcreag where lotcreag.ltcrecod = lotcre.ltcrecod
                    and lotcreag.clfcod   = clien.clicod
                  no-error.
    if not avail lotcreag
    then do:
        create lotcreag.
        assign
            lotcreag.ltcrecod = lotcre.ltcrecod
            lotcreag.clfcod   = clien.clicod.
    end.
end.
