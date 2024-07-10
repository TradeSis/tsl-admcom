/*  pedcan_aut3.p                                                          */
{/admcom/progr/admcab.i new}
pause 0 before-hide.
def var vpedtdc like com.pedid.pedtdc.
vpedtdc = 3.
def var p-valor as char.
p-valor = "".
run /admcom/progr/le_tabini.p (0, 0, "DATA_CANCELA_PEDIDOS", OUTPUT p-valor) .
if int(p-valor) <= 0 then leave.
for each estab no-lock.
    disp estab.etbcod p-valor.
    for each pedid where pedid.etbcod = estab.etbcod 
                     and pedid.pedtdc = vpedtdc 
                     and pedid.sitped = "E" 
                     and pedid.peddat <= today - int(p-valor)    :
        disp pedid.peddat today - pedid.peddat.
        for each liped of pedid.
            liped.lipsit = "C".
        end.
        pedid.sitped    = "C".
        pedid.pedobs[1] = "CANCELADO AUTOMATICAMENTE " +    " POR " + 
                          p-valor + " DIAS " + " EM "  +
                          string(today,"99/99/9999").
    end.
    for each pedid where pedid.etbcod = estab.etbcod 
                     and pedid.pedtdc = vpedtdc 
                     and pedid.sitped = "E" 
                     and pedid.modcod = "PEDR"
                     and pedid.peddat >= today - 400    :
        disp pedid.peddat today - pedid.peddat.
        for each liped of pedid.
            liped.lipsit = "C".
        end.
        pedid.sitped    = "C".
        pedid.pedobs[1] = "CANCELADO AUTOMATICAMENTE " +    " POR " + 
                          p-valor + " DIAS " + " EM "  +
                          string(today,"99/99/9999").
    end.
    for each pedid where pedid.etbcod = estab.etbcod 
                     and pedid.pedtdc = vpedtdc 
                     and pedid.sitped = "E" 
                     and pedid.modcod = "PEDC"
                     and pedid.Pendente .
        disp pedid.peddat today - pedid.peddat.
        for each liped of pedid.
            liped.lipsit = "C".
        end.
        pedid.sitped    = "C".
        pedid.pedobs[1] = "CANCELADO AUTOMATICAMENTE " +    " POR " + 
                          p-valor + " DIAS " + " EM "  +
                          string(today,"99/99/9999").
    end.
end.
for each pedid where pedid.pedtdc = 3       and 
                     pedid.modcod = "PEDO"  and 
                     pedid.clfcod = ?       and
                     pedid.condat = ?       and
                     pedid.sitped = "E"  :
    for each liped of pedid.
            liped.lipsit = "C".
    end.
    pedid.sitped    = "C".
    pedid.pedobs[1] = "CANCELADO AUTOMATICAMENTE " +    " POR " + 
                          p-valor + " DIAS " + " EM "  +
                          string(today,"99/99/9999").
end.
def temp-table ttped
    field rec as recid.
for each ttped. 
    delete ttped.
end.    
/* lendo pedidos PEDO - Outra Filial - fechados indevidamente
   o teste para isto é verificar se houve corte no liped */
/*
for each pedid where pedid.modcod  = "PEDO" and 
                     pedid.sitped  = "F"    and 
                     pedid.pedtdc  = 3      and 
                     pedid.etbcod >= 1      and
                     pedid.peddat >  today - int(p-valor) no-lock.
    find first liped of pedid where liped.dtcorte = ? no-error.
    if not avail liped then next.
    create ttped.
    assign ttped.rec = recid(pedid).
end.    
for each ttped.
    find pedid where recid(pedid) = ttped.rec.
    pedid.sitped = "E".
    for each liped of pedid.
        liped.lipsit = pedid.sitped.
    end.
end.    
*/
for each estab no-lock.
    disp estab.etbcod p-valor .
    for each pedid where pedid.etbcod = estab.etbcod 
                     and pedid.pedtdc = vpedtdc 
                     and pedid.sitped = "C" 
                     and pedid.peddat <= today - (365) :
        disp pedid.peddat today - pedid.peddat pedid.sitped.
        for each liped of pedid.
            delete liped.
        end.
        delete pedid.
    end.
end.
for each repexporta where repexporta.datatrig < today - 90.
    if repexporta.BASE = "GESTAO_EXCECAO" 
    then next.
    delete repexporta.
end.
 
run /admcom/progr/emailpendente.p .  

