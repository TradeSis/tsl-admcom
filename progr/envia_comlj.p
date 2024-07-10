    def input parameter vetbcod like estab.etbcod.
    def input parameter vdata as date.
    def input parameter vtabela as char.
    def output parameter vstatus as char.
    
    def var vqtd as int.
    def var vd as log.
    
    vqtd = 0.
    if vtabela = "ESTOQ"
    then do:

        for each com.estoq where
                 com.estoq.etbcod = vetbcod and
                 com.estoq.datexp = vdata
                 no-lock:
                 
            find com.produ where com.produ.procod = estoq.procod no-error.
            if avail com.produ
            then do:
                find comloja.produ where 
                     comloja.produ.procod = com.produ.procod
                     no-error.
                if not avail comloja.produ
                then do:
                    create comloja.produ.
                    buffer-copy com.produ to comloja.produ.
                end.
            end.
            find comloja.estoq where 
                 comloja.estoq.procod = com.estoq.procod and
                 comloja.estoq.etbcod = com.estoq.etbcod
                 no-error.
            if not avail comloja.estoq
            then do:
                create comloja.estoq.
                buffer-copy com.estoq to comloja.estoq.
                vqtd = vqtd + 1.
            end.
            else if comloja.estoq.estvenda <> com.estoq.estvenda
            then do:
                buffer-copy com.estoq to comloja.estoq.
                vqtd = vqtd + 1.
            end.
        end.                  
    end.
    if vtabela = "CLASE"
    then do:

        for each com.clase no-lock:
            find comloja.clase where 
                 comloja.clase.clacod = com.clase.clacod
                 no-lock no-error.
            if not avail comloja.clase
            then do:
                create comloja.clase.
                buffer-copy com.clase to comloja.clase.
                vqtd = vqtd + 1.
            end.
        end.                  
    end.
    vstatus = string(vqtd) + " REGISTROS ATUALIZADOS ".
    
