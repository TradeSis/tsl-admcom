
{admcab.i }
def var Arquivo as char format "x(50)".
def var vcat-cod   like produ.catcod.
def var vtemp-cod  like produ.temp-cod.

update vcat-cod. 
message "Confirma a geracao do arquivo?" update sresp.
if sresp =  no
then leave.

Arquivo = "/admcom/relat/concilia." + string(time).

update Arquivo .

def var vtoday as date.
vtoday = today.

def var vsel as int.

def temp-table tt-reserva no-undo
    field etbcod as int
    field procod as int
    field estatual as dec
    field reserva as dec
    field especial as dec
    index xx is unique primary etbcod procod asc.

def var v-item_attr_02_no as dec format ">>>>>>>>>>>>>>>>9999".

def var a_vista as log.
def temp-table tt-planobiz no-undo
    field crecod as integer
    index idx01 crecod.
for each tabaux where tabaux.tabela = "PlanoBiz" no-lock:
    create tt-planobiz.
    assign tt-planobiz.crecod = integer(tabaux.valor_campo).    
      
end.

def temp-table tt-1008 no-undo
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
    index tt-1008 is primary unique STOCK_DATE SKU_ID STORE_ID.
    .


def var vplanobiz as log.
def buffer bestoq for estoq.
def var vcodplano as int. 
def var vcrecod     as int.
def var vvprocod like produ.procod.
def var vreserva_loja_cd as dec.
def var compras_pendentes_entrega_CD as dec.
def var vestatual_cd as dec.

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
def buffer i510movim for movim.
def buffer i510plani for plani.

def temp-table tt-318 no-undo
    field SKU_ID  as char format "x(25)"
    field UDA_ID  as char format "x(10)"
    field ORIGIN_ID   as char format "x(12)"
    field UDA_CHAR    as char format "x(250)"
    field RECORD_STATUS   as char format "x(1)"
    index tt-318 is primary unique SKU_ID UDA_ID
.

/*
def temp-table tt-produ no-undo
    field procod like produ.procod
    index procod is primary unique procod .

         */
         
/* Label - Fabricante   */
def temp-table tt-226 no-undo
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
    field   ITEM_ATTR_01_NO as char format "xxxxxxxxxxxxxxxxxxxx"
    field   ITEM_ATTR_02_NO as dec format ">>>>>>>>>>>>>>>>9999"
    field   ITEM_ATTR_01_FLAG   as char format "x(1)"
    field   ITEM_ATTR_02_FLAG   as char format "x(1)"
    field   ITEM_ATTR_03_FLAG   as char format "x(1)"
    field   ITEM_ATTR_04_FLAG   as char format "x(1)"      
    field   ITEM_ATTR_05_FLAG   as char format "x(1)"
    field   ITEM_ATTR_06_FLAG   as char format "x(1)"
    field   RECORD_STATUS   as char format "x(1)"
    field   IMAGE_FILE_LINK as char format "x(1024)"
    index SKU_ID is primary unique SKU_ID.

def temp-table tt-323 no-undo
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
    index tt-323 is primary unique STORE_ID SKU_ID.
    
    
def temp-table tt-405 no-undo
    field EFFECTIVE_DATE   as char format "x(16)"
    field CALCULATE_DATE   as char format "x(16)"
    field SKU_ID  as char format "x(25)"
    field SUPPLIER_ID as char format "x(10)"
    field ORIGIN_ID   as char format "x(12)"
    field UNIT_COST   as dec format ">>>>>>>>>>>>>>>>9999"
    field RECORD_STATUS   as char format "x(1)"
    field data_exportacao as date
    field dtcusto   as date
    index tt-405    is primary unique CALCULATE_DATE
                                      SKU_ID
                                      SUPPLIER_ID.
                                      
def temp-table tt-510 no-undo
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
    index xx is primary unique 
                        SALES_DATE  
                        SKU_ID 
                        STORE_ID.
                        
def temp-table tt-810 no-undo
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
        field data_exportacao as date

        index xxx is primary unique  
                        EFFECTIVE_DATE
                        APPROVED_DATE
                        SKU_id
                        STORE_id  
                        TRAN_TYPE  
                        OFFER_id  
                        PRICE_TYPE
        index yyy                    
                        SKU_id
                        STORE_id  


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
for each produ where produ.procod < 9999999             
                  and catcod = vcat-cod

no-lock by procod desc.
    vtot = vtot + 1.
        if proseq <> 0
    then next .

end.

disp vtot.
def var vcont as int.
pause 0 before-hide.
vcont = 0.
for each produ where produ.procod < 9999999   
and catcod = vcat-cod


            no-lock .

     vcont = vcont + 1.
     if vcont mod 1000 = 0 or vcont < 500
     then disp vcont "de" vtot with 1 down no-label.
     
     find sClase     where sClase.clacod   = produ.clacod    no-lock no-error.
    if not avail sClase 
    then do on error undo.  
        next.
    end.        
    find Clase      where Clase.clacod    = sClase.clasup   no-lock no-error.
    if not avail clase 
    then do on error undo.
        next.
    end.
    find grupo      where grupo.clacod    = Clase.clasup    no-lock no-error.
    if not avail grupo 
    then do on error undo.
        next.
    end.
    find setClase   where setClase.clacod = grupo.clasup    no-lock no-error.  
    if not avail setclase 
    then do on error undo.
        next.
    end.
    find depto   where depto.clacod = setclase.clasup    no-lock no-error.   
    if not avail depto 
    then do on error undo.
        next.                  
    end.        
        
    if setClase.clacod = 0 
    then do on error undo.
        next.      
    end.
    if grupo.clacod = 0 
    then do on error undo.
        next.         
    end.
    if depto.clacod = 0 
    then do on error undo.
        next.         
    end.
    if Clase.clacod = 0 
    then do on error undo.
        next.         
    end.
    if sClase.clacod = 0 
    then do on error undo.
        next.        
    end.
    
    vestatual = 0.
    for each estoq of produ no-lock.
        vestatual = vestatual + estoq.estatual.
    end.
    
    if vestatual = 0
    then do.
        find first movim where movim.procod  = produ.procod and
                               movim.movtdc  = 4            and
                               movim.movdat >= vtoday - (30 * 6)  
                               no-lock no-error.
        if not avail movim
        then
        find first movim where movim.procod  = produ.procod and
                               movim.movtdc  = 5            and
                               movim.movdat >= vtoday - (30 * 6)  
                               no-lock no-error.
        if not avail movim
        then 
        find first movim where movim.procod  = produ.procod and
                               movim.movtdc  = 12            and
                               movim.movdat >= vtoday - (30 * 6)  
                               no-lock no-error.
        if not avail movim
        then
        find first movim where movim.procod  = produ.procod and
                               movim.movtdc  = 17            and
                               movim.movdat >= vtoday - (30 * 6)  
                               no-lock no-error.
        if not avail movim
        then
        find first movim where movim.procod  = produ.procod and
                               movim.movtdc  = 18            and
                               movim.movdat >= vtoday - (30 * 6)  
                               no-lock no-error.
        if not avail movim
        then
        find first movim where movim.procod  = produ.procod and
                               movim.movtdc  = 13           and
                               movim.movdat >= vtoday - (30 * 6)  
                               no-lock no-error.
        if not avail movim
        then if produ.prodtcad < vtoday - 365 
             then do on error undo.
                next.
             end.
    end.
    
    
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
        find first cplani use-index plani where cplani.movtdc = cmovim.movtdc 
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

    
    vsel = vsel + 1.
    def var xtime as int.
    xtime = time.
    
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
    if produ.proseq = 99 or produ.proseq = 98
    then vsituacao = no.
    if produ.pronom begins "*"
    then vsituacao = no.
    
    /**  318 */
    for each procarac  of produ no-lock.
        find subcarac of procarac no-lock no-error.
        
        if subcarac.subdes matches ("*NAO USAR*") or
           subcarac.subdes matches "*INATIVO*"
        then next.
        
            find tt-318 where tt-318.SKU_ID = string(produ.procod) and  
                              tt-318.UDA_ID = string(procar.subcod)
                              no-error.
            if not avail tt-318
            then create tt-318.
            assign 
            tt-318.SKU_ID           = string(produ.procod)
            tt-318.UDA_ID           = string(procar.subcod)
            tt-318.ORIGIN_ID        = "LEBES"
            tt-318.UDA_CHAR         = subcarac.subdes
                        

            
            tt-318.RECORD_STATUS            = "A"                .
            .    
    end.
    /********/
    
    create tt-226.
    
    run 1008.
    
def var vprodtcad as char.
vprodtcad = string(  day(produ.prodtcad),"99") 
          + string(month(produ.prodtcad),"99")
          + string( year(produ.prodtcad),"9999")
          + string("00:00:00").
vprodtcad = replace(vprodtcad,":","").
    
             
                
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
                tt-226.SEASON_ID   =   string(produ.temp-cod).
                if produ.temp-cod = 0
                then tt-226.SEASON_ID = "3".
                tt-226.LINE_ID =  "".
                tt-226.STYLE_ID    =  "".

                /* cor e tamanho */
                if produ.itecod <> produ.procod
                then do.
                    find produpai of produ no-lock no-error.
                    if avail produpai and
                       produpai.gracod <> 0
                    then do.   
                        tt-226.STYLE_ID = string(produ.itecod).
                        tt-226.LINE_ID  = trim(string((produ.itecod)) + "-" +
                                               string((produ.cor)))  .
                    end.
                end.
                tt-226.SKU_DESC    =   produ.pronom.
                tt-226.SKU_SHORT_DESC  =   produ.pronomc.
                tt-226.PACKAGE_UOM =  "UN".
                IMAGE_FILE_LINK =
                        "~\~\sv-ca-stg.lebes.com.br~\Pro_Im~\proim" + 
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
            /* em 10/07/2013 era assim
            tt-226.ORIGINAL_RETAIL_PRICE   =   if avail estoq
                                               then (estoq.estcusto * 10000)
                                               else 0.
                                          *********/
        find first hispre where hispre.procod = produ.procod and
                                hispre.estvenda-ant <> 0
                     use-index i-hispre no-lock no-error.
            tt-226.ORIGINAL_RETAIL_PRICE = if avail hispre
                                           then (hispre.estvenda-ant * 10000)
                                           else 
                                           if avail estoq
                                           then (estoq.estvenda * 10000)
                                           else 0 . 
                
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
                tt-226.ITEM_ATTR_01_NO     = 
                            string(produ.pvp * 10000,">>>>>>>>>>>>>>>>9999")
                                    .
                if produ.pvp = 0
                then tt-226.ITEM_ATTR_01_NO = ""  .
                tt-226.ITEM_ATTR_02_NO     =   v-item_attr_02_no .
                tt-226.ITEM_ATTR_01_FLAG   =   if produ.proipival = 1
                                               then "Y"
                                               else "N".
                tt-226.ITEM_ATTR_02_FLAG   =   string(vimportado,"Y/N") .
                tt-226.ITEM_ATTR_03_FLAG   =   if vetiqueta then "Y" else "N".
                tt-226.ITEM_ATTR_04_FLAG   =   if avail probrick then "Y" 
                                               else "N".
                /* em 10/07/2013 era assim 
                tt-226.ITEM_ATTR_05_FLAG   =   if vsituacao = yes then "Y" 
                                               else "N".
                                           ***/
                tt-226.ITEM_ATTR_05_FLAG   =   if produ.descontinuado = yes 
                                               then "Y" 
                                               else "N".
                tt-226.ITEM_ATTR_06_FLAG   =   string(vmostruario,"Y/N") .
                tt-226.RECORD_STATUS            = "A" .
                

    for each estab no-lock.
        def var vtipoLoja as char.
        vtipoLoja = if estab.tipoLoja = "Normal"
                    then "S"
                    else
                    if estab.tipoLoja = "CD"
                    then "W"
                    else
                    if estab.tipoLoja = "Outlet"
                    then "O"
                    else
                    if estab.tipoLoja = "E-COMMERCE"
                    then "E"
                    else "S".
        if vtipoLoja      = "W"       then next.
        if estab.tipoLoja = "Virtual" then next.
        if estab.tipoLoja = "escritorio"    then next.
            
        /***************/
        if produ.descontinuado then next.
        /***************/        
        
        if produ.catcod = 31
        then .
        else if produ.catcod = 41
             then.
             else next.
        
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
        find tt-323 where tt-323.STORE_ID   = string(estab.etbcod) and
                          tt-323.SKU_ID     = string(produ.procod)
                          no-error.  
        if not avail tt-323
        then create tt-323.
        assign STORE_ID   = string(estab.etbcod). 
               SKU_ID     = string(produ.procod). 
               ORIGIN_ID  = "LEBES" .
               OPEN_TO_BUY = string(produ.opentobuy,"Y/N")     .
               ITEM_ST_ATTR_01_NO  = vITEM_ST_ATTR_01_NO .
               ITEM_ST_ATTR_02_NO  = 0.
               ITEM_ST_ATTR_03_NO  =  vmovalicms * 10000.
                    
               ITEM_ST_ATTR_04_NO  = if produ.proipiper = ? or 
                                        produ.proipiper = 99
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
               
               
               tt-323.RECORD_STATUS            = "A"                .

    end. /* for each estab ... */

            
    find forne where forne.forcod = vemite no-lock no-error.
    if not avail forne 
    then do.
        next.
    end.
    /***/
    def buffer bbestoq for estoq.
    find first bbestoq where bbestoq.procod = produ.procod no-lock.
    def var vmanda as log.
    assign vmanda       = no 
           vmovdat      = vtoday
           vprocod      = produ.procod 
           vemite       = produ.fabcod 
           vmovpc       = bbestoq.estcusto. 
    
    def var xxUNIT_COST like tt-405.UNIT_COST.
    xxUNIT_COST           = vmovpc  * 10000     . 
    if xxUNIT_COST < 0 
    then xxUNIT_COST = xxUNIT_COST * -1.    
    def buffer xxprof405 for prof405.
    find last xxprof405 use-index DtCusto
                    where xxprof405.SKU_ID       = string(vprocod)
                      and xxprof405.SUPPLIER_ID  = string(vemite)     
                      and xxprof405.DtCusto     <  vmovdat        
                          no-lock no-error.
    if avail xxprof405
    then vmanda = xxUNIT_COST <> xxprof405.UNIT_COST.
    else vmanda = yes.
    
    if vmanda
    then do.
    find prof405 where prof405.CALCULATE_DATE = string(vmovdat,"99999999") and
                       prof405.SKU_ID         = string(vprocod)            and
                       prof405.SUPPLIER_ID    = string(vemite)
                       no-lock no-error.
    if avail prof405 or 
       (avail prof405 and prof405.data_exportacao <> ?)    
    then.
    else do.
        /*******/
        find tt-405 where tt-405.CALCULATE_DATE = string(vmovdat,"99999999")
                          and tt-405.SKU_ID         = string(vprocod)       
                          and tt-405.SUPPLIER_ID    = string(vemite)
                          no-error.
        if not avail tt-405
        then create tt-405.
        assign tt-405.EFFECTIVE_DATE      = string(vmovdat,"99999999") .
               tt-405.dtcusto             = vmovdat. 
               tt-405.CALCULATE_DATE      = string(vmovdat,"99999999") .
               tt-405.SKU_ID              = string(vprocod).
           tt-405.SUPPLIER_ID         = string(vemite)              .
           tt-405.ORIGIN_ID           = "LEBES"                  .
           tt-405.UNIT_COST           = vmovpc  * 10000     .
            if tt-405.UNIT_COST < 0
           then tt-405.UNIT_COST = tt-405.UNIT_COST * -1.
           tt-405.RECORD_STATUS            = "A"                .
    end.
    end.
    def var vpreco as log.
    def var vpromoc as log.

end.            





/*
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
        do vdata = vtoday - 40 to vtoday.
            for each liped use-index liped2 
                          where liped.pedtdc = 3
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
            for each liped use-index liped2 where liped.pedtdc = 6 
                             and liped.predt  = vdata
                             and liped.etbcod = par-etbcod
                             and liped.procod = par-procod no-lock.
                             
                find first pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum and
                                 pedid.pedsit = yes    and
                                 pedid.sitped = "P"
                                 no-lock no-error.
                
                vespecial = vespecial + liped.lipqtd.
               
            end.
            
            if (pestoq.estatual - vespecial) < 0
            then vespecial = 0.

            /****  antonio - sol 26212 - Reservas futuras *****/
            /*           assign vdata = vtoday + 1.*/
            for each liped use-index liped2 where liped.pedtdc = 3
                             and liped.predt  > vtoday
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
            for each liped use-index liped2 where liped.pedtdc = 8
                             and liped.predt  = vtoday
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
            end. /* vdata */ 
        end.           


end procedure.
*/


procedure pega-vreserva_loja_cd.
def buffer pestoq for estoq.
def input  parameter par-procod like produ.procod.

def var vespecial  as int.
def var vdata as date.
/*
find pestoq where pestoq.etbcod = par-etbcod and
                         pestoq.procod = par-procod no-lock no-error.
*/

           /* reserva = 0. */
           
            vespecial = 0.  
     do vdata = vtoday - 40 to vtoday.
            for each liped use-index liped2 
                          where liped.pedtdc = 3
                             and liped.predt  = vdata
                             and liped.procod = par-procod 
                             no-lock:
                                         
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.

                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.
              
                find first tt-reserva where
                    tt-reserva.procod = liped.procod and
                    tt-reserva.etbcod = liped.etbcod
                    no-error.
                if not avail tt-reserva
                then do:
                    create tt-reserva.
                    tt-reserva.etbcod = liped.etbcod.
                    tt-reserva.procod = liped.procod.
                end.
                
                tt-reserva.reserva = tt-reserva.reserva + liped.lipqtd.
                
            end.

            /* pedido especial */
             
            for each liped use-index liped2 where liped.pedtdc = 6 
                             and liped.predt  = vdata
                             and liped.procod = par-procod no-lock.
                             
                find first pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum and
                                 pedid.pedsit = yes    and
                                 pedid.sitped = "P"
                                 no-lock no-error.
                

                find first tt-reserva where
                    tt-reserva.procod = liped.procod and
                    tt-reserva.etbcod = liped.etbcod
                    no-error.
                if not avail tt-reserva
                then do:
                    create tt-reserva.
                    tt-reserva.etbcod = liped.etbcod.
                    tt-reserva.procod = liped.procod.
                end.
                
                tt-reserva.especial = tt-reserva.especial + liped.lipqtd.

            end.
            
            for each tt-reserva.
                if (tt-reserva.estatual - tt-reserva.especial) < 0
                then tt-reserva.especial = 0.
            end.
 
            /****  antonio - sol 26212 - Reservas futuras *****/
            /*           assign vdata = vtoday + 1.*/
            for each liped use-index liped2 where liped.pedtdc = 3
                             and liped.predt  > vtoday
                             and liped.procod = par-procod no-lock:
                                         
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.

                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.
 
                find first tt-reserva where
                    tt-reserva.procod = liped.procod and
                    tt-reserva.etbcod = liped.etbcod
                    no-error.
                if not avail tt-reserva
                then do:
                    create tt-reserva.
                    tt-reserva.etbcod = liped.etbcod.
                    tt-reserva.procod = liped.procod.
                end.
                
                tt-reserva.reserva = tt-reserva.reserva + liped.lipqtd.
 
            end.

          

            /*********** Reservas do E-Commerce **********/
            for each liped use-index liped2 where liped.pedtdc = 8
                             and liped.predt  = vtoday
                             and liped.procod = par-procod no-lock:
  
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid
                then next.

                find first tt-reserva where
                    tt-reserva.procod = liped.procod and
                    tt-reserva.etbcod = liped.etbcod
                    no-error.
                if not avail tt-reserva
                then do:
                    create tt-reserva.
                    tt-reserva.etbcod = liped.etbcod.
                    tt-reserva.procod = liped.procod.
                end.
                
                tt-reserva.reserva = tt-reserva.reserva + liped.lipqtd.
 
            end.
            /*** fim de reservas futuras - sol 26212 ***/    
    end. /* vdata */ 


end procedure.



procedure compras_pendentes_entrega_CD.
def input  parameter par-procod like produ.procod.
def output parameter compras_pendentes_entrega_CD as int.
compras_pendentes_entrega_CD = 0.
    for each liped where  liped.procod = par-procod and
                                 liped.pedtdc = 1 and
                                 (liped.predtf = ? or
                                 liped.predtf >= vtoday - 30) no-lock,
              first pedid of liped where pedid.pedsit = yes and
                            pedid.sitped <> "F"  and
                            pedid.peddat > vtoday - 180   no-lock:
            compras_pendentes_entrega_CD = compras_pendentes_entrega_CD +
                                (liped.lipqtd - liped.lipent).
    end.

end procedure.


def new shared var vestatual995  like estoq.estatual format "->>>>9".
def new shared var vestatual980  like estoq.estatual format "->>>>9".
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
    vestatual980 = 0.
    vestatual500 = 0.
    vestcusto = 0.

def var v8time as int.

    v8time = time.
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

    find estoq where estoq.etbcod = 980 and estoq.procod = vvprocod
        no-lock no-error.
    if avail estoq then assign vestatual980 = vestatual980 + estoq.estatual.

    find estoq where estoq.etbcod = 998 and estoq.procod = vvprocod
        no-lock no-error.
    if avail estoq then assign vestatual998 = vestatual998 + estoq.estatual.
    find estoq where estoq.etbcod = 500 and estoq.procod = vvprocod           
        no-lock no-error.                                                     
    if avail estoq then assign vestatual500 = vestatual500 + estoq.estatual.  


            
            vestatual_cd =  vestatual993 + 
                            vestatual995 + 
                            vestatual980 +
                            vestatual998 + 
                            vestatual500.

             run compras_pendentes_entrega_CD
                                ( input  produ.procod, 
                                  output compras_pendentes_entrega_CD).

             /* cria tt-reserva para pegar as reservas */
             for each tt-reserva.
                delete tt-reserva.
             end.   
             for each estoq where estoq.procod = produ.procod no-lock.
 
                find first tt-reserva where
                    tt-reserva.procod = estoq.procod and
                    tt-reserva.etbcod = estoq.etbcod
                    no-error.
                if not avail tt-reserva
                then do:
                    create tt-reserva.
                    tt-reserva.etbcod = estoq.etbcod.
                    tt-reserva.procod = estoq.procod.
                end.
                
                tt-reserva.estatual = tt-reserva.estatual + estoq.estatual.
              
             end.

             run pega-vreserva_loja_cd( input  produ.procod).

    for each estoq where estoq.procod = produ.procod /*and
                (estoq.etbcod = 1 or estoq.etbcod = 2 or estoq.etbcod = 3)
                */
                
                no-lock.      
                
            find estab where estab.etbcod = estoq.etbcod
                                no-lock no-error.
            if not avail estab
            then next.


          

            find first tt-reserva where
                tt-reserva.procod = produ.procod and
                tt-reserva.etbcod = estoq.etbcod no-error.
            vreserva_loja_cd = if avail tt-reserva
                               then tt-reserva.reserva
                               else 0.

            /* roda uma unica vez antes do for each estoq                  
            run vreserva_loja_cd( input  produ.procod, 
                                  input  estoq.etbcod, 
                                  output vreserva_loja_cd).

            */
            

            def var f as int.
            
            def var vtipoLoja as char.
            vtipoLoja = if estab.tipoLoja = "Normal"
                        then "S"
                        else
                        if estab.tipoLoja = "CD"
                        then "W"
                        else
                        if estab.tipoLoja = "Outlet"
                        then "O"
                        else
                        if estab.tipoLoja = "E-COMMERCE"
                        then "E"
                        else "S".
            if vtipoLoja      = "W"       then next.
            if estab.tipoLoja = "Virtual" then next.
            if estab.tipoLoja = "escritorio"    then next.

                
            find first tt-1008 
                where tt-1008.STOCK_DATE = string(vtoday,"99999999")
                  and tt-1008.SKU_ID     = string(produ.procod)
                  and tt-1008.STORE_ID   = string(estoq.etbcod)
                    no-error.
            if not avail tt-1008
            then do:
                create tt-1008.
                assign      .
                tt-1008.STOCK_DATE  = string(vtoday,"99999999")      .
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
                        
                    .
        
    
        end. /* if not avail tt-1008 ... */    
        
    
    end.


end procedure.




output to value(Arquivo).
    put unformatted
                                           "Código" 
       "|"                                 "Produto "
       "|"                                 "# Loja "
       "|"                                 "Prc a Vista Atual "
       
       "|"          "Tipo preço"
       "|"          "PVP Rec Fornecedor"
       "|"          "Artigo pai" 
       "|"          "Item-pai"
       "|"          "Departamento-codigo"
       "|"          "Departamento"
       "|"          "Setor cod"
       "|"          "Setor"
       "|"          "Grupo cod"
       "|"          "Grupo"
       "|"          "Classe cod"
       "|"          "Classe"
       
       "|"                                 "# Sub-Classe "
       "|"                                 "Sub-Classe "
       
       "|"          "Um. Medida"
       
       
       "|"                                 "Qtd. Estoque "
       
       "|"          "Estoque (Qtd)"
       
       
       "|"                                 "#Estoque CD "    
       "|"                                 "On-Order" 
       "|"                                 "Pode Comprar? "
       "|"                                 "R$ Estoque "
       "|"                                 "R$ Estoq. On-Order " 
       "|"                                 "R$ Estoque CD "

       "|"          "%Imposto"
       
       
       "|"                             "Alíquota de COFINS crédito"
       "|"                             "Alíquota de COFINS débito"
       "|"                             "Alíquota de ICMS crédito"
       "|"                             "Alíquota de ICMS débito"
       "|"                             "Alíquota de IPI"
       
       "|"          "Brand cod"
       "|"          "Brand"
       "|"          "Aliquota de MVA/IVA"
       
       
       "|"                             "Alíquota de PIS crédito"
       "|"                             "Alíquota de PIS débito"
       
       "|"          "Tamanho"
       "|"          "Principal fabricante cod"
       "|"          "Principal fabricante"
       

       "|"                             " Tipo de Loja"
       
       "|"          "Giro estoque ult 30d"
       
       "|"                                 " Preço Inicial"
       "|"                             " Preço de Custo"
       "|"                           " Data Efetiva do Preço de Custo"

       "|"          "Item pai cod"
       "|"          "Item cor cod"
       "|"          "Preço de custo liquido"
       "|"          "Item cod"

       "|"                             "# Estação"
       "|"                             "# Marca"
       "|"                             "Capacidade"
       
       "|"          "Classificação"
       "|"          "Companhia"
       "|"          "Companhia cod"
       "|"          "Cor"
       "|"          "Departamento"
       "|"          "Estatus"
       
       
       "|"                             " Estação"
       "|"                             " Dia da primeira venda"
       
       "|"          "Idade estoque ajustada"
       "|"          "Imagem de preço"
       
       
       "|"                             " Data Prod. Descontinuado"
       "|"                             " Inicio da estação "
       "|"                             "Fim da estação"
       "|"                             " Nomenclatura em Falta: DATA_FIM_VIDA"
       
       "|"          "Link p/ imagem"
       
       "|"                             " Marca"
       
       "|"          "Markup inicial"

       "|"                             " Pedido Especial "
       "|"                             "Produto Brick"
       "|"                             "Produto Importado"
       "|"                             "Produto de Mostruário"
       "|"                             "Produto descontinuado"
       
       "|"          "Voltagem"
       "|"          "Etiqueta preço"
       "|"          "Volume"
       "|"          "Vda ult 30 (qtd)"
       "|"          "Vda Ult 30 D (R$)"
       
       
       
            skip
           .

def var Artigo_pai as char.
def var Item-pai as char.
def var Item_cor_cod as char.

for each tt-323 where tt-323.STORE_ID = "1".
    find tt-226 of tt-323.
    find produ where produ.procod = int(tt-323.sku_id) no-lock.

    vtemp-cod = produ.temp-cod.
    if vtemp-cod = 0
    then vtemp-cod = 3.
    find temporada where temporada.temp-cod = vtemp-cod no-lock no-error.
    
    find clase of produ no-lock no-error.
    find estoq where estoq.procod = produ.procod and
                     estoq.etbcod = int(tt-323.store_id) no-lock no-error.
    find estab of estoq no-lock no-error.
    if not avail estab then next.
    vtipoLoja = if estab.tipoLoja = "Normal"
                then "S"
                else
                if estab.tipoLoja = "CD"
                then "W"
                else
                if estab.tipoLoja = "Outlet"
                then "O"
                else 
                if estab.tipoLoja = "E-COMMERCE"
                then "E"
                else "S".

    find first tt-1008 
                where tt-1008.STOCK_DATE = string(vtoday,"99999999")
                  and tt-1008.SKU_ID     = string(produ.procod)
                  and tt-1008.STORE_ID   = string(estoq.etbcod)
                    no-error.
    find first prof405 use-index prof4051 where 
                        prof405.sku_id = tt-323.sku_id
                        no-lock no-error.
    def var vdt_venda as char.
    vdt_venda = "".
    find first movim use-index datsai where movim.procod = produ.procod and
                                            movim.movtdc = 5 no-lock no-error.
    if avail movim    
    then vdt_venda = string(movim.movdat).
    find fabri of produ no-lock no-error.                 
        Artigo_pai = "".

   if produ.itecod <> produ.procod
    then do.
        Artigo_pai = string(produ.itecod).
        Item_cor_cod = trim(string((produ.itecod)) + "-" + 
                            string((produ.cor)))  .        
    end. 

    find sClase     where sClase.clacod   = produ.clacod    no-lock no-error.
    find Clase      where Clase.clacod    = sClase.clasup   no-lock no-error.
    find grupo      where grupo.clacod    = Clase.clasup    no-lock no-error.
    find setClase   where setClase.clacod = grupo.clasup    no-lock no-error.  
    find depto   where depto.clacod = setclase.clasup    no-lock no-error.   
    find categ of produ no-lock no-error.
    
    vvoltagem = "".
    for each procarac of produ no-lock.
        if carac.carcod = 004 
        then vvoltagem = subcarac.subdes.
    end.

    vetiqueta = no. 
    find produaux where
                     produaux.procod = produ.procod and
                     produaux.nome_campo = "Etiqueta-Preco"
                     no-error.
    if avail produaux and 
        produaux.valor_campo = "Sim"
    then vetiqueta = yes.
    
    
    put unformatted
            tt-323.sku_id               /*Código*/ 
       "|"    produ.pronom              /*Produto */
       "|"    tt-323.store_id           /*# Loja */
       "|"    estoq.estvenda            /*Prc a Vista Atual */

       "|"  "R"                              /*Tipo preço*/
        "|"  0                                /*PVP Rec Fornecedor*/
        "|"  Artigo_pai
        "|"  Item-pai


        "|"  string(depto.clacod)            /*Departamento_codigo*/
        "|"  string(depto.clanom)            /*Departamento*/
        "|"  
        if avail     setclase 
        then  string(setClase.clacod) 
        else ""                         /*  Setor_cod */ 
        "|"  
        if avail     setclase 
        then  string(setClase.clanom) 
        else ""                         /*  Setor */ 
        
        "|"  
        if avail     grupo 
        then  string(Grupo.clacod)
        else ""                         /*  Grupo_cod   */
        "|"  
        if avail     grupo 
        then  string(Grupo.clanom)
        else ""                         /*  Grupo   */
        
        "|"          
        if avail    clase 
        then string(clase.clacod)  
        else ""                         /* Classe_cod */
        "|"  
        if avail    clase 
        then string(clase.clanom)  
        else ""                         /* Classe */
        


       "|"    produ.clacod                 /*# Sub-Classe */
       "|"    sclase.clanom                /*Sub-Classe */
       
       "|"  "UN"                                 /*Um. Medida*/
       
       
       "|"    estoq.estatual               /*Qtd. Estoque */
       
       "|"  estoq.estatual                       /*Estoque (Qtd)*/
       
       "|"    tt-1008.OTHER_STK_QTY / 10000       /*#Estoque CD */    
       "|"    tt-1008.SOO_QTY     / 10000         /*On-Order*/
       "|"    OPEN_TO_BUY                  /*Pode Comprar? */
       "|"    tt-1008.SOH_VAL    / 10000          /*R$ Estoque */
       "|"    tt-1008.SOO_VAL    / 10000          /*R$ Estoq. On-Order */ 
       "|"    tt-1008.OTHER_STK_VAL   / 10000     /*R$ Estoque CD */
       
       "|"  0                            /*%Imposto*/
       
       "|"    ITEM_ST_ATTR_07_NO / 10000      /*Alíquota de COFINS crédito*/
       "|"    ITEM_ST_ATTR_08_NO / 10000      /*Alíquota de COFINS débito*/
       "|"    ITEM_ST_ATTR_03_NO / 10000      /*Alíquota de ICMS crédito*/
       "|"    ITEM_ST_ATTR_04_NO / 10000      /*Alíquota de ICMS débito*/
       "|"    ITEM_ST_ATTR_09_NO / 10000      /*Alíquota de IPI*/
       
       "|"  ""               /*Brand cod */
       "|"  ""               /*Brand     */
       "|"  ""               /*Aliquota de MVA/IVA*/
       
       "|"    ITEM_ST_ATTR_05_NO / 10000      /*Alíquota de PIS crédito*/
       "|"    ITEM_ST_ATTR_06_NO / 10000      /*Alíquota de PIS débito*/
       
       "|"  estab.tamanho                        /*Tamanho*/
       
       "|"  produ.fabcod                         /*Principal fabricante cod*/
       
       "|"  
       if avail fabri
       then fabri.fabnom 
       else ""                              /*Principal fabricante*/
       
       
       "|"    vtipoLoja                /* Tipo de Loja*/
       
       "|"  ""                               /*Giro estoque ult 30d*/
       
       "|"    tt-226.ORIGINAL_RETAIL_PRICE / 10000 /* Preço Inicial*/
       "|"    estoq.estcusto           /* Preço de Custo*/
       "|"    if avail prof405
              then prof405.CALCULATE_DATE 
              else "" /* Data Efetiva do Preço de Custo*/

       "|"  Item-pai                     /*Item pai cod*/
       "|"  Item_cor_cod                 /* # Item-Cor*/
       "|"  estoq.estcusto               /*Preço de custo liquido*/
       "|"  Item_cor_cod                 /*Item cod*/
       
       "|"  tt-226.SEASON_ID         /*# Estação*/
       "|"  tt-226.LABEL_ID          /*# Marca*/
       "|"  PACKAGE_SIZE             /*Capacidade*/
       
       "|"  ""                               /*Classificação*/
       "|"  ""                               /*Companhia*/
       "|"  ""                               /*Companhia cod*/
       "|"  ""                               /*Cor*/
       "|"  categ.catnom                    /*  Departamento*/

       "|"  tt-226.ITEM_ATTR_02_CHAR        /*Estatus*/
       
       "|"    if avail temporada
              then temporada.tempnom 
              else ""                  /* Estação*/
       "|"    vdt_venda                /* Dia da primeira venda*/
       
       "|"  ""                           /*Idade estoque ajustada*/
       "|"  ""                           /*Imagem de preço*/
       
       
       "|"    ""                       /* Data Prod. Descontinuado*/
       "|"    if avail temporada
              then temporada.dtini          
              else ?                   /* Inicio da estação */
       "|"    if avail temporada
              then temporada.dtfim          
              else ?                   /*Fim da estação*/
       "|"    tt-226.END_OF_LIFE_DATE  /* Nomenclatura em Falta: DATA_FIM_VIDA*/

       "|"    "http://sv-ca-itim-p.lebes.com.br/proim/" +
                                    string(produ.procod) + ".jpg"
                                         /*Link p/ imagem*/

       "|"   if avail fabri
             then fabri.fabnom
             else "" /* Marca*/
       
       "|"  ""       /*Markup inicial*/
       "|"  tt-226.ITEM_ATTR_01_FLAG        /* Pedido Especial */
       "|"  tt-226.ITEM_ATTR_04_FLAG        /*Produto Brick*/
       "|"  tt-226.ITEM_ATTR_02_FLAG        /*Produto Importado*/
       "|"  tt-226.ITEM_ATTR_06_FLAG        /*Produto de Mostruário*/
       "|"  tt-226.ITEM_ATTR_05_FLAG        /*Produto descontinuado*/
       "|"  vvoltagem                    /*Voltagem*/
       "|"  if vetiqueta then "Y" else "N"              /*Etiqueta preço*/
       "|"  ""                           /*Volume*/
       "|"  ""                           /*Vda ult 30 (qtd)*/
       "|"  ""                           /*Vda Ult 30 D (R$)*/
            skip
           .
end.    

OUTPUT CLOSE.


message "Arquivo" Arquivo "gerado"
        view-as alert-box.
