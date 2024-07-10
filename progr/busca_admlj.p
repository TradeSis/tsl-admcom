    def input parameter vetbcod like estab.etbcod.
    def input parameter vdata as date.
    def input parameter vtabela as char.
    def output parameter vstatus as char.
    def var vqtd as int.
    if vtabela = "CTDEVVEN"
    then do:
        for each admloja.ctdevven where admloja.ctdevven.dtexp >= vdata:
        do transaction:
            find first adm.ctdevven where 
                       adm.ctdevven.movtdc = admloja.ctdevven.movtdc and
                       adm.ctdevven.etbcod = admloja.ctdevven.etbcod and
                       adm.ctdevven.placod = admloja.ctdevven.placod  and
                    adm.ctdevven.movtdc-ori = admloja.ctdevven.movtdc-ori and
                    adm.ctdevven.etbcod-ori = admloja.ctdevven.etbcod-ori and
                    adm.ctdevven.placod-ori = admloja.ctdevven.placod-ori and
                    adm.ctdevven.movtdc-ven = admloja.ctdevven.movtdc-ven and
                    adm.ctdevven.etbcod-ven = admloja.ctdevven.etbcod-ven and
                    adm.ctdevven.placod-ven = admloja.ctdevven.placod-ven
                       no-error.
            if not avail adm.ctdevven
            then do:
                create adm.ctdevven.
            end. 
            buffer-copy admloja.ctdevven to adm.ctdevven.
            adm.ctdevven.exportado = yes.
            admloja.ctdevven.exportado = yes.
            find current adm.ctdevven no-lock no-error.
            vqtd = vqtd + 1.
            /*
            message admloja.ctdevven.pladat
                    admloja.ctdevven.exportado
                    adm.ctdevven.exportado.
            pause 0.
            */         
        end.
        end.
    end.
    if vtabela = "HABIL"
    then do:
        for each admloja.habil where admloja.habil.etbcod = vetbcod
                             and admloja.habil.habdat >= vdata 
                             no-lock:

            find adm.habil where 
                adm.habil.ciccgc  = admloja.habil.ciccgc
                and adm.habil.celular = admloja.habil.celular
                no-error.
                                    
            if not avail adm.habil
            then do transaction:
                create adm.habil.
                buffer-copy admloja.habil to adm.habil.
                vqtd = vqtd + 1.
            end.
        end.
    end. 
    if vtabela = "MAPCXA"
    THEN DO:
        for each admloja.mapcxa where 
                 admloja.mapcxa.etbcod = vetbcod and
                 admloja.mapcxa.datmov >= vdata and
                 admloja.mapcxa.datmov <= today - 1
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
    
    if vtabela = "EX-TBPRICE"
    THEN DO:
        for each admloja.tbprice where admloja.tbprice.datexp = ? or
                                       admloja.tbprice.datexp < vdata:

            delete admloja.tbprice.
            vqtd = vqtd + 1.
        end.    
    END.
    
    if vtabela = "BUS-TBPRICE"
    THEN DO:
        
        for each admloja.tbprice where
                 admloja.tbprice.etb_venda = vetbcod and
                 admloja.tbprice.data_venda >= vdata
                                  no-lock:
                                               
            if admloja.tbprice.char1 = "PRE-VENDA"
            then next.
    
            find first adm.tbprice where adm.tbprice.tipo = admloja.tbprice.tipo
                                and adm.tbprice.serial = admloja.tbprice.serial
                                exclusive-lock no-error.
            if not avail adm.tbprice
            then create adm.tbprice.
                        
            if avail adm.tbprice
            then do:            
            
                buffer-copy admloja.tbprice to adm.tbprice.
                vqtd = vqtd + 1.
                
            end.
        end.
    
    END.
    
    vstatus = string(vqtd) + " REGISTROS ATUALIZADOS ".
