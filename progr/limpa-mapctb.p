def var vetbcod     as integer.
def var vcxacod     as integer.
def var vpladat     as date.

def var vnrored     as integer.

def var vtotal      as decimal.

assign vetbcod = 84
       vpladat = 01/30/2012
       vcxacod = 2
       vnrored = 1148.

for each mapctb where etbcod = vetbcod
                  and cxacod = vcxacod
                  and nrored = vnrored
                  exclusive-lock.

    display mapctb.etbcod
            mapctb.cxacod
            mapctb.nrored
            mapctb.gtotal.

    find first mapcxa where mapcxa.etbcod = vetbcod
                        and mapcxa.cxacod = vcxacod
                        and mapcxa.nrored = vnrored
                        and mapcxa.datmov = mapctb.datmov no-lock no-error.
                                        
    if avail mapcxa then display "Sim.".
    else do:
    
        Display "Nao.".

        delete mapctb.

    end.
    pause.
    
end.