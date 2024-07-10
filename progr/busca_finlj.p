    def input parameter vetbcod like estab.etbcod.
    def input parameter vdata as date.
    def input parameter vtabela as char.
    def output parameter vstatus as char.
    
    def var vcobcod like finloja.titulo.cobcod.
    def buffer etitulo for finloja.titulo.
    def var vqtd as int.
    def var vd as log.
    disable triggers for load of finloja.titulo.
    
    if vtabela = "TITLUC"
    then do:
        for each finloja.titluc where finloja.titluc.datexp >= vdata:
            if finloja.titluc.titsit = "PAG" or
               finloja.titluc.titsit = "AUT"
               or finloja.titluc.titsit = "BLO" 
            then
            do transaction:
                find fin.titluc where 
                     fin.titluc.empcod = finloja.titluc.empcod and
                     fin.titluc.titnat = finloja.titluc.titnat and
                     fin.titluc.modcod = finloja.titluc.modcod and
                     fin.titluc.etbcod = finloja.titluc.etbcod and
                     fin.titluc.clifor = finloja.titluc.clifor and
                     fin.titluc.titnum = finloja.titluc.titnum and
                     fin.titluc.titpar = finloja.titluc.titpar
                       no-error.
                if not avail fin.titluc
                then do:
                    create fin.titluc.
                    buffer-copy finloja.titluc to fin.titluc.
                end.
                else if finloja.titluc.titsit = "PAG" and
                        fin.titluc.titsit <> "PAG"
                then do:
                    buffer-copy finloja.titluc to fin.titluc.
                end.
                find current fin.titluc no-lock no-error.
                vqtd = vqtd + 1.
            end.
        end.
    end.
    else if vtabela = "CHQ"
    then do:
        vqtd = 0.
        for each finloja.chq 
         where finloja.chq.datemi >= vdata  no-lock:
               
            find fin.chq where fin.chq.banco   = finloja.chq.banco   and
                       fin.chq.agencia = finloja.chq.agencia and
                       fin.chq.conta   = finloja.chq.conta   and
                       fin.chq.numero  = finloja.chq.numero no-error.
            if not avail fin.chq
            then do transaction:

                create fin.chq.
                {tt-chq.i fin.chq finloja.chq}
    
                vqtd = vqtd + 1.
            end.
        end.
        for each finloja.chq 
         where finloja.chq.datemi >= vdata no-lock:
               
            for each finloja.chqtit of finloja.chq no-lock:
    
            find fin.chqtit 
             where fin.chqtit.titnat  = finloja.chqtit.titnat  and
                   fin.chqtit.modcod  = finloja.chqtit.modcod  and
                   fin.chqtit.etbcod  = finloja.chqtit.etbcod  and
                   fin.chqtit.clifor  = finloja.chqtit.clifor  and
                   fin.chqtit.titnum  = finloja.chqtit.titnum  and
                   fin.chqtit.titpar  = finloja.chqtit.titpar  and
                   fin.chqtit.banco   = finloja.chqtit.banco   and
                   fin.chqtit.agencia = finloja.chqtit.agencia and 
                   fin.chqtit.conta   = finloja.chqtit.conta   and 
                   fin.chqtit.numero  = finloja.chqtit.numero no-error.
                   
            if not avail fin.chqtit
            then do transaction:

                create fin.chqtit.
                {tt-chqtit.i fin.chqtit finloja.chqtit}
                vqtd = vqtd + 1.
            end.
            end.
        end.
    end.
    else if vtabela = "TITULO.D"
    then do:
        vqtd = 0.
        for each finloja.titulo where 
                 finloja.titulo.datexp >= vdata and
                 finloja.titulo.titpar >= 30 no-lock:
            /*           
            if  finloja.titulo.etbcod <> vetbcod and
                finloja.titulo.etbcobra <> vetbcod
            then next.   
            */
            vd = no.
            /***DRAGAO
            if finloja.titulo.titpar >= 50
            then do transaction:
                find first etitulo where
                           etitulo.empcod = 19 and
                           etitulo.titnat = no and
                           etitulo.modcod = "CRE" and
                           etitulo.etbcod = finloja.titulo.etbcod and
                           etitulo.clifor = finloja.titulo.clifor and
                           etitulo.titnum = finloja.titulo.titnum and
                           etitulo.titpar < 50 and
                           etitulo.titpar > 30
                           no-lock no-error.
                if avail etitulo 
                then vd = no.
                else do:          
                    vcobcod = 2.
                    find d.titulo where 
                         d.titulo.empcod = finloja.titulo.empcod and
                                d.titulo.titnat = finloja.titulo.titnat and
                                d.titulo.modcod = finloja.titulo.modcod and
                                d.titulo.etbcod = finloja.titulo.etbcod and
                                d.titulo.clifor = finloja.titulo.clifor and
                                d.titulo.titnum = finloja.titulo.titnum and
                                d.titulo.titpar = finloja.titulo.titpar 
                                    no-error.
                    if avail d.titulo          
                    then do:
                        vcobcod = d.titulo.cobcod.
                        if d.titulo.titsit <> "PAG"
                        then do:
                            if d.titulo.etbcod <> finloja.titulo.etbcod and
                            d.titulo.titdtven >= finloja.titulo.titdtven
                            then.
                            else do:
                            {tt-titulo.i d.titulo finloja.titulo}.
                            d.titulo.cobcod = vcobcod.
                            vqtd = vqtd + 1.
                            end.
                        end.
                    end.
                    else do:
                        create d.titulo.
                        {tt-titulo.i d.titulo finloja.titulo}.
                        vqtd = vqtd + 1.
                    end.
                    vd = yes.
                end.         
            end.
            ***/
            if vd = no 
            then do transaction:  
                vcobcod = 2.
                find fin.titulo 
                    where fin.titulo.empcod = finloja.titulo.empcod and
                   fin.titulo.titnat = finloja.titulo.titnat and 
                   fin.titulo.modcod = finloja.titulo.modcod and 
                   fin.titulo.etbcod = finloja.titulo.etbcod and 
                   fin.titulo.clifor = finloja.titulo.clifor and 
                   fin.titulo.titnum = finloja.titulo.titnum and 
                   fin.titulo.titpar = finloja.titulo.titpar no-error.
                if not avail fin.titulo 
                then do:
                    create fin.titulo. 
                    {tt-titulo.i fin.titulo finloja.titulo}.
                    vqtd = vqtd + 1.
                end.
                else do:
                    vcobcod = fin.titulo.cobcod.
        
                    if fin.titulo.titsit <> "PAG"  
                    then do: 
                        if fin.titulo.etbcod = finloja.titulo.etbcod
                        and fin.titulo.titdtven >= finloja.titulo.titdtven
                        then.
                        else do:
                        {tt-titulo.i fin.titulo finloja.titulo}. 
                        if finloja.titulo.cobcod <> vcobcod
                        then fin.titulo.cobcod = vcobcod.
                        vqtd = vqtd + 1.
                        end.
                    end.
                end.
            end.        
        end.
    end.
    else if vtabela = "BONUS"
    then do:
        vqtd = 0.
        for each finloja.titulo where finloja.titulo.datexp >= vdata and
                              finloja.titulo.titnat = yes and
                              finloja.titulo.modcod = "BON" no-lock:
            do transaction:
                find fin.titulo where 
                     fin.titulo.empcod = finloja.titulo.empcod and
                     fin.titulo.titnat = finloja.titulo.titnat and
                     fin.titulo.modcod = finloja.titulo.modcod and
                     fin.titulo.etbcod = finloja.titulo.etbcod and
                     fin.titulo.clifor = finloja.titulo.clifor and
                     fin.titulo.titnum = finloja.titulo.titnum and
                     fin.titulo.titpar = finloja.titulo.titpar
                       no-error.
                if not avail fin.titulo
                then do:
                    create fin.titulo.
                    buffer-copy finloja.titulo to fin.titulo.
                end.
                else if finloja.titulo.titsit = "PAG" and
                        fin.titulo.titsit <> "PAG"
                then do:
                    buffer-copy finloja.titulo to fin.titulo.
                end.
                find current fin.titulo no-lock no-error.
                vqtd = vqtd + 1.
            end.
        end.
    end.
    else if vtabela = "CHP"
    then do:
        vqtd = 0.
        for each finloja.titulo where finloja.titulo.datexp >= vdata and
                              finloja.titulo.titnat = yes and
                              finloja.titulo.modcod = "CHP" and
                              finloja.titulo.empcod = 19 and 
                              finloja.titulo.etbcod = 999 and
                              finloja.titulo.titnumger <> ""
                              no-lock:
            do transaction:
                find fin.titulo where 
                     fin.titulo.empcod = finloja.titulo.empcod and
                     fin.titulo.titnat = finloja.titulo.titnat and
                     fin.titulo.modcod = finloja.titulo.modcod and
                     fin.titulo.etbcod = finloja.titulo.etbcod and
                     fin.titulo.clifor = finloja.titulo.clifor and
                     fin.titulo.titnum = finloja.titulo.titnum and
                     fin.titulo.titpar = finloja.titulo.titpar
                       no-error.
                if not avail fin.titulo
                then do:
                    create fin.titulo.
                    buffer-copy finloja.titulo to fin.titulo.
                end.
                else if finloja.titulo.titsit = "PAG" and
                        fin.titulo.titsit <> "PAG"
                then do:
                    buffer-copy finloja.titulo to fin.titulo.
                end.
                else fin.titulo.titnumger = finloja.titulo.titnumger.
                find current fin.titulo no-lock no-error.
                vqtd = vqtd + 1.
            end.
        end.
    end.
    else if vtabela = "TIT_NOVACAO"
    then do:
        vqtd = 0.
        /****
        for each finloja.tit_novacao where
                 /*finloja.tit_novacao.datexp = ? or*/
                 finloja.tit_novacao.datexp >= vdata
                 no-lock:
            find first fin.tit_novacao where
                 fin.tit_novacao.tipo      = finloja.tit_novacao.tipo and
                 fin.tit_novacao.id_acordo  = finloja.tit_novacao.id_acordo and
                 fin.tit_novacao.ori_empcod = finloja.tit_novacao.ori_empcod and
                 fin.tit_novacao.ori_titnat = finloja.tit_novacao.ori_titnat and
                 fin.tit_novacao.ori_modcod = finloja.tit_novacao.ori_modcod and
                 fin.tit_novacao.ori_etbcod = finloja.tit_novacao.ori_etbcod and
                 fin.tit_novacao.ori_clifor = finloja.tit_novacao.ori_clifor and
                 fin.tit_novacao.ori_titnum = finloja.tit_novacao.ori_titnum and
                 fin.tit_novacao.ori_titpar = finloja.tit_novacao.ori_titpar and
                 fin.tit_novacao.ori_titdtemi = finloja.tit_novacao.ori_titdtemi
                          exclusive no-error.
            if not avail fin.tit_novacao
            then find first fin.tit_novacao  where
                 fin.tit_novacao.tipo      = "" and
                 fin.tit_novacao.id_acordo  = finloja.tit_novacao.id_acordo and
                 fin.tit_novacao.ori_empcod = finloja.tit_novacao.ori_empcod and
                 fin.tit_novacao.ori_titnat = finloja.tit_novacao.ori_titnat and
                 fin.tit_novacao.ori_modcod = finloja.tit_novacao.ori_modcod and
                 fin.tit_novacao.ori_etbcod = finloja.tit_novacao.ori_etbcod and
                 fin.tit_novacao.ori_clifor = finloja.tit_novacao.ori_clifor and
                 fin.tit_novacao.ori_titnum = finloja.tit_novacao.ori_titnum and
                 fin.tit_novacao.ori_titpar = finloja.tit_novacao.ori_titpar and
                 fin.tit_novacao.ori_titdtemi = finloja.tit_novacao.ori_titdtemi
                          exclusive no-error.

            
            
            if not avail fin.tit_novacao
            then create fin.tit_novacao.
            buffer-copy finloja.tit_novacao to fin.tit_novacao.
                 
            vqtd = vqtd + 1.

            find first finloja.titulo where
                 finloja.titulo.empcod = finloja.tit_novacao.ori_empcod and
                 finloja.titulo.titnat = finloja.tit_novacao.ori_titnat and
                 finloja.titulo.modcod = finloja.tit_novacao.ori_modcod and
                 finloja.titulo.etbcod = finloja.tit_novacao.ori_etbcod and
                 finloja.titulo.clifor = finloja.tit_novacao.ori_clifor and
                 finloja.titulo.titnum = finloja.tit_novacao.ori_titnum and
                 finloja.titulo.titpar = finloja.tit_novacao.ori_titpar
                       no-lock no-error.
            if avail finloja.titulo and
                finloja.titulo.titdtpag <> ? and
                finloja.titulo.moecod = "NOV"
            then do:
                find first fin.titulo where
                       fin.titulo.empcod = finloja.titulo.empcod and
                       fin.titulo.titnat = finloja.titulo.titnat and
                       fin.titulo.modcod = finloja.titulo.modcod and
                       fin.titulo.etbcod = finloja.titulo.etbcod and
                       fin.titulo.clifor = finloja.titulo.clifor and
                       fin.titulo.titnum = finloja.titulo.titnum and
                       fin.titulo.titpar = finloja.titulo.titpar
                       no-error.
                if avail fin.titulo and fin.titulo.moecod = ""
                then buffer-copy finloja.titulo to fin.titulo.
            end.    
        end.
        for each finloja.titulo where
                 finloja.titulo.datexp >= vdata no-lock:
            if   finloja.titulo.titdtpag <> ? and
                 finloja.titulo.moecod = "NOV"
            then.
            else next.
            find first fin.titulo where
                       fin.titulo.empcod = finloja.titulo.empcod and
                       fin.titulo.titnat = finloja.titulo.titnat and
                       fin.titulo.modcod = finloja.titulo.modcod and
                       fin.titulo.etbcod = finloja.titulo.etbcod and
                       fin.titulo.clifor = finloja.titulo.clifor and
                       fin.titulo.titnum = finloja.titulo.titnum and
                       fin.titulo.titpar = finloja.titulo.titpar
                       no-error.
            if avail fin.titulo and fin.titulo.moecod = ""
            then buffer-copy finloja.titulo to fin.titulo.
        end.     
        ****/          
        for each    finloja.titulo where
                    finloja.titulo.empcod = 19 and
                    finloja.titulo.titnat = no and
                    finloja.titulo.modcod = "CRE" and
                    finloja.titulo.etbcod = vetbcod and
                    finloja.titulo.titdtemi >= vdata and
                    finloja.titulo.titpar = 0 and
                    finloja.titulo.titsit = "PAG" and
                    finloja.titulo.titdtpag <> ? and
                    finloja.titulo.titvlpag <> 0 and
                    finloja.titulo.etbcobra = 0
                    :
            /*
            finloja.titulo.titvlpag = finloja.titulo.titvlcob.
            finloja.titulo.titsit = "PAG".
            */     
            find first fin.titulo where
                       fin.titulo.empcod = finloja.titulo.empcod and
                       fin.titulo.titnat = finloja.titulo.titnat and
                       fin.titulo.modcod = finloja.titulo.modcod and
                       fin.titulo.etbcod = finloja.titulo.etbcod and
                       fin.titulo.clifor = finloja.titulo.clifor and
                       fin.titulo.titnum = finloja.titulo.titnum and
                       fin.titulo.titpar = finloja.titulo.titpar
                       no-error.
                       
            if avail fin.titulo /*and fin.titulo.titsit = "LIB"*/
            then do:
                /*
                buffer-copy finloja.titulo to fin.titulo.
                */
                vqtd = vqtd + 1.
            end.    
        end.     
     end.     
    vstatus = string(vqtd) + " REGISTROS ATUALIZADOS ".
    
