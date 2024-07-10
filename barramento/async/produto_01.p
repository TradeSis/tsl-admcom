/*PRPK - helio 21042022 - nova tabela */

/* helio 12/11/2021 novos campos fase 2 */

DEFINE INPUT  PARAMETER lcJsonEntrada      AS LONGCHAR.
def    output param     vok as char no-undo.
vok = "".

DEFINE var lcJsonsaida      AS LONGCHAR.

{/admcom/barramento/functions.i}

{/admcom/barramento/async/produto_01.i}

/* LE ENTRADA */
lokJSON = hprodutoEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").

/* helio 20112020 */
def temp-table ttcorcup no-undo
    field clacod    as int.
    
if search("/admcom/progr/corcup.txt") <> ?
then do:
    input from /admcom/progr/corcup.txt.     
    repeat.
        create ttcorcup.
        import ttcorcup.
    end.
    input close.
    for each ttcorcup where ttcorcup.clacod  = ? or ttcorcup.clacod = 0.
        delete ttcorcup.
    end.    
end.    

/* helio 20112020 */
def var poutros as char. /* helio 03/09/2021 */
/**
pause 1.
**def var vsaida as char.
find first ttproduto.        

vsaida = "./json/produto/" + trim(ttproduto.codigoProduto) + "_" + ttproduto.tipo + "_" 
                           + trim(ttproduto.ativo)  + "_" + string(time)
                           + "produto.json".


**hprodutoEntrada:WRITE-JSON("FILE",vsaida, true).
**/

def buffer bcaract for caract.
def buffer bsubcaract for subcaract.

for each ttproduto.

    /*
    field tipo as char  
    field descricaoTipo as char  
    field codigoFabricante as char
    field descricaoFabricante as char  
    field descricaoFornecedor as char  
    field tipoEan as char
    */
    
    poutros = "".
    
    find produ where produ.procod = int(ttproduto.codigoProduto) exclusive no-wait no-error.
    if not avail produ
    then do:
        if locked produ
        then return.
        create produ.     
        produ.procod = int(ttproduto.codigoProduto).
    end.  

    produ.tipoSAP = ttproduto.tipo.
    
    if produ.tipoSAP = "SERV"
    then produ.proipiper = 98.
    
    produ.datexp = today.
    
    produ.prodtcad = aaaa-mm-dd_todate(ttproduto.dataCadastro).

    produ.proseq = if ttproduto.ativo = "true"
                   then 0
                   else 99. /*26112020 helio estava 98 */

    produ.itecod = produ.procod. 
    if ttproduto.descricaoCompleta <> ?
    then produ.pronom  = ttproduto.descricaoCompleta. 
    if ttproduto.descricaoCompacta <> ?
    then produ.pronomc = ttproduto.descricaoCompacta.
    produ.catcod = int(ttproduto.categoria). 
    produ.clacod = int(ttproduto.codMercadologico). 
    
    /* helio 20112020 - pesquisa mercadologico para setar corcod = "CUP" */
        find first ttcorcup where ttcorcup.clacod = produ.clacod no-lock no-error.
        if avail ttcorcup
        then do:
            produ.corcod = "CUP".
        end.
    /*helio 20112020*/ 
    
    produ.fabcod = int(ttproduto.codigoFornecedor). 
    if ttproduto.descricaoFornecedor <> "" and ttproduto.descricaoFornecedor <> ?
    then do:
        poutros = poutros + "descricaoFornecedor#" + trim(ttproduto.descricaoFornecedor) + "|".
    end.
    
    /* fase ii - helio 11/11/2021 */
    if ttproduto.statusItem <> "" 
    then do:
        if ttproduto.statusItem <> ? /* helio 28/01/2022 */
        then  do:
            if ttproduto.statusItem = "DE"
            then  poutros = poutros + "statusItem#DESCONTINUADO" + "|".
            else  poutros = poutros + "statusItem#" + trim(ttproduto.statusItem) + "|".
        end.    
        else  poutros = poutros + "statusItem#" + "ATIVO" + "|".
        
    end.

    
    if produ.procod = 8011 or  /*- Troca Garantida 12 Meses.*/
       produ.procod = 8012 or  /*- Troca Garantida 24 Meses.*/
       produ.procod = 8013 or  /*- Garantia Estendida 12 Meses.*/
       produ.procod = 8014 or  /*- Garantia Estendida 24 Meses.*/
       produ.procod = 8015     /*- Roubo, Furto e Quebra 12 Meses.*/
    then do:
        /* produtos garantia não atualizar proindice */
    end.
    else do:
        produ.proindice = if trim(ttproduto.ean) = "SEM GTIN"
                          then "SEM GTIN " + string(produ.procod)
                          else trim(ttproduto.ean).  
    end. 
    if ttproduto.prazoFabricacao <> "" and ttproduto.prazoFabricacao <> ? /* helio 28/01/2022 ajuste nome do campo */
    then do: 
        poutros = poutros + "LEADTIME#" + trim(ttproduto.prazoFabricacao) + "|". /* mesmo nome para ir para a pv */
    end.    
    
    for each ttcomercial where ttcomercial.idpai =  ttproduto.id.

        if produ.catcod <> 41
        then do:
            produ.protam = string(true_tolog(paraMontagem),"Sim/Nao").
        end. 
           
        if true_tolog(pedidoEspecial)
        then produ.proipival = 1.
        else produ.proipival = 0.

        produ.ind_vex = true_tolog(vex)   .
        produ.descontinuado = true_tolog(ttcomercial.descontinuado)  no-error .
        
        
        def var vtempogar as int.
        
        vtempogar = int(tempoGarantia) no-error.
        if vtempogar = ? then vtempogar = 0.
        if vtempogar > 0
        then do: 
            find first produaux where produaux.procod     = produ.procod
                                  and produaux.nome_campo = "TempoGar"
                            exclusive no-wait no-error.
            if not avail produaux 
            then do:
                if not locked produaux
                then do:
                    create produaux.
                    produaux.procod = produ.procod.
                    produaux.nome_campo = "TempoGar".
                end.
            end. 
            produaux.valor_campo = tempoGarantia.
            produaux.exportar    = yes.
            produaux.datexp      = today. 
        end.
        
        def var vpack as int.
        
        vpack = int(pack) no-error.
        if vpack = ? then vpack = 0.
        if vpack > 0
        then do: 
            find first produaux where produaux.procod     = produ.procod
                                  and produaux.nome_campo = "pack"
                            exclusive no-wait no-error.
            if not avail produaux 
            then do:
                if not locked produaux
                then do:
                    create produaux.
                    produaux.procod = produ.procod.
                    produaux.nome_campo = "pack".
                end.
            end. 
            produaux.valor_campo = pack.
            produaux.exportar    = yes.
            produaux.datexp      = today. 
        end.
        /* helio 13/07/2021 PACK */
        else do:
            find first produaux where produaux.procod     = produ.procod
                                  and produaux.nome_campo = "pack"
                            exclusive no-wait no-error.
        
            if avail produaux
            then do:
                produaux.valor_campo = "".
                produaux.exportar    = yes.
                produaux.datexp      = today. 
            end.
        end.
        
        if ttcomercial.idServicoHubSeg <> "" and ttcomercial.idServicoHubSeg <> ?
        then do:
            /* medico na tela 042022 - helio */
            if ttcomercial.idServicoHubSeg begins "DOC24"
            then do:
                find medprodu where medprodu.procod = produ.procod exclusive no-wait no-error.
                if not avail medprodu
                then do:
                    if not locked medprodu
                    then do:
                        create medprodu.
                        medprodu.procod = produ.procod.
                    end.
                end.
                if avail medprodu
                then do:
                    medprodu.idmedico     = ttcomercial.idServicoHubSeg.
                    /*{1}.valorServico = {2}.valorServico atualizado em produtoloja*/
                    medprodu.IDPerfil     = 1.
                    medprodu.tipoServico  = "DOC24".
                end.
            end.
            else do:
                poutros = poutros + "IDSEGURO#" + trim(ttcomercial.idServicoHubSeg) + "|".
            end.
        end.
        
    end.
    def var vetccod like estac.etccod.
    for each ttcaracteristica where ttcaracteristica.idpai  =  ttproduto.id.
        /*
         field grupoCaracteristica as char 
         field shelfLife as char
        */ 
        /* 09.06.2020 depara de ADMCOM para SAP, para os codigos ate 6. */
        vetccod =      if int(ttcaracteristica.codigoEstacao) = 1000 then 1
                  else if int(ttcaracteristica.codigoEstacao) = 2000 then 2
                  else if int(ttcaracteristica.codigoEstacao) = 3000 then 3
                  else if int(ttcaracteristica.codigoEstacao) = 4000 then 4
                  else if int(ttcaracteristica.codigoEstacao) = 5000 then 5
                  else if int(ttcaracteristica.codigoEstacao) = 6000 then 6
                  else int(ttcaracteristica.codigoEstacao).
        
        produ.etccod    = vetccod.
        produ.temp-cod  = int(codigoTemporada).
        
        find first ttcaracteristicagenerica where ttcaracteristicagenerica.idpai = ttcaracteristica.id no-error.
        if avail ttcaracteristicagenerica
        then do:
            for each procaract where procaract.procod = produ.procod.
                delete procaract.
            end.    
        end.
        for each ttcaracteristicagenerica where ttcaracteristicagenerica.idpai = ttcaracteristica.id.
            /*
                field descricao as char 
                field valor as char
            */
            
            if ttcaracteristicagenerica.descricao = "TIPO_MIX" 
            then do:
                poutros = poutros + "TIPOMIX#" + trim(ttcaracteristicagenerica.valor) + "|".
            end.    
            
                       
            find first caract where caract.cardes = ttcaracteristicagenerica.descricao no-lock no-error.
            if not avail caract
            then do on error undo:
                find last bcaract no-lock no-error. 
                create caract.
                ASSIGN
                    caract.carcod = if avail bcaract then bcaract.carcod + 1 else 1.
                    caract.cardes = ttcaracteristicagenerica.descricao.
                    caract.dtcad  = today.
                    caract.dtexp  = today.
                    caract.ordem  = 0.
            end.
            find first subcaract where subcaract.carcod = caract.carcod and
                                       subcaract.subdes = ttcaracteristicagenerica.valor
                                       no-lock no-error.
            if not avail subcaract
            then do:
                find last bsubcaract no-lock no-error.
                create subcaract.
                ASSIGN 
                    subcaract.subcod = if avail bsubcaract then bsubcaract.subcod + 1 else 1.
                    subcaract.carcod = caract.carcod .
                    subcaract.subcar = subcaract.subcod.
                    subcaract.subdes = ttcaracteristicagenerica.valor.
                    subcaract.dtcad  = today.
                    subcaract.dtexp  = today.
            end.
            find first procaract where procaract.procod = produ.procod and
                                       procaract.subcod = subcaract.subcod
                                       no-lock no-error.
            if not avail procaract
            then do:
                create procaract.
                procaract.procod = produ.procod.
                procaract.subcod = subcaract.subcod.
            end.
                                                   
            
        end.
    end.            
    for each ttdimensoes of ttproduto.
        /*
        field volume as char 
        field alturaEmbalagem as char 
        field larguraEmbalagem as char 
        field comprimentoEmbalagem as char 
        field pesoEmbalagem as char 
        field alturaProduto as char 
        field larguraProduto as char 
        field comprimentoProduto as char 
        field pesoProduto as char 
        field pesoTotal as char 
        field tara as char 
        field pesoLiquido as char 
        */
    end.
    for each ttcontabil  where ttcontabil.idpai  =  ttproduto.id.

        /*
        field indGtin as char 
        field categoriaFiscal as char 
        field ncm as char 
        field codigoCest  as char
        */
        
        produ.codfis     = int(ttcontabil.ncm).
        
        find clafis      where clafis.codfis = produ.codfis no-error.
        if not avail clafis
        then do:
            create clafis.
            clafis.codfis       = produ.codfis.
            clafis.desfis       = ttcontabil.ncm.
        end.
            clafis.char1        = ttcontabil.codigoCest.
            clafis.datexp       = today.

    end.

    for each ttcomponentes where ttcomponentes.idpai =  ttproduto.id
        on error undo.
        /*
        field codigoProduto as char  
        field quantidade as char
        field permiteVendaAvulsa as char
        */
        if produ.tipoSAP = "PRPK" /* ajuste 19042022 porque estava sobrepondo os prpk do normal */
        then do:
            /* nada, alterado em 19042022 */
            find ProdAgPk where 
                prodagPk.ProAgrup = produ.procod and
                ProdAgPk.procod = int(ttcomponentes.codigoProduto) 
                exclusive no-wait no-error.        
            if not avail ProdAgPk
            then do:
                create ProdAgPk.
                prodagpk.ProAgr = produ.procod.
                prodagpk.procod = int(ttcomponentes.codigoProduto).
            end.      
            prodagpk.QtdVenda     = int(ttcomponentes.quantidade). 

        end.
        else do:
            find prodagrup where prodagrup.procod = int(ttcomponentes.codigoProduto) exclusive no-wait no-error.        
            if not avail prodagrup
            then do:
                create prodagrup.
                prodagrup.procod = int(ttcomponentes.codigoProduto).
            end.      
            prodagrup.ProAgr = produ.procod. 
            prodagrup.QtdVenda     = int(ttcomponentes.quantidade). 
            prodagrup.permiteVendaAvulsa = ttcomponentes.permiteVendaAvulsa = "true". 
        
            run /admcom/progr/geraindicegenerico.p (prodagrup.procod, poutros).
        
        end.
            
    end.    

    
    run /admcom/progr/geraindicegenerico.p (produ.procod, poutros).
    
end.    





