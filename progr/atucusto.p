for each produ no-lock:

    disp produ.procod with 1 down. pause 0.

    for each estab where estab.etbcod >= 995 and
                         estab.etbcod <= 99 no-lock:
    
        find hiest where hiest.etbcod = estab.etbcod and
                         hiest.procod = produ.procod and
                         hiest.hieano = 2001 and
                         hiest.hiemes = 02.
        
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock.
        assign hiest.hiepcf = estoq.estcusto
               hiest.hiepvf = estoq.estvenda.
    end.
end.