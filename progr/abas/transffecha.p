def input parameter par-rec as recid.

def new shared temp-table tt-cortes no-undo
    field rec       as recid
    field etbcod    like abascorteprod.etbcod
    field abtcod    like abascorteprod.abtcod
    field seq       as int format ">>>>9"
    field Oper      as char
    field datareal  like abascorte.datareal
    field horareal  like abascorte.horareal
    field dcbcod    like abascorte.dcbcod   format ">>>>>>>"
    field numero    as   int                format ">>>>>>>"
    field qtd       as int format ">>>9"
    field qtdemWMS  like abastransf.qtdemwms
    field qtdatend  like abastransf.qtdatend 
    field qtdPEND   as int format ">>>9"
    field abtsit    like abastransf.abtsit
    field traetbcod like plani.etbcod
    field traplacod like plani.placod
    index sequencia is unique primary etbcod asc abtcod asc dcbcod asc seq  asc.

    def var vreserv_ecom as dec.

    find abasintegracao where recid(abasintegracao) = par-rec exclusive.

    abasintegracao.dtfim = today.
    abasintegracao.hrfim = time.
    
    unix silent value("mv " + abasintegracao.diretorio + abasintegracao.arquivo + " /admcom/tmp/alcis/bkp/").
    
    for each abasCARGAprod of abasintegracao no-lock.   
        
        for each abascorteprod where
                    abascorteprod.dcbcod = abascargaprod.dcbcod and
                    abascorteprod.procod = abascargaprod.procod
                    no-lock.
            find abastransf    of abascorteprod exclusive no-error. 
            if avail abastransf 
            then do:
                run abas/transfqtdsit.p (recid(abastransf), yes).
            end.
                        
            find abasconfprod where
                        abasconfprod.dcbcod = abascorteprod.dcbcod and
                        abasconfprod.dcbpseq = abascorteprod.dcbpseq  
                            no-lock no-error.
        

            do: 
                find abastransf    of abascorteprod exclusive no-error. 
                if avail abastransf 
                then do:
                    
                    /* ajuste quando emite a nota mesmo cancelada */
                    if abastransf.abtsit = "CA" and
                       abastransf.qtdemwms <> 0
                    then abastransf.qtdemwms = 0.
                       
                    /* BAIXAR RESERVA ECOM */ 
            
                
                if abastransf.abatipo = "WEB"
                then do:        
                    vreserv_ecom = 0.
                    for each prodistr where 
                             prodistr.etbabast      = 200           and
                             prodistr.tipo          = "ECOM"        and
                             prodistr.procod        = abascorteprod.procod and
                             prodistr.predt        <= today         and 
                             prodistr.SimbEntregue >= today no-lock.
                        vreserv_ecom = vreserv_ecom + 
                            (prodistr.lipqtd - prodistr.preqtent).
                    end.
                    if vreserv_ecom > 0
                    then do.
                        for each prodistr where 
                                 prodistr.etbabast      = 200           and
                                 prodistr.tipo          = "ECOM"        and
                                 prodistr.procod        = abascorteprod.procod and
                                 prodistr.predt        <= today         and 
                                 prodistr.SimbEntregue >= today and
                                 prodistr.lipqtd - prodistr.preqtent > 0 .
                            prodistr.preqtent = prodistr.preqtent + 
                                            if avail abasconfprod
                                            then abasconfprod.qtdcarga
                                            else abascorteprod.qtdcorte.
                            if prodistr.preqtent > prodistr.lipqtd
                            then prodistr.preqtent = prodistr.lipqtd.
                    
                            /* historico */
                            create hprodistr.
                            ASSIGN hprodistr.data     = today
                                   hprodistr.hora     = time
                                   hprodistr.procod   = prodistr.procod
                                   hprodistr.lipqtd   = prodistr.lipqtd
                                   hprodistr.lipsit   = prodistr.lipsit
                                   hprodistr.preqtent = if avail abasconfprod
                                                        then abasconfprod.qtdcarga
                                                        else abascorteprod.qtdcorte
                                   hprodistr.etbcod   = prodistr.etbcod
                                   hprodistr.numero   = abastransf.abtcod
                                   hprodistr.etbabast = prodistr.etbabast
                                   hprodistr.predt    = abastransf.dttransf
                                   hprodistr.lipseq   = prodistr.lipseq
                                   hprodistr.Tipo     = prodistr.Tipo
                                   hprodistr.EtbOri   = prodistr.EtbOri
                                   hprodistr.movpc    = prodistr.movpc
                                   hprodistr.proposta = "Pedido : " +
                                                            string(abastransf.abtcod)
                                   hprodistr.funcod   = prodistr.funcod.
                                pause 1 no-message.
                        end.    
                    end.
                    else do:
                        vreserv_ecom = 0.
                        for each prodistr where 
                             prodistr.etbabast      = 200           and
                             prodistr.tipo          = "ECMA"        and
                             prodistr.procod        = abascorteprod.procod and
                             prodistr.predt        <= today         and 
                             prodistr.SimbEntregue >= today no-lock.
                            vreserv_ecom = vreserv_ecom + 
                                    (prodistr.lipqtd - prodistr.preqtent).
                        end.
                        if vreserv_ecom > 0
                        then do.
                            for each prodistr where 
                                     prodistr.etbabast      = 200           and
                                     prodistr.tipo          = "ECMA"        and
                                     prodistr.procod        = abascorteprod.procod and
                                     prodistr.predt        <= today         and 
                                     prodistr.SimbEntregue >= today and
                                     prodistr.lipqtd - prodistr.preqtent > 0 .
                                prodistr.preqtent = prodistr.preqtent + 
                                                if avail abasconfprod
                                                then abasconfprod.qtdcarga
                                                else abascorteprod.qtdcorte.
                                if prodistr.preqtent > prodistr.lipqtd
                                then prodistr.preqtent = prodistr.lipqtd.
            
                                /* historico */
                                create hprodistr.
                                ASSIGN hprodistr.data     = today
                                       hprodistr.hora     = time
                                       hprodistr.procod   = prodistr.procod
                                       hprodistr.lipqtd   = prodistr.lipqtd
                                       hprodistr.lipsit   = prodistr.lipsit
                                       hprodistr.preqtent = if avail abasconfprod
                                                            then abasconfprod.qtdcarga
                                                            else abascorteprod.qtdcorte
                                       hprodistr.etbcod   = prodistr.etbcod
                                       hprodistr.numero   = abastransf.abtcod
                                       hprodistr.etbabast = prodistr.etbabast
                                       hprodistr.predt    = abastransf.dttransf
                                       hprodistr.lipseq   = prodistr.lipseq
                                       hprodistr.Tipo     = prodistr.Tipo
                                       hprodistr.EtbOri   = prodistr.EtbOri
                                       hprodistr.movpc    = prodistr.movpc
                                       hprodistr.proposta = "Pedido : " +
                                                                string(abastransf.abtcod)
                                       hprodistr.funcod   = prodistr.funcod.
                                pause 1 no-message.
                            end.    
                        end.
                    end.
                end.
            end.                 
        end.            
        end.
     end.    
