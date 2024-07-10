/*
#1 TP 24965306 - 03.07.2018 - Ricardo
*/
def input parameter par-dtrec as date.
/*#1 disable triggers for load of com.estoq.*/

find DtRecebimento where DtRecebimento.dtreceb = par-dtrec no-lock.

FUNCTION data_itim return date
    ( input p-data as char).
    def var data_itim as date.
    data_itim = ?.
    data_itim = date(
                int(substr(p-data,3,2)), 
                int(substr(p-data,1,2)), 
                int(substr(p-data,5,4))
                ) no-error.
    return data_itim.
end FUNCTION.

def var vsysdata as char.
def var cus like estoq.estcusto.
def var vcusto like estoq.estcusto.
def var ven like estoq.estvenda.
def var vpreco like estoq.estVENDA.
def var vtime as int. 
def var vmenpro like admprog.menpro.

vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").

vtime = time.

def temp-table tt-810 no-undo
        field TRAN_TYPE   as char format "x(1)"
        field APPROVED_DATE   as char format "x(16)"
        field EFFECTIVE_DATE  as char format "x(16)"
        field DUE_DATE    as char format "x(16)"
        field PRICE_KEY   as dec  format ">>>>>>>>>>>>>>>>>>>>>9"
        field SKU_ID  as char format "x(25)"
        field STORE_ID    as char format "x(10)"
        field RETAIL_PRICE    as dec format "->>>>>>>>>>>>>>>9999"
        field RETAIL_PRICE_INST   as dec format "->>>>>>>>>>>>>>>9999"
        field RETAIL_PRICE_PLAN   as char format "x(25)"
        field PUBLISH_PRICE   as dec format "->>>>>>>>>>>>>>>9999"
        field OFFER_ID    as char format "x(32)"
        field ORIGIN_ID   as char format "x(12)"
        field PRICE_SYSTEM_ID as char format "x(25)"
        field PRICE_TYPE  as char format "x(1)"
        field RECORD_STATUS   as char format "x(1)"
        field CREATE_USER_ID  as char format "x(25)"
        field CREATE_DATETIME as char format "x(16)"
        field LAST_UPDATE_USER_ID as char format "x(25)"
        field LAST_UPDATE_DATETIME    as char format "x(16)"
        field data_exportacao as date

        index xxx is primary unique  
                        EFFECTIVE_DATE
                        APPROVED_DATE
                        SKU_id
                        STORE_id  
                        TRAN_TYPE  
                        OFFER_id  
                        PRICE_TYPE.                        

for each prof_1701 of DtRecebimento 
                   where Prof_1701.dtintegracao = ? and
                         Prof_1701.marca.
    /* preco regular => grava preco de venda (estoq.estatual)   */ 
    if (prof_1701.PRICE_TYPE = "R" and prof_1701.OFFER_ID = "") or
       (prof_1701.PRICE_TYPE = "C" and prof_1701.OFFER_ID <> "")
    then do.  
        if data_itim(prof_1701.EFFECTIVE_DATE) < today - 2
        then do.
            dtintegracao     = today.
            hrintegra        = time.
            next.
        end.    
        find estoq where estoq.etbcod = int(store_id) and
                         estoq.procod = int(PRODUCT_ID)
                         no-error.        
        if not avail estoq 
        then next.
        cus = estoq.estcusto. 
        ven = estoq.estvenda.   
        assign estoq.datexp    = today
               estoq.estvenda  = dec(APPROVED_PRICE).
        /* gravar aux-estoq com o PRICE_TYPE */
        find aux_estoq where aux_estoq.etbcod      = estoq.etbcod and
                             aux_estoq.procod      = estoq.procod and
                             aux_estoq.Nome_Campo  = "PRICE_TYPE"
                             no-error.
        if not avail aux_estoq
        then create aux_estoq.
        ASSIGN aux_estoq.etbcod      = estoq.etbcod 
               aux_estoq.procod      = estoq.procod 
               aux_estoq.Nome_Campo  = "PRICE_TYPE"
               aux_estoq.Valor_Campo = PRICE_TYPE
               aux_estoq.datexp      = today.
               aux_estoq.Tipo_Campo  = "CHAR".
        vcusto = estoq.estcusto.
        vpreco = estoq.estvenda.
        /* hispre admcom */
        do:
            vmenpro = string(year(today),"9999") +
                                    string(month(today),"99")  +
                                    string(day(today),"99") +
                                    string(estoq.procod,"999999999") +
                                    string(time).

            find admprog where admprog.menpro = vmenpro no-error.
            if not avail admprog
            then do:     
                create admprog.
                admprog.menpro = vmenpro.
            end.
            find func where func.etbcod = 999 and
                            func.funcod = 234 no-lock no-error.
            admprog.progtipo = string(string(estoq.procod,"999999") + " " +
                                      string(func.funnom,"x(10)") + " " +
                                      string(today) + 
                                      " CUSTO " + string(cus,">,>>9.99") +  
                                      "/" + string(vcusto,">,>>9.99") + 
                                      "   VENDA " + string(ven,">,>>9.99") +
                                      "/" + string(vpreco,">,>>9.99"),"x(78)").

            find hispre where hispre.procod   = estoq.procod
                          and hispre.dtalt    = today
                          and hispre.hora-inc = vtime
                          and hispre.funcod   = func.funcod no-error.
            if not avail hispre
            then do:
                create hispre.
                assign hispre.procod       = estoq.procod
                       hispre.dtalt        = today
                       hispre.hora-inc     = vtime
                       hispre.funcod       = func.funcod
                       hispre.estcusto-ant = cus
                       hispre.estcusto-nov = vcusto
                       hispre.estvenda-ant = ven
                       hispre.estvenda-nov = vpreco.
            end.
        end.
        /*****************/
        find precoHrg where 
             precoHrg.Etbcod  = estoq.etbcod and 
             precoHrg.procod  = estoq.procod and 
             precoHrg.DatIVig = data_itim(prof_1701.EFFECTIVE_DATE)
                            no-error.
        if not avail precoHrg
        then create PrecoHrg.
        ASSIGN precoHrg.Etbcod     = estoq.etbcod               .
               precoHrg.procod     = estoq.procod               .
               precoHrg.PrVenda    = estoq.estvenda             .
               precoHrg.DatIVig    = data_itim(prof_1701.EFFECTIVE_DATE)  .
               precoHrg.SitPrecoRg = prof_1701.PRICE_TYPE.
               precoHrg.PRICE_TYPE = prof_1701.PRICE_TYPE.
               precoHrg.MotivoSug  = prof_1701.OFFER_ID.
               precoHrg.dtexp      = today                      .
               precoHrg.FinCod     = 0                          .
               precoHrg.FunCod     = 0                          .
               precoHrg.data       = today                      .
               precoHrg.hora       = time                       .
               precoHrg.DatFVig    = data_itim(DUE_DATE)        .
               precoHrg.EFFECTIVE_DATE = prof_1701.EFFECTIVE_DATE.
               precohrg.APPROVED_DATE  = prof_1701.APPROVED_DATE.
               precohrg.PRICE_KEY  = prof_1701.PRICE_KEY
               .
        dtintegracao     = today.
        hrintegra        = time.      
        /********************
        estoq.dtaltpreco = today /*data_itim(CREATE_DATETIME)*/ no-error.
        if estoq.dtaltpreco = ? then estoq.dtaltpreco = today.
        *********************/
        /* quando vem do Profimetrics, não é desta forma */ 
        estoq.dtaltpreco = ?.
        
        find produ of estoq no-lock.
        /***hisprpro*/
            find hisprpro where 
                    hisprpro.procod = estoq.procod and
                    hisprpro.etbcod = estoq.etbcod and
                    hisprpro.Data_inicio = data_itim(prof_1701.EFFECTIVE_DATE)
                    no-error.
            if not avail hisprpro
            then create hisprpro.
            ASSIGN 
               hisprpro.preco_tipo = prof_1701.PRICE_TYPE
               hisprpro.etbcod     = estoq.etbcod
               hisprpro.procod     = estoq.procod
               hisprpro.data_inicio = data_itim(prof_1701.EFFECTIVE_DATE)
               hisprpro.data_fim    = data_itim(DUE_DATE)
               hisprpro.preco_valor = dec(APPROVED_PRICE)
               hisprpro.OFFER_ID   = prof_1701.OFFER_ID
               /*
               hisprpro.preco_plano  = int(prof_1763.PLAN_ID)
               hisprpro.preco_parcela = dec(prof_1720.PROMO_PRICE_INST)
               */
               hisprpro.PRICE_KEY  = prof_1701.PRICE_KEY
               hisprpro.data_inclu = today
               hisprpro.hora_inclu = time .
        /***/
        
        
        /* cria 810 para enviar ao profimetrics */
        create tt-810. 
        assign      
                tt-810.TRAN_TYPE          = "C".
         /* tt-810.APPROVED_DATE      = string(estoq.DtAltPreco,"99999999"). */
                tt-810.APPROVED_DATE      = prof_1701.APPROVED_DATE.
                
         /* tt-810.EFFECTIVE_DATE     = string(estoq.DtAltPreco,"99999999"). */
                tt-810.EFFECTIVE_DATE     = prof_1701.EFFECTIVE_DATE.
                
                tt-810.DUE_DATE            = prof_1701.DUE_DATE.
                tt-810.PRICE_KEY           = dec(prof_1701.PRICE_KEY).
                tt-810.SKU_ID              = string(estoq.procod).
                tt-810.STORE_ID            = string(estoq.etbcod).
                tt-810.RETAIL_PRICE        = estoq.estvenda * 10000.
                tt-810.RETAIL_PRICE_INST   = 0.
                tt-810.RETAIL_PRICE_PLAN   = (if produ.catcod = 31
                                       then "87"
                                       else "90")
                                       /*string(estoq.tabcod)*/     .
                tt-810.PUBLISH_PRICE       = tt-810.RETAIL_PRICE_INST  .
                                /* em 04/04 alterado para ir o mesmo           ~                                      RETAIL_PRICE_INST
                                estoq.estproper * 10000.
                                */
                tt-810.OFFER_ID            = prof_1701.OFFER_ID.
                tt-810.ORIGIN_ID           = "LEBES"  .
                tt-810.PRICE_SYSTEM_ID     = "IPO"  .
                tt-810.PRICE_TYPE          = prof_1701.PRICE_TYPE   .
                tt-810.RECORD_STATUS       = "A"   .
                tt-810.CREATE_USER_ID           = "ADMCOM"           .
                tt-810.CREATE_DATETIME          = vsysdata           .
                tt-810.LAST_UPDATE_USER_ID      = "ADMCOM"           .
                tt-810.LAST_UPDATE_DATETIME     = vsysdata           .
        /***********/
        find prof810 where prof810.EFFECTIVE_DATE = tt-810.EFFECTIVE_DATE and
                           prof810.APPROVED_DATE  = tt-810.APPROVED_DATE  and
                           prof810.SKU_id         = tt-810.SKU_id         and
                           prof810.STORE_id       = tt-810.STORE_id       and
                           prof810.TRAN_TYPE      = tt-810.TRAN_TYPE      and
                           prof810.OFFER_id       = tt-810.OFFER_id       and
                           prof810.PRICE_TYPE     = tt-810.PRICE_TYPE     
                           no-error.
        if not avail prof810
        then create prof810.
        buffer-copy tt-810 except data_exportacao to prof810.
        prof810.data_exportacao = ?.   
        prof810.retornar = yes. 
        /******************************************/
        next.
    end.
    
    def var cria-ctpromoc as log.
    
    if prof_1701.PRICE_TYPE = "P" and 
       prof_1701.OFFER_ID   <> ""
    then do.
        /*
        cria-ctpromoc = yes.
        find first prof_1703 of prof_1701 no-lock no-error.
        if avail prof_1703 and prof_1703.tipo_oferta_admcom = "39"
        then do.
            cria-ctpromoc = no.
        end.
        */
        cria-ctpromoc = no.
        find first prof_1703 of prof_1701 no-lock no-error.
        if avail prof_1703 and prof_1703.OFFER_TYPE = "NON_PRICE"
        then cria-ctpromoc = yes.
    end.
    
    /* estoq -> dados de promocao */
    if cria-ctpromoc  = no  
    then do. 
        find first prof_1703 of prof_1701 no-lock. 
        find first prof_1720 of prof_1703 where
                        prof_1720.PROD_ID   = prof_1701.PRODUCT_ID and
                        prof_1720.STORE_ID  = prof_1701.STORE_ID no-lock
                                                                 no-error.
        find first prof_1763 of prof_1703 where
                        prof_1763.REC_PLAN_FAG = "Y"
                        no-lock no-error.
        if avail prof_1720 and 
           avail prof_1763 
        then do.
            for each ctpromoc where ctpromoc.OFFER_ID = prof_1703.OFFER_ID.
                ctpromoc.situacao = "C".
            end.            
            find precoPromoc where 
                    precoPromoc.procod = int(      prof_1720.PROD_ID) and
                    precoPromoc.etbcod = int(      prof_1720.STORE_ID)   and
                    precoPromoc.DtIVig = data_itim(prof_1703.offer_start_date)
                    no-error.
            if not avail precoPromoc
            then create precoPromoc.
            ASSIGN 
               precoPromoc.etbcod     = int(prof_1720.STORE_ID)             .
               precoPromoc.procod     = int(prof_1720.PROD_ID)      .
               precoPromoc.DtIVig     = data_itim(prof_1703.offer_start_date).
               precoPromoc.DtFVig     = data_itim(prof_1703.offer_end_date).
               precoPromoc.perc       = 0                        .
               precoPromoc.PrPromocao = dec(prof_1720.PROMO_PRICE)   .
               precopromoc.OFFER_ID   = prof_1720.OFFER_ID.
               precoPromoc.protdc     = 1                        .
               precoPromoc.funcod     = 0                        .
               precoPromoc.Plano      = int(prof_1763.PLAN_ID)   .
               precoPromoc.PrParcelas = dec(prof_1720.PROMO_PRICE_INST)      .
               precoPromoc.PRICE_KEY  = prof_1701.PRICE_KEY       .
               precopromoc.data       = today                    .
               precopromoc.hora       = time .
            find estoq where estoq.etbcod = int(prof_1720.STORE_ID)
                         and estoq.procod = int(prof_1720.PROD_ID)
                             no-error.
            if not avail estoq
            then do.
                create estoq.
                estoq.etbcod = int(prof_1720.STORE_ID).
                estoq.procod = int(prof_1720.PROD_ID).
            end. 
            estoq.datexp        = today. 
            estoq.estproper     = dec(prof_1720.PROMO_PRICE). 
                                                          /* promocao */
            estoq.estbaldat     = data_itim(prof_1703.offer_start_date).
                                                          /* inicio vigencia */ 
            estoq.estprodat     = data_itim(prof_1703.offer_end_date).   
                                                          /* fim vigencia */
            estoq.estmin        = dec(prof_1720.PROMO_PRICE_INST).    
                                                          /* parcelas */
            estoq.tabcod        = int(prof_1763.PLAN_ID). /* plano */
            estoq.dtaltpromoc = ?.  

            /***** HisPrPro 
            find hisprpro where 
                    hisprpro.preco_tipo = "PROMOCAO" and
                    hisprpro.procod = int(      prof_1720.PROD_ID) and
                    hisprpro.etbcod = int(      prof_1720.STORE_ID)   and
                    hisprpro.Data_inicio = 
                                    data_itim(prof_1703.offer_start_date) and
                    hisprpro.data_fim = data_itim(prof_1703.offer_end_date)
                    no-error.
            if not avail hisprpro
            then create hisprpro.
            ASSIGN 
               hisprpro.preco_tipo = "PROMOCAO"
               hisprpro.etbcod     = int(prof_1720.STORE_ID)
               hisprpro.procod     = int(prof_1720.PROD_ID)
               hisprpro.data_inicio = data_itim(prof_1703.offer_start_date)
               hisprpro.data_fim     = data_itim(prof_1703.offer_end_date)
               hisprpro.preco_valor = dec(prof_1720.PROMO_PRICE)
               hisprpro.OFFER_ID   = prof_1720.OFFER_ID
               hisprpro.preco_plano  = int(prof_1763.PLAN_ID)
               hisprpro.preco_parcela = dec(prof_1720.PROMO_PRICE_INST)
               hisprpro.PRICE_KEY  = prof_1701.PRICE_KEY
               hisprpro.data_inclu = today
               hisprpro.hora_inclu = time .
             
            ****/
            /* cria 810 para enviar ao profimetrics */
            create tt-810. 
            assign      
                tt-810.TRAN_TYPE         = "C".
                tt-810.APPROVED_DATE     = prof_1701.APPROVED_DATE.
                tt-810.EFFECTIVE_DATE    = prof_1701.EFFECTIVE_DATE.
                tt-810.DUE_DATE          = prof_1701.DUE_DATE.
                tt-810.PRICE_KEY         = dec(prof_1701.PRICE_KEY).
                tt-810.SKU_ID            = prof_1701.PRODUCT_ID.
                tt-810.STORE_ID          = prof_1701.STORE_ID.
                tt-810.RETAIL_PRICE      = dec(APPROVED_PRICE) * 10000.
                tt-810.RETAIL_PRICE_INST = dec(APPROVED_PRICE_INST) * 10000.
                tt-810.RETAIL_PRICE_PLAN = APPROVED_PRICE_PLAN.
                tt-810.PUBLISH_PRICE     = dec(prof_1701.PUBLISH_PRICE) * 10000.
                tt-810.OFFER_ID          = prof_1701.OFFER_ID        .
                tt-810.ORIGIN_ID         = "LEBES"  .
                tt-810.PRICE_SYSTEM_ID   = "IPO"  .
                tt-810.PRICE_TYPE        = prof_1701.PRICE_TYPE .
                tt-810.RECORD_STATUS     = "A"   .
                tt-810.CREATE_USER_ID    = "ADMCOM"           .
                tt-810.CREATE_DATETIME   = vsysdata           .
                tt-810.LAST_UPDATE_USER_ID  = "ADMCOM"           .
                tt-810.LAST_UPDATE_DATETIME = vsysdata           .
            /***********/
            find prof810 where 
                        prof810.EFFECTIVE_DATE = tt-810.EFFECTIVE_DATE and
                           prof810.APPROVED_DATE  = tt-810.APPROVED_DATE  and
                           prof810.SKU_id         = tt-810.SKU_id         and
                           prof810.STORE_id       = tt-810.STORE_id       and
                           prof810.TRAN_TYPE      = tt-810.TRAN_TYPE      and
                           prof810.OFFER_id       = tt-810.OFFER_id       and
                           prof810.PRICE_TYPE     = tt-810.PRICE_TYPE     
                           no-error.
            if not avail prof810
            then create prof810.
            buffer-copy tt-810 except data_exportacao to prof810.
            prof810.data_exportacao = ?.   
            prof810.retornar = yes. 
            /******************************************/
            prof_1701.dtintegracao = today.
            prof_1701.hrintegra = time.
        end.
                
    end.
    
    /* ctpromoc                                */
    if cria-ctpromoc
    then do. 
        def var cria as log.
        cria = no.
        /* verificar ctpromoc e liberar */
        find first ctpromoc  where
                    ctpromoc.OFFER_ID = prof_1701.OFFER_ID and
                    ctpromoc.linha = 0 
                    no-error.        
        if avail ctpromoc
        then do.
           run ativa_ctpromoc.
        end.
        if cria
        then do.
            /*
            create precoPromoc.
            ASSIGN 
               precoPromoc.etbcod     = int(prof_1701.STORE_ID)             .
               precoPromoc.procod     = int(prof_1701.PRODUCT_ID)      .
               precoPromoc.DtIVig     = data_itim(prof_1701.EFFECTIVE_DATE).
               precoPromoc.DtFVig     = data_itim(prof_1701.DUE_DATE).
               precoPromoc.perc       = 0                        .
               precoPromoc.PrPromocao = dec(APPROVED_PRICE)   .
               precoPromoc.protdc     = 1                        .
               precoPromoc.funcod     = 0                        .
               precoPromoc.Plano      = int(prof_1701.APPROVED_PRICE_PLAN)   .
               precoPromoc.PrParcelas = dec(prof_1701.PUBLISH_PRICE)      .
               precoPromoc.PRICE_KEY  = prof_1701.PRICE_KEY       .
               precopromoc.data       = today                    .
               precopromoc.hora       = time .
            */
            /* cria 810 para enviar ao profimetrics */
            create tt-810. 
            assign      
                tt-810.TRAN_TYPE         = "C".
                tt-810.APPROVED_DATE     = prof_1701.APPROVED_DATE.
                tt-810.EFFECTIVE_DATE    = prof_1701.EFFECTIVE_DATE.
                tt-810.DUE_DATE          = prof_1701.DUE_DATE.
                tt-810.PRICE_KEY         = dec(prof_1701.PRICE_KEY).
                tt-810.SKU_ID            = prof_1701.PRODUCT_ID.
                tt-810.STORE_ID          = prof_1701.STORE_ID.
                tt-810.RETAIL_PRICE      = dec(APPROVED_PRICE) * 10000.
                tt-810.RETAIL_PRICE_INST = dec(APPROVED_PRICE_INST) * 10000.
                tt-810.RETAIL_PRICE_PLAN = APPROVED_PRICE_PLAN.
                tt-810.PUBLISH_PRICE     = dec(prof_1701.PUBLISH_PRICE) * 10000.
                tt-810.OFFER_ID          = prof_1701.OFFER_ID        .
                tt-810.ORIGIN_ID         = "LEBES"  .
                tt-810.PRICE_SYSTEM_ID   = "IPO"  .
                tt-810.PRICE_TYPE        = prof_1701.PRICE_TYPE .
                tt-810.RECORD_STATUS     = "A"   .
                tt-810.CREATE_USER_ID    = "ADMCOM"           .
                tt-810.CREATE_DATETIME   = vsysdata           .
                tt-810.LAST_UPDATE_USER_ID  = "ADMCOM"           .
                tt-810.LAST_UPDATE_DATETIME = vsysdata           .
            /***********/
            find prof810 where 
                        prof810.EFFECTIVE_DATE = tt-810.EFFECTIVE_DATE and
                           prof810.APPROVED_DATE  = tt-810.APPROVED_DATE  and
                           prof810.SKU_id         = tt-810.SKU_id         and
                           prof810.STORE_id       = tt-810.STORE_id       and
                           prof810.TRAN_TYPE      = tt-810.TRAN_TYPE      and
                           prof810.OFFER_id       = tt-810.OFFER_id       and
                           prof810.PRICE_TYPE     = tt-810.PRICE_TYPE     
                           no-error.
            if not avail prof810
            then create prof810.
            buffer-copy tt-810 except data_exportacao to prof810.
            prof810.data_exportacao = ?.   
            prof810.retornar = yes. 
            /******************************************/
            prof_1701.dtintegracao = today.
            prof_1701.hrintegra = time.
        end.
    end.    
end.


def buffer fctpromoc for ctpromoc.
def buffer pctpromoc for ctpromoc.

procedure ativa_ctpromoc.           
                     ctpromoc.situacao = "L".        
                     cria = yes.
                     if (ctpromoc.promocod = 20 or
                         ctpromoc.promocod = 22)
                     then do.    
                            for each pctpromoc where
                                 pctpromoc.sequencia = ctpromoc.sequencia and
                                 pctpromoc.linha > 0 and
                                 pctpromoc.procod > 0
                                 no-lock:
                                find first fctpromoc where
                                   fctpromoc.sequencia = ctpromoc.sequencia and
                                   fctpromoc.linha > 0 and
                                   fctpromoc.etbcod > 0 and
                                   fctpromoc.situacao <> "I" and
                                   fctpromoc.situacao <> "E"
                                   no-lock no-error.
                                if not avail fctpromoc
                                then do:   
                                    for each estab no-lock:
                                        find first fctpromoc where
                                 fctpromoc.sequencia = ctpromoc.sequencia and
                                 fctpromoc.linha > 0 and
                                 fctpromoc.etbcod = estab.etbcod and
                                 fctpromoc.situacao <> "E"
                                 no-lock no-error.
                                        if avail fctpromoc then next.
 
                                    run /admcom/progr/itim/cria-hispre_itim.p(
                                        input estab.etbcod, 
                                        input pctpromoc.procod,
                                        input 0,
                                        input pctpromoc.precosugerido,
                                        input 0, input time).
                                        end.
                                end.
                                else
                                for each fctpromoc where
                                   fctpromoc.sequencia = ctpromoc.sequencia and
                                   fctpromoc.linha > 0 and
                                   fctpromoc.etbcod > 0 and
                                   fctpromoc.situacao <> "I" and
                                   fctpromoc.situacao <> "E"
                                   no-lock :
                                    run /admcom/progr/itim/cria-hispre_itim.p(
                                        input fctpromoc.etbcod,
                                        input pctpromoc.procod,
                                        input 0,
                                        input pctpromoc.precosugerido,
                                        input 0, input time).
                                end.
 
                            end.
                            ctpromoc.situacao = "L".        
                            cria = yes.

                     end.


end procedure.
