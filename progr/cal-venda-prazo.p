{admcab.i}
def input parameter par-recid as recid.
def output parameter par-principal as dec.
def output parameter par-acrescimo as dec.
def output parameter par-entrada as dec.

def var valor-chp as dec.

find contrato where recid(contrato) = par-recid no-lock.
find first contnf where contnf.etbcod = contrato.etbcod and
                          contnf.contnum = contrato.contnum
                                no-lock no-error.
if avail contnf
then do:
            
            find first plani where plani.etbcod = contnf.etbcod and
                             plani.placod = contnf.placod and
                             plani.movtdc = 5 and
                             plani.pladat = contrato.dtinicial
                             no-lock no-error.
            if avail plani and  plani.crecod = 2 
            then do:
                valor-chp = 0.
                run ver-cheque-presente.
                assign
                    par-principal = plani.platot - 
                            (plani.vlserv + valor-chp + plani.descprod)
                    par-acrescimo = contrato.vltotal - par-principal
                    par-entrada   = contrato.vlentra
                    .                
            end.
end.

procedure ver-cheque-presente:
    def var vi as int.
    valor-chp = 0.
            if acha("QTDCHQUTILIZADO",plani.notobs[3]) <> ?
            then do vi = 1 to int(acha("QTDCHQUTILIZADO",plani.notobs[3])):
                valor-chp = valor-chp + dec(acha("VALCHQPRESENTEUTILIZACAO" + 
                            string(vi),plani.notobs[3])) .
            end.    
    if valor-chp < 0
    then valor-chp = 0.  
end procedure.
