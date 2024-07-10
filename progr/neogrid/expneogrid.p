/*  neogrid/expneogrid.p   */
def var vlocal as char.
pause 0 before-hide.

def input parameter par-tipo    as char.
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.

def var nome-arquivo as char.


def var vtoday as date.
vtoday = today.

/*** ***/
def var vtemmix  as log.
def var vcriamix as log.
def var vestmax  like mixmprod.estmax.
def var vestmin  like mixmprod.estmin.

def temp-table tt-estab-mix
    field etbcod     like mixmprod.etbcod
    field codgrupo   like mixmprod.codgrupo
    field prioridade like mixmgrupo.prioridade
    field estmax     like mixmprod.estmax
    field estmin     like mixmprod.estmin
    field situacao   as log
    
    index estab is primary unique etbcod.
/*** ***/


def temp-table temp-item
    field item    as char
    field ean     as char
    field descr   as char
    field fabcod  as char
    field marca   as char
    field unidade as char
    field emb     as int
    field embtra  as int
    field grupo1  as char
    field dgrupo1 as char
    field grupo2  as char
    field dgrupo2 as char
    field grupo3  as char
    field dgrupo3 as char
    field grupo4  as char
    field dgrupo4 as char
    field grupo5  as char
    field dgrupo5 as char
    index item is primary unique item.
    
for each temp-item.
    delete temp-item.
end.

def temp-table temp-sku
    field local                 as char
    field item                  as char
    field tipo                  as char
    field Local_Abast           as char
    field Descontinuado         as char
    field DataDescontinuacao    as char
    field Indicador             as char
    field DataValidade          as char
    index temp-sku   is primary unique local asc item asc.
    
    
for each temp-sku.
    delete temp-sku.
end.

def temp-table  temp-stock
    field DtRefer        as char     
    field Local          as char     
    field Item           as char     
    field EstDisp        as char     
    field EstTran        as char     
    field EstornoVenda   as char     
    field QtdPedPendente as char     
    field QtdSaiTransf   as char     
    field QtdEntTransf   as char   
    index temp-stock is primary unique DtRefer Local Item.

def var vsel as int.

def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").

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
    field CREATE_USER_ID  as char format "x(25)"
    field CREATE_DATETIME as char format "x(16)"
    field LAST_UPDATE_USER_ID as char format "x(25)"
    field LAST_UPDATE_DATETIME    as char format "x(16)"
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
    field   CREATE_USER_ID  as char format "x(25)"
    field   CREATE_DATETIME as char format "x(16)"
    field   LAST_UPDATE_USER_ID as char format "x(25)"
    field   LAST_UPDATE_DATETIME    as char format "x(16)"
    field   IMAGE_FILE_LINK as char format "x(1024)".

def temp-table tt-323 no-undo
    field STORE_ID    as char format "x(10)"
    field SKU_ID      as char format "x(25)"
    field ORIGIN_ID   as char format "x(12)"
    field OPEN_TO_BUY as char format "x(1)"
    field MIN_STK_QTY         as dec format ">>>>>>>>9999"
    field MAX_STK_QTY         as dec format ">>>>>>>>9999"
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
    field RECORD_STATUS       as char format "x(1)"
    field CREATE_USER_ID      as char format "x(25)"
    field CREATE_DATETIME     as char format "x(16)"
    field LAST_UPDATE_USER_ID as char format "x(25)"
    field LAST_UPDATE_DATETIME as char format "x(16)"

    index tt-323 is primary unique STORE_ID SKU_ID.
    
def var vestatual like estoq.estatual.

def buffer cmovim for movim.
def buffer cplani for plani.

def var vsituacao as log.

def var vestatus-d as char extent 4  FORMAT "X(15)"
    init["NORMAL","BRINDE","FORA DE LINHA","FORA DO MIX"].            
def var vestatus as int.    
def var vtot as int.
vtot = 0.
def buffer bforne for forne.
def buffer bfabri for fabri.

def buffer clase1 for clase.
def buffer clase2 for clase.
def buffer clase3 for clase.
def buffer clase4 for clase.
def buffer clase5 for clase.
def buffer clase6 for clase.

def temp-table ttprodu
    field procod    like produ.procod
    index procod is primary unique procod. 

def temp-table tt-cla 
    field clacod    like clase.clacod column-label "SubClasse" 
    index clacod is primary unique clacod. 
for each tt-cla.
    delete tt-cla.
end.
def buffer xclase for clase.
do on error undo. 
    find first tbcntgen where tbcntgen.tipcon = 9999 and 
                              tbcntgen.etbcod = 0 no-error.  
    if not avail tbcntgen 
    then do.
        create tbcntgen. 
        tbcntgen.tipcon = 9999. 
        tbcntgen.etbcod = 0. 
        tbcntgen.campo1[1] = 
                        "CLASSES PARA A EXPOTACAO NEOGRID estao no campo2[1]".
        tbcntgen.campo2[1] = "129000000".
    end.
end.

def var vparam as char. 
vparam = tbcntgen.campo2[1].

def var vct as int.

do vct = 1 to int(num-entries(vparam)) with down. 
    if entry(vct, vparam, ",") = "" 
    then next. 
    create tt-cla. 
    assign tt-cla.clacod = int(entry(vct, vparam, ",")).
end.

for each tt-cla.
    run produtos (input tt-cla.clacod).
end.

procedure produtos.
def input parameter par-clacod  like clase.clacod.

find clase where clase.clacod = par-clacod no-lock.
for each produ where produ.clacod = clase.clacod no-lock. 
    create ttprodu.
    ttprodu.procod = produ.procod.
end.

for each clase1 where clase1.clasup = clase.clacod no-lock.
    for each produ where produ.clacod = clase1.clacod no-lock. 
        create ttprodu.
        ttprodu.procod = produ.procod.
    end.
    for each clase2 where clase2.clasup = clase1.clacod no-lock.
        for each produ where produ.clacod = clase2.clacod no-lock. 
            create ttprodu.
            ttprodu.procod = produ.procod.
        end.
        for each clase3 where clase3.clasup = clase2.clacod no-lock.
            for each produ where produ.clacod = clase3.clacod no-lock. 
                create ttprodu.
                ttprodu.procod = produ.procod.
            end.
            for each clase4 where clase4.clasup = clase3.clacod no-lock.
                for each produ where produ.clacod = clase4.clacod no-lock. 
                    create ttprodu.
                    ttprodu.procod = produ.procod.
                end.
                for each clase5 where clase5.clasup = clase4.clacod no-lock.
                    for each produ where produ.clacod = clase5.clacod no-lock. 
                        create ttprodu.
                        ttprodu.procod = produ.procod.
                    end.
                    for each clase6 where 
                                        clase6.clasup = clase5.clacod no-lock.
                        for each produ where 
                                        produ.clacod = clase6.clacod no-lock. 
                            create ttprodu.
                            ttprodu.procod = produ.procod.
                        end.
                    end.
                end.
            end.
        end.
    end.
end.
end procedure.

for each forneaux where forneaux.Nome_Campo = "NEOGRID" no-lock,
    first bforne of forneaux no-lock,
    first bfabri where bfabri.fabcod = bforne.forcod no-lock,
    each produ where produ.procod < 9999999 
       and produ.fabcod = bfabri.fabcod
                     no-lock .
    find first ttprodu where ttprodu.procod = produ.procod no-lock no-error.
    if not avail ttprodu
    then next.
    vtot = vtot + 1.
end.


def var vcont as int.
vcont = 0.

for each forneaux where forneaux.Nome_Campo = "NEOGRID" no-lock,
    first bforne of forneaux no-lock,
    first bfabri where bfabri.fabcod = bforne.forcod no-lock,    
    each produ where produ.procod < 9999999 
       and produ.fabcod = bfabri.fabcod
                     no-lock .
    find first ttprodu where ttprodu.procod = produ.procod no-lock no-error.
    if not avail ttprodu
    then next.
    if proseq <> 0
    then do on error undo.
        next. 
    end. 
    vcont = vcont + 1.
    if vcont mod 1 = 0 or vcont < 10
    then do.
        message vcont "de" vtot vcont / vtot * 100 "SELECIONADO: " vsel.
    end.
    
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
    if vsel mod 1 = 0
    then do.
    message "      " produ.procod "selecionado" vsel time xtime.
    end.
    
    /*** Estatus ***/
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
                tt-226.SKU_ID      =   string(produ.procod)
                tt-226.MERCH_L2_ID =   string(depto.clacod)
                tt-226.MERCH_L3_ID =   if avail setclase
                                       then  string(setClase.clacod)
                                       else "" 
                tt-226.MERCH_L4_ID =   if avail     grupo
                                       then  string(Grupo.clacod)
                                       else ""
                tt-226.MERCH_L5_ID =   if avail    clase
                                       then string(clase.clacod) 
                                       else ""
                tt-226.MERCH_L6_ID =   if avail    sclase
                                       then string(sclase.clacod) 
                                       else "" 
                tt-226.ORIGIN_ID   =   "LEBES"
                tt-226.LABEL_ID    =   string(produ.fabcod)
                tt-226.PRIMARY_SUPPLIER_ID  = string(produ.fabcod)
                tt-226.COLOUR_ID   =   ""
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
                tt-226.IMAGE_FILE_LINK =
                        /**
                        "~\~\sv-ca-stg.lebes.com.br~\Pro_Im~\proim" + 
                                "~\" +
                                    string(produ.procod) + ".jpg".
                                    **/

        "http://sv-ca-itim-p.lebes.com.br/proim/" +
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
                tt-226.CREATE_USER_ID           = "ADMCOM"           .
                tt-226.CREATE_DATETIME          = vprodtcad           .
                tt-226.LAST_UPDATE_USER_ID      = "ADMCOM"           .
                tt-226.LAST_UPDATE_DATETIME     = vsysdata           .

    assign
        vcriamix = yes
        vestmax  = 0
        vestmin  = 0.
    if produ.catcod = 41
    then run mix-moda (output vtemmix). /* acertar tt-estab */

    /***
        ESTAB
    ***/

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
        if estab.tipoLoja = "escritorio" then next.
            
        /***************
        em 12/09/2013 todos os produtos irao para o Profimetrics
        54 [LEBES] Retirar filtro "descontinuados" e "classes" na interface 323
        
        if produ.clacod = 128061101 or
           produ.clacod = 128061701 or 
           produ.clacod = 128061702 or 
           produ.clacod = 128060107 or 
           produ.clacod = 129050101 or 
           produ.clacod = 118060101 or 
           produ.clacod = 118060102 or 
           produ.clacod = 118060103 or 
           produ.clacod = 118060201 or 
           produ.clacod = 118060202 or 
           produ.clacod = 118060203 or 
           produ.clacod = 118060204 or 
           produ.clacod = 127040202 or 
           produ.clacod = 127040203 or 
           produ.clacod = 127040204 or 
           produ.clacod = 127040205 or 
           produ.clacod = 127040206  
        then.
        else 
        if produ.descontinuado 
        then 
            if produ.datfimvida < 08/10/2013 then next.
        ***************/        
        
        if produ.catcod = 31 or
           produ.catcod = 41
        then .
        else next.
        
        if produ.catcod = 41 
        then do.
            assign
                vestmax = 0
                vestmin = 0
                vcriamix = no.

            if vtemmix
            then do.
                find tt-estab-mix where tt-estab-mix.etbcod = estab.etbcod
                                    and tt-estab-mix.situacao
                              no-lock no-error.
                if not avail tt-estab-mix
                then assign
                        vcriamix = no.
                else
                    assign
                        vestmax  = tt-estab-mix.estmax
                        vestmin  = tt-estab-mix.estmin
                        vcriamix = yes.
            end.
        end.    

        def var vITEM_ST_ATTR_01_NO as dec.
        find estoq where estoq.procod = produ.procod and 
                         estoq.etbcod = estab.etbcod no-lock no-error.
        /* em 16/10/2013 - produto sem registro de estoq não cria 323*/
        if not avail estoq
        then next.
        vITEM_ST_ATTR_01_NO = if avail estoq and estoq.estatual > 0
                              then estoq.estatual * 10000
                              else 0.
        if vmovalicms = ? 
        then vmovalicms = 0.

        if vcriamix
        then do.

            find tt-323 where tt-323.STORE_ID   = string(estab.etbcod) and
                              tt-323.SKU_ID     = string(produ.procod)
                          no-error.  
            if not avail tt-323
            then create tt-323.
            assign tt-323.STORE_ID    = string(estab.etbcod)
                   tt-323.SKU_ID      = string(produ.procod)
                   tt-323.ORIGIN_ID   = "LEBES"
                   tt-323.OPEN_TO_BUY = string(produ.opentobuy,"Y/N")
                   tt-323.MIN_STK_QTY = vestmin * 10000
                   tt-323.MAX_STK_QTY = vestmax * 10000
                   tt-323.ITEM_ST_ATTR_01_NO  = vITEM_ST_ATTR_01_NO
                   tt-323.ITEM_ST_ATTR_02_NO  = 0
                   tt-323.ITEM_ST_ATTR_03_NO  = vmovalicms * 10000
                   tt-323.ITEM_ST_ATTR_04_NO  = if produ.proipiper = ? or 
                                                   produ.proipiper = 99
                                                then 0
                                                else produ.proipiper * 10000
                   /*17    * 10000       .*/
                   tt-323.ITEM_ST_ATTR_09_NO  = 0     * 10000
                   tt-323.ITEM_ST_ATTR_10_NO  = 0     * 10000
               
               
                   tt-323.RECORD_STATUS            = "A"
                   tt-323.CREATE_USER_ID           = "ADMCOM"
                   tt-323.CREATE_DATETIME          = vsysdata
                   tt-323.LAST_UPDATE_USER_ID      = "ADMCOM"
                   tt-323.LAST_UPDATE_DATETIME     = vsysdata.
        end. /* vtemmix */
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
    
    def var vpreco as log.
    def var vpromoc as log.
 
    run exp226.    
    run exp323.

    for each tt-226. delete tt-226. end.
    for each tt-323. delete tt-323. end.
    for each tt-1008. delete tt-1008. end.
    
end.            


procedure exp226.

for each tt-226.
    find produ where produ.procod = int(tt-226.SKU_ID) no-lock no-error.
    find first ttprodu where ttprodu.procod = produ.procod no-lock no-error.
    if not avail ttprodu
    then next.
    find fabri of produ no-lock no-error.
    if not avail fabri then next.
    find first forne where forne.forcod = fabri.fabcod no-lock no-error.
    if not avail forne then next.
    find forneaux of forne where 
         forneaux.Nome_Campo = "NEOGRID" no-lock no-error.
    if not avail forneaux then next.
    if forneaux.Valor_Campo <> "SIM" then next.    
    /*if tt-226.EAN = "" then next.*/
    find first temp-item 
                where temp-item.item = tt-226.SKU_ID
                        no-error.
    if not avail temp-item
    then create temp-item.
    assign temp-item.item    = tt-226.SKU_ID
           temp-item.ean     = tt-226.EAN
           temp-item.descr   = tt-226.SKU_DESC
           temp-item.fabcod  = tt-226.LABEL_ID
           temp-item.marca   = ""
           temp-item.unidade = if avail produ
                                  then produ.prouncom
                                  else ""
           temp-item.emb     = 0                
           temp-item.embtra  = 0.
                            
    find clase where clase.clacod = int(tt-226.MERCH_L2_ID) no-lock no-error.
           temp-item.grupo1  = tt-226.MERCH_L2_ID.
           temp-item.dgrupo1 = if avail clase then clase.clanom else "".
           
    find clase where clase.clacod = int(tt-226.MERCH_L3_ID) no-lock no-error.  
           temp-item.grupo2  = tt-226.MERCH_L3_ID.
           temp-item.dgrupo2 = if avail clase then clase.clanom else "". 
           
    find clase where clase.clacod = int(tt-226.MERCH_L4_ID) no-lock no-error.             temp-item.grupo3  = tt-226.MERCH_L4_ID.
           temp-item.dgrupo3 = if avail clase then clase.clanom else "".
           
    find clase where clase.clacod = int(tt-226.MERCH_L5_ID) no-lock no-error.
           temp-item.grupo4  = tt-226.MERCH_L5_ID.
           temp-item.dgrupo4 = if avail clase then clase.clanom else "".

    find clase where clase.clacod = int(tt-226.MERCH_L6_ID) no-lock no-error.
           temp-item.grupo5  = tt-226.MERCH_L6_ID.
           temp-item.dgrupo5 = if avail clase then clase.clanom else "".


end.

end procedure.



procedure exp323.


for each tt-323.
    find produ where produ.procod = int(tt-323.SKU_ID) no-lock.
    find first ttprodu where ttprodu.procod = produ.procod no-lock no-error.
    if not avail ttprodu
    then next.
    find fabri of produ no-lock no-error.
    if not avail fabri then next.
    find first forne where forne.forcod = fabri.fabcod no-lock no-error.
    if not avail forne then next.
    find forneaux of forne where 
         forneaux.Nome_Campo = "NEOGRID" no-lock no-error.
    if not avail forneaux then next.
    if forneaux.Valor_Campo <> "SIM" then next.    
    def var vlocal as char.
    find estab where estab.etbcod = int(tt-323.STORE_ID) no-lock no-error.
    if estab.etbcod = 189 then next.
    vlocal =  string(estab.etbcod,"999").
    find produ where produ.procod = int(tt-323.SKU_ID) no-lock.
    find temp-sku where temp-sku.local = vlocal and
                           temp-sku.item  = tt-323.SKU_ID 
                           no-error.
    if not avail temp-sku
    then create temp-sku.
    assign temp-sku.local  = vlocal
           temp-sku.item   = tt-323.SKU_ID
           temp-sku.tipo               = ""
           temp-sku.Local_Abast        = string(900,"999")
           temp-sku.Descontinuado      = if produ.descontinuado = yes  
                                            then "1"   
                                            else "0"
           temp-sku.DataDescontinuacao = if produ.datfimvida = ?
                                            then "00000000"
                                            else 
                                string(year (produ.datfimvida),"9999") +
                                string(month(produ.datfimvida),"99"  ) + 
                                string(day  (produ.datfimvida),"99"  )
           temp-sku.indicador          = ""   
           temp-sku.DataValidade       = ""  .
end.
end procedure.

procedure pega-vreserva_loja_cd.
def buffer pestoq for estoq.
def input  parameter par-procod like produ.procod.

def var vespecial  as int.
def var vdata as date.

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

if compras_pendentes_entrega_CD < 0
then compras_pendentes_entrega_CD = 0.
end procedure.


def var vestatual900  like estoq.estatual format "->>>>9".
def var vestatual980  like estoq.estatual format "->>>>9".
def var vdisponiv993  like estoq.estatual format "->>>>9".
def var vdisponiv981  like estoq.estatual format "->>>>9".
def var vestatual993  like estoq.estatual format "->>>>9".
def var vestatual981  like estoq.estatual format "->>>>9".
def var vestatual998  like estoq.estatual format "->>>>9".
def var vestatual500  like estoq.estatual format "->>>>9".
def var vreservado like estoq.estatual.
def var vestcusto like estoq.estcusto.



procedure 1008.
    
    vdisponiv993 = 0.
    vdisponiv981 = 0.
    vestatual993 = 0. vestatual981 = 0.
    vestatual900 = 0.
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
    find estoq where estoq.etbcod = 981 and estoq.procod = vvprocod
        no-lock no-error.
    if avail estoq then assign vestatual981 = vestatual981 + estoq.estatual.
    
    find estoq where estoq.etbcod = 900 and estoq.procod = vvprocod
        no-lock no-error.
    if avail estoq then assign vestatual900 = vestatual900 + estoq.estatual.

    find estoq where estoq.etbcod = 980 and estoq.procod = vvprocod
        no-lock no-error.
    if avail estoq then assign vestatual980 = vestatual980 + estoq.estatual.

    find estoq where estoq.etbcod = 998 and estoq.procod = vvprocod
        no-lock no-error.
    if avail estoq then assign vestatual998 = vestatual998 + estoq.estatual.
    find estoq where estoq.etbcod = 500 and estoq.procod = vvprocod           
        no-lock no-error.                                                     
    if avail estoq then assign vestatual500 = vestatual500 + estoq.estatual.  


                                           /* estoq terceiros */
            vestatual_cd =  vestatual993 + vestatual981 +
                            vestatual900 + 
                            vestatual980 +
                            /* em 28/08 Joao solicitou para nao enviar estoque
                               do deposito 998     
                            vestatual998 + 
                            */
                            vestatual500.

             run compras_pendentes_entrega_CD
                                ( input  produ.procod, 
                                  output compras_pendentes_entrega_CD).

             /* cria tt-reserva para pegar as reservas */

             run pega-vreserva_loja_cd( input  produ.procod).

    for each estoq where estoq.procod = produ.procod /*and
                (estoq.etbcod = 1 or estoq.etbcod = 2 or estoq.etbcod = 3)
                */
                
                no-lock.      
            if estoq.etbcod = 189 then next.    
            if estoq.etbcod = 981 then next.    
            find estab where estab.etbcod = estoq.etbcod
                                no-lock no-error.
            if not avail estab
            then next.

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
            /* depositos vao para a NEOGRID 
            if vtipoLoja      = "W"       then next. */
            
            if estab.tipoLoja = "Virtual" and
               estab.etbcod <> 981 then next.
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
                        
                    tt-1008.CREATE_USER_ID           = "ADMCOM"           .
                    tt-1008.CREATE_DATETIME          = vsysdata           .
                    tt-1008.LAST_UPDATE_USER_ID      = "ADMCOM"           .
                    tt-1008.LAST_UPDATE_DATETIME     = vsysdata           .
                    .
        
    
        end. /* if not avail tt-1008 ... */    
        /* cria temp-table STOCK da NEOGRID     */
        find fabri of produ no-lock no-error.
        if avail fabri 
        then do.
            find first forne where forne.forcod = fabri.fabcod no-lock no-error.
            if avail forne 
            then do.
                find first ttprodu where 
                                ttprodu.procod = produ.procod no-lock no-error.
                find forneaux of forne where 
                     forneaux.Nome_Campo = "NEOGRID" no-lock no-error.
                def buffer estoq_981 for estoq.
                def var vestatual like estoq.estatual.
                vestatual = estoq.estatual.
                if estoq.etbcod = 993
                then do.
                    find estoq_981 where estoq_981.etbcod = 981 and
                                         estoq_981.procod = estoq.procod 
                                         no-lock no-error.
                    if avail estoq_981
                    then vestatual = vestatual + estoq_981.estatual.
                end.
                if avail forneaux and avail ttprodu
                then do.
                    if forneaux.Valor_Campo = "SIM" /*and
                       produ.proindice <> ? */
                    then do.
                        vlocal =  string(estoq.etbcod,"999").
                        create temp-stock.
                        assign
                        temp-stock.DtRefer        =
                                string(year (vtoday),"9999") +
                                string(month(vtoday),"99"  ) + 
                                string(day  (vtoday),"99"  )
                        temp-stock.Local          = vlocal
                        temp-stock.Item           = string(produ.procod)
                        temp-stock.EstDisp        = if vestatual > 0
                                               then 

            trim(string(vestatual,">>>>>>>>>>>>>>9.9999"))
                                               else trim("0")
                        temp-stock.EstTran        = ""
                        temp-stock.EstornoVenda   = ""
                        temp-stock.QtdPedPendente = 
            trim(string(compras_pendentes_entrega_CD ,">>>>>>>>>>>>>>9.9999"))
                        temp-stock.QtdSaiTransf   = ""
                        temp-stock.QtdEntTransf   = ""
                        .
                    end.
                end.
            end.
        end.
        /*                                      */

        
        
    
    end.


end procedure.


procedure mix-moda.

    def output parameter par-tem-mix as log.
    par-tem-mix = no.

    for each tt-estab-mix.
        delete tt-estab-mix.
    end.

    /* Tratar mix desativados 03/10/2013 */
    for each mixmprod where mixmprod.procod = produ.procod
                        and mixmprod.etbcod = 0
                        and mixmprod.situacao = no
                      no-lock.

        /* Estabs do grupo */
        for each mixmgruetb where mixmgruetb.codgrupo = mixmprod.codgrupo
                            no-lock.
            find tt-estab-mix where tt-estab-mix.etbcod     = mixmgruetb.etbcod
                            no-error.
            if not avail tt-estab-mix
            then create tt-estab-mix.
            assign
                tt-estab-mix.etbcod     = mixmgruetb.etbcod
                tt-estab-mix.situacao   = no.
        end.
    end.    
    /* Definir os estabelecimentos do produto */
    for each mixmprod where mixmprod.procod = produ.procod
                        and mixmprod.etbcod = 0
                        and mixmprod.situacao
                      no-lock.
        find mixmgrupo of mixmprod no-lock.

        /* Estabs do grupo */
        for each mixmgruetb where mixmgruetb.codgrupo = mixmprod.codgrupo
                              and mixmgruetb.situacao
                            no-lock.
            par-tem-mix = yes.

            find tt-estab-mix where tt-estab-mix.etbcod = mixmgruetb.etbcod
                              no-error.
            if not avail tt-estab-mix or
               tt-estab-mix.situacao = no
            then do.
                if not avail tt-estab-mix
                then do.
                    create tt-estab-mix.
                    assign
                        tt-estab-mix.etbcod     = mixmgruetb.etbcod.
                end.
                assign
                    tt-estab-mix.codgrupo   = mixmgruetb.codgrupo
                    tt-estab-mix.prioridade = mixmgrupo.prioridade
                    tt-estab-mix.estmax     = mixmprod.estmax
                    tt-estab-mix.estmin     = mixmprod.estmin
                    tt-estab-mix.situacao   = yes.
            end.
            else do.
                /* Estab ja incluido - verificar prioridade */
                if mixmgrupo.prioridade < tt-estab-mix.prioridade
                then
                    assign
                        tt-estab-mix.codgrupo   = mixmgruetb.codgrupo
                        tt-estab-mix.prioridade = mixmgrupo.prioridade
                        tt-estab-mix.estmax     = mixmprod.estmax
                        tt-estab-mix.estmin     = mixmprod.estmin.
            end.
        end.
    end.

    /* Acertar excecoes de min e max */
        
    for each mixmprod where mixmprod.procod = produ.procod
                        and mixmprod.etbcod > 0
                        and mixmprod.situacao
                      no-lock.
                                                            /**/
        find tt-estab-mix where tt-estab-mix.etbcod = mixmprod.etbcod 
                          no-error.
        if not avail tt-estab-mix
        then next.
        
        if tt-estab-mix.codgrupo = mixmprod.codgrupo
        then assign
            tt-estab-mix.estmax     = mixmprod.estmax
            tt-estab-mix.estmin     = mixmprod.estmin.
    end.

end procedure.



nome-arquivo = "/admcom/tmp/neogrid/" + 
                "ITEM_" +
                    string(year (today),"9999") +
                    string(month(today),"99"  ) +
                    string(day  (today),"99"  ) +
           substr(  string(time        ,"HH:MM"),1,2) +
           substr(  string(time        ,"HH:MM"),4,2) +
                    "001".
output to value(nome-arquivo).
for each temp-item.
    put unformatted 
           temp-item.item    ";"
           temp-item.ean     ";"
           temp-item.descr   ";"
           temp-item.fabcod  ";"
           temp-item.marca   ";"
           temp-item.unidade ";"
           temp-item.emb     ";"
           temp-item.embtra  ";"
           temp-item.grupo1  ";"
           temp-item.dgrupo1 ";"
           temp-item.grupo2  ";"
           temp-item.dgrupo2 ";"
           temp-item.grupo3  ";"
           temp-item.dgrupo3 ";"
           temp-item.grupo4  ";"
           temp-item.dgrupo4 ";"
           temp-item.grupo5  ";"
           temp-item.dgrupo5 
        skip.
    delete temp-item.
end.
output close.       
unix silent value ("unix2dos " + nome-arquivo).


nome-arquivo = "/admcom/tmp/neogrid/" + 
                "SKU_" +
                    string(year (today),"9999") +
                    string(month(today),"99"  ) +
                    string(day  (today),"99"  ) +
           substr(  string(time        ,"HH:MM"),1,2) +
           substr(  string(time        ,"HH:MM"),4,2) +
                    "001".
output to value(nome-arquivo ).
for each temp-sku.
    put unformatted 
           temp-sku.local               ";"
           temp-sku.item                ";"
           temp-sku.tipo                ";"
           temp-sku.Local_Abast         ";"
           temp-sku.Descontinuado       ";"
           temp-sku.DataDescontinuacao  ";"
           temp-sku.Indicador           ";"
           temp-sku.DataValidade  
        skip.
    delete temp-sku.
end.
output close.       
unix silent value ("unix2dos " + nome-arquivo).


nome-arquivo = "/admcom/tmp/neogrid/" + 
                "STOCK_" +
                    string(year (today),"9999") +
                    string(month(today),"99"  ) +
                    string(day  (today),"99"  ) +
           substr(  string(time        ,"HH:MM"),1,2) +
           substr(  string(time        ,"HH:MM"),4,2) +
                    "001".
output to value(nome-arquivo ).
for each temp-stock.
    put unformatted 
         temp-stock.DtRefer        ";"     
         temp-stock.Local          ";"     
         temp-stock.Item           ";"     
         temp-stock.EstDisp        ";"     
         temp-stock.EstTran        ";"     
         temp-stock.EstornoVenda   ";"     
         temp-stock.QtdPedPendente ";"     
         temp-stock.QtdSaiTransf   ";"     
         temp-stock.QtdEntTransf    
        skip.
    delete temp-stock.
end.
output close.       
unix silent value ("unix2dos " + nome-arquivo).





def temp-table temp-local
    field codigo    as char
    field aux       as char
    field descr     as char
    field cidade    as char
    field ufecod    as char
    field estatus   as char
    field tipo      as char
    field bandeira  as char
    field descband  as char
    index temp-local is primary unique codigo
           .  
for each temp-local.
    delete temp-local.
end.
for each estab no-lock.
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
    
    find regiao of estab no-lock no-error.
    find unfed of estab no-lock.
    def var vtipo as char.
    vtipo =  
            if estab.tipoLoja = "CD" 
            then "01" else
            if estab.tipoLoja = "E-commerce"  
            then "08" else
            if estab.tipoLoja = "Escritorio"  
            then "10" else
            if estab.tipoLoja = "Normal"  
            then "05" else
            if estab.tipoLoja = "Outlet"  
            then "05" else 
            if estab.tipoLoja = "Virtual" 
            then "08" else "05".
    def var v as char.
    v = replace (etbcgc,".","").
    v = replace (v,"/","").
    v = replace (v,"-","").
    find first temp-local 
                where temp-local.codigo = string(estab.etbcod,"999")
                        no-error.
    if not avail temp-local
    then create temp-local.
    assign temp-local.codigo  = string(estab.etbcod,"999") 
           temp-local.aux     = v               
           temp-local.descr  = /*string(estab.etbcod,"999") + " " + */
                                                estab.endereco 
           temp-local.cidade = estab.munic          
           temp-local.ufecod = estab.ufecod         
           temp-local.estatus = "1"                  
           temp-local.tipo   = vtipo                
           temp-local.bandeira = ""                 
           temp-local.descband = ""                 
            .
    
end.            
            
nome-arquivo = "/admcom/tmp/neogrid/" + 
                "LOCATION_" +
                    string(year (today),"9999") +
                    string(month(today),"99"  ) +
                    string(day  (today),"99"  ) +
           substr(  string(time        ,"HH:MM"),1,2) +
           substr(  string(time        ,"HH:MM"),4,2) +
                    "001".
output to value(nome-arquivo ).
for each temp-local.
    if temp-local.aux = ""
    then next.
    put unformatted 
        temp-local.codigo  ";"
        temp-local.aux ";"
        temp-local.descr   ";"
        temp-local.cidade  ";"
        temp-local.ufecod  ";"
        temp-local.estatus ";"
        temp-local.tipo    ";"
        temp-local.bandeira    ";"
        temp-local.descband    
        skip.
    delete temp-local.
end.
output close.       
unix silent value ("unix2dos " + nome-arquivo).

nome-arquivo = "/admcom/tmp/neogrid/" + 
                "VENDOR_" +
                    string(year (today),"9999") +
                    string(month(today),"99"  ) +
                    string(day  (today),"99"  ) +
           substr(  string(time        ,"HH:MM"),1,2) +
           substr(  string(time        ,"HH:MM"),4,2) +
                    "001".
output to value(nome-arquivo ).
for each fabri no-lock. 
    find first forne where forne.forcod = fabri.fabcod no-lock no-error.
    if not avail forne then next.
    find forneaux of forne where 
         forneaux.Nome_Campo = "NEOGRID" no-lock no-error.
    if not avail forneaux then next.
    if forneaux.Valor_Campo <> "SIM" then next.
    
    put unformatted 
        fabri.fabcod   ";"
       (if avail forne
        then forne.forcgc
        else string(fabri.fabcod))   ";"
        fabri.fabnom   ";"
        (if avail forne
        then forne.ufecod
        else "")
        skip.
end.
output close.       
unix silent value ("unix2dos " + nome-arquivo).

       
       



pause 0 before-hide.

def var vdata   as date.



vtoday = today.


vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").
         
def temp-table temp-sales
    field dtreferencia      as char format "x(16)"
    field local             as char format "x(10)"
    field item              as char format "x(25)"
    field qtdvenda          as dec format ">>>>>>>>>>>>9.9999"
    field ctomedio          as dec format ">>>>>>>>>>>>9.9999"
    field pcvenda           as dec format ">>>>>>>>>>>>9.99"
    field vltotal           as dec format ">>>>>>>>>>>>9.9999"
    field qtdtickets        as dec format ">>>>>>>>>>>>>>>>>9"
    index xx is primary unique 
                        dtreferencia
                        local  
                        item     .
                        
def buffer nivel1 for clase.
def buffer nivel2 for clase.

def var vd as int.

vd = 1.



for each tipmov where movtdc = 5 no-lock.
    for each estab where estab.etbcod >= 1 and estab.etbcod <= 1000 no-lock. 
    do vdata = par-dtini to par-dtfim .
    for each plani where plani.movtdc = tipmov.movtdc
                 and plani.etbcod = estab.etbcod
                 and plani.pladat = vdata no-lock.
    for each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat no-lock,
            first produ where produ.procod = movim.procod no-lock,
            first sclase where sclase.clacod = produ.clacod no-lock,
            first clase where clase.clacod = sclase.clasup no-lock,
            first nivel2 where nivel2.clacod = clase.clasup no-lock,
            first nivel1 where nivel1.clacod = nivel2.clasup no-lock.
            if nivel1.clacod = 0
            then next.
            find first ttprodu where 
                                ttprodu.procod = produ.procod no-lock no-error.
            if not avail ttprodu
            then next.
            find fabri of produ no-lock no-error.
            if not avail fabri then next.
            find first forne where forne.forcod = fabri.fabcod 
                                no-lock no-error.
            if not avail forne then next.
            find forneaux of forne where 
                 forneaux.Nome_Campo = "NEOGRID" no-lock no-error.
            if not avail forneaux then next.
            if forneaux.Valor_Campo <> "SIM" then next.            
            
            qtd_venda   = movim.movqtm.
            vlocal =  string(movim.etbcod,"999").
            find temp-sales where 
                    temp-sales.dtreferencia = 
                                string(year (movim.movdat),"9999") +
                                string(month(movim.movdat),"99"  ) +
                                string(day  (movim.movdat),"99"  ) and
                    temp-sales.item     = string(movim.procod)    and 
                    temp-sales.local   = vlocal
                              no-error.
            if not avail temp-sales
            then create temp-sales.
            temp-sales.dtreferencia = 
                                string(year (movim.movdat),"9999") +
                                string(month(movim.movdat),"99"  ) +
                                string(day  (movim.movdat),"99"  ).
            temp-sales.item     = string(movim.procod).
            temp-sales.local   = vlocal.

            find estoq where estoq.etbcod = movim.etbcod and
                             estoq.procod = movim.procod no-lock.
            qtdvenda = qtdvenda + qtd_venda .
            qtdtickets  = qtdtickets + 1.
            pcvenda = estoq.estvenda.

    end.    /*  for each movim      */
    end.    /*  for each plani      */
    end.    /*  do vdata = vdtini   */
    end.    /*  for each estab      */
end.        /*  for each tipmov     */

if par-tipo = "SEMANAL"
then nome-arquivo = "/admcom/tmp/neogrid/" + 
                        "SEMANAL_" +
                            string(year (today),"9999") +
                            string(month(today),"99"  ) +
                            string(day  (today),"99"  ) +
                   substr(  string(time        ,"HH:MM"),1,2) +
                   substr(  string(time        ,"HH:MM"),4,2) +
                            ".txt".
else nome-arquivo = "/admcom/tmp/neogrid/" + 
                        "SALES_" +
                            string(year (today),"9999") +
                            string(month(today),"99"  ) +
                            string(day  (today),"99"  ) +
                   substr(  string(time        ,"HH:MM"),1,2) +
                   substr(  string(time        ,"HH:MM"),4,2) +
                            "001".

if par-tipo = "SEMANAL"
then output to value(nome-arquivo ).                    
else output to value(nome-arquivo ).                    

for each temp-sales.
    put unformatted
        temp-sales.DtReferencia             ";"
        temp-sales.Local                    ";"
        temp-sales.Item                     ";"
        trim(string(temp-sales.qtdvenda  ,">>>>>>>>>>>>9.9999")) ";"
        trim(string(temp-sales.ctomedio  ,">>>>>>>>>>>>9.9999")) ";"
        trim(string(temp-sales.pcvenda   ,">>>>>>>>>>>>9.99"  )) ";"
        trim(string(temp-sales.vltotal   ,">>>>>>>>>>>>9.99"  )) ";"
        trim(string(temp-sales.qtdtickets,">>>>>>>>>>>>>>>>>9"))
        skip.

end. 
output close.
unix silent value ("unix2dos " + nome-arquivo).

