/*neo_piloto - 17.06.2019 - nao gerar para lojas no piloto*/
{/admcom/progr/abas/neo_piloto.i}

/*#1 - helio.neto - 25.07 - parametro importa carga SIM/NAO */
def input parameter par-arquivo         as char.

def var vconfs as int.
def var par-importacarga    as log.
par-importacarga = par-arquivo <> "".

{/admcom/progr/admbatch.i}

{/admcom/progr/tpalcis-wms.i}
alcis-diretorio-bkp = alcis-diretorio-bkp + "/".

def var par-etbcod as int.

def var vDeletaArquivo as log.
def var vqtdcarga as dec.
def var vsldconf  as dec.

def shared temp-table ttarq no-undo
    field arq as char format "x(50)"
    field interface     as char 
    field Arquivo       as char initial ?
    field diretorio     as char
    index idx is unique primary interface asc Arquivo asc.

def temp-table ttheader no-undo
    field Remetente         as char format "x(10)"
    field NomeArquivo       as char format "x(4)"
    field NomeInterface     as char format "x(8)"
    field Site              as char format "x(3)"  
    field PROPRIETaRIO      as char format "x(12)"
    field NCarregamento     as char format "x(11)"     
    field NLoja             as char format "x(12)"     
    field DataREAL          as char format "xxxxxxxx"  
    field HoraREAL          as char format "xxxxxxx"  
    field Transportadora    as char format "x(12)"     
    field Placa             as char format "x(10)"
    field qtdelinhas        as char format "x(3)" /* #1 */.

def temp-table ttitem   no-undo    
    field Remetente         as char format "x(10)"
    field NomeArquivo       as char format "x(4)"
    field NomeInterface     as char format "x(8)"
    field Site              as char format "x(3)"
    field PROPRIETaRIO      as char format "x(12)"
    field NCarregamento     as char format "x(11)"
    field NPedido           as char format "x(12)"
    field NLoja             as char format "x(12)"
    field Produto           as char format "x(40)"
    field Quantidade        as char format "x(18)"
    field Unidade           as char format "x(6)".

def var vconta as int.
def var vlinha as char.

def var vhora as int.
def var vminu as int.


    for each ttarq where ttarq.interface = "EBLJ" and /* Esta interface */   
                         ttarq.arq <> ""
                         on error undo, return.                                    
                                                                             
        for each ttheader.
            delete ttheader.
        end.
        for each ttitem.
            delete ttitem. 

        end.            

        /*#1*/
        if par-arquivo <> ""
        then if ttarq.arquivo <> par-arquivo
             then do:
                next.
             end.   
        
        vDeletaArquivo = yes.
        find abasintegracao where 
                    abasintegracao.interface    = ttarq.interface and
                    abasintegracao.arquivo      = ttarq.arquivo 
                    no-lock no-error .  
        if not avail abasintegracao or
          (avail abasintegracao and abasintegracao.placod = ?)
        then do:
            vconta = 0. 
            input from value(ttarq.arq) no-echo.
            repeat.
                vconta = vconta + 1.
                import unformatted vlinha.
                if vconta = 1 
                then do.
                    create ttheader.
                    ttheader.Remetente      = substr(vlinha, 1 , 10).
                    ttheader.NomeArquivo    = substr(vlinha, 11, 4 ).
                    ttheader.NomeInterface  = substr(vlinha, 15, 8 ).
                    ttheader.Site           = substr(vlinha, 23, 3 ).
                    ttheader.PROPRIETaRIO   = substr(vlinha, 26, 12).
                    ttheader.NCarregamento  = substr(vlinha, 38, 11).
                    ttheader.NLoja          = substr(vlinha, 49, 12).
                    ttheader.Data           = substr(vlinha, 61, 8 ).
                    ttheader.Hora           = substr(vlinha, 69, 5 ).
                    ttheader.Transportadora = substr(vlinha, 74, 12).
                    ttheader.Placa          = substr(vlinha, 86, 10).
                    ttheader.qtdelinhas     = substr(vlinha, 96, 3). /* #1 */
                    vhora = int(substring(ttheader.hora,1,2)) * 60 * 60.
                    vminu = int(substring(ttheader.hora,4,2)) * 60.
                    
                    par-etbcod = int(ttheader.Nloja).
                    
                     /*neo_piloto*/
                    find first ttpiloto where ttpiloto.etbcod  = par-etbcod  and
                                          ttpiloto.dtini  <= today
                        no-error.
                    if today < wfilvirada and 
                       not avail ttpiloto  /* CRIA APENAS PARA as Lojas Piloto */
                    then leave.
                    
                    
                    
                    if not avail abasintegracao
                    then do:
                        create abasintegracao.
                        abasintegracao.interface    = ttarq.interface.
                        abasintegracao.arquivo      = ttarq.arquivo .
                    end.
                    else find current abasintegracao exclusive.
                                            
                    abasintegracao.diretorio    = ttarq.diretorio.    
                    
                    abasintegracao.NCarga       = dec(ttheader.NCarregamento).
                    
                    abasintegracao.etbcD        = int(ttheader.Proprietario).
                    abasintegracao.etbcod       = int(ttheader.Nloja).

                    abasintegracao.data         = date(ttheader.data).
                    abasintegracao.hora         = vhora + vminu.

                    abasintegracao.qtdlinhas    = int(ttheader.qtdelinhas).
                    abasintegracao.codigo_transp = ttheader.Transportadora.
                    abasintegracao.placa_veiculo = ttheader.Placa .
                    
                    
                    abasintegracao.dtfim        = ?. /* quando plani for emitido com placod */
                    abasintegracao.hrfim        = ?.
                    
                    abasintegracao.placod       = ?.
                    
                    
                    delete ttheader.
                    
                    next.
                end.
                /*#1*/
                if par-importacarga
                then do:
                
                    create ttitem.
                    ttitem.Remetente        = substr(vlinha,  1 , 10).
                    ttitem.NomeArquivo      = substr(vlinha,  11, 4 ).
                    ttitem.NomeInterface    = substr(vlinha,  15, 8 ).
                    ttitem.Site             = substr(vlinha,  23, 3 ).
                    ttitem.PROPRIETaRIO     = substr(vlinha,  26, 12).
                    ttitem.NCarregamento    = substr(vlinha,  38, 11).
                    ttitem.NPedido          = substr(vlinha,  49, 12).
                    ttitem.NLoja            = substr(vlinha,  61, 12).
                    ttitem.Produto          = substr(vlinha,  73, 40).
                    ttitem.Quantidade       = substr(vlinha, 113, 9 ).
                    ttitem.Unidade          = substr(vlinha, 131, 6 ).
                end.
                    
            end.
            input close.
            
            find abasintegracao where 
                        abasintegracao.interface    = ttarq.interface and
                        abasintegracao.arquivo      = ttarq.arquivo 
                        no-lock no-error .  

            if avail abasintegracao and
                par-importacarga /*#1*/
            then do:
                vconta = 0.
                for each abascargaprod where
                            abascargaprod.interface = abasintegracao.interface and
                            abascargaprod.arquivointegracao = abasintegracao.ArquivoIntegracao.
                    delete abascargaprod.
                end.
                
                for each ttitem.
                
                    vconta = vconta + 1.
                    
                    create abascargaprod.
                    abascargaprod.ArquivoIntegracao = abasintegracao.ArquivoIntegracao.
                    abascargaprod.interface         = abasintegracao.interface.
                    abascargaprod.Sequencia         = vconta.
                    abascargaprod.dcbcod            = int(substr(ttitem.NPedido,4,9)).
                    abascargaprod.qtdCarga          = dec(ttitem.Quantidade).
                    abascargaprod.procod            = int(ttitem.Produto).

                    abascargaprod.dcbpseq           = ?.
                    
                    vconfs = 0.
                    for each abasconfprod where 
                            abasconfprod.dcbcod = abascargaprod.dcbcod and
                            abasconfprod.procod = abascargaprod.procod
                            no-lock:
                        vconfs = vconfs + 1.
                    end.                                                    
                    if vconfs = 0
                    then do:
                        for each abascorteprod where
                            abascorteprod.dcbcod = abascargaprod.dcbcod and
                            abascorteprod.procod = abascargaprod.procod
                            no-lock:
                            
                                run abas/confcria.p (abasintegracao.interface,
                                                     abasintegracao.arquivo,
                                                     abascorteprod.dcbcod,
                                                     abascorteprod.dcbpseq,
                                                     abascorteprod.procod,
                                                     abascorteprod.qtdcorte).
                        end.                        
                    end.
                    vconfs = 0.
                    for each abasconfprod where 
                            abasconfprod.dcbcod = abascargaprod.dcbcod and
                            abasconfprod.procod = abascargaprod.procod
                            no-lock:
                        vconfs = vconfs + 1.
                    end.                                                    
                    if vconfs > 0 /* le de novo para ver se pode associar */
                    then do:
                        if vconfs = 1
                        then do:
                            find first abasconfprod where
                                    abasconfprod.dcbcod = abascargaprod.dcbcod and
                                    abasconfprod.procod = abascargaprod.procod
                                    exclusive.
                            abascargaprod.dcbpseq = abasconfprod.dcbpseq.        
                            abasconfprod.qtdcarga = abascargaprod.qtdcarga.
                        end.
                    end.  

                    vqtdcarga = abascargaprod.qtdcarga. 
                                            
                    if vconfs > 1
                    then for each abasconfprod where
                        abasconfprod.dcbcod = abascargaprod.dcbcod and
                        abasconfprod.procod = abascargaprod.procod and
                        abasconfprod.qtdconf - abasconfprod.qtdcarga > 0
                            exclusive
                            by abasconfprod.qtdconf.
                        vsldconf =  abasconfprod.qtdconf - abasconfprod.qtdcarga.
                        if vsldconf < vqtdcarga
                        then do:
                            abasconfprod.qtdcarga = abasconfprod.qtdcarga + vsldconf.
                            vqtdcarga = vqtdcarga - vsldconf.
                            
                        end.    
                        else do:
                            abasconfprod.qtdcarga = abasconfprod.qtdcarga + vqtdcarga.
                            vqtdcarga = vqtdcarga - vqtdcarga.
                        end.    

                    end.    
                        
                        
                    /**1    
                        
                    find first abascorteprod where    abascorteprod.dcbcod =          
                                                                 and abascorteprod.procod =                                                                                     no-lock no-error.
                                                                                    
                    if avail abascorteprod
                    then do:
                        
                        
                        find first abasconfprod where
                            abasconfprod.dcbcod = int(substr(ttitem.NPedido,4,9)) and
                            abasconfprod.procod = int(ttitem.Produto)
                            no-lock no-error. 
                        if not avail abasconfprod
                         then do:
                            for each abascorteprod where    abascorteprod.dcbcod = int(substr(ttitem.NPedido,4,9))
                                                    and abascorteprod.procod = int(ttitem.Produto)
                                                                                    no-lock:
                                
                                run abas/confcria.p (ttarq.interface,
                                                     ttarq.arquivo,
                                                     abascorteprod.dcbcod,
                                                     abascorteprod.dcbpseq,
                                                     abascorteprod.procod,
                                                     abascorteprod.qtdcorte).
                            end.                             
                            find first abasconfprod where
                                abasconfprod.dcbcod = int(substr(ttitem.NPedido,4,9)) and
                                abasconfprod.procod = int(ttitem.Produto)
                                no-lock no-error. 
                            if not avail abasconfprod
                            then next.
                            
                            
                        end.                            
                        
                    end.    
                    
                    
                    vconta = vconta + 1.
                    
                    find first abascargaprod where
                        abascargaprod.dcbcod = int(substr(ttitem.NPedido,4,9))
                            and
                        abascargaprod.procod = int(ttitem.Produto) and
                    abascargaprod.ArquivoIntegracao = abasintegracao.ArquivoIntegracao and
                    abascargaprod.interface         = abasintegracao.interface

                        no-lock no-error. 
                    if avail abascargaprod
                    then next.

                    create abascargaprod.
                    abascargaprod.ArquivoIntegracao = abasintegracao.ArquivoIntegracao.
                    abascargaprod.interface         = abasintegracao.interface.
                    abascargaprod.Sequencia         = vconta.
                    abascargaprod.dcbcod            = int(substr(ttitem.NPedido,4,9)).
                    abascargaprod.qtdCarga          = dec(ttitem.Quantidade).
                    abascargaprod.procod            = int(ttitem.Produto). 

                    delete ttitem.
                    
                    
                    
                    vqtdcarga = abascargaprod.qtdcarga. 
                                            
                    for each abasconfprod where
                        abasconfprod.dcbcod = abascargaprod.dcbcod and
                        abasconfprod.procod = abascargaprod.procod and
                        abasconfprod.qtdconf - abasconfprod.qtdcarga > 0
                            exclusive
                            by abasconfprod.arquivo.
                        vsldconf =  abasconfprod.qtdconf - abasconfprod.qtdcarga.

                        if vsldconf < vqtdcarga
                        then do:
                            abasconfprod.qtdcarga = abasconfprod.qtdcarga + vsldconf.
                            vqtdcarga = vqtdcarga - vsldconf.
                            
                        end.    
                        else do:
                            abasconfprod.qtdcarga = abasconfprod.qtdcarga + vqtdcarga.
                            vqtdcarga = vqtdcarga - vqtdcarga.
                        end.    

                    end.    
                    1**/
                    
                    delete ttitem.
                    
                end.
                if vconta = 0
                then vdeletaarquivo = no.
            end.    
        end.

        /*#1*/
        if par-importacarga
        then do:
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
                    hide message no-pause.
                    message "Interface nao carregada " ttarq.interface "Arquivo" ttarq.arquivo.
                    pause 1 no-message.
                    
                end.            
            end.
        end.         
        
    end.
            

