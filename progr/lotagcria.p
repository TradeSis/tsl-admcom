/*
*
*           lotagcria.p
*
                            Cria Lotcreag
* 
*/

/*
{admcab.i}
*/

def input parameter  par-lotcre     as recid.
def input parameter  par-titulo     as recid.

find lotcre where recid(lotcre) = par-lotcre no-lock.
find titulo where recid(titulo) = par-titulo no-lock.
/***
find clifor where clifor.clfcod = titulo.clfcod no-lock.
***/

do on error undo.
    find lotcreag where lotcreag.ltcrecod = lotcre.ltcrecod
                    and lotcreag.clfcod   = titulo.clifor
                  no-error.
    if not avail lotcreag
    then do:
        create lotcreag.
        assign
            lotcreag.ltcrecod = lotcre.ltcrecod
            lotcreag.clfcod   = titulo.clifor.
    end.

/***
    assign
        lotcreag.indsit   = clifor.situacao
        lotcreag.ltcremot = clifor.motivo.
***/
end.
