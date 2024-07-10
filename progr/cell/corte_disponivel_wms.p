/* Projeto Melhorias Mix - Luciano    */
/* corte_disponivel.p                                                   */

def input  parameter par-procod     like produ.procod.
def output parameter vestoq_depos   as   int format "->>>>>9".
def output parameter vreservas      as   int format "->>>>>9".
def output parameter vdisponivel    as   int format "->>>>>9".
vestoq_depos = 0.  
/*
find com.estoq where com.estoq.etbcod = 981  
                 and com.estoq.procod = par-procod  
                     no-lock no-error. 
vestoq_depos = if avail com.estoq
               then com.estoq.estatual
               else 0.
*/
find com.estoq where com.estoq.etbcod = 900
                 and com.estoq.procod = par-procod  
                     no-lock no-error.
vestoq_depos = vestoq_depos + (if avail com.estoq 
                               then com.estoq.estatual 
                               else 0).
def new global shared var vreserv_ecom  like estoq.estatual format "->>>>9".
run /admcom/progr/reserv_ecom.p (input  par-procod, 
                   output vreserv_ecom).
vestoq_depos = vestoq_depos - vreserv_ecom.

def var reserva as int.
def var vespecial as int.
def var vdata as date.
def var vreservado as int.

def new global shared temp-table tt-reservas
    field sequencia    as dec
    field rec_liped     as recid
    field tipo          as char
    field atende        as int
    field dispo         as int 
    field prioridade    as int format "->>>>" label "Pri"
    field regra         as int
    index sequencia   is primary prioridade
    index rec_liped is unique rec_liped .
    
for each tt-reservas. 
    delete tt-reservas.
end.
        
        
        if true
        then do.
            reserva = 0. 
            vespecial = 0.  
            do vdata = today - 45 to today.
                for each liped use-index liped2 where liped.pedtdc = 3
                                 and liped.procod = par-procod
                                 and liped.predt  = vdata
                                  no-lock:
                                         
                    if liped.etbcod = 200 and vreserv_ecom > 0 then next.
                    
                    
                    find pedid where pedid.etbcod = liped.etbcod and
                                     pedid.pedtdc = liped.pedtdc and
                                     pedid.pednum = liped.pednum 
                                                            no-lock no-error.
                    if not avail pedid 
                    then next.

                    if pedid.sitped <> "E" and
                       pedid.sitped <> "L"
                    then next.
                
                    reserva = reserva + liped.lipqtd.
                    create tt-reservas.
                    assign tt-reservas.rec_liped = recid(liped)
                           tt-reservas.sequencia = if pedid.sitped = "L"
                                                    then /*-1*/  1
                                                    else 1.
                    find first tbgenerica where tbgenerica.TGTabela = "TP_PEDID" and
                                          tbgenerica.TGCodigo = pedid.modcod
                          no-lock no-error.
                          .
                    tt-reservas.regra = if avail tbgenerica
                                        then tbgenerica.tgint 
                                        else 9999.
                    tt-reservas.sequencia = regra.
                end.
            end.
            
            /****  Reservas futuras *****/
            assign vdata = today + 1.
            for each liped use-index liped2 where liped.pedtdc = 3
                             and liped.procod = par-procod
                             and liped.predt  >= vdata
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
                create tt-reservas.
                assign tt-reservas.rec_liped = recid(liped)
                       tt-reservas.tipo      = ""
                       tt-reservas.sequencia= 3
                       .
                find first tbgenerica where tbgenerica.TGTabela = "TP_PEDID" and
                                      tbgenerica.TGCodigo = pedid.modcod
                      no-lock no-error.
                tt-reservas.regra = if avail tbgenerica
                                    then tbgenerica.tgint 
                                    else 9999.
            end.

            run /admcom/progr/disponivel.p (par-procod, output vreservado).
            reserva = reserva + vreservado.
        end.           
         
vreservas = reserva + vespecial.
vdisponivel = 
               (if vestoq_depos < 0
                then 0
                else vestoq_depos) - vreservas.

for each tt-reservas use-index rec_liped where tt-reservas.tipo      = "".
    find liped where recid(liped) = tt-reservas.rec_liped no-lock.
    find pedid of liped no-lock.
    if false /*tt-reservas.sequencia < 0*/
    then do.
        next.
    end.
    if tt-reservas.sequencia < 0
    then tt-reservas.sequencia = -1.
    else tt-reservas.sequencia = dec(string(liped.predt,"99999999") +
                                     string(liped.prehr,"99999")).
    tt-reservas.tipo      = "F".
end.        
def var v as int.
v = 0.
for each tt-reservas use-index rec_liped where tt-reservas.sequencia >= 0,
    liped where recid(liped) = tt-reservas.rec_liped no-lock,
    pedid of liped no-lock 
                           by tt-reservas.regra
                           by liped.predt
                           by liped.prehr .
    v = v + 1.
    tt-reservas.prioridade = v.
end.

if vreserv_ecom > 0
then do.
    def var qtd_200 like vreserv_ecom.
    qtd_200 = vreserv_ecom.
    def var tem_200 as log.
    tem_200 = no.
    v = -9999.
    for each tt-reservas use-index rec_liped where tt-reservas.sequencia >= 0,
        first liped where recid(liped) = tt-reservas.rec_liped and
                          liped.etbcod = 200            no-lock,
        pedid of liped no-lock by liped.predt
                               by liped.prehr .
        tt-reservas.prioridade = v.
        tem_200 = yes.
        qtd_200 = qtd_200 - liped.lipqtd          .
        v = v + 1.
        if qtd_200 <= 0 then leave.
    end.
    vestoq_depos = vestoq_depos + vreserv_ecom.
    if tem_200 = no then vestoq_depos = vestoq_depos - vreserv_ecom. 
end.

def var vdispo like vestoq_depos.
vdispo = vestoq_depos.
if vdispo < 0
then vdispo = 0.
def buffer btt-reservas for tt-reservas.
for each tt-reservas by tt-reservas.prioridade.
    find liped where recid(liped) = tt-reservas.rec_liped no-lock.
    find pedid of liped no-lock.
    tt-reservas.atende = if vdispo >= liped.lipqtd
                         then liped.lipqtd
                         else vdispo.
    if pedid.sitped = "L"
    then tt-reservas.atende = liped.lipent. 
    vdispo = vdispo - (if vdispo <= 0
                       then liped.lipqtd 
                       else tt-reservas.atende).
    tt-reservas.dispo = vdispo.  
    find last btt-reservas where 
              btt-reservas.prioridade < tt-reservas.prioridade
              use-index sequencia no-error.
    tt-reservas.atende = if avail btt-reservas and btt-reservas.dispo <= 0
                         then 0
                         else tt-reservas.atende.
end.    
vdispo = vestoq_depos.
if vdispo < 0
then vdispo = 0.
for each tt-reservas by tt-reservas.prioridade.
    find liped where recid(liped) = tt-reservas.rec_liped no-lock.
    vdispo = vdispo - tt-reservas.atende.
    if vdispo = 0 or tt-reservas.atende = 0
    then vdispo = vdispo + tt-reservas.atende - liped.lipqtd.
    tt-reservas.dispo = vdispo.
end.

vdisponivel = vdispo.


vestoq_depos = 0.  
/**
find com.estoq where com.estoq.etbcod = 981  
                 and com.estoq.procod = par-procod  
                     no-lock no-error. 
vestoq_depos = if avail com.estoq
               then com.estoq.estatual
               else 0.
**/
find com.estoq where com.estoq.etbcod = 900
                 and com.estoq.procod = par-procod  
                     no-lock no-error.
vestoq_depos = vestoq_depos + (if avail com.estoq 
                               then com.estoq.estatual 
                               else 0).
def var recalcula as log.
recalcula = no.

            if vreserv_ecom > 0
            then do.
                def var vdisp_ecom like vreserv_ecom.
                vdisp_ecom = vreserv_ecom. 
                do vdata = today - 45 to today.
                    for each liped where liped.pedtdc = 3
                                     and liped.predt  = vdata
                                     and liped.procod = par-procod no-lock
                                         by liped.pednum:
                                             
                        if liped.etbcod <> 200 then next.
                        
                        find pedid where pedid.etbcod = liped.etbcod and
                                         pedid.pedtdc = liped.pedtdc and
                                         pedid.pednum = liped.pednum 
                                                            no-lock no-error.
                        if not avail pedid 
                        then next.
            
                        if pedid.sitped <> "E" and
                           pedid.sitped <> "L"
                        then next.
                
                        reserva = reserva + liped.lipqtd.
                        create tt-reservas.
                        assign tt-reservas.rec_liped = recid(liped)
                               tt-reservas.sequencia = if pedid.sitped = "L"
                                                        then /*-1*/  1
                                                        else 1.
                        find first tbgenerica where 
                                tbgenerica.TGTabela = "TP_PEDID"
                                          and tbgenerica.TGCodigo = pedid.modcod
                                              no-lock no-error.
                        tt-reservas.regra = if avail tbgenerica
                                            then tbgenerica.tgint 
                                            else 9999.
                        tt-reservas.sequencia = regra.
                    


    tt-reservas.atende = if vdisp_ecom >= liped.lipqtd
                         then liped.lipqtd
                         else vdisp_ecom.
    if pedid.sitped = "L"
    then tt-reservas.atende = liped.lipent. 
    vdisp_ecom = vdisp_ecom - (if vdisp_ecom <= 0
                       then liped.lipqtd 
                       else tt-reservas.atende).
    tt-reservas.dispo = vdisp_ecom.  
    find last btt-reservas where 
              btt-reservas.prioridade < tt-reservas.prioridade
              use-index sequencia no-error.
    if tt-reservas.dispo < 0
    then do.
        tt-reservas.sequencia = dec(string(liped.predt,"99999999") +
                                    string(liped.prehr,"99999")).
        recalcula = yes.
    end.
                    
                    end.
                end.
            end.
                               
for each tt-reservas.
end.

if recalcula 
then do. 
vdispo = vestoq_depos - vreserv_ecom .
if vdispo < 0
then vdispo = 0.
for each tt-reservas use-index sequencia where tt-reservas.sequencia <> 50
            by tt-reservas.prioridade.
    find liped where recid(liped) = tt-reservas.rec_liped no-lock.
    find pedid of liped no-lock.
    tt-reservas.atende = if vdispo >= liped.lipqtd
                         then liped.lipqtd
                         else vdispo.
    if pedid.sitped = "L"
    then tt-reservas.atende = liped.lipent. 
    vdispo = vdispo - (if vdispo <= 0
                       then liped.lipqtd 
                       else tt-reservas.atende).
    tt-reservas.dispo = vdispo.  
    find last btt-reservas where 
              btt-reservas.prioridade < tt-reservas.prioridade
              use-index sequencia no-error.
    tt-reservas.atende = if avail btt-reservas and btt-reservas.dispo <= 0
                         then 0
                         else tt-reservas.atende.
end.    
vdispo = vestoq_depos - vreserv_ecom.
if vdispo < 0
then vdispo = 0.
for each tt-reservas  use-index sequencia where tt-reservas.sequencia <> 50
                by tt-reservas.prioridade.
    find liped where recid(liped) = tt-reservas.rec_liped no-lock.
    vdispo = vdispo - tt-reservas.atende.
    if vdispo = 0 or tt-reservas.atende = 0
    then vdispo = vdispo + tt-reservas.atende - liped.lipqtd.
    tt-reservas.dispo = vdispo.
end.

vdisponivel = vdispo.


end.
