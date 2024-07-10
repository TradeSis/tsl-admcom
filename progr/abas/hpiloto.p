{abas/neo_piloto.i}
pause 0 before-hide.
for each ttpiloto where dtini = today ,
    each pedid where sitped = "E" and pedid.etbcod = ttpiloto.etbcod    and pedtdc = 3   
        and pedid.peddat >= today - 45 
        and pedid.peddat <> ? .
    for each liped of pedid no-lock
        by modcod by pedid.peddat.
    
        disp pedid.etbcod pedid.pedtdc modcod format "x(04)" peddat.
        disp liped.procod liped.lipqtd (count total).

        find movim where movim.etbcod = pedid.etbcod and
                         movim.placod = liped.venda-placod and
                         movim.procod = liped.procod
            no-lock no-error.
        if not avail movim
        then do:
            if pedid.modcod = "PEDO"
            then do:
                find movim where movim.etbcod = pedid.vencod and
                                 movim.placod = pedid.frecod and
                                 movim.procod = liped.procod
                        no-lock no-error.
            end.
        end.
        if avail movim
        then do:
            find plani where plani.etbcod = movim.etbcod and 
                            plani.placod = movim.placod
                no-lock no-error.
            if avail plani
            then do:
                disp plani.numero.
            end.
        end.                
                              
        if pedid.modcod = "PEDA" or
           pedid.modcod = "PEDX"
        then find first abastipo where abastipo.abatipo = "NEG" no-lock.
        else find first  abastipo where abastipo.antigopedido = pedid.modcod no-lock no-error.
        if avail abastipo
        then do:
            disp abastipo.abatipo.
            find produ of liped no-lock.
            disp produ.catcod.
            find clase where clase.clacod = produ.clacod no-lock.
            disp clase.clanom.
            find estoq where estoq.etbcod = liped.etbcod and estoq.procod = liped.procod no-lock.
            disp estatual format "->>>9".
            def var pabtcod as int.
                run abas/transfcreate.p 
                                        (abastipo.abatipo,  
                                         pedid.etbcod,
                                         liped.procod,
                                         liped.lipqtd,
                                         "",
                                         pedid.peddat,
                                         if avail movim 
                                         then "MOVIM=" + string(recid(movim)) 
                                         else "EXTERNO=" + string(pedid.pednum) + "_" + string(liped.procod),
                                         "PEDIDOADMCOM="+ string(pedid.pednum),
                                         output pabtcod).


        end.  
    end.        
    
    pedid.sitped = "NN".
    
 end.
