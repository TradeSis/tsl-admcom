
procedure atualiza-mix:

    def input param icod-produto as int no-undo.

    for each mixmprod exclusive-lock
        where mixmprod.procod = icod-produto:
    
        delete mixmprod.

    end.

    for each tt-mix no-lock
        where tt-mix.cod-produto = icod-produto:
    
        find first mixmprod exclusive-lock
            where mixmprod.procod   = tt-mix.cod-produto
              and mixmprod.codgrupo = tt-mix.cod-mix no-error.

        if not avail mixmprod then do:
            
            create mixmprod.
            assign mixmprod.procod = icod-produto
                mixmprod.codgrupo = tt-mix.cod-mix.

        end.

        assign mixmprod.situacao  = tt-mix.ativo
            mixmprod.estmin = tt-mix.estmin
            mixmprod.estmax = tt-mix.estmax.
                      
    end.
            
    run logger(input ("MIXPROD Atualizado " + string(icod-produto))).

end procedure.

procedure atualiza-caracteristicas:

    def input param icod-produto as int no-undo.

    for each procaract exclusive-lock
        where procaract.procod = icod-produto:
        
        delete procaract.
    
    end.
    
    for each tt-caracteristica no-lock
        where tt-caracteristica.cod-produto = icod-produto:

        find first subcarac no-lock
                where subcarac.subdes = tt-caracteristica.subcaracteristica no-error.

        if avail subcarac then do:

            if not can-find(first procaract
                            where procaract.procod = tt-caracteristica.cod-produto
                                and procaract.subcod = subcarac.subcod) then do:
                    
                create procaract.
                assign procaract.procod = tt-caracteristica.cod-produto
                        procaract.subcod = subcarac.subcod
                        procaract.dtcad  = today
                        procaract.dtexp  = today.

            end.
        end.
    end.
        
    run logger(input ("PROCARACT Atualizado " + string(icod-produto))).

end procedure.

procedure atualiza-produto-ecommerce:

    def input param rowid-tt-prod as rowid no-undo.

    find first tt-produtos where rowid(tt-produtos) = rowid-tt-prod no-lock.

    if not can-find (first prodecom where prodecom.procod = tt-produtos.cod-produto) then do:
                            
        create prodecom.
        assign prodecom.procod = tt-produtos.cod-produto.
    
    end.
    else do:

        find first prodecom exclusive-lock
            where prodecom.procod = tt-produtos.cod-produto no-error.

    end.
    
    assign prodecom.altura        = tt-produtos.altura-produto
            prodecom.codCatFisKPL = tt-produtos.cod-cat-fiscal
            prodecom.desccom      = tt-produtos.desc-ecommerce
            prodecom.estmin       = tt-produtos.estoq-minimo
            prodecom.largura      = tt-produtos.largura-produto
            prodecom.peso         = tt-produtos.peso-produto
            prodecom.profund      = tt-produtos.profundidade-prod
            prodecom.voltagem     = tt-produtos.voltagem-produto
            prodecom.visivel      = yes.
    
    run logger(input ("PRODECOM Atualizado " + string(tt-produtos.cod-produto))).

end procedure.

procedure atualiza-produto-pai:

    def input param rowid-tt-prod as rowid no-undo.

    find first tt-produtos where rowid(tt-produtos) = rowid-tt-prod no-lock.

    if tt-produtos.cod-produto-pai <> ? then do:

        if not can-find (first produpai where produpai.itecod = int(tt-produtos.cod-produto-pai)) then do:

            create produpai.
            assign produpai.itecod = int(tt-produtos.cod-produto-pai).

        end.
        else do:
            
            find first produpai exclusive-lock
                where produpai.itecod = int(tt-produtos.cod-produto-pai) no-error.

        end.

        assign produpai.catcod     = tt-produtos.cod-departamento
                produpai.pronom    = tt-produtos.desc-produto
                produpai.fabcod    = tt-produtos.cod-fabricante
                produpai.clacod    = tt-produtos.cod-subclasse
                produpai.temp-cod  = tt-produtos.cod-estac
                produpai.prorefter = string(tt-produtos.referencia)
                produpai.datexp    = today.      
        
    end.
    
    run logger(input ("PRODUPAI Atualizado " + string(tt-produtos.cod-produto))).

end procedure.

procedure atualiza-estoque:

    def input param rowid-tt-prod as rowid no-undo.

    find first tt-produtos where rowid(tt-produtos) = rowid-tt-prod no-lock.

    for each estab no-lock:

        if not can-find (first estoq
            where estoq.etbcod = estab.etbcod
              and estoq.procod = tt-produtos.cod-produto) then do:

            create estoq.
            assign estoq.etbcod     = estab.etbcod
                    estoq.procod     = tt-produtos.cod-produto
                    estoq.estcusto   = tt-produtos.preco-custo
                    estoq.estdtcus   = today
                    estoq.estvenda   = tt-produtos.preco-venda
                    estoq.estdtven   = today
                    estoq.dtaltpreco = today
                    estoq.estideal   = -1
                    estoq.datexp     = today.                           
        end.

    end.

    run logger(input ("ESTOQ Atualizado " + string(tt-produtos.cod-produto))).

end procedure.

procedure atualiza-produaux:

    def input param rowid-tt-prod as rowid no-undo.

    find first tt-produtos where rowid(tt-produtos) = rowid-tt-prod no-lock.

    /* DATA DESCONTINUADO */

    find first produaux exclusive-lock
        where produaux.procod     = tt-produtos.cod-produto
          and produaux.nome_campo = "Data_descontinuado" no-error.

    if avail produaux then do:

        assign produaux.valor_campo = string(tt-produtos.data-descontinuado)
                produaux.datexp      = today.

    end.
    else if tt-produtos.descontinuado then do:

        create produaux.
        assign produaux.valor_campo = string(tt-produtos.data-descontinuado)
                produaux.nome_campo  = "Data_descontinuado"
                produaux.tipo_campo  = ""
                produaux.exportar    = no
                produaux.datexp      = today
                produaux.procod      = tt-produtos.cod-produto.

    end.

    /* TEMPO GARANTIA */

    find first produaux exclusive-lock
        where produaux.procod     = tt-produtos.cod-produto
          and produaux.nome_campo = "TempoGar" no-error.
                
    if avail produaux then do:

        assign produaux.valor_campo = string(tt-produtos.tempo-garantia)
                produaux.datexp            = today.

    end.
    else if tt-produtos.tempo-garantia <> 0 then do:

        create produaux.
        assign produaux.valor_campo = string(tt-produtos.tempo-garantia)
                produaux.nome_campo  = "TempoGar"
                produaux.tipo_campo  = ""
                produaux.exportar    = yes
                produaux.datexp            = today
                produaux.procod      = tt-produtos.cod-produto.

    end.

    /* PACK */

    if tt-produtos.cod-pack <> ? and tt-produtos.cod-pack <> 0 then do:

        find first produaux exclusive-lock
            where produaux.procod     = tt-produtos.cod-produto
              and produaux.nome_campo = "Pack" no-error.

        if not avail produaux then do:

            create produaux.
            assign produaux.procod      = tt-produtos.cod-produto
                    produaux.nome_campo  = "Pack"
                    produaux.tipo_campo  = ""
                    produaux.valor_campo = string(tt-produtos.cod-pack).

        end.
        else
            assign produaux.valor_campo = string(tt-produtos.cod-pack).
    
    end.


    /* EXPORTA E-COMMERCE */
    
    find first produaux exclusive-lock
        where produaux.procod     = tt-produtos.cod-produto
          and produaux.nome_campo = 'exporta-e-com' no-error.

    if not avail produaux then do:

        create produaux.
        assign produaux.procod      = tt-produtos.cod-produto
                produaux.nome_campo  = 'exporta-e-com'
                produaux.tipo_campo  = 'logical'.

    end.
    
    assign produaux.valor_campo = string(tt-produtos.exporta-ecommerce).
    
    run logger(input ("PRODUAUX Atualizado " + string(tt-produtos.cod-produto))).

end procedure.

procedure atualiza-abasgrad:

    def input param icod-produto as int no-undo.

    for each abasgrad exclusive-lock
        where abasgrad.procod = icod-produto:

        delete abasgrad.

    end.

    run logger("ABASGRAD RECEBIDOS PRODUTO " + String(icod-produto)).
    for each tt-estabelec no-lock
       where tt-estabelec.cod-produto = icod-produto:
        run logger("estab " + string(tt-estabelec.etbcod) + " qtd " + string(tt-estabelec.quantidade)).
    end.
    
    for each tt-estabelec no-lock
        where tt-estabelec.cod-produto = icod-produto:
            
            find first abasgrad 
                 where abasgrad.procod = icod-produto
                   and abasgrad.etbcod = tt-estabelec.etbcod
                 exclusive-lock no-error.  
            if not avail abasgrad then
               create abasgrad.
            
            assign abasgrad.procod = icod-produto
                abasgrad.etbcod = tt-estabelec.etbcod
                abasgrad.abgqtd = tt-estabelec.quantidade
                abasgrad.funcod = 1114
                abasgrad.etbfun = 999.

    end.

    run logger(input ("ABASGRAD Atualizado " + string(icod-produto))).

end procedure.

procedure atualiza-abasresoper:

    def input param rowid-tt-prod as rowid no-undo.

    find first tt-produtos where rowid(tt-produtos) = rowid-tt-prod no-lock.

    find first AbasResOper exclusive-lock
        where AbasResOper.procod = tt-produtos.cod-produto
          and AbasResOper.emite = tt-produtos.cod-fabricante no-error.

    if not avail AbasResOper then do:

        create AbasResOper.
        assign AbasResOper.procod = tt-produtos.cod-produto
            AbasResOper.emite = tt-produtos.cod-fabricante.

    end.

    assign AbasResOper.LeadTimeInfo = tt-produtos.leadTime
        AbasResOper.etbcod = 900.

    run logger(input ("AbasResOper Atualizado " + string(tt-produtos.cod-produto))).

end procedure.