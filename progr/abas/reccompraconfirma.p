{/admcom/progr/admbatch.i}

{/admcom/progr/tpalcis-wms.i}
alcis-diretorio-bkp = alcis-diretorio-bkp + "/".

def var vDeletaArquivo as log.

def temp-table tt-corte no-undo
    field wms       like abastransf.wms
    field etbcod    like abastransf.etbcod
    field rec       as recid
    index idx is unique primary rec asc
    index idx2 wms asc etbcod asc.
    
/* Compativel com cortecria.p */ 
def new shared temp-table tt-marca no-undo
    field rec as recid
    field etbcod    like abastransf.etbcod
    field qtdcorta  as dec
    index idx is unique primary rec asc
    index idx2                  etbcod asc.

def shared temp-table ttarq no-undo
    field arq as char format "x(50)"
    field interface     as char 
    field Arquivo       as char initial ?
    field diretorio     as char
    index idx is unique primary interface asc Arquivo asc.

def temp-table ttCRECheader no-undo
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field NotaFiscal        as char format "x(12)"
    field Proprietario      as char format "x(12)"
    field Fornecedor        as char format "x(12)"
    field Arquivo           as char format "x(20)"
    index i1 proprietario fornecedor notafiscal
    index idx is unique primary
            arquivo asc.

def temp-table ttCRECitem no-undo
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Produto           as char format "x(40)"
    field Quantidade        as char format "x(18)"
    field NotaFiscal        as char format "x(12)"
    field Proprietario      as char format "x(12)" 
    field Fornecedor        as char format "x(12)"
    field bloq              as char format "xx"
    field Qtde_no_Pack      as char format "x(18)"
    field Arquivo           as char format "x(20)"
    field sequencia         as int
    index i1 proprietario fornecedor notafiscal
    index i2 is unique primary Arquivo asc sequencia asc.

def var vconta as int.
def var vlinha as char.

def var vhora as int.
def var vminu as int.

    for each ttarq where ttarq.interface = "CREC" and /* Esta interface */
                         ttarq.arq <> "".

        vDeletaArquivo = yes.
        find abasintegracao where 
                    abasintegracao.interface    = ttarq.interface and
                    abasintegracao.arquivo      = ttarq.arquivo 
                    no-lock no-error .  
        if not avail abasintegracao 
            or (avail abasintegracao and
                abasintegracao.dtfim = ?)
        /* ainda naointegrado */
        then do:
        
            vconta = 0. 
            input from value(ttarq.arq) no-echo.
            repeat.
                vconta = vconta + 1.
                import unformatted vlinha.
                if vconta = 1 then do.
                    create ttCRECheader.
                    assign 
                    ttCRECheader.Remetente      = substr(vlinha,1 ,10) 
                    ttCRECheader.Nome_arquivo   = substr(vlinha,11,4 )
                    ttCRECheader.Nome_interface = substr(vlinha,15,8 )
                    ttCRECheader.Site           = substr(vlinha,23,3 )
                    ttCRECheader.NotaFiscal     = substr(vlinha,26,12)
                    ttCRECheader.Proprietario   = substr(vlinha,38,12)
                    ttCRECheader.Fornecedor     = substr(vlinha,50,12)
                    ttCRECheader.arquivo        = ttarq.arquivo.

                    if not avail abasintegracao
                    then do:
                        create abasintegracao.
                        abasintegracao.interface    = ttarq.interface.
                        abasintegracao.arquivo      = ttarq.arquivo .
                        abasintegracao.diretorio    = ttarq.diretorio.    
                    end.
                    else  
                        find current abasintegracao exclusive. 
                    abasintegracao.etbcod  = int(ttCRECheader.Proprietario).
                    abasintegracao.data         = today.
                    abasintegracao.hora         = time.
                    abasintegracao.dtfim        = today.
                    abasintegracao.hrfim        = time.
                    abasintegracao.Numero  = int(substr(ttCRECheader.NotaFiscal,1,
                                                    length(trim(ttCRECheader.NotaFiscal)) - 3)).
                    abasintegracao.Serie   = substr(ttCRECheader.NotaFiscal,
                                                    length(trim(ttCRECheader.NotaFiscal)) - 2,3).
                    abasintegracao.Emite   = int(ttCRECheader.Fornecedor).
                    
                    delete ttCRECheader.
                    
                    next.
                end.
            
                create ttCRECitem.
                assign 
                ttCRECitem.Remetente      = substr(vlinha,  1,10)
                ttCRECitem.Nome_arquivo   = substr(vlinha, 11,04)
                ttCRECitem.Nome_interface = substr(vlinha, 15,08)
                ttCRECitem.Produto        = substr(vlinha, 23,40)
                ttCRECitem.Quantidade     = substr(vlinha, 63,18)
                ttCRECitem.NotaFiscal     = substr(vlinha, 81,12)
                ttCRECitem.Proprietario   = substr(vlinha, 93,12)
                ttCRECitem.Fornecedor     = substr(vlinha,105,12)
                ttCRECitem.bloq           = substr(vlinha,117, 2)
                ttCRECitem.Qtde_no_Pack   = substr(vlinha,119,18)
                ttCRECitem.arquivo        = ttarq.arquivo 
                ttCRECitem.sequencia      = vconta - 1.
                
                
                create abasconfcompra.
                abasCONFcompra.interface         = ttarq.interface.
                abasCONFcompra.ArquivoIntegracao = ttarq.arquivo.
                abasCONFcompra.Sequencia         = ttCRECitem.sequencia.
                abasCONFcompra.procod            = int(ttCRECitem.Produto).
                abasCONFcompra.qtdConf           = dec(ttCRECitem.Quantidade) / 1000000000.

                delete ttcrecitem.
                
            end.
            input close.

            find abasintegracao where 
                        abasintegracao.interface    = ttarq.interface and
                        abasintegracao.arquivo      = ttarq.arquivo 
                        no-lock.
            
            
            find plani where
                        plani.movtdc = 4 and /* compra */ 
                        plani.etbcod = abasIntegracao.etbcod and
                        plani.emite  = abasIntegracao.emite and
                        plani.serie  = abasIntegracao.serie and
                        plani.numero = abasIntegracao.numero
                    no-lock no-error.
            if not avail plani
            then do:
                find plani where
                            plani.movtdc = 4 and /* compra */ 
                            plani.etbcod = abasIntegracao.etbcod and
                            plani.emite  = abasIntegracao.emite and
                            plani.serie  = string(int(
                                                abasIntegracao.serie)) and
                            plani.numero = abasIntegracao.numero
                        no-lock no-error.

                if not avail plani
                then do:
                    vDeletaArquivo = no.
                    for each abasconfcompra of abasintegracao.
                        delete abasconfcompra.
                    end.    
                end.     
            end.    
            if avail plani
            then do:
                /* pesquisa relacionamento NOTACOMPRA x PEDIDOCOMPRA */
                for each plaped where plaped.forcod = plani.emite and
                                      plaped.numero = plani.numero
                          no-lock:
                    /* ACHA PEDIDOCOMPRA */
                    find pedid where 
                            pedid.etbcod = plaped.pedetb and
                            pedid.pedtdc = plaped.pedtdc and
                            pedid.pednum = plaped.pednum 
                        no-lock no-error.
                    if avail pedid
                    then do:
                        for each liped of pedid no-lock.
                            find first abascompra where
                                abascompra.etbped = pedid.etbcod and
                                abascompra.pedtdc = pedid.pedtdc and
                                abascompra.pednum = pedid.pednum and
                                abascompra.procod = liped.procod
                                exclusive no-error.

                            if not avail abascompra
                            then do:
                                next.
                            end.    
                            
                            for each abasconfcompra of abasIntegracao where
                                    abasconfcompra.procod = abascompra.procod.
                                abasconfcompra.abccod = abascompra.abccod.                        
                                abascompra.qtdentregue = abascompra.qtdentregue + abasconfcompra.qtdconf. 
                            end.
                            
                            if abascompra.qtdentregue > 0
                            then do:
                                abascompra.abcsit = "EN". /* Entregue */
                                /* Testa se tem PedTransferecia  BLoqueado */
                                find abastransf where 
                                        abastransf.etbcod = abascompra.etbcod and
                                        abastransf.abtcod = abascompra.abtcod
                                    no-lock no-error.
                                if avail abastransf
                                then do:
                                    if abastransf.abtsit = "BL"
                                    then do:
                                        create tt-corte.
                                        tt-corte.wms    = abastransf.wms.
                                        tt-corte.etbcod = abastransf.etbcod.
                                        tt-corte.rec    = recid(abastransf).
                                    end.
                                 end.           
                            end.
                            
                        end.
                    end.      
                end.
            end.
        end.

        if vDeletaArquivo
        then do on error undo:
             find abasintegracao where 
                    abasintegracao.interface    = ttarq.interface and
                    abasintegracao.arquivo      = ttarq.arquivo 
                    exclusive no-error .  
            if avail abasintegracao             
            then do:
                abasintegracao.dtfim = today.
                abasintegracao.hrfim = time.
            end.
            /* PILOTO - NAO MUDA ARQUIVO DE LUGAR
            unix silent value("mv " + ttarq.arq + " " + alcis-diretorio-bkp).
            **/
        end.
        else do:
             find abasintegracao where 
                    abasintegracao.interface    = ttarq.interface and
                    abasintegracao.arquivo      = ttarq.arquivo 
                    exclusive no-error .  
            if avail abasintegracao             
            then do:
                delete abasintegracao.
            end.            
        end.
         
        /* tem corte a fazer? */
        for each tt-marca.
            delete tt-marca.
        end.    
        for each tt-corte break by tt-corte.wms by tt-corte.etbcod.
            create tt-marca.
            tt-marca.etbcod = tt-corte.etbcod.
            tt-marca.rec    = tt-corte.rec.
            find abastransf where recid(abastransf) = tt-corte.rec no-lock.
            tt-marca.qtdcorta = abastransf.abtqtd.
            if last-of(tt-corte.etbcod)
            then do:
                run abas/cortecria.p (tt-corte.wms).
                for each tt-marca.
                    delete tt-marca.
                end.    
            end.
        end.
    end.
