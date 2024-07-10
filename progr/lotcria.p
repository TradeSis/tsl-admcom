/*
*           lotcria.p
*
                        Cria Lotcre
*
*/

{admcab.i}

def buffer blotcre for lotcre.

def input  parameter par-lotcretp as recid.
def output parameter par-lotcre   as recid.

find lotcretp where recid(lotcretp) = par-lotcretp no-lock.


find last blotcre  where blotcre.ltcrecod > (setbcod * 1000000)
                    and blotcre.ltcrecod < (setbcod + 1) * 1000000
                  no-error.
create lotcre.
ASSIGN lotcre.ltcrecod  = if avail blotcre
                          then blotcre.ltcrecod + 1
                          else (setbcod * 1000000) + 1
       lotcre.ltcredt   = today
       lotcre.ltcrehr   = time
       lotcre.funcod    = sfuncod
       lotcre.ltcretcod = lotcretp.ltcretcod
       lotcre.etbcod    = setbcod.

assign par-lotcre = recid(lotcre).
