/* reserv_ecom.p                                                            */
/* Projeto Melhorias Mix - Luciano      */
def input  parameter par-procod     like produ.procod.
def output parameter vreserv_ecom   like prodistr.lipqtd.   

    vreserv_ecom = 0.
    for each prodistr where 
                     prodistr.etbabast      = 200           and
                     prodistr.tipo          = "ECOM"        and
                     prodistr.procod        = par-procod    and
                     prodistr.predt        <= today         and 
                     prodistr.SimbEntregue >= today         and
                     prodistr.lipsit = "A" no-lock.
        vreserv_ecom = vreserv_ecom + 
                    (prodistr.lipqtd - prodistr.preqtent).
    end.
    for each prodistr where 
                     prodistr.etbabast      = 200           and
                     prodistr.tipo          = "ECMA"        and
                     prodistr.procod        = par-procod    and
                     prodistr.predt        <= today         and 
                     prodistr.SimbEntregue >= today         and
                     prodistr.lipsit = "A" no-lock.
        vreserv_ecom = vreserv_ecom + 
                    (prodistr.lipqtd - prodistr.preqtent).
    end.
