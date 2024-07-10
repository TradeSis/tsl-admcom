/*  itim                                                                      */
/*  itim/integra_1703.p                                                       
#1 TP 24965306 - 03.07.2018 - Ricardo
*/
/* HELIO 03/06/15*/
def var par-ctpromoc as recid.

/* #1 disable triggers for load of com.estoq.*/
def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").

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

def var vlinha as int.
def buffer bctpromoc for ctpromoc.
def buffer xctpromoc for ctpromoc.
def var par-sequencia like ctpromoc.sequencia.

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

def input parameter par-rec as recid.
find prof_1703 where recid(prof_1703) = par-rec no-lock.
if prof_1703.dtintegracao <> ?
then leave.

if prof_1703.OFFER_TYPE_ID <> "SIMPLE"
then 
    IF prof_1703.OFFER_TYPE_ID = "COMPLEX" and
       prof_1703.OFFER_TYPE = "MIX_MATCH"  
    then.
    else 
        IF prof_1703.OFFER_TYPE_ID = "COMPLEX" and
           prof_1703.OFFER_TYPE    = "MIX_MATCH_CHEAP"  and
          (prof_1703.GET_VAL_TYPE  = "FIXED_PRICE_BASE"     or
           prof_1703.GET_VAL_TYPE  = "FIXED_PRICE_TOTAL"    or
           prof_1703.GET_VAL_TYPE  = "PERCENTAGE"           or
           prof_1703.GET_VAL_TYPE  = "GIFT")
        then.
        else 
            IF prof_1703.OFFER_TYPE_ID = "COMPLEX" and
               prof_1703.OFFER_TYPE    = "MULTI_UNIT"
            then.
            else leave.

find prof_1703 where recid(prof_1703) = par-rec no-lock.
/* cabecalho da oferta /  promocao / ctpromoc */
do transaction.
    find first ctpromoc where ctpromoc.OFFER_ID = prof_1703.OFFER_ID and
                              ctpromoc.linha    = 0  
                              exclusive  no-error.
    if not avail ctpromoc
    then do.
        find last bctpromoc  where bctpromoc.linha = 0  
                no-lock no-error.
        create ctpromoc. 
        assign
        ctpromoc.sequencia = if avail bctpromoc
                             then bctpromoc.sequencia + 1 
                             else 1                           
        ctpromoc.linha     = 0.
        ctpromoc.OFFER_ID = prof_1703.OFFER_ID.                             
    end.
    ctpromoc.OFFER_ID = prof_1703.OFFER_ID.  
    par-sequencia = ctpromoc.sequencia.
    
    /* parte inicial do ctpromoc */
    ASSIGN
        ctpromoc.dtinicio              = data_itim(prof_1703.OFFER_START_DATE).
        ctpromoc.dtfim                 = data_itim(OFFER_END_DATE)       .
        ctpromoc.promocod                = int(TIPO_OFERTA_ADMCOM)          .
        ctpromoc.linha                   = 0                                .
        ctpromoc.fincod                  = ?. 
        ctpromoc.precosugerido           = 0   .
        ctpromoc.campodec2[1]            = dec(PREM_promotor_VAL) . 
        ctpromoc.campodec2[2]            = dec(PREM_promotor_PERC).
        ctpromoc.campolog1               = EXIBIR_MENSA = "Y".
        ctpromoc.defaultprevenda         = PRE_VENDA = "Y".
        ctpromoc.diasentrada             = int(DIAS_PARA_EN).
        ctpromoc.diasparcela             = int(DIAS_PARA_PR).
        ctpromoc.campodec2[4]            = int(INTERVALO_QTD_ATE).
        ctpromoc.campodec2[5]            = int(INTERVALO_QTD_DE).
        ctpromoc.campolog3               = INTERVALO_A_ = "Y".
        ctpromoc.campolog4               = PREM_UNITARI = "Y".
        ctpromoc.dtentrada               = data_itim(DATA_ENTRADA)   .
        ctpromoc.dataparcela             = data_itim(DATA_PRIMEIR)   .
        ctpromoc.descontovalor           = dec(DESCONTO_VALOR).
        ctpromoc.descontopercentual      = dec(DESCONTO_PERCENTUAL).
        
        /****
        ctpromoc.etbcod                  = {2}.etbcod
        ctpromoc.fincod                  = {2}.fincod
        ctpromoc.setcod                  = {2}.setcod
        ctpromoc.fabcod                  = {2}.fabcod
        ctpromoc.clacod                  = {2}.clacod
        ctpromoc.procod                  = {2}.procod
        ctpromoc.probrinde               = {2}.probrinde
        *****/
        ctpromoc.situacao                = "M"                              .
    
    assign
        ctpromoc.tipo                    = ""
        ctpromoc.arredonda               = 0
        ctpromoc.precoliberado           = LIBERAR_PRECO = "Y" .
    ASSIGN
        ctpromoc.campodec2[3]            = dec(INTERVALO_VAL_DE)    .
        ctpromoc.vendaacimade            = dec(INTERVALO_VAL_ate) .
        ctpromoc.perguntaprodutousado    = EXIGIR_PROD_USADO = "Y"       .
        ctpromoc.bonusparcela            = CRED_BONUS_PARCELA = "Y"        .
        ctpromoc.bonuspercentual         = dec(CRED_BONUS_PERC) /  1    .
        ctpromoc.bonusvalor              = dec(CRED_BONUS_VAL) / 1       .
        ctpromoc.cartaoparcela           = CRED_CARTAO_PARCELA = "Y"          .
        ctpromoc.cartaopercentual        = dec(CRED_CARTAO_PERC) / 1   .
        ctpromoc.cartaovalor             = dec(CRED_CARTAO_VAL)  / 1    .
        ctpromoc.geradespesa             = GERAR_DESPESA_FIN = "Y"       .
        ctpromoc.pctvendedor             = dec(PREM_VENDEDOR_PERC) / 1    .
        ctpromoc.pctgerente              = dec(PREM_GERENTE_PERC) / 1   .
        ctpromoc.pctsupervisor           = dec(PREM_SUPERVISOR_PERC) / 1 .
        ctpromoc.valvendedor             = dec(PREM_VENDEDOR_VAL) / 1     .
        ctpromoc.valgerente              = dec(PREM_GERENTE_VAL) / 1      .
        ctpromoc.valsupervisor           = dec(PREM_SUPERVISOR_VAL) / 1  .
        ctpromoc.recibo                  = EMITIR_REC_DESPESA = "Y"      .
        ctpromoc.datexp                  = today.
    if ctpromoc.geradespesa
    then do. 
        run forne-despesa.
    end.

    ASSIGN
        ctpromoc.datinclu                = data_itim(CREATE_DATETIME)
        ctpromoc.exportado               = no
        ctpromoc.campochar[1]            = MENSAGEM_NA_TELA.
    
    ASSIGN
        ctpromoc.descricao[1]            = OFFER_DESC.

    ASSIGN
        ctpromoc.liberavenda             = LIBERAR_PLANO = "Y"           .
        ctpromoc.OFFER_ID                = prof_1703.OFFER_ID.
    par-ctpromoc = recid(ctpromoc).
end. /* transaction */

    find ctpromoc where recid(ctpromoc) = par-ctpromoc no-lock. 

    for each prof_1763 where of prof_1703 no-lock.
        find last xctpromoc where xctpromoc.sequencia = ctpromoc.sequencia
                    use-index indx1 no-lock no-error.
        vlinha = xctpromoc.linha + 1.
        create bctpromoc.                                                 
        assign bctpromoc.promocod  = ctpromoc.promocod 
               bctpromoc.OFFER_ID = prof_1703.OFFER_ID 
               bctpromoc.sequencia = ctpromoc.sequencia 
               bctpromoc.linha     = vlinha 
               bctpromoc.fincod    = ? 
               bctpromoc.probrinde  = 0
               bctpromoc.situacao  = "A"
               bctpromoc.fincod    = int(PLAN_ID)
               bctpromoc.OFFER_ID                = prof_1703.OFFER_ID.
    end.
    do transaction.
        find prof_1703 where recid(prof_1703) = par-rec exclusive.
        prof_1703.dtintegracao = today.
    end.

/*
 - SIMPLE: Campanhas de Produto, deve-se ter em conta interface de Preços             Aprovados */
if prof_1703.OFFER_TYPE_ID = "SIMPLE"  /* remarcacoes de precos */
then do.
    do transaction.
        find ctpromoc where recid(ctpromoc) = par-ctpromoc exclusive.
        ctpromoc.campodec[1] = 0.
        ctpromoc.qtdvenda = 1.
    end.
    find ctpromoc where recid(ctpromoc) = par-ctpromoc no-lock.
            
    /* produtos */ 
    for each prof_1720 of prof_1703 where PROD_ID <> "" and
                                          PROD_LEVEL = "SKU"
                                          no-lock. 
        find first bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia and
                                   bctpromoc.procod    = int(PROD_ID)
                                no-lock   no-error.        
        if avail bctpromoc
        then next.        

        find last xctpromoc where xctpromoc.sequencia = ctpromoc.sequencia
                    use-index indx1 no-lock no-error.
        vlinha = xctpromoc.linha + 1.
        create bctpromoc. 
        buffer-copy ctpromoc except linha to bctpromoc . 
        bctpromoc.OFFER_ID = prof_1703.OFFER_ID.
        bctpromoc.linha = vlinha.
        bctpromoc.procod = int(PROD_ID).
        bctpromoc.precosugerido = dec(PROMO_PRICE).
        if prof_1703.OFFER_TYPE = "NON_PRICE"
        then bctpromoc.precosugerido = 0.
        bctpromoc.OFFER_ID                = prof_1703.OFFER_ID.
        bctpromoc.campodec[1]  = qty.
    end.    
    /* estabelecimentos */
    for each prof_1720 of prof_1703 where STORE_ID <> "" no-lock. 
        find first bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia and
                                   bctpromoc.etbcod    = int(STORE_ID)
                                   no-lock no-error.        
        if avail bctpromoc
        then next.        
        
        find last xctpromoc where xctpromoc.sequencia = ctpromoc.sequencia
                    use-index indx1 no-lock no-error.
        vlinha = xctpromoc.linha + 1.        
        create bctpromoc.  
        buffer-copy ctpromoc except linha to bctpromoc . 
        bctpromoc.OFFER_ID = prof_1703.OFFER_ID.
        bctpromoc.linha = vlinha.
        bctpromoc.etbcod = int(STORE_ID).
        bctpromoc.situacao = "A".
        bctpromoc.OFFER_ID                = prof_1703.OFFER_ID.
    end.    
    
    do transaction.
        find prof_1703 where recid(prof_1703) = par-rec exclusive.
        prof_1703.dtintegracao = today.
    end. 
    run retorna_1701_810.

end.

/*
    - COMPLEX:  Campanhas de Desconto, deve-se ter em conta 
                interfaces de Produtos associados à campanha
    - MIX_MATCH (Casada/Brinde): 
                Na Compra de <Condiçao de Leve> Ganhe <Condição de Ganhe>*/

IF prof_1703.OFFER_TYPE_ID = "COMPLEX" and
   prof_1703.OFFER_TYPE = "MIX_MATCH"  
then do.
    find first prof_1720 of prof_1703 where
                            prof_1720.VALUE_TYPE = "VALUE" and
                            prof_1720.LIST_TYPE  = "G"
                            no-lock no-error.                   
    if avail prof_1720
    then do.
        do transaction.
            find prof_1703 where recid(prof_1703) = par-rec.
            prof_1703.dtintegracao = today.
            find ctpromoc where recid(ctpromoc) = par-ctpromoc exclusive.
            ctpromoc.situacao = "ERR".
            prof_1703.ErroIntegra = "1703.OFFER_TYPE_ID = COMPLEX, " +
                                    "1703.OFFER_TYPE = MIX_MATCH, "  +
                                    "1720.VALUE_TYPE = VALUE, "       +
                                    "1720.LIST_TYPE  =  G".
        end.
        leave.
    end.
    
    find ctpromoc where recid(ctpromoc) = par-ctpromoc no-lock.

        /*  algumas regras
        para prof_1703.OFFER_TYPE = MIX_MATCH sempre utilizarao BUY_TYPE = ANY
        o "comprado" = BUY_QTY GET_TYPE = ANY Casado/brinde = GET_QTY 
        VALUE_TYPE = FIXED_VALUE
                    calculo: VALUE / Numero de parcelas / coeficiente 
        */            

    def var brinde as log.
    brinde = no.
    /* uma vez era assim, pois alguem disse 
    if GET_VAL_TYPE = "GIFT" or
       GET_VAL_TYPE = "PERCENTAGE" AND GET_VAL = "100"
    then brinde = yes.   */

    find first prof_1720 of prof_1703 where
                            prof_1720.VALUE_TYPE = "GIFT" and
                            prof_1720.LIST_TYPE  = "G"
                            no-lock no-error.                   
    if avail prof_1720
    then brinde = yes.
    else brinde = no.
    
    do transaction:
        find ctpromoc where recid(ctpromoc) = par-ctpromoc exclusive.
        ctpromoc.qtdvenda  = int(BUY_QTY) .        /* comprado        */
        ctpromoc.qtdbrinde = int(GET_QTY) .        /* Brinde          */
    end.

    find ctpromoc where recid(ctpromoc) = par-ctpromoc no-lock.
                        
    for each prof_1720 of prof_1703 where PROD_ID <> "" and
                                          PROD_LEVEL = "APP_LEVEL" and
                                          LIST_TYPE = "B" /* COMPRA */
                                          no-lock. 
        find first bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia and
                                   bctpromoc.clacod    = int(PROD_ID)
                                 no-lock  no-error.        
        if avail bctpromoc
        then next.        
        find last xctpromoc where xctpromoc.sequencia = ctpromoc.sequencia
                    use-index indx1 no-lock no-error.
        vlinha = xctpromoc.linha + 1.        
        create bctpromoc. 
        bctpromoc.sequencia = ctpromoc.sequencia.
        bctpromoc.linha = vlinha. 
        buffer-copy ctpromoc except linha sequencia to bctpromoc .  
        bctpromoc.OFFER_ID = prof_1703.OFFER_ID.
        bctpromoc.clacod = int(PROD_ID).
        bctpromoc.precosugerido = dec(PUBLISH_PRIC).
        if prof_1703.OFFER_TYPE = "NON_PRICE"
        then bctpromoc.precosugerido = 0. 
        bctpromoc.OFFER_ID                = prof_1703.OFFER_ID.
    end. 
    for each prof_1720 of prof_1703 where PROD_ID <> "" and
                                          PROD_LEVEL = "SKU" and
                                          LIST_TYPE = "B" /* COMPRA */
                                          no-lock. 
        find first bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia and
                                   bctpromoc.procod    = int(PROD_ID)
                                   no-lock no-error.        
        if avail bctpromoc
        then next.        
        find last xctpromoc where xctpromoc.sequencia = ctpromoc.sequencia
                    use-index indx1 no-lock no-error.
        vlinha = xctpromoc.linha + 1.        
        create bctpromoc. 
        bctpromoc.sequencia = ctpromoc.sequencia.
        bctpromoc.linha = vlinha. 
        buffer-copy ctpromoc except linha sequencia to bctpromoc .  
        bctpromoc.OFFER_ID = prof_1703.OFFER_ID.
        bctpromoc.procod = int(PROD_ID).
        bctpromoc.precosugerido = dec(PUBLISH_PRIC).
        if prof_1703.OFFER_TYPE = "NON_PRICE"
        then bctpromoc.precosugerido = 0.
        bctpromoc.OFFER_ID                = prof_1703.OFFER_ID.
    end.                                
    for each prof_1720 of prof_1703 where PROD_ID <> "" and
                                          PROD_LEVEL = "SKU" and
                                          LIST_TYPE = "G"  /* OFERTA */
                                          no-lock. 
        if brinde = no /* casadinha */
        then 
        find first bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia and
                                   bctpromoc.produtovendacasada = int(PROD_ID)
                               and bctpromoc.fincod = ?   
                                 no-lock  no-error.        
        else         /* brinde      */
        find first bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia and
                                   bctpromoc.probrinde = int(PROD_ID)
                               and bctpromoc.fincod = ?   
                                 no-lock  no-error.        
        if avail bctpromoc
        then next.        
        find last xctpromoc where xctpromoc.sequencia = ctpromoc.sequencia
                    use-index indx1 no-lock no-error.
        vlinha = xctpromoc.linha + 1.        
        create bctpromoc. 
        buffer-copy ctpromoc except linha to bctpromoc . 
        bctpromoc.OFFER_ID = prof_1703.OFFER_ID.
        bctpromoc.linha = vlinha.
        bctpromoc.OFFER_ID                = prof_1703.OFFER_ID.
        
        if brinde = no
        then do.
            assign bctpromoc.produtovendacasada = int(PROD_ID)
                   bctpromoc.tipo = "PRODUTO"
                    .
            if VALUE_TYPE = "PERCENTAGE"
            then do.
                bctpromoc.tipo = "PRODUTO=|PERCENTUAL=|".
                bctpromoc.valorprodutovendacasada = VALUEE.
            end.
            if VALUE_TYPE = "VALUE"
            then do.
                bctpromoc.tipo = "PRODUTO=|VALOR=|".
                bctpromoc.valorprodutovendacasada = VALUEE.
            end.
            if VALUE_TYPE = "FIXED_PRICE_BASE" or
               VALUE_TYPE = "FIXED_PRICE_TOTAL"
            then do.
                run preco-inicial (recid(bctpromoc) ).
            end.
        end.
        else do.
            find ctpromoc where recid(ctpromoc) = par-ctpromoc exclusive.
             assign bctpromoc.probrinde          = int(PROD_ID)
                     ctpromoc.campodec[1]        = 0
                     ctpromoc.campodec[1]        = 0
                     ctpromoc.qtdbrinde          = dec(qty)
                    .
            if VALUE_TYPE = "GIFT"
            then ctpromoc.qtdbrinde = dec(GET_QTY). 
        end.
        
        bctpromoc.fincod = ?.
        bctpromoc.precosugerido = dec(PUBLISH_PRIC).
        if prof_1703.OFFER_TYPE = "NON_PRICE"
        then bctpromoc.precosugerido = 0.
    end.    
    
    find ctpromoc where recid(ctpromoc) = par-ctpromoc no-lock.
    
    for each prof_1720 of prof_1703 where STORE_ID <> "" no-lock .
        find first bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia and
                                   bctpromoc.etbcod    = int(STORE_ID)
                               no-lock    no-error. 
        if avail bctpromoc
        then next.
        find last xctpromoc where xctpromoc.sequencia = ctpromoc.sequencia
                    use-index indx1 no-lock no-error.
        vlinha = xctpromoc.linha + 1.        
        create bctpromoc.  
        buffer-copy ctpromoc except linha to bctpromoc . 
        bctpromoc.linha = vlinha.
        bctpromoc.OFFER_ID = prof_1703.OFFER_ID.
        bctpromoc.etbcod = int(STORE_ID).
        bctpromoc.situacao = "A".
        bctpromoc.OFFER_ID                = prof_1703.OFFER_ID.
    end.    
    do transaction.
        find prof_1703 where recid(prof_1703) = par-rec exclusive.
        prof_1703.dtintegracao = today.
    end.    
end.
/*
- COMPLEX: Campanhas de Desconto, deve-se ter em conta interfaces de Produtos associados à campanha
- MIX_MATCH_CHEAP (Casada/Brinde (Mais Barato)): Satisfazendo as condiçoes de compre, ganhe um desconto no artigo mais barato
*/

/* tipo de desconto Preco Fixo Base alimenta casadinha 
    PLANO PARCELA 
*/

IF prof_1703.OFFER_TYPE_ID = "COMPLEX" and
   prof_1703.OFFER_TYPE    = "MIX_MATCH_CHEAP"  and
  (prof_1703.GET_VAL_TYPE  = "FIXED_PRICE_BASE"  or
   prof_1703.GET_VAL_TYPE  = "FIXED_PRICE_TOTAL" or
   prof_1703.GET_VAL_TYPE  = "PERCENTAGE"        or
   prof_1703.GET_VAL_TYPE  = "GIFT"               )
then do.
    do transaction:
        find ctpromoc where recid(ctpromoc) = par-ctpromoc exclusive.
        ctpromoc.qtdvenda    = int(BUY_QTY) .   /* comprado        */
        ctpromoc.qtdbrinde   = 1 .              /* Brinde          */
        ctpromoc.campodec[1] = 0.
    end.
    find ctpromoc where recid(ctpromoc) = par-ctpromoc no-lock.
    
    for each prof_1720 of prof_1703 where PROD_ID <> "" and
                                          PROD_LEVEL = "APP_LEVEL" and
                                          LIST_TYPE = "B" /* COMPRA */
                                          no-lock. 
        find first bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia and
                                   bctpromoc.clacod    = int(PROD_ID)
                                 no-lock  no-error.        
        if avail bctpromoc
        then next.        
        find last xctpromoc where xctpromoc.sequencia = ctpromoc.sequencia
                    use-index indx1 no-lock no-error.
        vlinha = xctpromoc.linha + 1.        
        create bctpromoc. 
        bctpromoc.sequencia = ctpromoc.sequencia.
        bctpromoc.linha = vlinha. 
        buffer-copy ctpromoc except linha sequencia to bctpromoc .  
        bctpromoc.OFFER_ID = prof_1703.OFFER_ID.
        bctpromoc.clacod = int(PROD_ID).
        bctpromoc.precosugerido = 0.
        bctpromoc.OFFER_ID                = prof_1703.OFFER_ID.
    end. 
    for each prof_1720 of prof_1703 where PROD_ID <> "" and
                                          PROD_LEVEL = "SKU" and
                                          LIST_TYPE = "B" /* COMPRA */
                                          no-lock. 
        find first bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia and
                                   bctpromoc.procod    = int(PROD_ID)
                                 no-lock  no-error.        
        if avail bctpromoc
        then next.        
        find last xctpromoc where xctpromoc.sequencia = ctpromoc.sequencia
                    use-index indx1 no-lock no-error.
        vlinha = xctpromoc.linha + 1.        
        create bctpromoc. 
        bctpromoc.sequencia = ctpromoc.sequencia.
        bctpromoc.linha = vlinha. 
        buffer-copy ctpromoc except linha sequencia to bctpromoc .  
        bctpromoc.OFFER_ID = prof_1703.OFFER_ID.
        bctpromoc.procod = int(PROD_ID).
        bctpromoc.precosugerido = 0.
        bctpromoc.OFFER_ID                = prof_1703.OFFER_ID.
    end.    
    
    if prof_1703.GET_VAL_TYPE  = "GIFT"
    then do transaction.
        find ctpromoc where recid(ctpromoc) = par-ctpromoc exclusive.
        ctpromoc.qtdbrinde   = dec(GET_VAL).    
        ctpromoc.campodec[1] = dec(GET_VAL).
    end.
    find ctpromoc where recid(ctpromoc) = par-ctpromoc no-lock. 
    
    if prof_1703.GET_VAL_TYPE  <> "GIFT"
    then 
    for each prof_1720 of prof_1703 where PROD_ID <> "" and
            (PROD_LEVEL = "SKU" or
             PROD_LEVEL = "APP_LEVEL")
                                and
                                          LIST_TYPE = "B"  /* COMPRA */
                                          no-lock. 
        if PROD_LEVEL = "SKU"
        then
        find first bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia and
                                   bctpromoc.produtovendacasada = int(PROD_ID)
                               and bctpromoc.fincod = ?   
                                   no-lock no-error.        
        if PROD_LEVEL = "APP_LEVEL"
        then
        find first bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia and
                                   bctpromoc.produtovendacasada = int(PROD_ID)
                               and bctpromoc.fincod = ?   
                            no-lock       no-error.        
        
        if avail bctpromoc
        then next.        
        find last xctpromoc where xctpromoc.sequencia = ctpromoc.sequencia
                    use-index indx1 no-lock no-error.
        vlinha = xctpromoc.linha + 1.        
        create bctpromoc. 
        buffer-copy ctpromoc except linha to bctpromoc . 
        bctpromoc.OFFER_ID = prof_1703.OFFER_ID.
        bctpromoc.linha = vlinha.
        bctpromoc.OFFER_ID                = prof_1703.OFFER_ID.
        
        if TRUE
        then do.
            assign bctpromoc.produtovendacasada = int(PROD_ID).
            if PROD_LEVEL = "SKU"
            then bctpromoc.tipo = "PRODUTO" .
            if PROD_LEVEL = "APP_LEVEL"
            then bctpromoc.tipo = "CLASSE".
            
            if GET_VAL_TYPE = "PERCENTAGE"
            then do.
                if PROD_LEVEL = "SKU"
                then bctpromoc.tipo = "PRODUTO=|PERCENTUAL=|".
                if PROD_LEVEL = "APP_LEVEL"
                then bctpromoc.tipo = "CLASSE=|PERCENTUAL=|".
                bctpromoc.valorprodutovendacasada = dec(GET_VAL).
            end.
            if GET_VAL_TYPE = "VALUE"
            then do.
                if PROD_LEVEL = "SKU"
                then bctpromoc.tipo = "PRODUTO=|VALOR=|".
                if PROD_LEVEL = "APP_LEVEL"
                then  bctpromoc.tipo = "CLASSE=|VALOR=|".
                bctpromoc.valorprodutovendacasada = VALUEE.
            end.
            if GET_VAL_TYPE = "FIXED_PRICE_BASE" or
               GET_VAL_TYPE = "FIXED_PRICE_TOTAL"
            then do.
                
                run preco-inicial ( recid(bctpromoc) ).
            end.
        end.
        else do:
            find ctpromoc where recid(ctpromoc) = par-ctpromoc exclusive.
            assign bctpromoc.probrinde          = int(PROD_ID)
                     ctpromoc.campodec[1]        = 0
                     ctpromoc.campodec[1]        = 0
                     ctpromoc.qtdbrinde          = dec(qty).
        end.
        bctpromoc.fincod = ?.
        bctpromoc.precosugerido = dec(PUBLISH_PRIC).
        if prof_1703.OFFER_TYPE = "NON_PRICE"
        then bctpromoc.precosugerido = 0.
    end.
    
    find ctpromoc where recid(ctpromoc) = par-ctpromoc no-lock.
    
    for each prof_1720 of prof_1703 where STORE_ID <> "" no-lock .
        find first bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia and
                                   bctpromoc.etbcod    = int(STORE_ID)
                                  no-lock  no-error. 
        if avail bctpromoc
        then next.
        find last xctpromoc where xctpromoc.sequencia = ctpromoc.sequencia
                    use-index indx1 no-lock no-error.
        vlinha = xctpromoc.linha + 1.        
        create bctpromoc.  
        buffer-copy ctpromoc except linha to bctpromoc . 
        bctpromoc.linha = vlinha.
        bctpromoc.OFFER_ID = prof_1703.OFFER_ID.
        bctpromoc.etbcod = int(STORE_ID).
        bctpromoc.situacao = "A".
        bctpromoc.OFFER_ID                = prof_1703.OFFER_ID.
    end.    
    do transaction.
        find prof_1703 where recid(prof_1703) = par-rec no-lock.
        prof_1703.dtintegracao = today.
    end.    
end.



IF prof_1703.OFFER_TYPE_ID = "COMPLEX" and
   prof_1703.OFFER_TYPE    = "MULTI_UNIT"  
then do.
    do transaction.
        find ctpromoc where recid(ctpromoc) = par-ctpromoc exclusive.
        ctpromoc.qtdvenda           = int(BUY_QTY) .   /* comprado        */
        ctpromoc.qtdbrinde          = 1 .              /* Brinde          */
        ctpromoc.campodec[1]        = 0.
        if prof_1703.GET_VAL_TYPE = "VALUE"
        then ctpromoc.descontovalor     =  dec(GET_VAL).
        if prof_1703.GET_VAL_TYPE = "PERCENTAGE"
        then ctpromoc.descontopercentual = dec(GET_VAL).
    end.
    
    find ctpromoc where recid(ctpromoc) = par-ctpromoc no-lock.
    
    for each prof_1720 of prof_1703 where PROD_ID <> "" and
                                          PROD_LEVEL = "APP_LEVEL" and
                                          LIST_TYPE = "B" /* COMPRA */
                                          no-lock. 
        find first bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia and
                                   bctpromoc.clacod    = int(PROD_ID)
                                 no-lock  no-error.        
        if avail bctpromoc
        then next.        
        find last xctpromoc where xctpromoc.sequencia = ctpromoc.sequencia
                    use-index indx1 no-lock no-error.
        vlinha = xctpromoc.linha + 1.        
        create bctpromoc. 
        bctpromoc.sequencia = ctpromoc.sequencia.
        bctpromoc.linha = vlinha. 
        buffer-copy ctpromoc except linha sequencia to bctpromoc .  
        bctpromoc.OFFER_ID = prof_1703.OFFER_ID.
        bctpromoc.clacod = int(PROD_ID).
        bctpromoc.precosugerido = 0.
        bctpromoc.OFFER_ID                = prof_1703.OFFER_ID.
    end. 
    for each prof_1720 of prof_1703 where PROD_ID <> "" and
                                          PROD_LEVEL = "SKU" and
                                          LIST_TYPE = "B" /* COMPRA */
                                          no-lock. 
        find first bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia and
                                   bctpromoc.procod    = int(PROD_ID)
                                 no-lock  no-error.        
        if avail bctpromoc
        then next.        
        find last xctpromoc where xctpromoc.sequencia = ctpromoc.sequencia
                    use-index indx1 no-lock no-error.
        vlinha = xctpromoc.linha + 1.        
        create bctpromoc. 
        bctpromoc.sequencia = ctpromoc.sequencia.
        bctpromoc.linha = vlinha. 
        buffer-copy ctpromoc except linha sequencia to bctpromoc .  
        bctpromoc.OFFER_ID = prof_1703.OFFER_ID.
        bctpromoc.procod = int(PROD_ID).
        bctpromoc.precosugerido = 0.
        bctpromoc.OFFER_ID                = prof_1703.OFFER_ID.
    end.    
    
    if prof_1703.GET_VAL_TYPE  = "GIFT"
    then do.
        do transaction.
            find prof_1703 where recid(prof_1703) = par-rec exclusive.
            prof_1703.dtintegracao = today.
            
            find ctpromoc where recid(ctpromoc) = par-ctpromoc exclusive.
            ctpromoc.situacao = "ERR".
            prof_1703.ErroIntegra = "1703.OFFER_TYPE_ID = COMPLEX, " +
                                    "1703.OFFER_TYPE = MULTI_UNIT, "  +
                                    "1703.GET_VAL_TYPE = GIFT ".
        end.
        find ctpromoc where recid(ctpromoc) = par-ctpromoc no-lock.
        leave.
    end.
    find ctpromoc where recid(ctpromoc) = par-ctpromoc no-lock.
    
    for each prof_1720 of prof_1703 where STORE_ID <> "" no-lock .
        find first bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia and
                                   bctpromoc.etbcod    = int(STORE_ID)
                                 no-lock  no-error. 
        if avail bctpromoc
        then next.
        find last xctpromoc where xctpromoc.sequencia = ctpromoc.sequencia
                    use-index indx1 no-lock no-error.
        vlinha = xctpromoc.linha + 1.        
        create bctpromoc.  
        buffer-copy ctpromoc except linha to bctpromoc . 
        bctpromoc.linha = vlinha.
        bctpromoc.OFFER_ID = prof_1703.OFFER_ID.
        bctpromoc.etbcod = int(STORE_ID).
        bctpromoc.situacao = "A".
        bctpromoc.OFFER_ID                = prof_1703.OFFER_ID.
    end.    
    do transaction.
        find prof_1703 where recid(prof_1703) = par-rec exclusive.
        prof_1703.dtintegracao = today.
    end.    
end.






/*
connect -db adm.db -S 1904 -N tcp -H filial189 -ld adm_189 no-error.

if connected("adm_189")
then do.
    run envia_189.p ( input par-sequencia , input "CRIA" ).
    if connected("adm_189")
    then do.
        disconnect adm_189.
    end.
end.
*/

        




procedure retorna_1701_810.
for each prof_1701 of prof_1703
    transaction.
/* cria 810 para enviar ao profimetrics */
        create tt-810. 
        assign      
          tt-810.TRAN_TYPE           = "C".
          tt-810.APPROVED_DATE       = prof_1701.APPROVED_DATE.
          tt-810.EFFECTIVE_DATE      = prof_1701.EFFECTIVE_DATE.
          tt-810.DUE_DATE            = prof_1701.DUE_DATE.
          tt-810.PRICE_KEY           = dec(prof_1701.PRICE_KEY) .
          tt-810.SKU_ID              = prof_1701.PRODUCT_ID      .
          tt-810.STORE_ID            = prof_1701.STORE_ID    .
          tt-810.RETAIL_PRICE        = dec(prof_1701.APPROVED_PRICE) * 10000.
          tt-810.RETAIL_PRICE_INST   = dec(prof_1701.APPROVED_PRICE_INST)
                                                                * 10000.
          tt-810.RETAIL_PRICE_PLAN   = prof_1701.APPROVED_PRICE_PLAN.
          tt-810.PUBLISH_PRICE       = dec(prof_1701.PUBLISH_PRICE) * 10000.
          tt-810.OFFER_ID            = prof_1701.OFFER_ID        .
          tt-810.ORIGIN_ID           = "LEBES"  .
          tt-810.PRICE_SYSTEM_ID     = "IPO"  .
          tt-810.PRICE_TYPE          = prof_1701.PRICE_TYPE    .
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
                          exclusive no-error.                 
        if not avail prof810
        then create prof810.
        buffer-copy tt-810 except data_exportacao to prof810.
        prof810.data_exportacao = ?.
        prof810.retornar = yes. 
        /******************************************/
end.
end procedure.



procedure preco-inicial:
def buffer c-tpromoc for ctpromoc.
def buffer ectpromoc for ctpromoc.
def buffer fctpromoc for ctpromoc.
def buffer dctpromoc for ctpromoc.

def input parameter pr-rec as recid. 
find c-tpromoc where recid(c-tpromoc) = pr-rec no-lock.
for each ectpromoc where
                    ectpromoc.sequencia = c-tpromoc.sequencia and
                    ectpromoc.produtovendacasada = 0  and
                    ectpromoc.fincod <> ? no-lock
                    transaction.
                    
                    find first fctpromoc where
                        fctpromoc.sequencia = ectpromoc.sequencia and
                        fctpromoc.produtovendacasada = 
                            c-tpromoc.produtovendacasada and
                        fctpromoc.fincod = ectpromoc.fincod
                           no-error.
                    if not avail fctpromoc
                    then do :
                         find last dctpromoc where 
                            dctpromoc.sequencia = bctpromoc.sequencia 
                            no-lock no-error.
                            create fctpromoc.
                            assign fctpromoc.promocod = bctpromoc.promocod
                                fctpromoc.OFFER_ID = prof_1703.OFFER_ID
                                fctpromoc.sequencia = bctpromoc.sequencia
                                fctpromoc.linha     = dctpromoc.linha + 1 
                                fctpromoc.fincod    = ectpromoc.fincod
                                fctpromoc.produtovendacasada = 
                                    c-tpromoc.produtovendacasada.
                    end.
                    do.
                        if prof_1703.OFFER_TYPE = "MIX_MATCH"
                        then
                            fctpromoc.valorprodutovendacasada = 
                                                dec(prof_1720.VALUEE) .
                                                
                        if  prof_1703.OFFER_TYPE = "MIX_MATCH_CHEAP"
                        then
                            fctpromoc.valorprodutovendacasada =
                                                dec(prof_1703.GET_VAL).
                            
                        fctpromoc.campolog2 = no.
                        if prof_1720.VALUE_TYPE   = "FIXED_PRICE_TOTAL" or
                           prof_1703.GET_VAL_TYPE = "FIXED_PRICE_TOTAL"
                        then fctpromoc.campolog2 = yes.
                    end.
            end.
end procedure.




procedure forne-despesa :
    def var forne-vendedor as int   format ">>>>>>>>>>9".
    def var forne-gerente  as int   format ">>>>>>>>>>9".
    def var forne-supervisor as int format ">>>>>>>>>>9".
    def var forne-promotor as int   format ">>>>>>>>>>9".
    def var cod-forne as int        format ">>>>>>>>>>9".
    
    assign
        cod-forne        = int(prof_1703.GERAL)
        forne-vendedor   = int(prof_1703.VENDEDOR)
        forne-gerente    = int(prof_1703.GERENTE) 
        forne-supervisor = int(prof_1703.SUPERVISOR)
        forne-promotor   = int(prof_1703.PROMOTOR). 
        
    ctpromoc.campochar[2] = "".
    if cod-forne <> ?
    then  ctpromoc.campochar[2] = "FORNECEDOR=" + string(cod-forne) + "|".
    if forne-vendedor <> ?
    then  
    ctpromoc.campochar[2] = ctpromoc.campochar[2] +
                    "FORNE-VENDEDOR=" + string(forne-vendedor) + "|".
    if forne-gerente <> ?
    then   ctpromoc.campochar[2] = ctpromoc.campochar[2] + 
                    "FORNE-GERENTE=" + string(forne-gerente) + "|".
    if forne-supervisor <> ?
    then   ctpromoc.campochar[2] = ctpromoc.campochar[2] +
                    "FORNE-SUPERVISOR=" + string(forne-supervisor) + "|".
    if forne-promotor <> ?
    then   ctpromoc.campochar[2] = ctpromoc.campochar[2] +
                    "FORNE-PROMOTOR=" + string(forne-promotor) + "|".

end  procedure.

