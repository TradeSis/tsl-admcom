        output to produ.sem.fabri .
        put unformatted "INICIADO" skip.
        export delimiter ";" 
                "procod"
                "pronom"
                "fabcod" 
                "emite".
        output close.

def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").

def var v-item_attr_02_no as dec format ">>>>>>>>>>>>>>>>9999".

def var vdata as date.

def var a_vista as log.
def temp-table tt-planobiz
    field crecod as integer
    index idx01 crecod.
for each tabaux where tabaux.tabela = "PlanoBiz" no-lock:
    create tt-planobiz.
    assign tt-planobiz.crecod = integer(tabaux.valor_campo).    
      
end.

def temp-table tt-1008
    field STOCK_DATE  as char format "x(16)"
    field SKU_ID  as char format "x(25)"
    field STORE_ID    as char format "x(10)"
    field ORIGIN_ID   as char format "x(12)"
    field SOH_VAL as dec format "->>>>>>>>>>>>>>>9999"
    field SIT_VAL as dec format "->>>>>>>>>>>>>>>9999"
    field SOO_VAL as dec format "->>>>>>>>>>>>>>>9999"
    field OTHER_STK_VAL   as dec format "->>>>>>>>>>>>>>>9999"
    field SOH_QTY as dec format "->>>>>>>>>>>>>>>9999"
    field SIT_QTY as dec format "->>>>>>>>>>>>>>>9999"
    field SOO_QTY as dec format "->>>>>>>>>>>>>>>9999"
    field OTHER_STK_QTY   as dec format "->>>>>>>>>>>>>>>9999"
    field CREATE_USER_ID  as char format "x(25)"
    field CREATE_DATETIME as char format "x(16)"
    field LAST_UPDATE_USER_ID as char format "x(25)"
    field LAST_UPDATE_DATETIME    as char format "x(16)"
    index ind01 STOCK_DATE SKU_ID STORE_ID.
    .


def var vplanobiz as log.
def buffer bestoq for estoq.
def var vcodplano as int. 
def var vcrecod     as int.
def var vvprocod like produ.procod.
def var vreserva_loja_cd as dec.
def var compras_pendentes_entrega_CD as dec.
def var vestatual_cd as dec.

def var vdti as date init today .
def var vdtf as date init today.
def var val_acr like plani.platot.
def var val_des like plani.platot.
def var val_dev like plani.platot.
def var val_com like plani.platot.
def var valor_venda like val_com.
def var qtd_venda   like movim.movqtm.
def var val_fin like plani.platot.
def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer setclase for clase.
def buffer depto    for clase.
vdti = 08/31/2012.
vdtf = today - 10.         
def buffer i510movim for movim.
def buffer i510plani for plani.

def temp-table tt-318
    field SKU_ID  as char format "x(25)"
    field UDA_ID  as char format "x(10)"
    field ORIGIN_ID   as char format "x(12)"
    field UDA_CHAR    as char format "x(250)"
    field RECORD_STATUS   as char format "x(1)"
    field CREATE_USER_ID  as char format "x(25)"
    field CREATE_DATETIME as char format "x(14)"
    field LAST_UPDATE_USER_ID as char format "x(25)"
    field LAST_UPDATE_DATETIME  as char format "x(14)"      
.


def temp-table tt-produ
    field procod like produ.procod
    index procod is primary unique procod .
         
/* Label - Fabricante   */
def temp-table tt-226
    field   SKU_ID  as char format "x(25)"
    field   MERCH_L2_ID as char format "x(25)"
    field   MERCH_L3_ID as char format "x(25)"
    field   MERCH_L4_ID as char format "x(25)"
    field   MERCH_L5_ID as char format "x(25)"
    field   MERCH_L6_ID as char format "x(25)"
    field   ORIGIN_ID   as char format "x(12)"
    field   LABEL_ID    as char format "x(25)"
    field   PRIMARY_SUPPLIER_ID as char format "x(10)"
    field   COLOUR_ID   as char format "x(10)"
    field   SEASON_ID   as char format "x(10)"
    field   LINE_ID as char format "x(25)"
    field   STYLE_ID    as char format "x(25)"
    field   SKU_DESC    as char format "x(128)"
    field   SKU_SHORT_DESC  as char format "x(64)"
    field   PACKAGE_UOM as char format "x(4)"
    field   END_OF_LIFE_DATE    as char format "x(16)"
    field   ORIGINAL_RETAIL_PRICE   as dec format ">>>>>>>>>>>>>>>>9999"
    field   EAN as char format "x(20)"
    field   PACKAGE_SIZE    as dec format ">>>>>>>>>>>>>>>>9999"
    field   ITEM_ATTR_01_CHAR   as char format "x(40)"
    field   ITEM_ATTR_02_CHAR   as char format "x(40)"
    field   ITEM_ATTR_03_CHAR   as char format "x(40)"
    field   ITEM_ATTR_04_CHAR   as char format "x(40)"
    field   ITEM_ATTR_06_CHAR   as char format "x(40)"
    field   ITEM_ATTR_01_NO as dec format ">>>>>>>>>>>>>>>>9999"
    field   ITEM_ATTR_02_NO as dec format ">>>>>>>>>>>>>>>>9999"
    field   ITEM_ATTR_01_FLAG   as char format "x(1)"
    field   ITEM_ATTR_02_FLAG   as char format "x(1)"
    field   ITEM_ATTR_03_FLAG   as char format "x(1)"
    field   ITEM_ATTR_04_FLAG   as char format "x(1)"      
    field   ITEM_ATTR_05_FLAG   as char format "x(1)"
    field   ITEM_ATTR_06_FLAG   as char format "x(1)"
    field   RECORD_STATUS   as char format "x(1)"
    field   CREATE_USER_ID  as char format "x(25)"
    field   CREATE_DATETIME as char format "x(16)"
    field   LAST_UPDATE_USER_ID as char format "x(25)"
    field   LAST_UPDATE_DATETIME    as char format "x(16)"
    field   IMAGE_FILE_LINK as char format "x(1024)".

def temp-table tt-323
    field STORE_ID    as char format "x(10)"
    field SKU_ID  as char format "x(25)"
    field ORIGIN_ID   as char format "x(12)"
    field OPEN_TO_BUY as char format "x(1)"
    field ITEM_ST_ATTR_01_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_02_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_03_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_04_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_05_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_06_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_07_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_08_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_09_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_10_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field RECORD_STATUS   as char format "x(1)"
    field CREATE_USER_ID  as char format "x(25)"
    field CREATE_DATETIME as char format "x(16)"
    field LAST_UPDATE_USER_ID as char format "x(25)"
    field LAST_UPDATE_DATETIME    as char format "x(16)".
    
def temp-table tt-405
    field EFFECTIVE_DATE   as char format "x(16)"
    field CALCULATE_DATE   as char format "x(16)"
    field SKU_ID  as char format "x(25)"
    field SUPPLIER_ID as char format "x(10)"
    field ORIGIN_ID   as char format "x(12)"
    field UNIT_COST   as dec format ">>>>>>>>>>>>>>>>9999"
    field RECORD_STATUS   as char format "x(1)"
    field CREATE_USER_ID  as char format "x(25)"
    field CREATE_DATETIME  as char format "x(16)"
    field LAST_UPDATE_USER_ID as char format "x(25)"
    field LAST_UPDATE_DATETIME     as char format "x(16)"
    index tt-405    is primary unique CALCULATE_DATE
                                      SKU_ID
                                      SUPPLIER_ID.
                                      
def temp-table tt-510
    field SALES_DATE  as char format "x(16)"
    field SKU_ID  as char format "x(25)"
    field STORE_ID    as char format "x(10)"
    field ORIGIN_ID   as char format "x(12)"
    field TOT_SLS_VAL as dec format "->>>>>>>>>>>>>>>9999"
    field REG_SLS_VAL as dec format "->>>>>>>>>>>>>>>9999"
    field PRM_SLS_VAL as dec format "->>>>>>>>>>>>>>>9999"
    field CLR_SLS_VAL as dec format "->>>>>>>>>>>>>>>9999"
    field TOT_SLS_QTY as dec format "->>>>>>>>>>>>>>>9999"
    field REG_SLS_QTY as dec format "->>>>>>>>>>>>>>>9999"
    field PRM_SLS_QTY as dec format "->>>>>>>>>>>>>>>9999"
    field CLR_SLS_QTY as dec format "->>>>>>>>>>>>>>>9999"
    field REG_RTRN_QTY    as dec format "->>>>>>>>>>>>>>>9999"
    field REG_RTRN_VAL    as dec format "->>>>>>>>>>>>>>>9999"
    field PRM_RTRN_QTY    as dec format "->>>>>>>>>>>>>>>9999"
    field PRM_RTRN_VAL    as dec format "->>>>>>>>>>>>>>>9999"
    field CLR_RTRN_QTY    as dec format "->>>>>>>>>>>>>>>9999"
    field CLR_RTRN_VAL    as dec format "->>>>>>>>>>>>>>>9999"
    field OFFER_ID    as char format "x(12)"
    field RECORD_STATUS   as char format "x(1)"
    field CREATE_USER_ID  as char format "x(25)"
    field CREATE_DATETIME as char format "x(16)"
    field LAST_UPDATE_USER_ID as char format "x(25)"
    field LAST_UPDATE_DATETIME    as char format "x(16)"
    index xx is primary unique 
                        SALES_DATE  
                        SKU_ID 
                        STORE_ID.
                        
def temp-table tt-810
        field TRAN_TYPE   as char format "x(1)"
        field APPROVED_DATE   as char format "x(16)"
        field EFFECTIVE_DATE  as char format "x(16)"
        field DUE_DATE    as char format "x(16)"
        field PRICE_KEY   as dec format ">>>>>>>>>>>>>>>>>>>>>9"
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
        index xxx is primary unique  
                        EFFECTIVE_DATE
                        APPROVED_DATE
                        SKU_id
                        STORE_id  
                        TRAN_TYPE  
                        OFFER_id  
                        PRICE_TYPE
        .                        

def var vestatual like estoq.estatual.

def buffer cmovim for movim.
def buffer cplani for plani.

def var vsituacao as log.

def var vestatus-d as char extent 4  FORMAT "X(15)"
    init["NORMAL","BRINDE","FORA DE LINHA","FORA DO MIX"].            
def var vestatus as int.    
def var vtot as int.
vtot = 0.
for each produ where produ.procod < 999999 no-lock.
    vtot = vtot + 1.
end.

disp vtot.

def var vcont as int.

vcont = 0.
for each produ where produ.procod < 999999 no-lock.
    vcont = vcont + 1.
    if vcont mod 1000 = 0 
    then do.
        disp vcont "de" vtot vcont / vtot * 100
                with 1 down. pause 0.
    end.
    if proseq = 99
    then next.
     
    
    def var vmovalicms  like movim.movalicms.    
    def var vmovdat     as date.
    def var vprocod     like produ.procod.
    def var vemite      like plani.emite.
    def var vmovpc      as dec.
    vprocod = produ.procod.
    find first estoq where estoq.procod = produ.procod no-lock no-error.
    find last cmovim where cmovim.movtdc = 4
                       and cmovim.procod = produ.procod
                        no-lock no-error.
    if avail cmovim
    then do.
        find cplani where cplani.movtdc = cmovim.movtdc 
                      and cplani.etbcod = cmovim.etbcod
                      and cplani.placod = cmovim.placod no-lock no-error.
        if not avail cplani
        then assign vmovalicms  = 12
                    vmovdat     = produ.prodtcad
                    vemite      = produ.fabcod
                    vmovpc      = if avail estoq
                                  then estoq.estcusto
                                  else 0
                    .
        else assign vmovalicms = cmovim.movalicms
                    vmovdat    = cmovim.movdat
                    vmovpc     = cmovim.movpc
                    vemite     = cplani.emite.
    end.
    else assign vmovalicms = 12
                vmovdat    = produ.prodtcad 
                vemite     = produ.fabcod
                vmovpc      = if avail estoq 
                              then estoq.estcusto 
                              else 0.
    
    /*find produsku of produ no-lock no-error.
    if avail produsku then next.*/
    find sClase     where sClase.clacod   = produ.clacod    no-lock no-error.
    if not avail sClase then next.
    find Clase      where Clase.clacod    = sClase.clasup   no-lock no-error.
    if not avail clase then next.
    find grupo      where grupo.clacod    = Clase.clasup    no-lock no-error.
    if not avail grupo then next.
    find setClase   where setClase.clacod = grupo.clasup    no-lock no-error.  
    if not avail setclase then next.
    find depto   where depto.clacod = setclase.clasup    no-lock no-error.   
    if not avail depto then next.                  
    
    if setClase.clacod = 0 then next.      
    if grupo.clacod = 0 then next.         
    if depto.clacod = 0 then next.         
    if Clase.clacod = 0 then next.         
    if sClase.clacod = 0 then next.        
    
    vestatual = 0.
    for each estoq of produ no-lock.
        vestatual = vestatual + estoq.estatual.
    end.
    if vestatual = 0
    then do.
        find first movim where movim.procod  = produ.procod and
                               movim.movtdc  = 4            and
                               movim.movdat >= today - 365  
                               no-lock no-error.
        if not avail movim
        then
        find first movim where movim.procod  = produ.procod and
                               movim.movtdc  = 5            and
                               movim.movdat >= today - 365  
                               no-lock no-error.
        if not avail movim
        then 
        find first movim where movim.procod  = produ.procod and
                               movim.movtdc  = 12            and
                               movim.movdat >= today - 365  
                               no-lock no-error.
        if not avail movim
        then
        find first movim where movim.procod  = produ.procod and
                               movim.movtdc  = 17            and
                               movim.movdat >= today - 365  
                               no-lock no-error.
        if not avail movim
        then
        find first movim where movim.procod  = produ.procod and
                               movim.movtdc  = 18            and
                               movim.movdat >= today - 365  
                               no-lock no-error.
        if not avail movim
        then
        find first movim where movim.procod  = produ.procod and
                               movim.movtdc  = 13           and
                               movim.movdat >= today - 365  
                               no-lock no-error.
        if not avail movim
        then if produ.prodtcad < today - 365 then next.
    end.
    
    /*** Estatus ***/
    find produaux where
                     produaux.procod = produ.procod and
                     produaux.nome_campo = "Estatus"
                     no-lock no-error.
    if avail produaux  
    then vestatus = int(valor_campo). 
    else vestatus = 0.     
    def var vetiqueta as log.
    vetiqueta = no. 
    find produaux where
                     produaux.procod = produ.procod and
                     produaux.nome_campo = "Etiqueta-Preco"
                     no-error.
    if avail produaux and 
        produaux.valor_campo = "Sim"
    then vetiqueta = yes.
    
    find probrick where probrick.procod = produ.procod no-lock no-error.
    vsituacao = yes.
    if produ.proseq = 99
    then vsituacao = no.
    if produ.pronom begins "*"
    then vsituacao = no.
    

    hide message no-pause.
    
    find first tt-produ where tt-produ.procod = produ.procod
        no-error.
    if not avail tt-produ
    then do:
        create tt-produ.
        tt-produ.procod = produ.procod.
    end.
    /**  318 */
    for each procarac  of produ no-lock.
        find subcarac of procarac no-lock no-error.
        
        if subcarac.subdes matches ("*NAO USAR*") or
           subcarac.subdes matches "*INATIVO*"
        then next.
        
            create tt-318.
            assign 
            tt-318.SKU_ID           = string(produ.procod)
            tt-318.UDA_ID           = string(procar.subcod)
            tt-318.ORIGIN_ID        = "LEBES"
            tt-318.UDA_CHAR         = subcarac.subdes
                        

            
            tt-318.RECORD_STATUS            = "A"                .
            tt-318.CREATE_USER_ID           = "ADMCOM"           .
            tt-318.CREATE_DATETIME          = vsysdata           .
            tt-318.LAST_UPDATE_USER_ID      = "ADMCOM"           .
            tt-318.LAST_UPDATE_DATETIME     = vsysdata           .
            .    
    end.
    /********/
    
    
    create tt-226.
    
    run 1008.
                
                def var vvoltagem as char. 
                def var vimportado  as log.
                def var vmostruario as log.
                vvoltagem = "".
                vimportado = no.
                vmostruario = no.
                for each procarac of produ no-lock.
                    find subcarac of procarac no-lock.
                    find carac of subcarac no-lock.
                    if carac.carcod = 004
                    then vvoltagem = subcarac.subdes.
                    if carac.carcod = 005 and
                       subcarac.SubCar = 1 
                    then vimportado = yes.
                    if carac.carcod = 005 and
                       subcarac.SubCar = 2 
                    then vmostruario = yes.     
                end.            
            
            assign 
                tt-226.SKU_ID  =   string(produ.procod).
                tt-226.MERCH_L2_ID =   string(depto.clacod).
                tt-226.MERCH_L3_ID =   if avail     setclase
                                       then  string(setClase.clacod)
                                       else ""   .
                tt-226.MERCH_L4_ID =   if avail     grupo
                                       then  string(Grupo.clacod)
                                       else "".
                tt-226.MERCH_L5_ID =   if avail    clase
                                       then string(clase.clacod) 
                                       else "".
                tt-226.MERCH_L6_ID =   if avail    sclase
                                       then string(sclase.clacod) 
                                       else "" .
                tt-226.ORIGIN_ID   =   "LEBES".
                tt-226.LABEL_ID    =   string(produ.fabcod).
                tt-226.PRIMARY_SUPPLIER_ID  = string(produ.fabcod).
                tt-226.COLOUR_ID   =   "".
                tt-226.SEASON_ID   =   string(temp-cod).
                tt-226.LINE_ID =  "".
                tt-226.STYLE_ID    =  "".
                tt-226.SKU_DESC    =   produ.pronom.
                tt-226.SKU_SHORT_DESC  =   produ.pronomc.
                tt-226.PACKAGE_UOM =  "UN".
                IMAGE_FILE_LINK =
                        "~\~\sv-ca-stg.lebes.com.br~\Pro_Im" + 
                                "~\" +
                                    string(produ.procod) + ".jpg".
        find first prodatrib of produ where   
                        prodatrib.atribcod = 14
                        no-lock no-error.
        if avail prodatrib
        then  tt-226.PACKAGE_SIZE    = prodatrib.valor.  
        else  tt-226.PACKAGE_SIZE    = 1. 
        tt-226.END_OF_LIFE_DATE    = if produ.datFimVida = ?
                                     then ""
                                     else (string(  day(datFimVida),"99")  
                                         + string(month(datFimVida),"99") 
                                         + string(year (datFimVida),"9999"))
                                     .
        find first estoq where estoq.procod = produ.procod no-lock no-error.
                tt-226.ORIGINAL_RETAIL_PRICE   =   if avail estoq
                                                   then (estoq.estcusto * 10000)
                                                   else 0.
                tt-226.EAN =   if produ.proindice <> ?
                               then produ.proindice
                               else "".
            if produ.catcod = 41
            then v-item_attr_02_no = ((tt-226.ORIGINAL_RETAIL_PRICE) / 15).
            else v-item_attr_02_no = ((tt-226.ORIGINAL_RETAIL_PRICE) / 20)
                                   * 1.658.
                tt-226.ITEM_ATTR_01_CHAR   =   produ.prorefter              .
                tt-226.ITEM_ATTR_02_CHAR   =  vestatus-d[vestatus + 1]     .
                tt-226.ITEM_ATTR_03_CHAR   =   (if produ.catcod = 31
                                               then "87"
                                               else "90").
                tt-226.ITEM_ATTR_04_CHAR   =   "AMBOS" .
                 
                tt-226.ITEM_ATTR_06_CHAR   = vvoltagem .
                tt-226.ITEM_ATTR_01_NO     = produ.pvp * 10000        .
                tt-226.ITEM_ATTR_02_NO     =   v-item_attr_02_no .
                tt-226.ITEM_ATTR_01_FLAG   =   if produ.proipival = 1
                                               then "Y"
                                               else "N".
                tt-226.ITEM_ATTR_02_FLAG   =   string(vimportado,"Y/N") .
                tt-226.ITEM_ATTR_03_FLAG   =   if vetiqueta then "Y" else "N".
                tt-226.ITEM_ATTR_04_FLAG   =   if avail probrick then "Y" 
                                               else "N".
                tt-226.ITEM_ATTR_05_FLAG   =   if vsituacao = yes then "Y" 
                                               else "N".
                tt-226.ITEM_ATTR_06_FLAG   =   string(vmostruario,"Y/N") .
                tt-226.RECORD_STATUS            = "A" .
                tt-226.CREATE_USER_ID           = "ADMCOM"           .
                tt-226.CREATE_DATETIME          = vsysdata           .
                tt-226.LAST_UPDATE_USER_ID      = "ADMCOM"           .
                tt-226.LAST_UPDATE_DATETIME     = vsysdata           .
                

    for each estab no-lock.
            
        if produ.catcod = 41 
        then do.  /*
            find estoq where estoq.procod = produ.procod and
                             estoq.etbcod = estab.etbcod no-lock no-error.
            if not avail estoq or (avail estoq and estoq.estatual = 0)
            then next.         */
        end.    
        def var vITEM_ST_ATTR_01_NO as dec.
        find estoq where estoq.procod = produ.procod and 
                         estoq.etbcod = estab.etbcod no-lock no-error.
        vITEM_ST_ATTR_01_NO = if avail estoq and estoq.estatual > 0
                              then estoq.estatual * 10000
                              else 0.
        if vmovalicms = ? 
        then vmovalicms = 0.
        create tt-323.
        assign STORE_ID   = string(estab.etbcod). 
               SKU_ID     = string(produ.procod). 
               ORIGIN_ID  = "LEBES" .
               OPEN_TO_BUY = string(produ.opentobuy,"Y/N")     .
               ITEM_ST_ATTR_01_NO  = vITEM_ST_ATTR_01_NO .
               ITEM_ST_ATTR_02_NO  = 0.
               ITEM_ST_ATTR_03_NO  =  vmovalicms * 10000.
                    
               ITEM_ST_ATTR_04_NO  = if produ.proipiper = ? 
                                     then 0
                                     else produ.proipiper * 10000.
        def var vpisent     like clafis.pisent.
        def var vpissai     like clafis.pissai.
        def var vcofinsent  like clafis.cofinsent.
        def var vcofinssai  like clafis.cofinssai.
        vpisent = 0.
        vpissai = 0.
        vcofinsent = 0.
        vcofinssai = 0.
        find clafis where clafis.codfis = produ.codfis no-lock no-error.
        if avail clafis
        then assign vpisent     = clafis.pisent
                    vpissai     = clafis.pissai
                    vcofinsent  = clafis.cofinsent
                    vcofinssai  = clafis.cofinssai.

        if vpisent = ?      then vpisent = 0.
        if vpissai = ?      then vpissai = 0.
        if vcofinsent = ?   then vcofinsent = 0.
        if vcofinsent = ?   then vcofinssai = 0.

               /*17    * 10000       .*/
               ITEM_ST_ATTR_05_NO  = vpisent  * 10000      .
               ITEM_ST_ATTR_06_NO  = vpissai  * 10000    .
               ITEM_ST_ATTR_07_NO  = vcofinsent   * 10000    .
               ITEM_ST_ATTR_08_NO  = vcofinssai   * 10000   .
               ITEM_ST_ATTR_09_NO  = 0     * 10000  .
               ITEM_ST_ATTR_10_NO  = 0     * 10000 .
               
/*               message ITEM_ST_ATTR_03_NO           
                    ITEM_ST_ATTR_04_NO
               ITEM_ST_ATTR_05_NO ITEM_ST_ATTR_06_NO ITEM_ST_ATTR_07_NO ITEM_ST_ATTR_08_NO.     */
               
               tt-323.RECORD_STATUS            = "A"                .
               tt-323.CREATE_USER_ID           = "ADMCOM"           .
               tt-323.CREATE_DATETIME          = vsysdata           .
               tt-323.LAST_UPDATE_USER_ID      = "ADMCOM"           .
               tt-323.LAST_UPDATE_DATETIME     = vsysdata           .

    end. /* for each estab ... */

                
    find forne where forne.forcod = vemite no-lock no-error.
    if not avail forne 
    then do.
        output to produ.sem.fabri append.
        export delimiter ";" 
                produ.procod
                produ.pronom
                produ.fabcod 
                vemite.
        output close.
    end.
    
    find tt-405 where tt-405.CALCULATE_DATE = string(vmovdat,"99999999")                    and tt-405.SKU_ID         = string(vprocod)       
                  and tt-405.SUPPLIER_ID    = string(vemite)
                      no-error.
    if not avail tt-405
    then create tt-405.
    assign tt-405.EFFECTIVE_DATE      = string(vmovdat,"99999999") .
           tt-405.CALCULATE_DATE      = string(vmovdat,"99999999") .
           tt-405.SKU_ID              = string(vprocod).
           tt-405.SUPPLIER_ID         = string(vemite)              .
           tt-405.ORIGIN_ID           = "LEBES"                  .
           tt-405.UNIT_COST           = vmovpc  * 10000     .
           if tt-405.UNIT_COST < 0
           then tt-405.UNIT_COST = tt-405.UNIT_COST * -1.
           tt-405.RECORD_STATUS            = "A"                .
           tt-405.CREATE_USER_ID           = "ADMCOM"           .
           tt-405.CREATE_DATETIME          = vsysdata           .
           tt-405.LAST_UPDATE_USER_ID      = "ADMCOM"           .
           tt-405.LAST_UPDATE_DATETIME     = vsysdata           .

    
    for each estoq where estoq.procod = produ.procod no-lock.      
            find estab where estab.etbcod = estoq.etbcod no-lock no-error.
            if not avail estab
            then next.

            hide message no-pause.

            create tt-810.
            assign      
                TRAN_TYPE           = "C".
                APPROVED_DATE       = string(today,"99999999") .
                EFFECTIVE_DATE      = string(today,"99999999") .
                DUE_DATE            = "".
                /*
                PRICE_KEY           = next-value(Seq_itim).
                */
                PRICE_KEY           = dec(
                                          string(1,"9") +  /* 1 = regular */
                                          string(estoq.etbcod,"999") +
                                          string(estoq.procod,"9999999")    
                                                ).                
                SKU_ID              = string(estoq.procod).
                STORE_ID            = string(estoq.etbcod).
                RETAIL_PRICE        = estoq.estvenda * 10000.
                RETAIL_PRICE_INST   = 0.
                RETAIL_PRICE_PLAN   = (if produ.catcod = 31
                                       then "87"
                                       else "90")
                                       /*string(estoq.tabcod)*/     .
                PUBLISH_PRICE       = RETAIL_PRICE_INST  .
                                /* em 04/04 alterado para ir o mesmo                                                 RETAIL_PRICE_INST
                                estoq.estproper * 10000.
                                */
                OFFER_ID            = ""        .
                ORIGIN_ID           = "LEBES"  .
                PRICE_SYSTEM_ID     = ""      .
                PRICE_TYPE          = "R"    .
                RECORD_STATUS       = "A"   .
                tt-810.CREATE_USER_ID           = "ADMCOM"           .
                tt-810.CREATE_DATETIME          = vsysdata           .
                tt-810.LAST_UPDATE_USER_ID      = "ADMCOM"           .
                tt-810.LAST_UPDATE_DATETIME     = vsysdata           .
        
            if estoq.estproper <> 0 and estprodat <> ? and 
               estoq.estbaldat <> ? and estprodat >= today
            then do.
                def var vdata_aprovacao as char.
                find last hispre of produ no-lock no-error.
                if avail hispre
                then vdata_aprovacao = string(hispre.dtalt,"99999999").
                else vdata_aprovacao = string(estoq.datexp,"99999999").
                def var vdata_inicio as char.
                vdata_inicio = string(estoq.estbaldat,"99999999").
                def var vdata_fim as char.
                vdata_fim = string(estoq.estprodat,"99999999").

                create tt-810.
                assign      
                    TRAN_TYPE           = "C".
                    APPROVED_DATE       = vdata_aprovacao.
                    EFFECTIVE_DATE      = vdata_inicio   .
                    DUE_DATE            = if vdata_fim <> ?
                                          then vdata_fim
                                          else ""  .
                    PRICE_KEY           = dec(
                                          string(2,"9") + /* 2 = promocional */
                                          string(estoq.etbcod,"999") +
                                          string(estoq.procod,"9999999")    
                                                ).
                    SKU_ID              = string(estoq.procod).
                    STORE_ID            = string(estoq.etbcod).
                    RETAIL_PRICE        = estoq.estproper * 10000.
                    RETAIL_PRICE_INST   = estoq.estmin * 10000 .
                    RETAIL_PRICE_PLAN   = (if produ.catcod = 31
                                           then "87"
                                           else "90")
                                           /*string(estoq.tabcod)*/     .
                    PUBLISH_PRICE       = RETAIL_PRICE_INST  .
                    OFFER_ID            = ""        .
                    ORIGIN_ID           = "LEBES"  .
                    PRICE_SYSTEM_ID     = ""      .
                    PRICE_TYPE          = "P"    .
                    RECORD_STATUS       = "A"   .
                    tt-810.CREATE_USER_ID           = "ADMCOM"           .
                    tt-810.CREATE_DATETIME          = vsysdata           .
                    tt-810.LAST_UPDATE_USER_ID      = "ADMCOM"           .
                    tt-810.LAST_UPDATE_DATETIME     = vsysdata           .
            end.

    end.

end.            


hide message no-pause.
message "Salvando produtos...".

output to /admcom/progr/itim/produ.txt.
for each tt-produ.
export tt-produ.
end.
output close.

hide message no-pause.
message "Gerando 226...".

output to value("/admcom/tmp/itim/input/ADMCOM_0226_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-226.
    put                      
    tt-226.SKU_ID      "|"
    tt-226.MERCH_L2_ID     "|"
    tt-226.MERCH_L3_ID     "|"
    tt-226.MERCH_L4_ID     "|"
    tt-226.MERCH_L5_ID     "|"
    tt-226.MERCH_L6_ID     "|"
    tt-226.ORIGIN_ID       "|"
    tt-226.LABEL_ID        "|"
    tt-226.PRIMARY_SUPPLIER_ID "|"
    tt-226.COLOUR_ID       "|"
    tt-226.SEASON_ID       "|"
    tt-226.LINE_ID     "|"
    tt-226.STYLE_ID        "|"
    tt-226.SKU_DESC        "|"
    tt-226.SKU_SHORT_DESC      "|"
    tt-226.PACKAGE_UOM     "|"
    tt-226.END_OF_LIFE_DATE        "|"
    tt-226.ORIGINAL_RETAIL_PRICE       "|"
    tt-226.EAN     "|"
    tt-226.PACKAGE_SIZE        "|"
    tt-226.ITEM_ATTR_01_CHAR       "|"
    tt-226.ITEM_ATTR_02_CHAR       "|"
    tt-226.ITEM_ATTR_03_CHAR       "|"
    tt-226.ITEM_ATTR_04_CHAR       "|"
    tt-226.ITEM_ATTR_06_CHAR       "|"
    tt-226.ITEM_ATTR_01_NO     "|"
    tt-226.ITEM_ATTR_02_NO     "|"
    tt-226.ITEM_ATTR_01_FLAG       "|"
    tt-226.ITEM_ATTR_02_FLAG       "|"
    tt-226.ITEM_ATTR_03_FLAG       "|"
    tt-226.ITEM_ATTR_04_FLAG       "|"
    tt-226.ITEM_ATTR_05_FLAG       "|"
    tt-226.ITEM_ATTR_06_FLAG       "|"
    tt-226.RECORD_STATUS       "|"
    tt-226.CREATE_USER_ID      "|"
    tt-226.CREATE_DATETIME     "|"
    tt-226.LAST_UPDATE_USER_ID     "|"
    tt-226.LAST_UPDATE_DATETIME        "|"
    tt-226.IMAGE_FILE_LINK     
    
        skip.
        
end.
output close .

hide message no-pause.
message "Gerando 323...".

output to value("/admcom/tmp/itim/input/ADMCOM_0323_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-323.
    put                      
        tt-323.STORE_ID                          "|"
        tt-323.SKU_ID                            "|"        
        tt-323.ORIGIN_ID                         "|"
        tt-323.OPEN_TO_BUY                       "|" 
        tt-323.ITEM_ST_ATTR_01_NO                "|"        
        tt-323.ITEM_ST_ATTR_02_NO                "|" 
        tt-323.ITEM_ST_ATTR_03_NO                "|" 
        tt-323.ITEM_ST_ATTR_04_NO                "|" 
        tt-323.ITEM_ST_ATTR_05_NO                "|" 
        tt-323.ITEM_ST_ATTR_06_NO                "|" 
        tt-323.ITEM_ST_ATTR_07_NO                "|" 
        tt-323.ITEM_ST_ATTR_08_NO                "|" 
        tt-323.ITEM_ST_ATTR_09_NO                "|"
        tt-323.ITEM_ST_ATTR_10_NO                "|" 
        tt-323.RECORD_STATUS                     "|" 
        tt-323.CREATE_USER_ID                    "|" 
        tt-323.CREATE_DATETIME                   "|" 
        tt-323.LAST_UPDATE_USER_ID               "|" 
        tt-323.LAST_UPDATE_DATETIME
        skip.
        
end.
output close .

hide message no-pause.
message "Gerando 405...".

output to value("/admcom/tmp/itim/input/ADMCOM_0405_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-405.
    put                      
        tt-405.EFFECTIVE_DATE            "|"
        tt-405.CALCULATE_DATE            "|"
        tt-405.SKU_ID                    "|"
        tt-405.SUPPLIER_ID               "|"
        tt-405.ORIGIN_ID                 "|"
        tt-405.UNIT_COST                 "|"
        tt-405.RECORD_STATUS             "|"
        tt-405.CREATE_USER_ID            "|"
        tt-405.CREATE_DATETIME           "|"
        tt-405.LAST_UPDATE_USER_ID       "|"
        tt-405.LAST_UPDATE_DATETIME
        skip.
        
end.
output close .


output to value("/admcom/tmp/itim/input/ADMCOM_0810_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-810.
    put                      
        tt-810.TRAN_TYPE                   "|"
        tt-810.APPROVED_DATE               "|"
        tt-810.EFFECTIVE_DATE              "|"
        tt-810.DUE_DATE                    "|"
        tt-810.PRICE_KEY                   "|"
        tt-810.SKU_ID                      "|"
        tt-810.STORE_ID                    "|"
        tt-810.RETAIL_PRICE                "|"
        tt-810.RETAIL_PRICE_INST           "|"
        tt-810.RETAIL_PRICE_PLAN           "|"
        tt-810.PUBLISH_PRICE               "|"
        tt-810.OFFER_ID                    "|"
        tt-810.ORIGIN_ID                   "|"
        tt-810.PRICE_SYSTEM_ID             "|"
        tt-810.PRICE_TYPE                  "|"
        tt-810.RECORD_STATUS               "|"
        tt-810.CREATE_USER_ID              "|"
        tt-810.CREATE_DATETIME             "|"
        tt-810.LAST_UPDATE_USER_ID         "|"
        tt-810.LAST_UPDATE_DATETIME
        skip.
        
end.
output close .

output to value("/admcom/tmp/itim/input/ADMCOM_0318_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-318.
    put                      
        tt-318.SKU_ID                    "|"
        tt-318.UDA_ID                    "|"
        tt-318.ORIGIN_ID                 "|"
        tt-318.UDA_CHAR                  "|"
        tt-318.RECORD_STATUS             "|"
        tt-318.CREATE_USER_ID            "|"
        tt-318.CREATE_DATETIME           "|"
        tt-318.LAST_UPDATE_USER_ID       "|"
        tt-318.LAST_UPDATE_DATETIME
        skip.
        
end.
output close .

output to value("/admcom/tmp/itim/input/ADMCOM_1008_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") append.
for each tt-1008.
    put                      
        STOCK_DATE              "|"
        SKU_ID                  "|"
        STORE_ID                "|"
        ORIGIN_ID               "|"
        SOH_VAL format "->>>>>>>>>>>>>>>9999"        "|"
        SIT_VAL format "->>>>>>>>>>>>>>>9999"                "|"
        SOO_VAL format "->>>>>>>>>>>>>>>9999"                "|"
        OTHER_STK_VAL format "->>>>>>>>>>>>>>>9999"          "|"
        SOH_QTY format "->>>>>>>>>>>>>>>9999"                "|"
        SIT_QTY format "->>>>>>>>>>>>>>>9999"                "|"
        SOO_QTY format "->>>>>>>>>>>>>>>9999"                "|"
        OTHER_STK_QTY format "->>>>>>>>>>>>>>>9999"          "|"
        CREATE_USER_ID          "|"
        CREATE_DATETIME         "|"
        LAST_UPDATE_USER_ID     "|"
        LAST_UPDATE_DATETIME
        skip.
end.
output close .






procedure vreserva_loja_cd.
def buffer pestoq for estoq.
def input  parameter par-procod like produ.procod.
def input  parameter par-etbcod like estoq.etbcod.
def output parameter reserva    as int.

def var vespecial  as int.
def var vdata as date.

find pestoq where pestoq.etbcod = par-etbcod and
                         pestoq.procod = par-procod no-lock no-error.

        if true
        then do:
            reserva = 0. 
            vespecial = 0.  
            do vdata = today - 40 to today.
            for each liped where liped.pedtdc = 3
                             and liped.predt  = vdata
                             and liped.procod = par-procod 
                             and liped.etbcod = par-etbcod
                             no-lock:
                                         
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.

                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.
                
                reserva = reserva + liped.lipqtd.
            end.

            /* pedido especial */

            for each liped where liped.pedtdc = 6 
                             and liped.predt  = vdata
                             and liped.etbcod = par-etbcod
                             and liped.procod = par-procod no-lock,
                first pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum and
                                 pedid.pedsit = yes    and
                                 pedid.sitped = "P"
                                 no-lock.
                
                vespecial = vespecial + liped.lipqtd.
               end.
            end.
            
            if (pestoq.estatual - vespecial) < 0
            then vespecial = 0.


            /****  antonio - sol 26212 - Reservas futuras *****/
                       assign vdata = today + 1.
            for each liped where liped.pedtdc = 3
                             and liped.predt  > vdata
                             and liped.etbcod = par-etbcod
                             and liped.procod = par-procod no-lock:
                                         
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.

                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.
                reserva = reserva + liped.lipqtd.
            end.
            
            /*********** Reservas do E-Commerce **********/
            for each liped where liped.pedtdc = 8
                             and liped.predt  = today
                             and liped.etbcod = par-etbcod
                             and liped.procod = par-procod no-lock:
  
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid
                then next.
                                                                 
                reserva = reserva + liped.lipqtd.
            end.
            /*** fim de reservas futuras - sol 26212 ***/    

        end.           


end procedure.


procedure compras_pendentes_entrega_CD.
def input  parameter par-procod like produ.procod.
def output parameter compras_pendentes_entrega_CD as int.
compras_pendentes_entrega_CD = 0.
    for each liped where  liped.procod = par-procod and
                                 liped.pedtdc = 1 and
                                 (liped.predtf = ? or
                                 liped.predtf >= today - 30) no-lock,
              first pedid of liped where pedid.pedsit = yes and
                            pedid.sitped <> "F"  and
                            pedid.peddat > today - 180   no-lock:
            compras_pendentes_entrega_CD = compras_pendentes_entrega_CD +
                                (liped.lipqtd - liped.lipent).
    end.

end procedure.


def new shared var vestatual995  like estoq.estatual format "->>>>9".
def new shared var vdisponiv993  like estoq.estatual format "->>>>9".
def new shared var vestatual993  like estoq.estatual format "->>>>9".
def new shared var vestatual998  like estoq.estatual format "->>>>9".
def new shared var vestatual500  like estoq.estatual format "->>>>9".
def var vreservado like estoq.estatual.
def var vestcusto like estoq.estcusto.



procedure 1008.
    
    vdisponiv993 = 0.
    vestatual993 = 0.
    vestatual995 = 0.
    vestatual998 = 0.
    vestatual500 = 0.
    vestcusto = 0.

    find first bestoq where bestoq.procod = produ.procod no-lock no-error.
    vestcusto = if avail bestoq
                then bestoq.estcusto
                else 0.
    
    assign vvprocod = int(produ.procod).
    find estoq where estoq.etbcod = 993 and estoq.procod = vvprocod
        no-lock no-error.
    if avail estoq then assign vestatual993 = vestatual993 + estoq.estatual.
    find estoq where estoq.etbcod = 995 and estoq.procod = vvprocod
        no-lock no-error.
    if avail estoq then assign vestatual995 = vestatual995 + estoq.estatual.
    find estoq where estoq.etbcod = 998 and estoq.procod = vvprocod
        no-lock no-error.
    if avail estoq then assign vestatual998 = vestatual998 + estoq.estatual.
    find estoq where estoq.etbcod = 500 and estoq.procod = vvprocod           
        no-lock no-error.                                                     
    if avail estoq then assign vestatual500 = vestatual500 + estoq.estatual.  


    for each estoq where estoq.procod = produ.procod /*and
                (estoq.etbcod = 1 or estoq.etbcod = 2 or estoq.etbcod = 3)
                */
                
                no-lock.      
                
            find estab where estab.etbcod = estoq.etbcod
                                no-lock no-error.
            if not avail estab
            then next.

            run compras_pendentes_entrega_CD
                                ( input  produ.procod, 
                                  output compras_pendentes_entrega_CD).
            
            
            vestatual_cd =  vestatual993 + 
                            vestatual995 + 
                            vestatual998 + 
                            vestatual500.
            
            run vreserva_loja_cd( input  produ.procod, 
                                  input  estoq.etbcod, 
                                  output vreserva_loja_cd).


            def var f as int.
            
            
                
            find first tt-1008 
                where tt-1008.STOCK_DATE = string(today,"99999999")
                  and tt-1008.SKU_ID     = string(produ.procod)
                  and tt-1008.STORE_ID   = string(estoq.etbcod)
                    no-error.
            if not avail tt-1008
            then do:
                create tt-1008.
                assign      .
                tt-1008.STOCK_DATE  = string(today,"99999999")      .
                tt-1008.SKU_ID      = string(produ.procod)          .
                tt-1008.STORE_ID    = string(estoq.etbcod)           .
                tt-1008.ORIGIN_ID   = "LEBES"                 .
                tt-1008.SOH_VAL     = estoq.estatual * vestcusto * 10000 .
                tt-1008.SIT_VAL     = vreserva_loja_cd * vestcusto * 10000.
                tt-1008.SOO_VAL     = compras_pendentes_entrega_CD * vestcusto
                                                    * 10000.
                tt-1008.OTHER_STK_VAL = vestatual_cd * vestcusto * 10000    .
                tt-1008.SOH_QTY       = estoq.estatual      * 10000       .
                tt-1008.SIT_QTY       = vreserva_loja_cd * 10000.
                tt-1008.SOO_QTY       = compras_pendentes_entrega_CD * 10000.
                tt-1008.OTHER_STK_QTY = vestatual_cd * 10000.
                        
                    tt-1008.CREATE_USER_ID           = "ADMCOM"           .
                    tt-1008.CREATE_DATETIME          = vsysdata           .
                    tt-1008.LAST_UPDATE_USER_ID      = "ADMCOM"           .
                    tt-1008.LAST_UPDATE_DATETIME     = vsysdata           .
                    .
        
    
        end. /* if not avail tt-1008 ... */    
        
    
    end.

end procedure.

        output to produ.sem.fabri append.
        put unformatted skip "FINAL" skip.
        output close.

