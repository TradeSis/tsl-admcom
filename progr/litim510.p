def var  /*input parameter*/ par-destino as char
                format "x(60)".



update par-destino label "Arquivo destino" colon 16
        with side-label row 3 width 80.

pause 0 before-hide.
def var a_vista as log.
def temp-table tt-planobiz
    field crecod as integer
    index idx01 crecod.
for each tabaux where tabaux.tabela = "PlanoBiz" no-lock:
    create tt-planobiz.
    assign tt-planobiz.crecod = integer(tabaux.valor_campo).    
      
end.
def var vplanobiz as log.
def buffer bestoq for estoq.
def var vcodplano as int. 
def var vcrecod     as int.
def var vvprocod like produ.procod.
def var vreserva_loja_cd as dec.
def var compras_pendentes_entrega_CD as dec.
def var vestatual_cd as dec.

def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").
         
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
                        STORE_ID
    .
def var val_acr like plani.platot.
def var val_des like plani.platot.
def var val_dev like plani.platot.
def var val_com like plani.platot.
def var valor_venda like val_com.
def var qtd_venda   like movim.movqtm.
def var val_fin like plani.platot.
def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer nivel1 for clase.
def buffer nivel2 for clase.

def var vdtini  as date.
def var vdtfim  as date.
def var vdata   as date.
find first tbcntgen where tbcntgen.tipcon = 10 and
                          tbcntgen.etbcod = 0 no-lock.
vdtini = tbcntgen.datini.
vdtfim = tbcntgen.datfim.

update vdtini colon 16 label "Data Inicio"
       vdtfim   label "Data Fim"
       vprocod as int label "Produto" colon 16
       vetbcod as int label "Filial"   colon 16.  

for each tipmov where movtdc = 5 or tipmov.movtdc = 12  no-lock.
    for each estab where estab.etbcod >= 1 and estab.etbcod <= 1000
     and (if vetbcod <> 0
            then etbcod = vetbcod
            else true)
     no-lock. 
    do vdata = vdtini to vdtfim.
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

            if vprocod <> 0
            then if movim.procod <> vprocod
                 then next.
                 
            if nivel1.clacod = 0
            then next.
            find first prof226 where prof226.SKU_ID  = string(movim.procod)
                                        no-lock
                                        no-error.
            if not avail prof226 or
               (avail prof226 and prof226.data_exportacao = ?)
            then next.    
            
            disp  "Processando " estab.etbnom no-label
                  plani.pladat format "99/99/9999" 
                /*skip
                 produ.procod no-label produ.pronom format "x(40)" no-label*/
                 with frame f-vvv1
                            side-labels width 80. pause 0.
            
            
            val_fin = 0.                    
            val_des = 0.   
            val_dev = 0.   
            val_acr = 0. 
                         
            val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.acfprod.
            if val_acr = ? then val_acr = 0.
            
            val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.descprod.
            if val_des = ? then val_des = 0.
            val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.vlserv.
            if val_dev = ? then val_dev = 0.
            if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
            then
                val_fin = ((((movim.movpc * movim.movqtm) - val_dev - val_des)
                                 /
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
            if val_fin = ? then val_fin = 0.
            
            val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + 
                            val_acr + 
                          val_fin. 

            if val_com = ? then val_com = 0.
             
           

            valor_venda = val_com. 
            qtd_venda   = movim.movqtm.
            
            /**/ 
            a_vista = plani.crecod = 1. 
            assign vcodplano = 0. 
            assign vcodplano = plani.pedcod. 
            if vcodplano = 0
            then do: 
                /*Nede 06-02-2012*/
                find first titulo use-index etbcod
                     where titulo.etbcobra = plani.etbcod
                       and titulo.titdtpag = plani.pladat
                       and titulo.titsit = "PAG" 
                       and titulo.moecod = "CAR" 
                       and titulo.titdtemi = titulo.titdtpag
                       and titulo.titnum = "v"
                                         + string(plani.numero)
                                no-lock no-error.
                if avail titulo 
                then vcodplano = 999.
                else vcodplano = 0.                                    
            end.   
            vcrecod = vcodplano.
            if can-find(first tt-planobiz 
                            where tt-planobiz.crecod = vcrecod) 
            then assign vplanobiz = yes.
            else assign vplanobiz = no.            
/**/
            if movim.movtdc = 12
            then 
                assign a_vista = ?
                       vplanobiz = ?
                       .
            
            
            find tt-510 where 
                    tt-510.SALES_DATE = string(movim.movdat,"99999999") and
                    tt-510.SKU_ID     = string(movim.procod)            and 
                    tt-510.STORE_ID   = string(movim.etbcod)
                              no-error.
            if not avail tt-510
            then create tt-510.
            tt-510.SALES_DATE = string(movim.movdat,"99999999").
            tt-510.SKU_ID     = string(movim.procod).
            tt-510.STORE_ID   = string(movim.etbcod).
            tt-510.ORIGIN_ID  =   "LEBES".


if valor_venda = 0
then  do.
    find first ctdevven where ctdevven.etbcod-ven = plani.etbcod and
                              ctdevven.placod-ven = plani.placod and
                              ctdevven.movtdc-ven = plani.movtdc 
                              no-lock no-error.
    if avail ctdevven  
    then do. 
        def buffer bmovim for movim. 
        find bmovim where bmovim.etbcod = ctdevven.etbcod-ori and       
                          bmovim.placod = ctdevven.placod-ori and
                          bmovim.movtdc = ctdevven.movtdc-ori and
                          bmovim.procod = movim.procod
                          no-lock no-error.  
        if avail bmovim
        then do.
            valor_venda = bmovim.movpc * bmovim.movqtm.
        end.
    end. 
end .

/*  Total Vendas Valor  */
if a_vista <> ?
then
    TOT_SLS_VAL = (TOT_SLS_VAL + valor_venda) . 
else 
    assign
    REG_RTRN_QTY = (REG_RTRN_QTY + qtd_venda) 
                                    /*  Devol vendas à vista em quantidade  */
    REG_RTRN_VAL = (REG_RTRN_VAL + valor_venda) .     
                                    /*  Devol vendas à vista em valor   */
        

/*  Vl de vendas à vista */
if a_vista 
then 
    REG_SLS_VAL = (REG_SLS_VAL + valor_venda) . 

/*  Valor de vendas parceladas (sem Bi$)    */
if a_vista = no and vplanobiz = no
then
    PRM_SLS_VAL = (PRM_SLS_VAL + valor_venda) .      

/*  Valor de vendas no plano Bi$    */
if a_vista = no and vplanobiz
then 
    CLR_SLS_VAL =  (CLR_SLS_VAL + valor_venda) .


/*  Total Vendas unidade    */
if a_vista <> ?
then
    TOT_SLS_QTY = TOT_SLS_QTY + qtd_venda .

/*  Quantidade de vendas à vista    */
if a_vista 
then
    REG_SLS_QTY = (REG_SLS_QTY + qtd_venda) .      

/*  Quantidade de vendas parceladas (sem Bi$)*/
if a_vista = no and vplanobiz = no
then
    PRM_SLS_QTY = (PRM_SLS_QTY +  qtd_venda) .

/*  Quantidade de vendas no plano Bi$   */
if a_vista = no and vplanobiz
then
    CLR_SLS_QTY = (CLR_SLS_QTY +  qtd_venda) .      


PRM_RTRN_QTY = 0.      /*  Devol vendas parceladas sem Bi$ em quantidade  */
PRM_RTRN_VAL = 0.      /*  Devol vendas parceladas sem Bi$ em valor*/
CLR_RTRN_QTY = 0.      /*  Devol vendas parceladas no Bi$ em quantidade  */
CLR_RTRN_VAL = 0.      /*  Devol vendas parceladas no Bi$ em valor */

OFFER_ID = "".      /*  Código da Oferta corresponte para vendas promocionais (se existirem)  */
                    
                    tt-510.CREATE_USER_ID           = "ADMCOM"           .
                    tt-510.CREATE_DATETIME          = vsysdata           .
                    tt-510.LAST_UPDATE_USER_ID      = "ADMCOM"           .
                    tt-510.LAST_UPDATE_DATETIME     = vsysdata           .
                    .
            def var f as int.
        f = f + 1.
        if f mod 10000 = 0 
        then
        message  f  "Loja" STORE_ID 
                            "Data" pladat  
                            .


    end.    /*  for each movim      */
    end.    /*  for each plani      */
    end.    /*  do vdata = vdtini   */
    end.    /*  for each estab      */
end.        /*  for each tipmov     */

for each tt-510.
TOT_SLS_VAL =   TOT_SLS_VAL *   10000   .
REG_SLS_VAL =   REG_SLS_VAL *   10000   .
PRM_SLS_VAL =   PRM_SLS_VAL *   10000   .
CLR_SLS_VAL =   CLR_SLS_VAL *   10000   .
TOT_SLS_QTY =   TOT_SLS_QTY *   10000   .
REG_SLS_QTY =   REG_SLS_QTY *   10000   .
PRM_SLS_QTY =   PRM_SLS_QTY *   10000   .
CLR_SLS_QTY =   CLR_SLS_QTY *   10000   .
REG_RTRN_QTY    =   REG_RTRN_QTY    *   10000   .
REG_RTRN_VAL    =   REG_RTRN_VAL    *   10000   .
PRM_RTRN_QTY    =   PRM_RTRN_QTY    *   10000   .
PRM_RTRN_VAL    =   PRM_RTRN_VAL    *   10000   .
CLR_RTRN_QTY    =   CLR_RTRN_QTY    *   10000   .
CLR_RTRN_VAL    =   CLR_RTRN_VAL    *   10000   .

end.

output to value( par-destino ).
/*
output to value("/admcom/progr/itim/ADMCOM_0510_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
*/
                    
    put unformatted          
       "SALES_DATE"            "|"
       "SKU_ID"                "|"
       "STORE_ID"              "|"
       "ORIGIN_ID"             "|"
       "TOT_SLS_VAL"           "|"
       "REG_SLS_VAL"           "|"
       "PRM_SLS_VAL"           "|"
       "CLR_SLS_VAL"           "|"
       "TOT_SLS_QTY"           "|"
       "REG_SLS_QTY"           "|"
       "PRM_SLS_QTY"           "|"
       "CLR_SLS_QTY"           "|"
       "REG_RTRN_QTY"          "|"
       "REG_RTRN_VAL"          "|"
       "PRM_RTRN_QTY"          "|"
       "PRM_RTRN_VAL"          "|"
       "CLR_RTRN_QTY"          "|"
       "CLR_RTRN_VAL"          "|"
       "OFFER_ID"              "|"
       "RECORD_STATUS"         "|"
       "CREATE_USER_ID"        "|"
       "CREATE_DATETIME"       "|"
       "LAST_UPDATE_USER_ID"   "|"
       "LAST_UPDATE_DATETIME"  
        
        skip.

for each tt-510.
    put unformatted          
       SALES_DATE            "|"
       tt-510.SKU_ID                "|"
       STORE_ID              "|"
       ORIGIN_ID             "|"
       TOT_SLS_VAL           "|"
       REG_SLS_VAL           "|"
       PRM_SLS_VAL           "|"
       CLR_SLS_VAL           "|"
       TOT_SLS_QTY           "|"
       REG_SLS_QTY           "|"
       PRM_SLS_QTY           "|"
       CLR_SLS_QTY           "|"
       REG_RTRN_QTY          "|"
       REG_RTRN_VAL          "|"
       PRM_RTRN_QTY          "|"
       PRM_RTRN_VAL          "|"
       CLR_RTRN_QTY          "|"
       CLR_RTRN_VAL          "|"
       OFFER_ID              "|"
       RECORD_STATUS         "|"
       CREATE_USER_ID        "|"
       CREATE_DATETIME       "|"
       LAST_UPDATE_USER_ID   "|"
       LAST_UPDATE_DATETIME  
       skip.
end. 
output close.

