/*neo_piloto - 17.06.2019 - nao gerar para lojas no piloto*/
{/admcom/progr/abas/neo_piloto.i}

/*#1 - helio.neto - 25.07 - parametro importa carga SIM/NAO */
def input parameter par-arquivo         as char.

def var par-importacarga    as log.
par-importacarga = par-arquivo <> "".

{/admcom/progr/admbatch.i}

{/admcom/progr/tpalcis-wms.i}
alcis-diretorio-bkp = alcis-diretorio-bkp + "/".

def var vDeletaArquivo as log.

def var par-etbcod as int.

def var vlen as int.

def shared temp-table ttarq no-undo
    field arq as char format "x(50)"
    field interface     as char 
    field Arquivo       as char initial ?
    field diretorio     as char
    index idx is unique primary interface asc Arquivo asc.

def temp-table ttheader no-undo
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field Proprietario      as int
    field Etbcod            as int
    field N_Gaiola          as int
    field Itens             as int.

def temp-table ttitem no-undo
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field Proprietario      as char format "x(12)"
    field Etbcod            as char format "x(12)"
    field N_Gaiola          as char format "x(11)"
    field Seq               as int  format ">>9"
    field Procod            as int
    field Qtd               as dec
    field Unidade           as char format "x(6)"
    field id_distrib        as char.


def var vconta as int.
def var vlinha as char.

def var vhora as int.
def var vminu as int.


    for each ttarq where ttarq.interface = "FCGL" and /* Esta interface */
                         ttarq.arq <> "".
        
        /*#1*/
        if par-arquivo <> ""
        then if ttarq.arquivo <> par-arquivo
             then do:
                next.
             end.   
        

        for each ttheader. delete ttheader. end.
        for each ttitem.   delete ttitem.   end.
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
                    assign 
                    ttheader.Remetente      = substr(vlinha,1 ,10)
                    ttheader.Nome_arquivo   = substr(vlinha,11,4 )
                    ttheader.Nome_interface = substr(vlinha,15,8 )
                    ttheader.Site           = substr(vlinha,23,3 )
                    ttheader.Proprietario   = int( substr(vlinha,26,12) )
                    ttheader.Etbcod         = int( substr(vlinha,38,12) )
                    ttheader.N_Gaiola       = int( substr(vlinha,50,11) )
                    ttheader.Itens          = int( substr(vlinha,61,3) ).

                    par-etbcod = int(ttheader.etbcod).
                    
                    /*** 24.06.2019 moda virou todas as lojas
                    
                     /*neo_piloto*/
                    find first ttpiloto where ttpiloto.etbcod  = par-etbcod  and
                                          ttpiloto.dtini  <= today
                        no-error.
                    if today < wfilvirada and 
                       not avail ttpiloto  /* CRIA APENAS PARA as Lojas Piloto */
                    then leave.
                    ****/
                    
                    if not avail abasintegracao
                    then do:
                        create abasintegracao.
                        abasintegracao.interface    = ttarq.interface.
                        abasintegracao.arquivo      = ttarq.arquivo .
                    end.
                    else find current abasintegracao exclusive.    
                            
                    abasintegracao.diretorio    = ttarq.diretorio.    
                    
                    abasintegracao.NCarga       = dec(ttheader.N_Gaiola).
                    
                    abasintegracao.etbcD        = int(ttheader.Proprietario).
                    abasintegracao.etbcod       = int(ttheader.etbcod).

                    abasintegracao.data         = today.
                    abasintegracao.hora         = time.

                    abasintegracao.qtdlinhas    = int(ttheader.itens).
                    /*
                    abasintegracao.codigo_transp = ttheader.Transportadora.
                    abasintegracao.placa_veiculo = ttheader.Placa .
                    */
                    
                    
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
                    assign 
                        ttitem.Remetente      = substr(vlinha, 1,10)
                        ttitem.Nome_arquivo   = substr(vlinha,11,4)
                        ttitem.Nome_interface = substr(vlinha,15,8)
                        ttitem.Site           = substr(vlinha,23,3)
                        ttitem.Proprietario   = substr(vlinha,26,12)
                        ttitem.Etbcod         = substr(vlinha,38,12)
                        ttitem.N_Gaiola       = substr(vlinha,50,11)
                        ttitem.seq            = int(substr(vlinha,61,3))
                        ttitem.procod         = int(substr(vlinha,64,40))
                        ttitem.qtd            = dec(substr(vlinha,104,18)) / 1000000000
                        ttitem.unidade        = substr(vlinha,122,6)
                        ttitem.id_distrib     = substr(vlinha,128,32).
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

                    vlen = length(trim(ttitem.id_distrib)).

                    create abascargaprod.
                    abascargaprod.ArquivoIntegracao = abasintegracao.ArquivoIntegracao.
                    abascargaprod.interface         = abasintegracao.interface.
                    abascargaprod.Sequencia         = vconta.
                    abascargaprod.dcbcod            = int(substr(ttitem.id_distrib,1,vlen - 5)) no-error.
                    abascargaprod.qtdCarga          = dec(ttitem.Qtd).
                    abascargaprod.procod            = int(ttitem.Procod). 

                    abascargaprod.dcbpseq           = int(substr(ttitem.id_distrib,vlen - 4)).
                    
                    find abasconfprod where abasconfprod.dcbcod  = abascargaprod.dcbcod and
                                            abasconfprod.dcbpseq = abascargaprod.dcbpseq
                                      no-lock no-error.
                    if not avail abasconfprod
                    then do:                        
                        find abascorteprod where abascorteprod.dcbcod  = abascargaprod.dcbcod and
                                                 abascorteprod.dcbpseq = abascargaprod.dcbpseq
                                no-lock no-error.
                                                  
                        if avail abascorteprod
                        then do:
                            run abas/confcria.p (abascargaprod.interface,
                                             abascargaprod.ArquivoIntegracao,
                                             abascargaprod.dcbcod,
                                             abascargaprod.dcbpseq,
                                             abascargaprod.procod,
                                             abascorteprod.qtdcorte).
                        end.
                    end.
                    find abasconfprod where abasconfprod.dcbcod  = abascargaprod.dcbcod and
                                            abasconfprod.dcbpseq = abascargaprod.dcbpseq
                                      exclusive no-error.
                    if avail abasconfprod
                    then do:
                        abasconfprod.qtdcarga = abasconfprod.qtdcarga + abascargaprod.qtdcarga.
                    end.
                    
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
                /* 
                 find abasintegracao where 
                    abasintegracao.interface    = ttarq.interface and
                    abasintegracao.arquivo      = ttarq.arquivo 
                    exclusive no-error .  
                if avail abasintegracao  and 
                         abasintegracao.placod <> ?   
                then do:
                    abasintegracao.dtfim = today.
                    abasintegracao.hrfim = time.
                end.
                /* PILOTO - NAO MUDA ARQUIVO DE LUGAR
                unix silent value("mv " + ttarq.arq + " " + alcis-diretorio-bkp).
                **/
                */
            end.    
            else do:
                 find abasintegracao where 
                        abasintegracao.interface    = ttarq.interface and
                        abasintegracao.arquivo      = ttarq.arquivo 
                        exclusive no-error .  
                if avail abasintegracao and abasintegracao.placod = ?            
                then do:
                    delete abasintegracao.
                    hide message no-pause.
                    message "Interface nao carregada " ttarq.interface "Arquivo" ttarq.arquivo.
                    pause 1 no-message.
                end.            
            end.
        end. /*#1*/ 
        
    end.
            

