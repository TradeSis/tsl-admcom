def input parameter p-contnum like contrato.contnum.
def output parameter p-tj as dec.

p-tj = 0.
find first contrato where contrato.contnum = p-contnum
            no-lock no-error.
if avail contrato
then do:

    find first finan where finan.fincod = contrato.crecod
                        no-lock no-error.

    find first contnf where
               contnf.etbcod  = contrato.etbcod and
               contnf.contnum = contrato.contnum
               no-lock no-error.
               
    find first plani where plani.etbcod = contnf.etbcod and
                     plani.placod = contnf.placod and
                     plani.movtdc = 5 and
                     plani.pladat = contrato.dtinicial
                     no-lock no-error.
                     
    if avail plani
    then  p-tj = (1 + (((biss - platot) /
                                (platot * finnpc)) * finnpc) )   .
    else p-tj = ?.        
end.
else p-tj = ?.
