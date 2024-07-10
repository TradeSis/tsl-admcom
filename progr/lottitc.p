/*
*       lottitc.p
*
                    Cria Lotcretit
*/

/*
{admcab.i}
  */
def input parameter par-lotcre      as recid.
def input parameter par-titulo      as recid.
def input parameter par-data        as date.
def input parameter par-titnum      as char.

find lotcre where recid(lotcre) = par-lotcre no-lock.
find titulo where recid(titulo) = par-titulo no-lock.

find lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod
                 and lotcretit.clfcod   = titulo.clifor
/***                     
                     lotcretit.titcod   = titulo.titcod
***/
                 and lotcretit.modcod   = titulo.modcod
                 and lotcretit.etbcod   = titulo.etbcod
                 and lotcretit.titnum   = titulo.titnum
                 and lotcretit.titpar   = titulo.titpar
               no-lock no-error.

if not avail lotcretit
then do on error undo:
    create lotcretit.
    assign
        lotcretit.ltcrecod  = lotcre.ltcrecod
        lotcretit.clfcod    = titulo.clifor
        lotcretit.modcod    = titulo.modcod
        lotcretit.etbcod    = titulo.etbcod
        lotcretit.titnum    = titulo.titnum
        lotcretit.titpar    = titulo.titpar
        lotcretit.lottitpag = par-data
        lotcretit.numero    = par-titnum
/***
        lotcretit.titnum    = par-titnum.
***/
    .
end.
