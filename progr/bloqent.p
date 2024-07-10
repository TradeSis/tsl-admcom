def input parameter p-recpla as recid.
def output parameter p-ok as log.
p-ok = yes.

find plani where recid(plani) = p-recpla no-lock no-error.
if avail plani
then do:
    find first tbcntgen where tbcntgen.tipcon = 2 and
                          tbcntgen.etbcod = 0 and
                          tbcntgen.numfim = "" and
                          tbcntgen.numini = string(plani.emite)
                          no-lock no-error.
    if avail tbcntgen
    then do:
        find first tbprice where
                   tbprice.etb_compra  = plani.desti and
                   tbprice.data_compra = plani.pladat and
                   tbprice.nota_compra = plani.numero
                   no-lock no-error.
        if not avail tbprice
        then p-ok = no.         
    end.
end.