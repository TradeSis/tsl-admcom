

def var vdatbuscaini as date.
vdatbuscaini = date(01,01,year(today - 365)) .

def buffer bestab for estab.

pause 0 before-hide.
def var vi as int.

/* 03.05.19  - Sem refaz tudo */
for each abasresoper.
    abasresoper.leadtime = 0.
end.
for each abashisoper.
    delete abashisoper.
end.    
    
for each estab where estab.etbcod >= 900 no-lock.

    /* Calcula LeadTime Inicial FORNE->CD */
    
    message today string(time,"HH:MM:SS") " Processando Estab " estab.etbcod " FORNE->CD ".
    for each plani where
            plani.movtdc = 04 and
            plani.etbcod = estab.etbcod and
            plani.pladat >=  vdatbuscaini no-lock.
        find forne where forne.forcod = plani.emite no-lock no-error.
        if not avail forne
        then do:
            next. /* nao se trata de nota de compra */
        end.    
        if plani.desti <> estab.etbcod
        then do:
            next. /* Nao eh entrada no estab */
        end.    
        
        vi = vi + 1.
        if vi < 10 or vi mod 1000 = 0
        then do:
            message today string(time,"HH:MM:SS") " Processando Estab " estab.etbcod  plani.pladat.
        end.    

        for each movim where 
                movim.etbcod = plani.etbcod and
                movim.placod = plani.placod
                 no-lock.
            find first abashisoper where             
                abashisoper.procod = movim.procod and
                abashisoper.etbcod = plani.etbcod and
                abashisoper.emite  = plani.emite  and
                abashisoper.placod = plani.placod 
                no-error.
            if not avail abashisoper
            then do:
                create abashisoper.
                abashisoper.procod  = movim.procod.
                abashisoper.etbcod  = plani.etbcod.
                abashisoper.emite   = plani.emite.
                abashisoper.placod  = plani.placod.
                abashisoper.datfim  = plani.datexp.
                abashisoper.datini  = ?.
                abashisoper.datproc = ?.
                abashisoper.leadtime = 0.
            end.
        end.                                    

        /* tentar achar o pedido de compra */ 
        for each plaped where plaped.forcod = plani.emite and
                              plaped.numero = plani.numero and
                              plaped.placod = plani.placod
                no-lock.
            find pedid where pedid.etbcod = plaped.pedetb and
                             pedid.pedtdc = plaped.pedtdc and
                             pedid.pednum = plaped.pednum 
                no-lock  no-error.
            if avail pedid
            then do:
                for each movim where 
                        movim.etbcod = plani.etbcod and
                        movim.placod = plani.placod
                         no-lock.
                         
                    for each liped of pedid 
                        where
                            liped.procod = movim.procod
                        no-lock.
                        find abashisoper where             
                            abashisoper.procod = movim.procod and
                            abashisoper.etbcod = plani.etbcod and
                            abashisoper.emite  = plani.emite  and
                            abashisoper.placod = plani.placod 
                            no-error.
                        if avail abashisoper
                        then do:
                            if abashisoper.datini = ?
                            then do:
                                abashisoper.datini   = pedid.peddat.
                                abashisoper.pedtdc   = pedid.pedtdc.
                                abashisoper.pednum   = pedid.pednum.
                                abashisoper.etbPed   = pedid.etbcod. 
                                abashisoper.datproc   = ?.
                                abashisoper.leadtime = abashisoper.datfim - abashisoper.datini.
                            end.
                        end.
                    end.
                end.
            end.    
        end.        
    end.    
    /* Calculando LeadTime CD-> FILIAL */

    message today string(time,"HH:MM:SS") " Processando Estab " estab.etbcod " CD -> ESTAB".

    for each plani where
            plani.movtdc = 06 and
            plani.etbcod = estab.etbcod and
            plani.pladat >=  vdatbuscaini no-lock.
        if plani.etbcod <> plani.emite
        then do:
            next. /* Nao eh emissao do cd */
        end.    
        if plani.emite = plani.desti
        then do:
            next. /* eh outra coisa */
        end.
        
        /* ACHA DESTINO */
        find bestab where bestab.etbcod = plani.desti no-lock no-error.
        if not avail bestab
        then do:
            next. /* destino nao eh filial */
        end.
        if bestab.etbcod >= 900
        then do:
            next. /*destino tem que ser loja */
        end.
        vi = vi + 1.
        if vi < 10 or vi mod 1000 = 0
        then do:
            message today string(time,"HH:MM:SS") " Processando Estab " estab.etbcod  plani.pladat.
        end.    

        for each movim where 
                movim.etbcod = plani.etbcod and
                movim.placod = plani.placod
                 no-lock.
            
            find first abashisoper where             
                abashisoper.procod = movim.procod and
                abashisoper.etbcod = bestab.etbcod and
                abashisoper.emite  = plani.emite and
                abashisoper.placod = plani.placod 
                no-error.
            if not avail abashisoper
            then do:
                create abashisoper.
                abashisoper.procod  = movim.procod.
                abashisoper.etbcod  = bestab.etbcod.
                abashisoper.emite   = plani.emite.
                abashisoper.placod  = plani.placod.
                abashisoper.datini  = plani.pladat.
                abashisoper.datfim  = ?.
                abashisoper.datproc = ?.
                abashisoper.leadtime = 0.
            end.
        end.                                    

        /* tentar achar o confirmacao da transferencia */ 
        find first nottra where nottra.etbcod = plani.etbcod and
                                nottra.desti  = plani.desti  and
                                nottra.numero = plani.numero and
                                nottra.movtdc = plani.movtdc and
                                nottra.serie  = plani.serie 
           NO-LOCK no-error.
        if avail nottra
        then do:
            for each movim where 
                    movim.etbcod = plani.etbcod and
                    movim.placod = plani.placod
                     no-lock.
                     
                find first abashisoper where             
                    abashisoper.procod = movim.procod and
                    abashisoper.etbcod = bestab.etbcod and
                    abashisoper.emite  = plani.emite and
                    abashisoper.placod = plani.placod 
                    no-error.
                if avail abashisoper
                then do: 
                    if abashisoper.datfim = ? 
                    then do: 
                        abashisoper.datfim   = nottra.datexp. 
                        abashisoper.datproc   = ?. 
                        abashisoper.leadtime = abashisoper.datfim - abashisoper.datini. 
                    end.
                end.
            end.                    
        end.    
        else do:
            /* quando não tem confirmação, usa a do proprio dia de emissao */
            for each movim where 
                    movim.etbcod = plani.etbcod and
                    movim.placod = plani.placod
                 no-lock.
                find first abashisoper where             
                    abashisoper.procod = movim.procod and
                    abashisoper.etbcod = bestab.etbcod and
                    abashisoper.emite  = plani.emite and
                    abashisoper.placod = plani.placod 
                    no-error.
                if abashisoper.datfim = ? 
                then do:  
                    abashisoper.datfim   = plani.dtinclu.
                    abashisoper.datproc   = ?.  
                    abashisoper.leadtime = abashisoper.datfim - abashisoper.datini.  
                end.
            end.                                    
        end.
    end.
end.         

message today string(time,"HH:MM:SS") " Processando Calculo Medias ".
   
for each abashisoper use-index abasproc
        where abashisoper.datproc = ? 
        exclusive.
    if abashisoper.datini = ? or
       abashisoper.datfim = ?
    then next. /* nao completo */ 
         
    find first abasresoper where
        abasresoper.procod = abashisoper.procod and
        abasresoper.etbcod = abashisoper.etbcod and
        abasresoper.emite  = abashisoper.emite
        exclusive no-error.
    if not avail abasresoper
    then do:
        create abasresoper.
        abasresoper.procod = abashisoper.procod.
        abasresoper.emite  = abashisoper.emite. 
        abasresoper.etbcod = abashisoper.etbcod.
        abasresoper.leadtime = 0.
        abasresoper.qtdoper  = 0.
    end.    
    abasresoper.qtdoper  = abasresoper.qtdoper + 1.
    abasresoper.sumleadtime = abasresoper.sumleadtime + abashisoper.leadtime.
    abasresoper.leadtime = abasresoper.sum / abasresoper.qtdoper.
    
    abashisoper.datproc = today.
    abasresoper.datEnvio = ?. /* marca para enviar */
    
end.

message today string(time,"HH:MM:SS") " FIM ".

