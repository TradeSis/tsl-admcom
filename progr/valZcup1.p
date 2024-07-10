    def input parameter vetbcod like estab.etbcod.
    def input parameter vdti as date.
    def input parameter vdtf as date.
    def input parameter vtabela as char.
    def output parameter vstatus as char.
    def var vqtd as int.
    if vtabela = "MAPCXA"
    THEN DO:
        for each admloja.mapcxa where 
                 admloja.mapcxa.etbcod = vetbcod and
                 admloja.mapcxa.datmov >= vdti and
                 admloja.mapcxa.datmov <= vdtf 
                 no-lock:
            find adm.mapcxa where
                 adm.mapcxa.etbcod = admloja.mapcxa.etbcod and
                 adm.mapcxa.cxacod = admloja.mapcxa.cxacod and
                 adm.mapcxa.datmov = admloja.mapcxa.datmov
                  no-error.
            if not avail adm.mapcxa
            then create adm.mapcxa.
            
            buffer-copy admloja.mapcxa to adm.mapcxa.
            vqtd = vqtd + 1.
        end.
    END.
    
    vstatus = string(vqtd) + " REGISTROS ATUALIZADOS ".
