/*  Nao colocar admcab.i
    Gravar informacoes de ICMS no plani e movim
*/

def input  parameter par-rec         as recid.

find plani  where recid(plani) = par-rec no-lock.

if plani.icmssubst > 0
then run rateio-movsubst (plani.bsubst, plani.icmssubst /*, output sresp*/).


procedure rateio-movsubst.

    def input  parameter par-bicmssubs as dec.
    def input  parameter par-icmssubst as dec.

    def var vprotot    as dec.
    def var vmovtot    as dec.
    /* Arredondamento */
    def var vmovseq    as int.
    def var vmaior     as dec.
    def var vmovbsubst as dec.
    def var vmovsubst  as dec.

    for each movim where movim.etbcod = plani.etbcod
                     and movim.placod = plani.placod
                     and movim.movtdc = plani.movtdc
                     and movim.movdat = plani.pladat
                   no-lock.
        find produ of movim no-lock no-error.
        if not avail produ then next.
        
        if produ.proipiper = 99
        then do.
            vmovtot = movim.movpc * movim.movqtm.
            vprotot = vprotot + vmovtot.
            if vmovtot > vmaior
            then assign
                    vmovseq = movim.movseq
                    vmaior  = vmovtot.
        end.
    end.

    for each movim where movim.etbcod = plani.etbcod
                     and movim.placod = plani.placod
                     and movim.movtdc = plani.movtdc
                     and movim.movdat = plani.pladat.
        find produ of movim no-lock no-error.
        if not avail produ then next.
        if produ.proipiper = 99
        then assign
                movim.movbsubst = round(((movim.movpc  * movim.movqtm) 
                                / vprotot) * par-bicmssubs,2) 
                movim.movsubst  = round(((movim.movpc  * movim.movqtm)
                                / vprotot) * par-icmssubst,2)
                vmovbsubst = vmovbsubst + movim.movbsubst
                vmovsubst  = vmovsubst  + movim.movsubst.
        else assign
                movim.movbsubst = 0
                movim.movsubst  = 0.
    end.
    /*
    message vmovseq vmaior vmovbsubst.
    */
    if (vmovbsubst > 0 and plani.bsubst <> vmovbsubst) or
       (vmovsubst > 0 and plani.icmssubst <> vmovsubst)
    then do.
        find movim where movim.etbcod = plani.etbcod
                     and movim.placod = plani.placod
                     and movim.movseq = vmovseq.
        movim.movbsubst = movim.movbsubst + plani.bsubst    - vmovbsubst.
        movim.movsubst  = movim.movsubst  + plani.icmssubst - vmovsubst.
    end.

end procedure.
 