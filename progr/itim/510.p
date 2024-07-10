def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").

def var vdata as date.

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
vdti = today - 30 * 4.
vdtf = today - 10.         
disp vdti vdtf.
pause 1.
def buffer i510movim for movim.
def buffer i510plani for plani.

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

def var vestatual like estoq.estatual.

def buffer cmovim for movim.
def buffer cplani for plani.

def var vsituacao as log.

def var vestatus-d as char extent 4  FORMAT "X(15)"
    init["NORMAL","BRINDE","FORA DE LINHA","FORA DO MIX"].            
def var vestatus as int.    


for each produ where produ.procod < 999999 


no-lock.
    if proseq = 99
    then next.
    find first movim where movim.movtdc = 5
                       and movim.procod = produ.procod
                       and movim.movdat >= today - 365
                            no-lock no-error.
    if not avail movim
    then next.
    
    /* Custo */
    find last cmovim where cmovim.movtdc = 4
                       and cmovim.procod = produ.procod
                        no-lock no-error.
    if not avail cmovim
    then next.
    find cplani where cplani.movtdc = cmovim.movtdc 
                  and cplani.etbcod = cmovim.etbcod
                  and cplani.placod = cmovim.placod no-lock no-error.
    if not avail cplani
    then next.
    
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
                               movim.movdat >= today - 365 no-lock no-error.
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
    def var fff as int.
    fff = fff + 1.
    if fff mod 100 = 0
    then   message produ.procod.    
    do vdata = vdti to vdtf.
    for each tipmov where tipmov.movtdc = 5 
                       or tipmov.movtdc = 12 no-lock,
        each i510movim use-index datsai
                       where i510movim.procod = produ.procod
                         and i510movim.movtdc = tipmov.movtdc
                         and i510movim.movdat = vdata  no-lock,
        each i510plani where i510plani.etbcod = i510movim.etbcod
                         and i510plani.placod = i510movim.placod
                         and i510plani.pladat = vdata no-lock.
        find estab where estab.etbcod = i510plani.etbcod no-lock.              
        
        def var ggg as int.
        ggg = ggg + 1.
        if ggg mod 1000 = 0
        then  do.      
            disp produ.procod vdata tipmov.movtdc ggg.
            pause 0.
        end.
        val_fin = 0.                    
        val_des = 0.   
        val_dev = 0.   
        val_acr = 0. 
                         
        val_acr =  ((i510movim.movpc * i510movim.movqtm) / i510plani.platot) * 
                     i510plani.acfprod.
        if val_acr = ? then val_acr = 0.
            
        val_des =  ((i510movim.movpc * i510movim.movqtm) / i510plani.platot) * 
                     i510plani.descprod.
        if val_des = ? then val_des = 0.
        val_dev =  ((i510movim.movpc * i510movim.movqtm) / i510plani.platot) * 
                     i510plani.vlserv.
        if val_dev = ? then val_dev = 0.
        if (i510plani.platot - i510plani.vlserv - i510plani.descprod) < i510plani.biss
        then val_fin = ((((i510movim.movpc * i510movim.movqtm) - val_dev - val_des)
                     /
                       (i510plani.platot - i510plani.vlserv - i510plani.descprod))
                      * i510plani.biss) - ((i510movim.movpc * i510movim.movqtm) - 
                        val_dev - val_des).
        if val_fin = ? then val_fin = 0.
            
        val_com = (i510movim.movpc * i510movim.movqtm) - 
                        /*val_dev*/ - val_des + 
                   val_acr + 
                   val_fin. 

        if val_com = ? then val_com = 0.
             
        valor_venda = val_com. 
        qtd_venda   = i510movim.movqtm.
            
        /**/ 
        a_vista = i510plani.crecod = 1. 
        assign vcodplano = 0. 
        assign vcodplano = i510plani.pedcod. 
        if vcodplano = 0
        then do: 
            /*Nede 06-02-2012*/
            find first titulo use-index etbcod
                where titulo.etbcobra = i510plani.etbcod
                  and titulo.titdtpag = i510plani.pladat
                  and titulo.titsit = "PAG" 
                  and titulo.moecod = "CAR" 
                  and titulo.titdtemi = titulo.titdtpag
                  and titulo.titnum = "v"
                                    + string(i510plani.numero)
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
        if i510movim.movtdc = 12
        then assign a_vista = ?
                    vplanobiz = ?.
            
        find first tt-510
            where tt-510.SALES_DATE = string(i510movim.movdat,"99999999") 
              and tt-510.SKU_ID     = string(i510movim.procod)            
              and tt-510.STORE_ID   = string(i510movim.etbcod)
                  no-error.
        if not avail tt-510
        then create tt-510.
        tt-510.SALES_DATE = string(i510movim.movdat,"99999999").
        tt-510.SKU_ID     = string(i510movim.procod).
        tt-510.STORE_ID   = string(i510movim.etbcod).
        tt-510.ORIGIN_ID  =   "LEBES".

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
        then REG_SLS_VAL = (REG_SLS_VAL + valor_venda) . 

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
            TOT_SLS_QTY = qtd_venda .

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

        PRM_RTRN_QTY = 0. /*  Devol vendas parceladas sem Bi$ em quantidade  */
        PRM_RTRN_VAL = 0. /*  Devol vendas parceladas sem Bi$ em valor*/
        CLR_RTRN_QTY = 0. /*  Devol vendas parceladas no Bi$ em quantidade  */
        CLR_RTRN_VAL = 0. /*  Devol vendas parceladas no Bi$ em valor */

        OFFER_ID = "". /* Código da Oferta corresponte para vendas promocionais                           (se existirem)  */
                    
        tt-510.CREATE_USER_ID           = "ADMCOM"           .
        tt-510.CREATE_DATETIME          = vsysdata           .
        tt-510.LAST_UPDATE_USER_ID      = "ADMCOM"           .
        tt-510.LAST_UPDATE_DATETIME     = vsysdata           .

    end.
    end. /* do vdata ... */


end.

    for each tt-510  .

        if TOT_SLS_VAL = 0 AND TOT_SLS_QTY = 1    
        then do.
            delete tt-510.
            next.
        end.
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


output to value("/admcom/tmp/itim/input/ADMCOM_0510_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-510.
    put                      
       tt-510.SALES_DATE            "|"
       tt-510.SKU_ID                "|"
       tt-510.STORE_ID              "|"
       tt-510.ORIGIN_ID             "|"
       tt-510.TOT_SLS_VAL           "|"
       tt-510.REG_SLS_VAL           "|"
       tt-510.PRM_SLS_VAL           "|"
       tt-510.CLR_SLS_VAL           "|"
       tt-510.TOT_SLS_QTY           "|"
       tt-510.REG_SLS_QTY           "|"
       tt-510.PRM_SLS_QTY           "|"
       tt-510.CLR_SLS_QTY           "|"
       tt-510.REG_RTRN_QTY          "|"
       tt-510.REG_RTRN_VAL          "|"
       tt-510.PRM_RTRN_QTY          "|"
       tt-510.PRM_RTRN_VAL          "|"
       tt-510.CLR_RTRN_QTY          "|"
       tt-510.CLR_RTRN_VAL          "|"
       tt-510.OFFER_ID              "|"
       tt-510.RECORD_STATUS         "|"
       tt-510.CREATE_USER_ID        "|"
       tt-510.CREATE_DATETIME       "|"
       tt-510.LAST_UPDATE_USER_ID   "|"
       tt-510.LAST_UPDATE_DATETIME  
       skip.
end. 
output close.




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
