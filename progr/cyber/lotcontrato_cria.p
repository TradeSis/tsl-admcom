/* cyber/lotcontrato_cria.p                         */
def input parameter  par-lotcre         as recid.
def input parameter  par-contrato       as recid.

find lotcre   where recid(lotcre)   = par-lotcre no-lock.
find cyber_contrato where recid(cyber_contrato) = par-contrato no-lock.

    find LotCreContrato where LotCreContrato.ltcrecod = lotcre.ltcrecod
                          and LotCreContrato.contnum  = cyber_contrato.contnum
                        no-lock no-error.
    if not avail LotCreContrato
    then do on error undo:
        create LotCreContrato.
        assign
            LotCreContrato.ltcrecod   = lotcre.ltcrecod
            LotCreContrato.contnum    = cyber_contrato.contnum
            LotCreContrato.spcretorno = cyber_contrato.banco /* Dragao */.
    end.

    find lotcreag where lotcreag.ltcrecod = lotcre.ltcrecod
                    and lotcreag.clfcod   = cyber_contrato.clicod
                  no-lock no-error.
    if not avail lotcreag
    then do on error undo:
        create lotcreag.
        assign
            lotcreag.ltcrecod = lotcre.ltcrecod
            lotcreag.clfcod   = cyber_contrato.clicod.
    end.

