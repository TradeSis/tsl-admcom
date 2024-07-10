    def input parameter vetbcod like estab.etbcod.
    def input parameter vdata as date.
    def input parameter vcxacod as int.
    def output parameter vstatus as char.
    def var vqtd as int.
    for each admloja.mapcxa where 
                 admloja.mapcxa.etbcod = vetbcod and
                 admloja.mapcxa.datmov = vdata  and
                 admloja.mapcxa.cxacod = vcxacod
                 no-lock:
            find first adm.mapcxa where
                 adm.mapcxa.etbcod = admloja.mapcxa.etbcod and
                 adm.mapcxa.cxacod = admloja.mapcxa.cxacod and
                 adm.mapcxa.datmov = admloja.mapcxa.datmov
                  no-error.
            if not avail adm.mapcxa
            then create adm.mapcxa.
            
            buffer-copy admloja.mapcxa to adm.mapcxa.
            vqtd = vqtd + 1.
    end.
