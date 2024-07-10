/* #27092022 helio - (Lucas) Ajuste Acréscimo - Exportador/Integração */
/* helio 13072022 #02092022 - projeto Criar Produtos - ADM */
/* medico na tela 042022 - helio */
/* heliosf 21012022 novo layout pix */
/* helio 19112021 - Meio de pagamento PIX suporte ADMCOM */
/* HUBSEG 19/10/2021 */
def var valteraprincipal as log.

    def var psicred as recid.
    def var val_tfc as dec init 0.
    for each ttrecebimentos where ttrecebimentos.idpai = {1}.
        /*
        field troco as char 
        */
        vcodigo_forma  = ttrecebimentos.formaPagamento.
        find first pdvforma where      
                 pdvforma.etbcod     = pdvmov.etbcod and
                 pdvforma.cmocod     = pdvmov.cmocod and
                 pdvforma.DataMov    = pdvmov.DataMov and
                 pdvforma.Sequencia  = pdvmov.Sequencia and
                 pdvforma.ctmcod     = pdvmov.ctmcod and
                 pdvforma.COO        = pdvmov.COO and
                 pdvforma.seqforma   = int(ttrecebimentos.sequencial)
                no-error.
        if not avail pdvforma 
        then do: 
            create pdvforma.
            assign
                pdvforma.etbcod     = pdvmov.etbcod
                pdvforma.DataMov    = pdvmov.DataMov
                pdvforma.cmocod     = pdvmov.cmocod
                pdvforma.COO        = pdvmov.COO
                pdvforma.Sequencia  = pdvmov.Sequencia
                pdvforma.ctmcod     = pdvmov.ctmcod 
                pdvforma.seqforma   = int(ttrecebimentos.sequencial).
        end.                     

        find pdvtforma where pdvtforma.pdvtfcod = vcodigo_forma no-lock no-error.
        pdvforma.crecod       = 1.
        pdvforma.modcod       = if vmodcod = ""
                                then if avail pdvtforma
                                     then pdvtforma.modcod
                                     else vmodcod
                                else vmodcod.
        pdvforma.pdvtfcod     = vcodigo_forma.
        pdvforma.fincod       = int(ttrecebimentos.codigoPlano).
        pdvforma.valor_forma  = dec(ttrecebimentos.valorRecebido).
        pdvforma.valor        = dec(ttrecebimentos.valorRecebido) - dec(ttrecebimentos.troco).
        
        /*
        pdvforma.observacao   = vobservacao.
        */


        
        if pdvforma.pdvtfcod = "1"
        then do on error undo: 
            find first pdvmoeda where      
                     pdvmoeda.etbcod     = pdvmov.etbcod and
                     pdvmoeda.cmocod     = pdvmov.cmocod and
                     pdvmoeda.DataMov    = pdvmov.DataMov and
                     pdvmoeda.Sequencia  = pdvmov.Sequencia and
                     pdvmoeda.ctmcod     = pdvmov.ctmcod and
                     pdvmoeda.COO        = pdvmov.COO and
                     pdvmoeda.seqforma   = pdvforma.seqforma and
                     pdvmoeda.seqfp      = 1 and
                     pdvmoeda.titpar     = 0
                    no-error.
            if not avail pdvmoeda 
            then do: 
                create pdvmoeda. 
                /*pdvmoeda.titcod   = next-value(titcod).*/ 
                assign 
                    pdvmoeda.etbcod     = pdvmov.etbcod 
                    pdvmoeda.DataMov    = pdvmov.DataMov 
                    pdvmoeda.cmocod     = pdvmov.cmocod 
                    pdvmoeda.COO        = pdvmov.COO 
                    pdvmoeda.Sequencia  = pdvmov.Sequencia 
                    pdvmoeda.ctmcod     = pdvmov.ctmcod 
                    pdvmoeda.seqforma   = pdvforma.seqforma 
                    pdvmoeda.seqfp      = 1 
                    pdvmoeda.titpar     = 0.   
            end.                    
            pdvmoeda.moecod   = pdvforma.modcod. 
            pdvmoeda.valor    = pdvforma.valor.
            
            pdvforma.crecod = 1.
            
        end.

        message "ECOM" vecommerce avail pdvmov avail pdvdoc.
        if vecommerce
        then do on error undo:
            /* #02092022 */
            message "PEDIDO" pdvforma.etbcod vnumeropedido string(pdvdoc.numero_pedido).
            
            find first contrsite where contrsite.etbcod       = pdvforma.etbcod and
                                       contrsite.codigoPedido = vnumeropedido
                no-lock no-error.
            if avail contrsite
            then do:
                message "CONTRSITE" contrsite.contnum pdvdoc.etbcod pdvdoc.placod.
                find contrato where contrato.contnum = contrsite.contnum no-lock.

                pdvforma.contnum      = string(contrato.contnum).
                pdvforma.modcod       = contrato.modcod.
                pdvforma.clifor       = contrato.clicod.
                pdvforma.crecod       = 2.
            
                pdvforma.qtd_parcelas = contrato.nro_parcelas.
                pdvforma.valor_ACF    = contrato.vlf_acrescimo.
                pdvforma.valor        = contrato.vltotal.
                
/****                
                /* helio 03022022 pedido ecommerce não estava criando contnff */
                find plani where plani.etbcod = pdvdoc.etbcod and
                                 plani.placod =  pdvdoc.placod
                                 no-lock.
                /* helio 03022022 coloquei para testar se ja existe */ 
                find first contnf where contnf.etbcod = pdvdoc.etbcod and
                                       contnf.placod = pdvdoc.placod and
                                       contnf.contnum = contrsite.contnum
                    no-lock no-error.
                if not avail contnf
                then do:
                    create contnf.
                    assign
                        contnf.contnum = contrsite.contnum
                        contnf.etbcod  = pdvdoc.etbcod
                        contnf.placod  = pdvdoc.placod
                        contnf.notanum = plani.numero
                        contnf.notaser = plani.serie.
                end.        
                message "CONTNF" new contnf "PEDIDO" contrsite.contnum pdvdoc.etbcod pdvdoc.placod plani.numero plani.serie.
                /**/
***/                
                    
            end.
        end.
        else for each ttcontrato where ttcontrato.id = ttrecebimentos.id: 
            /*
            field tipoOperacao as char 
            field dataEfetivacao as char 
            field primeiroVencimento as char 
            field taxaCetAno as char 
            field tipoContrato as char 
            **/
        
            pdvforma.contnum      = ttcontrato.numeroContrato.
            pdvforma.clifor       = int(pdvdoc.clifor).
            pdvforma.crecod       = 2.
            
            pdvforma.qtd_parcelas  = int(ttcontrato.qtdParcelas).
            pdvforma.valor_ACF    = dec(ttcontrato.valorAcrescimo).
            pdvforma.valor        = dec(ttcontrato.valorTotal).


            find contrato where contrato.contnum  = int(pdvforma.contnum) exclusive no-error.
            if not avail contrato
            then do:
                create contrato.
                contrato.contnum       = int(pdvforma.contnum).
            end.     

            ASSIGN contrato.vlseguro = 0. 
              contrato.clicod        = pdvdoc.clifor.
              contrato.dtinicial     = aaaa-mm-dd_todate(dataInicial).
              contrato.etbcod        = pdvmov.etbcod.
              contrato.vltotal       = dec(ttcontrato.valorTotal) + dec(ttcontrato.valorEntrada).
              contrato.vlentra       = dec(ttcontrato.valorEntrada).
              contrato.crecod        = pdvforma.fincod.
              contrato.vltaxa        = dec(ttcontrato.valorTFC).
              val_tfc = dec(ttcontrato.valorTFC).
              contrato.modcod        = pdvforma.modcod /*ttcontrato.modalidade*/ .
              contrato.DtEfetiva     = aaaa-mm-dd_todate(ttcontrato.dataEfetivacao).
              contrato.VlIof         = dec(ttcontrato.valorIof).
              contrato.Cet           = dec(ttcontrato.taxaCet).
              contrato.TxJuros       = dec(ttcontrato.taxaMes).
              contrato.vlf_principal = dec(ttcontrato.valorPrincipal). 
              
              message contrato.contnum vctmcod pdvdoc.idAdesaoHubSeg "princ" contrato.vlf_principal "acres" pdvforma.valor_ACF.
              
              /* #02092022 */
              if  vctmcod = "VHS" or vctmcod = "D24"
              then do:
                  contrato.idAdesaoHubSeg = pdvdoc.idAdesaoHubSeg.
                  contrato.vlf_hubseg = contrato.vlf_principal.

                    if vctmcod = "D24"
                    then do:
                        find medadesao where medadesao.idadesao = int(idAdesaoHubSeg) 
                                exclusive no-wait no-error.
                        if avail medadesao
                        then do:
                            medadesao.clicod = pdvdoc.clifor.
                            medadesao.fincod = contrato.crecod.
                            medadesao.contnum = contrato.contnum.
                        end.        
                    end.
                  
              end.
              
              contrato.vlf_acrescimo = dec(ttcontrato.valorAcrescimo).
                                            /* helio 200421
                                            **dec(ttcontrato.valorTotal) - dec(ttcontrato.valorPrincipal) - dec(ttcontrato.valorIof).
                                            */    
              
              valteraprincipal = no.
              /* helio 16102023 ID 47776 - Acréscimo zerado / Exportador - solicitado retirar
              * /* #27092022 helio */
              *if contrato.vlf_acrescimo > 0 and contrato.vlf_acrescimo <= 5.00
              *then do:
              *      contrato.vlf_principal = contrato.vlf_principal + contrato.vlf_acrescimo.
              *      contrato.vlf_acrescimo = 0.   
              *      valteraprincipal = yes.
              *end.
              *
              * /* #27092022 */
              ***/
              
              if contrato.vlf_acrescimo < 0   /* 18.06.20 14:18 Novacao total e principal esta vindo iguais */
              then contrato.vlf_acrescimo = 0.

              contrato.nro_parcelas  = int(ttcontrato.qtdParcelas).

              contrato.banco = if true_tolog(ttcontrato.contratoFinanceira)
                               then if pdvmov.ctmcod = "P47" 
                                    then 13 
                                    else 10
                               else contrato.banco.
              contrato.tpcontrato = if pdvmov.ctmcod = "P48"
                                    then "N"
                                    else "".

              /*
              contrato.situacao      = {2}.situacao
              contrato.indimp        = {2}.indimp
              contrato.lotcod        = {2}.lotcod
              contrato.autoriza      = {2}.autoriza.
              contrato.vlfrete       = {2}.vlfrete
              contrato.datexp        = {2}.datexp
              */

                /* #02092022 - trocou de posicao */
                if pdvmov.ctmcod = "P48"
                then do:

                    
                    contrato.banco = if true_tolog(ttcontrato.contratoFinanceira)
                                     then if contrato.modcod = "CPN"
                                          then 13
                                          else 10
                                     else contrato.banco.

                                     
                end.
              
            if true_tolog(ttcontrato.contratoFinanceira) /* Marca Financeira */
            then do on error undo:
                            
                run /admcom/progr/fin/sicrecontr_create.p (recid(pdvforma),
                                             contrato.contnum,
                                             output psicred).

                find sicred_contrato where recid(sicred_contrato) = psicred no-lock no-error.
            
            end.
            
            for each ttparcelas where ttparcelas.idpai = ttcontrato.id.
                /*
                field dataEmissao as char 
                field codigoCobranca as char 
                field valorPrincipal as char 
                field valorFinanceiroAcrescimo as char 
                field valorSeguro as char 
                field situacao as char
                */

                vtitpar = int(ttparcelas.sequencial).
                find first pdvmoeda where      
                     pdvmoeda.etbcod       = pdvmov.etbcod and
                     pdvmoeda.cmocod       = pdvmov.cmocod and
                     pdvmoeda.DataMov      = pdvmov.DataMov and
                     pdvmoeda.Sequencia    = pdvmov.Sequencia and
                     pdvmoeda.ctmcod       = pdvmov.ctmcod and
                     pdvmoeda.COO          = pdvmov.COO and
                     pdvmoeda.seqforma     = pdvforma.seqforma and
                     pdvmoeda.seqfp        = 1 and
                     pdvmoeda.titpar       = vtitpar
                    no-error.
                if not avail pdvmoeda
                then do: 
                    create pdvmoeda.
                    /*pdvmoeda.titcod   = next-value(titcod).*/
                    assign
                         pdvmoeda.etbcod       = pdvmov.etbcod
                         pdvmoeda.DataMov      = pdvmov.DataMov
                         pdvmoeda.cmocod       = pdvmov.cmocod
                         pdvmoeda.COO          = pdvmov.COO
                         pdvmoeda.Sequencia    = pdvmov.Sequencia
                         pdvmoeda.ctmcod       = pdvmov.ctmcod
                         pdvmoeda.seqforma     = pdvforma.seqforma
                         pdvmoeda.seqfp        = 1
                         pdvmoeda.titpar       = vtitpar.   
                end.                  
                assign
                    pdvmoeda.contrato_p2k = pdvforma.contnum.
                pdvmoeda.clifor = contrato.clicod.
                pdvmoeda.titnum = string(contrato.contnum).
                pdvmoeda.moecod = pdvforma.modcod.
                pdvmoeda.modcod = pdvforma.modcod.

                pdvmoeda.valor = dec(ttparcelas.valorparcela).
                
                pdvmoeda.titdtven = aaaa-mm-dd_todate(ttparcelas.datavencimento).

                /*220720*/
                if pdvmoeda.titdtven < pdvmoeda.datamov
                then pdvmoeda.titdtven = pdvmoeda.datamov.

                message pdvmoeda.titnum pdvmoeda.titpar ttparcelas.datavencimento pdvmoeda.titdtven.
        
                find first titulo where titulo.contnum = contrato.contnum and
                                  titulo.titpar  = pdvmoeda.titpar  
                        no-error.
                if not avail titulo
                then do:
                    find first titulo where
                    titulo.empcod     = 19 and
                    titulo.titnat     = no and
                    titulo.modcod     = pdvmoeda.modcod and
                    titulo.etbcod     = pdvmoeda.etbcod and
                    titulo.clifor     = pdvmoeda.clifor and
                    titulo.titnum     = pdvmoeda.titnum and 
                    titulo.titpar     = pdvmoeda.titpar and
                    titulo.titdtemi   = pdvmoeda.datamov
                    no-error.
                    if not avail titulo
                    then do:
                        create titulo. 
                        titulo.datexp = today.
                    end.           
                    titulo.contnum  = contrato.contnum. 
                    
                    assign            
                    titulo.empcod     = 19
                    titulo.titnat     = no
                    titulo.modcod     = pdvmoeda.modcod 
                    titulo.etbcod     = pdvmoeda.etbcod 
                    titulo.clifor     = pdvmoeda.clifor 
                    titulo.titnum     = pdvmoeda.titnum 
                    titulo.titpar     = pdvmoeda.titpar 
                    titulo.titdtemi   = pdvmoeda.datamov
                    titulo.titdtven   = pdvmoeda.titdtven.
                    titulo.titsit     = "LIB".
                end.        
                assign
                    titulo.modcod     = contrato.modcod
                    titulo.titvlcob   = pdvmoeda.valor
                    titulo.titnumger  = pdvmoeda.contrato_p2k 
                    titulo.tpcontrato = contrato.tpcontrato.

                assign
                    titulo.vlf_acrescimo  = contrato.vlf_acrescimo / contrato.nro_parcelas.
                    titulo.vlf_principal = dec(ttparcelas.valorPrincipal).
               
                /* #27092022 helio */
                if valteraprincipal
                then do:
                    assign
                        titulo.vlf_principal = contrato.vlf_principal / contrato.nro_parcelas.
                end.
                
                
                /* #02092022 */    
                if  vctmcod = "VHS" or vctmcod = "D24"
                then do:
                    titulo.vlf_hubseg = titulo.vlf_principal.
                end.

                titulo.cobcod = if avail sicred_contrato
                                then sicred_contrato.cobcod
                                else 1.
                                

                run /admcom/progr/fin/gerahisposcart.p   
                    (recid(titulo),  
                     "emissao",  
                     titulo.titdtemi,
                     titulo.tpcontrato,
                     titulo.titvlcob,
                     titulo.cobcod,
                     titulo.cobcod). 
                       
            end.
                                    
/**                                    

DEFINE TEMP-TABLE ttseguro NO-UNDO SERIALIZE-NAME "seguro"
        field rstatus as char serialize-name "status"
        field dataInicioVigencia as char 
        field dataFimVigencia as char 
index x is unique primary idpai asc id asc.
        */
            for each ttseguro where ttseguro.idpai = ttcontrato.id.
                vtpseguro =  if pdvmov.ctmcod = "P44" or
                                pdvmov.ctmcod = "P47"
                             then 3
                             else  int(tipoSeguro).
                    
                find vndseguro where
                        vndseguro.tpseguro = vtpseguro
                    and vndseguro.etbcod   = pdvmov.etbcod
                    and vndseguro.certifi  = numeroApolice
                       no-error.
                if not avail vndseguro
                then do.
                    create vndseguro.
                    assign
                        vndseguro.tpseguro = vtpseguro.
                        vndseguro.certifi  = numeroApolice.
                        vndseguro.etbcod   = pdvmov.etbcod.
                end.
                find current plani no-lock no-error.
                assign  
                    vndseguro.placod   = if avail plani
                                         then plani.placod 
                                         else ?.
                    vndseguro.prseguro = dec(ttseguro.valorSeguro).
                    vndseguro.pladat   = pdvmov.datamov .
                    vndseguro.dtincl   = pdvmov.datamov .
                    vndseguro.procod   = int(codigoSeguro).
                    vndseguro.clicod   = if avail plani
                                         then plani.desti
                                         else if avail contrato
                                              then contrato.clicod
                                              else ?.
                    vndseguro.codsegur = int(codigoSeguradora).
                    vndseguro.contnum  = int(pdvforma.contnum) .
                    vndseguro.dtivig   = aaaa-mm-dd_todate(ttseguro.dataInicioVigencia).
                    vndseguro.dtfvig   = aaaa-mm-dd_todate(ttseguro.dataFimVigencia).
                    vndseguro.datexp   = today .
                    vndseguro.exportado = no. 
                    vndseguro.numerosorte = numeroSorteio .
                    
                find contrato where contrato.contnum = int(pdvforma.contnum) exclusive.
                
                if dec(ttseguro.valorSeguro) = ? then ttseguro.valorSeguro = "0".
                
                contrato.vlseguro = dec(ttseguro.valorSeguro).
                
                contrato.vlf_principal = contrato.vlf_principal - dec(ttseguro.valorSeguro).
                
                /* #02092022 */
                if  vctmcod = "VHS" or vctmcod = "D24" 
                then do:
                    contrato.vlf_hubseg = contrato.vlf_principal.
                end.
                for each titulo where titulo.contnum = contrato.contnum.
                    titulo.titdesc        = contrato.vlseguro / contrato.nro_parcela. /* apenas compatibilidade, porque nao usa mais este campo */
                    titulo.vlf_principal  = contrato.vlf_principal / contrato.nro_parcelas.
                    if  vctmcod = "VHS" or vctmcod = "D24"
                    then do:
                        titulo.vlf_hubseg = titulo.vlf_principal.
                    end.
                end.                
                    
                find current plani exclusive no-error.
                if avail plani
                then  do:
                    plani.seguro  = plani.seguro  + contrato.vlseguro.

            /* cria movim seguro prestamista */

                /*** Seguro eh um item da nota */
                vmovseq = vmovseq + 1.
                create movim.
                assign
                    movim.movtdc = plani.movtdc
                    movim.etbcod = plani.etbcod
                    movim.placod = plani.placod
                    movim.emite  = plani.emite
                    movim.desti  = plani.desti
                    movim.movdat = plani.pladat
                    movim.movhr  = plani.horincl
                    movim.movseq = vmovseq
                    movim.procod = vndseguro.procod
                    movim.movqtm = 1
                    movim.movpc  = vndseguro.prseguro
                    movim.movalicms = 98 /* #3 */.

                end.
                
            /* movim seguro */                                    
                                                
            end.

            /*delete ttcontrato.*/
            
            
        end.
        
        for each ttcartaoDebito where ttcartaoDebito.id = ttrecebimentos.id: 
            /*
            field codigoAprovacao as char 
            field nsuTransCtf as char 
            */
            pdvforma.qtd_parcelas = int(ttcartaoDebito.qtdParcelas).
            pdvforma.valor        = dec(ttcartaoDebito.valorTotal).
            pdvforma.valor_acf    = dec(ttcartaoDebito.valorAcrescimo).
            pdvforma.observacao = ttcartaoDebito.codigoVan + "|" + ttcartaoDebito.nomeVan + "|" + 
                                  ttcartaoDebito.codigoAutorizadora + "|" + ttcartaoDebito.nomeAutorizadora.
            pdvforma.modcod   = "CAR".
            pdvforma.clifor   = pdvdoc.clifor.
            pdvforma.crecod   = 1.
            pdvforma.contnum  = ttcartaoDebito.nsuTransAutorizadora.

            vtotalsemjuros     = pdvforma.valor_forma.
            vtitvlcobsemjuros = round(vtotalsemjuros / pdvforma.qtd_parcelas,2).

            vtitvlcob = round(pdvforma.valor / pdvforma.qtd_parcelas,2).
            vtotal = round(vtitvlcob * pdvforma.qtd_parcelas,2).

            if pdvforma.valor > vtotal
            then vultima = vtitvlcob + (pdvforma.valor - vtotal).
            else vultima = vtitvlcob - (vtotal - pdvforma.valor).
                
            vdia = day(pdvmov.datamov). 
            vvenc = pdvmov.datamov.

            do vi = 1 to pdvforma.qtd_parcelas:
                find first pdvmoeda where      
                     pdvmoeda.etbcod     = pdvmov.etbcod and
                     pdvmoeda.cmocod     = pdvmov.cmocod and
                     pdvmoeda.DataMov    = pdvmov.DataMov and
                     pdvmoeda.Sequencia  = pdvmov.Sequencia and
                     pdvmoeda.ctmcod     = pdvmov.ctmcod and
                     pdvmoeda.COO        = pdvmov.COO and
                     pdvmoeda.seqforma   = pdvforma.seqforma and
                     pdvmoeda.seqfp      = 1 and
                     pdvmoeda.titpar     = vi
                    no-error.
                if not avail pdvmoeda
                then do:
                    create pdvmoeda.
                    /*pdvmoeda.titcod   = next-value(titcod).*/
                    assign
                        pdvmoeda.etbcod     = pdvmov.etbcod
                        pdvmoeda.DataMov    = pdvmov.DataMov
                        pdvmoeda.cmocod     = pdvmov.cmocod
                        pdvmoeda.COO        = pdvmov.COO
                        pdvmoeda.Sequencia  = pdvmov.Sequencia
                        pdvmoeda.ctmcod     = pdvmov.ctmcod
                        pdvmoeda.seqforma   = pdvforma.seqforma
                        pdvmoeda.seqfp      = 1
                        pdvmoeda.titpar     = vi.   
                end.                  
                assign
                    pdvmoeda.moecod   = pdvtforma.modcod.
                    pdvmoeda.titnum   = pdvforma.contnum.
                
                if vi = pdvforma.qtd_parcelas
                then pdvmoeda.valor = vultima.
                else pdvmoeda.valor = vtitvlcob. 
                
                vmes = month(vvenc) + vi. 
                if vmes > 12 
                then assign vmes = vmes - 12 
                     vano = year(vvenc) + 1. 
                else vano = year(vvenc). 
                if vdia = 31 and (vmes = 2 or 
                                  vmes = 4 or 
                                  vmes = 6 or 
                                  vmes = 9 or 
                                  vmes = 11) 
                then vdia = 30. 
                if vdia > 28  and vmes = 2 
                then  vdia = 28.  
                
                pdvmoeda.titdtven =  date(vmes,vdia,vano).  
                
                if pdvmoeda.moecod = "TDB" and  
                   weekday(pdvmoeda.titdtven) = 7 
                then pdvmoeda.titdtven = pdvmoeda.titdtven + 2.  
                if pdvmoeda.moecod = "TDB" and  
                   weekday(pdvmoeda.titdtven) = 8  
                then pdvmoeda.titdtven = pdvmoeda.titdtven + 1.
                
            end.
            
        end.        
        /* helio 19112021 - Meio de pagamento PIX suporte ADMCOM */ 
        for each ttpixDebito where ttpixDebito.id = ttrecebimentos.id: 
            /*
            field codigoAprovacao as char 
            field nsuTransCtf as char 
            */
            pdvforma.qtd_parcelas = 1.
            pdvforma.valor        = dec(ttpixDebito.valorTotal).
            pdvforma.valor_acf    = dec(ttpixDebito.valorAcrescimo).
            pdvforma.observacao = ttpixdebito.idTransacao.
            pdvforma.modcod   = "CAR".
            pdvforma.clifor   = pdvdoc.clifor.
            pdvforma.crecod   = 1.
            pdvforma.contnum  = ttpixDebito.idTransacao.

            vtotalsemjuros     = pdvforma.valor_forma.
            vtitvlcobsemjuros = round(vtotalsemjuros / pdvforma.qtd_parcelas,2).

            vtitvlcob = round(pdvforma.valor / pdvforma.qtd_parcelas,2).
            vtotal = round(vtitvlcob * pdvforma.qtd_parcelas,2).

            if pdvforma.valor > vtotal
            then vultima = vtitvlcob + (pdvforma.valor - vtotal).
            else vultima = vtitvlcob - (vtotal - pdvforma.valor).
                
            vdia = day(pdvmov.datamov). 
            vvenc = pdvmov.datamov.

                find first pdvmoeda where      
                     pdvmoeda.etbcod     = pdvmov.etbcod and
                     pdvmoeda.cmocod     = pdvmov.cmocod and
                     pdvmoeda.DataMov    = pdvmov.DataMov and
                     pdvmoeda.Sequencia  = pdvmov.Sequencia and
                     pdvmoeda.ctmcod     = pdvmov.ctmcod and
                     pdvmoeda.COO        = pdvmov.COO and
                     pdvmoeda.seqforma   = pdvforma.seqforma and
                     pdvmoeda.seqfp      = 1 and
                     pdvmoeda.titpar     = 0
                    no-error.
                if not avail pdvmoeda
                then do:
                    create pdvmoeda.
                    /*pdvmoeda.titcod   = next-value(titcod).*/
                    assign
                        pdvmoeda.etbcod     = pdvmov.etbcod
                        pdvmoeda.DataMov    = pdvmov.DataMov
                        pdvmoeda.cmocod     = pdvmov.cmocod
                        pdvmoeda.COO        = pdvmov.COO
                        pdvmoeda.Sequencia  = pdvmov.Sequencia
                        pdvmoeda.ctmcod     = pdvmov.ctmcod
                        pdvmoeda.seqforma   = pdvforma.seqforma
                        pdvmoeda.seqfp      = 1
                        pdvmoeda.titpar     = 0.   
                end.                  
                assign
                    pdvmoeda.moecod   = pdvtforma.modcod.
                    pdvmoeda.titnum   = pdvforma.contnum.
                
                pdvmoeda.valor = vtitvlcob. 
                pdvmoeda.titdtven =  vvenc.
                
            
        end.        
        /* helio 19112021 - Meio de pagamento PIX suporte ADMCOM */
       
 
        for each ttcartaoCredito where ttcartaoCredito.id = ttrecebimentos.id: 
            /*
            field codigoAprovacao as char 
            field nsuTransCtf as char 
            */
            pdvforma.qtd_parcelas = int(ttcartaoCredito.qtdParcelas).
            pdvforma.valor        = dec(ttcartaoCredito.valorTotal).
            pdvforma.valor_acf    = dec(ttcartaoCredito.valorAcrescimo).
            pdvforma.observacao = ttcartaoCredito.codigoVan + "|" + ttcartaoCredito.nomeVan + "|" + 
                                  ttcartaoCredito.codigoAutorizadora + "|" + ttcartaoCredito.nomeAutorizadora.
            pdvforma.modcod   = "CAR".
            pdvforma.clifor   = pdvdoc.clifor.
            pdvforma.crecod   = 1.
            pdvforma.contnum  = ttcartaoCredito.nsuTransAutorizadora.

            vtotalsemjuros     = pdvforma.valor_forma.
            vtitvlcobsemjuros = round(vtotalsemjuros / pdvforma.qtd_parcelas,2).

            vtitvlcob = round(pdvforma.valor / pdvforma.qtd_parcelas,2).
            vtotal = round(vtitvlcob * pdvforma.qtd_parcelas,2).

            if pdvforma.valor > vtotal
            then vultima = vtitvlcob + (pdvforma.valor - vtotal).
            else vultima = vtitvlcob - (vtotal - pdvforma.valor).
                
            vdia = day(pdvmov.datamov). 
            vvenc = pdvmov.datamov.

            do vi = 1 to pdvforma.qtd_parcelas:
                find first pdvmoeda where      
                     pdvmoeda.etbcod     = pdvmov.etbcod and
                     pdvmoeda.cmocod     = pdvmov.cmocod and
                     pdvmoeda.DataMov    = pdvmov.DataMov and
                     pdvmoeda.Sequencia  = pdvmov.Sequencia and
                     pdvmoeda.ctmcod     = pdvmov.ctmcod and
                     pdvmoeda.COO        = pdvmov.COO and
                     pdvmoeda.seqforma   = pdvforma.seqforma and
                     pdvmoeda.seqfp      = 1 and
                     pdvmoeda.titpar     = vi
                    no-error.
                if not avail pdvmoeda
                then do:
                    create pdvmoeda.
                    /*pdvmoeda.titcod   = next-value(titcod).*/
                    assign
                        pdvmoeda.etbcod     = pdvmov.etbcod
                        pdvmoeda.DataMov    = pdvmov.DataMov
                        pdvmoeda.cmocod     = pdvmov.cmocod
                        pdvmoeda.COO        = pdvmov.COO
                        pdvmoeda.Sequencia  = pdvmov.Sequencia
                        pdvmoeda.ctmcod     = pdvmov.ctmcod
                        pdvmoeda.seqforma   = pdvforma.seqforma
                        pdvmoeda.seqfp      = 1
                        pdvmoeda.titpar     = vi.   
                end.                  
                assign
                    pdvmoeda.moecod   = pdvforma.modcod.
                    pdvmoeda.titnum   = pdvforma.contnum. 
                
                if vi = pdvforma.qtd_parcelas
                then pdvmoeda.valor = vultima.
                else pdvmoeda.valor = vtitvlcob.
                vmes = month(vvenc) + vi. 
                if vmes > 12 
                then assign vmes = vmes - 12 
                     vano = year(vvenc) + 1. 
                else vano = year(vvenc). 
                if vdia = 31 and (vmes = 2 or 
                                  vmes = 4 or 
                                  vmes = 6 or 
                                  vmes = 9 or 
                                  vmes = 11) 
                then vdia = 30. 
                if vdia > 28  and vmes = 2 
                then  vdia = 28.  
                
                pdvmoeda.titdtven =  date(vmes,vdia,vano).  
                
                if pdvmoeda.moecod = "TDB" and  
                   weekday(pdvmoeda.titdtven) = 7 
                then pdvmoeda.titdtven = pdvmoeda.titdtven + 2.  
                if pdvmoeda.moecod = "TDB" and  
                   weekday(pdvmoeda.titdtven) = 8  
                then pdvmoeda.titdtven = pdvmoeda.titdtven + 1.

            end.
            
        end.        
        
        
        for each ttcartaoPresente where ttcartaoPresente.id = ttrecebimentos.id: 

            /*
            field numeroCartao as char 
            field codigoAprovacao as char 
            field nsuTransAutorizadora as char 
            field codigoAutorizadora as char 
            field nomeAutorizadora as char 
            field codigoVan as char 
            field nomeVan as char 
            */
            pdvforma.observacao = ttcartaoPresente.codigoVan + "|" + ttcartaoPresente.nomeVan + "|" + 
                                  ttcartaoPresente.codigoAutorizadora + "|" + ttcartaoPresente.nomeAutorizadora.
            pdvforma.contnum = ttcartaoPresente.numeroCartao                                  .
            pdvforma.crecod  = 1.
                
            find first pdvmoeda where      
                     pdvmoeda.etbcod     = pdvmov.etbcod and
                     pdvmoeda.cmocod     = pdvmov.cmocod and
                     pdvmoeda.DataMov    = pdvmov.DataMov and
                     pdvmoeda.Sequencia  = pdvmov.Sequencia and
                     pdvmoeda.ctmcod     = pdvmov.ctmcod and
                     pdvmoeda.COO        = pdvmov.COO and
                     pdvmoeda.seqforma   = pdvforma.seqforma and
                     pdvmoeda.seqfp      = 1 and
                     pdvmoeda.titpar     = 0
                    no-error.
                if not avail pdvmoeda
                then do:
                    create pdvmoeda.
                    /*pdvmoeda.titcod   = next-value(titcod).*/
                    assign
                        pdvmoeda.etbcod     = pdvmov.etbcod
                        pdvmoeda.DataMov    = pdvmov.DataMov
                        pdvmoeda.cmocod     = pdvmov.cmocod
                        pdvmoeda.COO        = pdvmov.COO
                        pdvmoeda.Sequencia  = pdvmov.Sequencia
                        pdvmoeda.ctmcod     = pdvmov.ctmcod
                        pdvmoeda.seqforma   = pdvforma.seqforma
                        pdvmoeda.seqfp      = 1
                        pdvmoeda.titpar     = 0.   
                end.                  
                assign
                    pdvmoeda.moecod   = pdvforma.modcod.
                
                pdvmoeda.valor = pdvforma.valor.
                pdvmoeda.titdtven = pdvforma.datamov.                
                pdvmoeda.titnum = pdvforma.contnum.
        end.
        
        /*

        DEFINE TEMP-TABLE ttvaleTrocaGarantida NO-UNDO SERIALIZE-NAME "valeTrocaGarantida"
        field id as char 
        field idPai as char 
        field certificado as char 
        field numeroAutorizacao as char 
        field seqProduto as char 
        field origemNumeroComponente as char 
        field origemDataTransacao as char 
        field origemNsuTransacao as char 
        field origemCodigoLoja as char 
        index x is unique primary idpai asc id asc.

        DEFINE TEMP-TABLE ttvaleTroca NO-UNDO SERIALIZE-NAME "valeTroca"
        field id as char 
        field idPai as char 
        field numeroValeTroca as char 
        field codigoAprovacao as char 
        field nsuTransAutorizadora as char 
        field codigoAutorizadora as char 
        field nomeAutorizadora as char 
        field codigoVan as char 
        field nomeVan as char 
        index x is unique primary idpai asc id asc.

**/
        for each ttcheque where ttcheque.id = ttrecebimentos.id: 

            /*
        DEFINE TEMP-TABLE ttcheque NO-UNDO SERIALIZE-NAME "cheque"
        field id as char 
        field idPai as char 
        field banco as char 
        field agencia as char 
        field conta as char 
        field numeroCheque as char 
        field cpfCnpj as char 
        field valor as char 
        field dataCheque as char 
        index x is unique primary idpai asc id asc.
            */
            
            pdvforma.contnum = ttcheque.numeroCheque.
            pdvforma.crecod  = 1.
                
            find first pdvmoeda where      
                     pdvmoeda.etbcod     = pdvmov.etbcod and
                     pdvmoeda.cmocod     = pdvmov.cmocod and
                     pdvmoeda.DataMov    = pdvmov.DataMov and
                     pdvmoeda.Sequencia  = pdvmov.Sequencia and
                     pdvmoeda.ctmcod     = pdvmov.ctmcod and
                     pdvmoeda.COO        = pdvmov.COO and
                     pdvmoeda.seqforma   = pdvforma.seqforma and
                     pdvmoeda.seqfp      = 1 and
                     pdvmoeda.titpar     = 0
                    no-error.
                if not avail pdvmoeda
                then do:
                    create pdvmoeda.
                    assign
                        pdvmoeda.etbcod     = pdvmov.etbcod
                        pdvmoeda.DataMov    = pdvmov.DataMov
                        pdvmoeda.cmocod     = pdvmov.cmocod
                        pdvmoeda.COO        = pdvmov.COO
                        pdvmoeda.Sequencia  = pdvmov.Sequencia
                        pdvmoeda.ctmcod     = pdvmov.ctmcod
                        pdvmoeda.seqforma   = pdvforma.seqforma
                        pdvmoeda.seqfp      = 1
                        pdvmoeda.titpar     = 0.   
                end.                  
                assign
                    pdvmoeda.moecod   = pdvforma.modcod.
                
                pdvmoeda.valor = pdvforma.valor.
                pdvmoeda.titdtven = aaaa-mm-dd_todate(ttcheque.dataCheque).
                pdvmoeda.titnum = pdvforma.contnum.
                
        end.

            
        /*delete ttrecebimentos.*/
        message "FIM ttrecebimentos." ttrecebimentos.formaPagamento avail pdvforma pdvforma.crecod.
         
    end.

    message "FIM FOR EACH TTRECEIMENTOS".
  
    /* Ajusta contrato ADMCOM */
    assign
        vvalor_contrato = 0
        vvalor_vista    = 0.

    find first pdvforma of pdvmov where  
            pdvforma.crecod = 2 
            no-lock no-error.
    if not avail pdvforma
    then find first pdvforma of pdvmov where
            pdvforma.crecod = 1
            no-lock no-error.
             
    message "RECEBIMENTOS" "PDVFORMA" avail pdvforma "PLANI=" avail plani.
    if avail pdvforma
    then message pdvforma.modcod.
    
    for each pdvmoeda of pdvmov no-lock.
        vvalor_contrato = vvalor_contrato + pdvmoeda.valor.

        if pdvforma.crecod = 2 and (pdvmoeda.titpar = 0 or pdvmoeda.moecod <> pdvforma.modcod) 
        then do.
            vvalor_vista = vvalor_vista + pdvmoeda.valor.

            /**
            if vmoecod = ""
            then vmoecod = pdvmoeda.moecod.
            else if pdvmoeda.moecod <> vmoecod
            then vmoecod = "PDM".
            **/
            
        end.
    end. 
    if avail plani
    then do:
    do on error undo:
        find current pdvdoc exclusive. 
        assign
            pdvdoc.fincod = pdvforma.fincod.
            pdvdoc.crecod = pdvforma.crecod.
            pdvdoc.contnum = pdvforma.contnum.

        find current plani exclusive no-error.
            
        if avail plani
        then do:
            /* Deposito CP */
            find first contCP where contCP.etbcod = plani.etbcod and
                                    contCP.placod = plani.placod and
                                    contCP.contnum = ?
                        exclusive no-error.
            if avail contCP
            then do:
                contCP.contnum = int(pdvdoc.contnum).
            end.     
                                     
            plani.pedcod   = pdvdoc.fincod . 
            plani.crecod   = pdvdoc.crecod.
        
            if pdvdoc.crecod = 2  
            then do: 
                find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock.        
                plani.modcod = contrato.modcod. 
                create contnf.
                assign
                    contnf.contnum = int(pdvdoc.contnum)
                    contnf.etbcod  = plani.etbcod
                    contnf.placod  = plani.placod
                    contnf.notanum = plani.numero
                    contnf.notaser = plani.serie.
            
            end.    
            else plani.modcod = "VVI".
            find current plani  no-lock.
        end.
        
        find current pdvdoc no-lock.
    end.
    end. 
   
    message "RECEBIMENTOS" pdvforma.crecod "PLANI=" avail plani "CONTRATO" pdvforma.contnum "VALOR" vvalor_contrato "ENTRADA" vvalor_vista
        .

    if pdvforma.crecod = 2
    then do on error undo:
        
        if vvalor_vista > 0
        then do: 
            
            find contrato where contrato.contnum = int(pdvforma.contnum) no-lock.        

            find titulo where
                    titulo.empcod   = 19 and
                    titulo.titnat   = no and
                    titulo.modcod   = contrato.modcod and
                    titulo.etbcod   = contrato.etbcod and
                    titulo.clifor   = contrato.clicod and
                    titulo.titnum   = string(contrato.contnum) and
                    titulo.titpar   = 0 and
                    titulo.titdtemi = contrato.dtinicial
                    no-error.

            if not avail titulo
            then do:
                /* Cria 1 titulo VVI PAGO (Padrao Lebes) */                 
                create titulo. 
                titulo.datexp = today.
                titulo.contnum      = contrato.contnum.
                assign  
                    titulo.empcod   = 19
                    titulo.titnat   = no
                    titulo.modcod   = contrato.modcod 
                    titulo.etbcod   = contrato.etbcod 
                    titulo.clifor   = contrato.clicod
                    titulo.titnum   = string(contrato.contnum) 
                    titulo.titpar   = 0
                    titulo.titdtemi = contrato.dtinicial.
            end.            
            assign
                titulo.moecod   = "PDM"
                titulo.titvlcob = vvalor_vista
                titulo.titdtpag = titulo.titdtemi
                titulo.etbcobra = pdvmov.etbcod
                titulo.titvlpag = titulo.titvlcob
                titulo.titsit   = "PAG"
                titulo.cxacod   = cmon.cxacod
                titulo.cxmdata  = pdvmov.datamov
                titulo.cxmhora  = string(pdvmov.horamov)
                titulo.titdtven = titulo.titdtemi.

                
            /* Le os pdvmoeda e cria TITPAG */ 
            for each pdvmoeda of pdvmov where pdvmoeda.moecod <> "CRE" NO-LOCK.
                /** cria titpag padrao Lebes **/
                find first titpag where 
                          titpag.empcod = titulo.empcod and
                          titpag.titnat = titulo.titnat and
                          titpag.modcod = titulo.modcod and
                          titpag.etbcod = titulo.etbcod and
                          titpag.clifor = titulo.clifor and
                          titpag.titnum = titulo.titnum and
                          titpag.titpar = titulo.titpar and
                          titpag.cxacod = titulo.cxacod and
                          titpag.cxmdata = titulo.cxmdata and
                          titpag.moecod = pdvmoeda.moecod
                          no-error.
                if not avail titpag
                then do:          
                    create titpag.
                    assign
                        titpag.empcod = titulo.empcod
                        titpag.titnat = titulo.titnat
                        titpag.modcod = titulo.modcod
                        titpag.etbcod = titulo.etbcod
                        titpag.clifor = titulo.clifor
                        titpag.titnum = titulo.titnum
                        titpag.titpar = titulo.titpar
                        titpag.cxacod = titulo.cxacod
                        titpag.cxmdata = titulo.cxmdata
                        titpag.moecod = pdvmoeda.moecod
                        titpag.titobs[3] = "P2K|Seq=" + string(pdvmov.sequencia).
                        /* #2 Juros Cartao */ 
                end.
                titpag.titvlpag = titpag.titvlpag + pdvmoeda.valor.            
            end.    
        end.
   end. 
