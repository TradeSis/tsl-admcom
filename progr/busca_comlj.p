    {admcab.i}
    
    disable triggers for load of com.plani.
    
    disable triggers for load of com.movim.
    
    def input parameter vdata as date.
    def input parameter vtabela as char.
    def output parameter vstatus as char.
    def var vqtd as int.
    
    def shared temp-table tt-movim like com.movim.
    
    if vtabela = "COBRANCA"
    then do:
        for each comloja.cobranca where 
                 comloja.cobranca.cobgera > vdata no-lock:
            find com.cobranca where
                 com.cobranca.etbcod = comloja.cobranca.etbcod and
                 com.cobranca.cobcod = comloja.cobranca.cobcod and
                 com.cobranca.clicod = comloja.cobranca.clicod
                 no-lock no-error.
            if not avail com.cobranca
            then do:
                create com.cobranca.
                buffer-copy comloja.cobranca to com.cobranca.
            end.     
            vqtd = vqtd + 1.
        end.
    end.
    
    if vtabela = "PEDID"
    then do:
        for each comloja.pedid where
                 comloja.pedid.peddat >= vdata no-lock.
            find com.pedid where
                     com.pedid.etbcod = comloja.pedid.etbcod and
                     com.pedid.pedtdc = comloja.pedid.pedtdc and
                     com.pedid.pednum = comloja.pedid.pednum
                     no-lock no-error.
            if not avail com.pedid
            then do:
                create com.pedid.
                buffer-copy comloja.pedid to com.pedid.
            end.
            for each comloja.liped of comloja.pedid no-lock:
                find com.liped where
                     com.liped.etbcod = comloja.liped.etbcod and
                     com.liped.pedtdc = comloja.liped.pedtdc and
                     com.liped.pednum = comloja.liped.pednum and
                     com.liped.procod = comloja.liped.procod and
                     com.liped.lipcor = comloja.liped.lipcor and
                     com.liped.predt  = comloja.liped.predt
                     no-lock no-error.
                if not avail com.liped
                then do:
                     create com.liped.
                     buffer-copy comloja.liped to com.liped.
                end.     
            end.
            vqtd = vqtd + 1.         
        end.
    end.   
    
    if vtabela = "DEV. VENDA"
    then do:
        for each comloja.plani where 
                 comloja.plani.datexp >= vdata :
            if comloja.plani.movtdc <> 12 
            then next.
            if comloja.plani.pladat = today
            then next.
            find com.plani where com.plani.etbcod = comloja.plani.etbcod and
                         com.plani.placod = comloja.plani.placod and
                         com.plani.serie  = comloja.plani.serie no-error.
            if not avail com.plani 
            then do transaction:  

                create com.plani.
                {t-plani.i com.plani comloja.plani}.
                comloja.plani.exportado = yes.
                for each comloja.movim where
                         comloja.movim.etbcod = comloja.plani.etbcod and
                         comloja.movim.placod = comloja.plani.placod and
                         comloja.movim.movtdc = comloja.plani.movtdc
                         .
                    find com.movim where 
                         com.movim.etbcod = comloja.movim.etbcod and
                         com.movim.placod = comloja.movim.placod and
                         com.movim.procod = comloja.movim.procod no-error.
                    if not avail com.movim
                    then do:
                        create com.movim.
                        {t-movim.i com.movim comloja.movim}.
                        comloja.movim.exportado = yes.
                        run atuest_hd.p (input recid(com.movim),
                         input "i",
                         input 0).
                    end.
                end.
                vqtd = vqtd + 1.
            end.
        end.
    end. 
    
    if vtabela = "PLANI"
    then do:
         
        for each comloja.plani where comloja.plani.datexp >= vdata
                                     no-lock:
    
            if comloja.plani.pladat = today
            then next.
    
            find com.plani where com.plani.etbcod = comloja.plani.etbcod
                             and com.plani.placod = comloja.plani.placod
                             and com.plani.serie  = comloja.plani.serie 
                                            no-error.
            if not avail com.plani 
            then do transaction:  

                create com.plani.
                {t-plani.i com.plani comloja.plani}.
    
            end.
            else do transaction:
                 /**** Alterado em 15/02/2012 para sobrepor
                       campo preenchido na filial e vazio na matriz *****/
                if substr(comloja.plani.notped,1,1) = "C"
                    and com.plani.notped = ""
                then assign com.plani.notped = comloja.plani.notped.

                if com.plani.ufemi = ""
                then assign com.plani.ufemi = comloja.plani.ufemi.
    
            end.
            
            vqtd = vqtd + 1.
            
        end.
    end. 
    if vtabela = "CUPOM 45"
    then do:
         
        for each comloja.plani where comloja.plani.datexp >= vdata
                    and comloja.plani.movtdc = 45
                                     no-lock:
    
            if comloja.plani.pladat = today
            then next.
    
            find com.plani where com.plani.etbcod = comloja.plani.etbcod
                             and com.plani.placod = comloja.plani.placod
                             and com.plani.serie  = comloja.plani.serie 
                                            no-error.
            if not avail com.plani 
            then do transaction:  

                create com.plani.
                {t-plani.i com.plani comloja.plani}.
    
            end.
            else do transaction:
                 /**** Alterado em 15/02/2012 para sobrepor
                       campo preenchido na filial e vazio na matriz *****/
                if substr(comloja.plani.notped,1,1) = "C"
                    and com.plani.notped = ""
                then assign com.plani.notped = comloja.plani.notped.

                if com.plani.ufemi = ""
                then assign com.plani.ufemi = comloja.plani.ufemi.
    
            end.
            
            for each comloja.movim where
                     comloja.movim.etbcod = comloja.plani.etbcod and
                     comloja.movim.placod = comloja.plani.placod and
                     comloja.movim.movtdc = comloja.plani.movtdc and
                     comloja.movim.movdat = comloja.plani.pladat
                     no-lock.
                find first com.movim where
                           com.movim.etbcod = comloja.movim.etbcod and
                           com.movim.placod = comloja.movim.placod and
                           com.movim.procod = comloja.movim.procod
                           no-error.
                if not avail com.movim
                then do:
                    create com.movim.
                    {t-movim.i com.movim comloja.movim}
                end.           
            end.
                     
            vqtd = vqtd + 1.
            
        end.
    end.
    if vtabela = "PLAMOV5"
    then do:
        for each comloja.plani where comloja.plani.datexp >= vdata
                                     no-lock:
            if comloja.plani.pladat = today
            then next.
            if comloja.plani.movtdc <> 5 and
               comloja.plani.movtdc <> 65
            then next.   
            find com.plani where com.plani.etbcod = comloja.plani.etbcod
                             and com.plani.placod = comloja.plani.placod
                             and com.plani.serie  = comloja.plani.serie 
                                            no-error.
            if not avail com.plani 
            then do transaction:  

                create com.plani.
                {t-plani.i com.plani comloja.plani}.

                for each comloja.movim where
                         comloja.movim.etbcod = comloja.plani.etbcod and
                         comloja.movim.placod = comloja.plani.placod and
                         comloja.movim.movtdc = comloja.plani.movtdc and
                         comloja.movim.movdat = comloja.plani.pladat
                         no-lock.
                    find com.movim where 
                         com.movim.etbcod = comloja.movim.etbcod and
                         com.movim.placod = comloja.movim.placod and
                         com.movim.procod = comloja.movim.procod
                         no-lock no-error.
                    if not avail com.movim
                    then do:
                        create com.movim.
                        assign
                            com.movim.movtdc    = comloja.movim.movtdc
                            com.movim.PlaCod    = comloja.movim.PlaCod
                            com.movim.etbcod    = comloja.movim.etbcod
                            com.movim.movseq    = comloja.movim.movseq
                            com.movim.procod    = comloja.movim.procod
                            com.movim.movqtm    = comloja.movim.movqtm
                            com.movim.movpc     = comloja.movim.movpc
                            com.movim.MovDev    = comloja.movim.MovDev
                            com.movim.MovAcFin  = comloja.movim.MovAcFin
                            com.movim.movipi    = comloja.movim.movipi
                            com.movim.MovPro    = comloja.movim.MovPro
                            com.movim.MovICMS   = comloja.movim.MovICMS
                            com.movim.MovAlICMS = comloja.movim.MovAlICMS
                            com.movim.MovPDesc  = comloja.movim.MovPDesc
                            com.movim.MovCtM    = comloja.movim.MovCtM
                            com.movim.MovAlIPI  = comloja.movim.MovAlIPI
                            com.movim.movdat    = comloja.movim.movdat
                            com.movim.MovHr     = comloja.movim.MovHr
                            com.movim.MovDes    = comloja.movim.MovDes
                            com.movim.MovSubst  = comloja.movim.MovSubst
                            com.movim.emite     = comloja.movim.emite
                            com.movim.desti     = comloja.movim.desti
                            .
                        assign
                            com.movim.OCNum[1]  = comloja.movim.OCNum[1]
                            com.movim.OCNum[2]  = comloja.movim.OCNum[2]
                            com.movim.OCNum[3]  = comloja.movim.OCNum[3]
                            com.movim.OCNum[4]  = comloja.movim.OCNum[4]
                            com.movim.OCNum[5]  = comloja.movim.OCNum[5]
                            com.movim.OCNum[6]  = comloja.movim.OCNum[6]
                            com.movim.OCNum[7]  = comloja.movim.OCNum[7]
                            com.movim.OCNum[8]  = comloja.movim.OCNum[8]
                            com.movim.OCNum[9]  = comloja.movim.OCNum[9]
                            com.movim.datexp    = comloja.movim.datexp
                            .
                        assign
                           com.movim.movpis       = comloja.movim.movpis
                           com.movim.movcofins    = comloja.movim.movcofins
                           com.movim.movalpis     = comloja.movim.movalpis
                           com.movim.movalcofins  = comloja.movim.movalcofins
                           com.movim.movbpiscof   = comloja.movim.movbpiscof
                           com.movim.movcstpiscof = comloja.movim.movcstpiscof
                           com.movim.movbicms     = comloja.movim.movbicms
                           com.movim.opfcod       = comloja.movim.opfcod
                           com.movim.movcsticms   = comloja.movim.movcsticms
                           .
                        
                        find com.produ where
                             com.produ.procod = com.movim.procod
                             no-lock no-error.
                        if  avail com.produ and
                                  com.produ.pronom matches "*RECARGA*"
                        then.
                        else do:
                            create tt-movim.
                            buffer-copy com.movim to tt-movim.
                        end.
                        vqtd = vqtd + 1.
                    end.              
                end.
            end.
        end.
    end.
    if vtabela = "PREVENDA"
    then do:
        for each comloja.plani where comloja.plani.datexp >= vdata
                                     no-lock:
            /*if comloja.plani.pladat = today
            then next.*/
            if comloja.plani.movtdc <> 30
            then next.   
            find com.plani where com.plani.etbcod = comloja.plani.etbcod
                             and com.plani.placod = comloja.plani.placod
                             and com.plani.serie  = comloja.plani.serie 
                                            no-error.
            if not avail com.plani 
            then do transaction:  

                create com.plani.
                {t-plani.i com.plani comloja.plani}.

                for each comloja.movim where
                         comloja.movim.etbcod = comloja.plani.etbcod and
                         comloja.movim.placod = comloja.plani.placod and
                         comloja.movim.movtdc = comloja.plani.movtdc and
                         comloja.movim.movdat = comloja.plani.pladat
                         no-lock.
                    find com.movim where 
                         com.movim.etbcod = comloja.movim.etbcod and
                         com.movim.placod = comloja.movim.placod and
                         com.movim.procod = comloja.movim.procod
                         no-lock no-error.
                    if not avail com.movim
                    then do:
                        create com.movim.
                        assign
                            com.movim.movtdc    = comloja.movim.movtdc
                            com.movim.PlaCod    = comloja.movim.PlaCod
                            com.movim.etbcod    = comloja.movim.etbcod
                            com.movim.movseq    = comloja.movim.movseq
                            com.movim.procod    = comloja.movim.procod
                            com.movim.movqtm    = comloja.movim.movqtm
                            com.movim.movpc     = comloja.movim.movpc
                            com.movim.MovDev    = comloja.movim.MovDev
                            com.movim.MovAcFin  = comloja.movim.MovAcFin
                            com.movim.movipi    = comloja.movim.movipi
                            com.movim.MovPro    = comloja.movim.MovPro
                            com.movim.MovICMS   = comloja.movim.MovICMS
                            com.movim.MovAlICMS = comloja.movim.MovAlICMS
                            com.movim.MovPDesc  = comloja.movim.MovPDesc
                            com.movim.MovCtM    = comloja.movim.MovCtM
                            com.movim.MovAlIPI  = comloja.movim.MovAlIPI
                            com.movim.movdat    = comloja.movim.movdat
                            com.movim.MovHr     = comloja.movim.MovHr
                            com.movim.MovDes    = comloja.movim.MovDes
                            com.movim.MovSubst  = comloja.movim.MovSubst
                            com.movim.emite     = comloja.movim.emite
                            com.movim.desti     = comloja.movim.desti
                            .
                        assign
                            com.movim.OCNum[1]  = comloja.movim.OCNum[1]
                            com.movim.OCNum[2]  = comloja.movim.OCNum[2]
                            com.movim.OCNum[3]  = comloja.movim.OCNum[3]
                            com.movim.OCNum[4]  = comloja.movim.OCNum[4]
                            com.movim.OCNum[5]  = comloja.movim.OCNum[5]
                            com.movim.OCNum[6]  = comloja.movim.OCNum[6]
                            com.movim.OCNum[7]  = comloja.movim.OCNum[7]
                            com.movim.OCNum[8]  = comloja.movim.OCNum[8]
                            com.movim.OCNum[9]  = comloja.movim.OCNum[9]
                            com.movim.datexp    = comloja.movim.datexp
                            .
                        assign
                           com.movim.movpis       = comloja.movim.movpis
                           com.movim.movcofins    = comloja.movim.movcofins
                           com.movim.movalpis     = comloja.movim.movalpis
                           com.movim.movalcofins  = comloja.movim.movalcofins
                           com.movim.movbpiscof   = comloja.movim.movbpiscof
                           com.movim.movcstpiscof = comloja.movim.movcstpiscof
                           com.movim.movbicms     = comloja.movim.movbicms
                           com.movim.opfcod       = comloja.movim.opfcod
                           com.movim.movcsticms   = comloja.movim.movcsticms
                           .
                        /***
                        find com.produ where
                             com.produ.procod = com.movim.procod
                             no-lock no-error.
                        if  avail com.produ and
                                  com.produ.pronom matches "*RECARGA*"
                        then.
                        else do:
                            create tt-movim.
                            buffer-copy com.movim to tt-movim.
                        end.
                        ***/
                        vqtd = vqtd + 1.
                    end.              
                end.
            end.
        end.
    end.   
    vstatus = string(vqtd) + " REGISTROS ATUALIZADOS ".
