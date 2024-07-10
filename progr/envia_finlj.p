    def input parameter vetbcod like estab.etbcod.
    def input parameter vdata as date.
    def input parameter vtabela as char.
    def output parameter vstatus as char.
    
    def var vcobcod like finloja.titulo.cobcod.
    def buffer etitulo for finloja.titulo.
    def var vqtd as int.
    def var vd as log.
    
    vqtd = 0.
    if vtabela = "FINAN"
    then do:
        for each fin.cpag no-lock:
            for each fin.finan where
                     fin.finan.fincod = fin.cpag.cpagcod /*and
                     fin.finan.datexp >= vdata*/
                     no-lock:
               find finloja.finan where 
                     finloja.finan.fincod = fin.finan.fincod
                    exclusive no-wait no-error.
                if locked finloja.finan then next.
                if not avail finloja.finan
                then  create finloja.finan.
                {tt-finan.i finloja.finan fin.finan}
                vqtd = vqtd + 1.
                
                find first adm.finesp where 
                           adm.finesp.fincod = fin.finan.fincod
                           no-lock no-error.
                if avail adm.finesp
                then do:
                    find first admloja.finesp where
                               admloja.finesp.fincod = adm.finesp.fincod
                               exclusive no-wait no-error.
                    if locked admloja.finesp
                    then.
                    else do on error undo:
                        if not avail admloja.finesp
                        then create admloja.finesp.       
                        assign 
                            admloja.finesp.fincod  = adm.finesp.fincod
                            admloja.finesp.dataini = adm.finesp.dataini
                            admloja.finesp.datafin = adm.finesp.datafin
                            admloja.finesp.dataven = adm.finesp.dataven
                            admloja.finesp.diaven  = adm.finesp.diaven
                            admloja.finesp.finarr  = adm.finesp.finarr
                            admloja.finesp.catcod  = adm.finesp.catcod
                            admloja.finesp.datexp  = adm.finesp.datexp
                            .
                    end.
                end.    
                for each adm.fincla where
                         adm.fincla.fincod = fin.finan.fincod
                         no-lock:
                    find first admloja.fincla where
                               admloja.fincla.fincod = adm.fincla.fincod and
                               admloja.fincla.clacod = adm.fincla.clacod
                               no-lock no-error.
                    if not avail admloja.fincla
                    then do on error undo:
                        create admloja.fincla.
                        assign 
                            admloja.fincla.fincod = adm.fincla.fincod
                            admloja.fincla.clacod = adm.fincla.clacod
                            .
                    end.
                end.
                for each adm.finfab where
                         adm.finfab.fincod = fin.finan.fincod
                         no-lock:
                    find first admloja.finfab where
                               admloja.finfab.fincod = adm.finfab.fincod and
                               admloja.finfab.fabcod = adm.finfab.fabcod
                               no-lock no-error.
                    if not avail admloja.finfab           
                    then do on error undo:
                        create admloja.finfab.
                        assign 
                            admloja.finfab.fincod = adm.finfab.fincod
                            admloja.finfab.fabcod = adm.finfab.fabcod
                            .
                    end.
                end.
                for each adm.finpro where
                         adm.finpro.fincod = fin.finan.fincod
                         no-lock:
                    find first admloja.finpro where            
                               admloja.finpro.fincod = adm.finpro.fincod and
                               admloja.finpro.procod = adm.finpro.procod
                               no-lock no-error.
                    if not avail admloja.finpro
                    then do on error undo:
                        create admloja.finpro.
                        assign 
                            admloja.finpro.fincod = adm.finpro.fincod
                            admloja.finpro.procod = adm.finpro.procod
                            .
                    end.
                end.                                       
            end.
        end.
    end.
    vstatus = string(vqtd) + " REGISTROS ATUALIZADOS ".
    
