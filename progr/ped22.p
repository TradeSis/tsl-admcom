{admcab.i}
{defp.i}

def input parameter recpla as recid.

def var vrec as recid.
def buffer bliped for liped.
def var v-ped as int.
def temp-table waux
    field auxrec as recid.
def var vnum like pedid.pednum.

for each w-movim: 
    delete w-movim. 
end. 

for each wprodu: 
    delete wprodu. 
end. 

for each waux: 
    delete waux. 
end.

do on error undo. 
    find forne where forne.forcod = 5027 no-lock. 
    vrec = recid(forne).
    
    run nffped.p (input vrec, 
                  input 0).

    find first wfped no-lock no-error.
    if not avail wfped
    then do:
        message "Para continuar selecione pelo menos um pedido.".
        undo.
    end.       
end.
    
    vforcod = forne.forcod.
    
    find plani where recid(plani) = recpla no-lock. 

    for each wfped:
        find pedid where recid(pedid) = wfped.rec NO-LOCK no-error.
        if avail pedid
        then do:
            for each liped where liped.pedtdc = pedid.pedtdc and
                                 liped.etbcod = pedid.etbcod and
                                 liped.pednum = pedid.pednum no-lock:
                if avail liped
                then do:                                              
                    find first movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and 
                                     movim.movtdc = plani.movtdc and 
                                     movim.movdat = plani.pladat and
                                     movim.procod = liped.procod 
                                     no-lock no-error.
                    if not avail movim
                    then do:
                        /* message "Existem produtos na NF sem pedido selecionado.". */

                        find first nottra where nottra.etbcod = plani.etbcod and
                                     nottra.desti  = plani.desti  and
                                     nottra.numero = plani.numero and
                                     nottra.movtdc = plani.movtdc and
                                     nottra.serie  = plani.serie no-error.
                        if avail nottra 
                        then delete nottra.
                        pause.
                        return.
                    end.
                end.    
            end.        
        end.
    end.
    
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and 
                         movim.movtdc = plani.movtdc and 
                         movim.movdat = plani.pladat no-lock:
        
        find produ where produ.procod = movim.procod no-lock no-error.
        find first w-movim where w-movim.wrec = recid(produ) no-error.  
        if not avail w-movim  
        then do: 
            create w-movim.  
            assign w-movim.wrec   = recid(produ) 
                   w-movim.movqtm = movim.movqtm 
                   w-movim.movpc  = movim.movpc.
        end.
    end.
    
    /* ex plaped*/ 
       
    for each wfped:
        create waux.
        assign waux.auxrec = wfped.rec.
    end.
    
    for each w-movim:
        find produ where recid(produ) = w-movim.wrec no-lock no-error.
        if not avail produ
        then next.
        
        for each wfped:
            find pedid where recid(pedid) = wfped.rec NO-LOCK no-error.
            if avail pedid
            then do:
                find first liped where liped.pedtdc = pedid.pedtdc and
                                       liped.etbcod = pedid.etbcod and
                                       liped.procod = produ.procod and
                                       liped.pednum = pedid.pednum
                                 NO-LOCK no-error.
                if avail liped
                then do:
                    find first wprodu where wprodu.wpro = liped.procod no-error.
                    if not avail wprodu 
                    then do: 
                        create wprodu.
                        assign wprodu.wpro = liped.procod.
                    end.
                    wprodu.wqtd = wprodu.wqtd + 1.
                end.
            end.
        end.
        for each wprodu:
            if wprodu.wqtd = 1
            then delete wprodu.
        end.
        vnum = 0.

        for each wfped:

            find pedid where recid(pedid) = wfped.rec no-lock no-error.
            if avail pedid
            then do:
                find first liped where liped.pedtdc = pedid.pedtdc and
                                       liped.etbcod = pedid.etbcod and
                                       liped.procod = produ.procod and
                                       liped.pednum = pedid.pednum no-error.
                if avail liped
                then do transaction:
                   vnum = 0.
                   sresp = yes.
                   find first wprodu where wprodu.wpro = liped.procod no-error.
                   if avail wprodu
                   then do:
                        vnum = 0.
                        message "PRODUTO EXISTE EM MAIS DE UM PEDIDO".
                        find produ where produ.procod = liped.procod no-lock.
                        display produ.procod
                                produ.pronom format "x(30)"
                                w-movim.movqtm label "Qtd"
                                    with frame f-l1 side-label width 80.
                        for each waux:
                           find pedid where recid(pedid) = waux.auxrec
                                                                    no-error.
                           find first bliped where
                                      bliped.pedtdc = pedid.pedtdc and
                                      bliped.etbcod = pedid.etbcod and
                                      bliped.procod = produ.procod and
                                      bliped.pednum = pedid.pednum
                                            no-lock no-error.
                           if not avail bliped
                           then next.
                           
                           find first wprodu where wprodu.wpro =
                                            bliped.procod no-error.
                           if not avail wprodu
                           then next.
                           disp pedid.pednum
                                bliped.procod
                                produ.pronom format "x(30)"
                                bliped.lipqtd
                                        with frame f-l2 centered color
                                                message 6 down.
                        end.
                        v-ped = 0.
                        vnum  = pedid.pednum.
                        update vnum label "Pedido"
                               v-ped label "Quantidade"
                               with frame f-l3 centered no-box side-label
                                                color message overlay.
                        find first liped where liped.pedtdc = pedid.pedtdc and
                                               liped.etbcod = pedid.etbcod and
                                               liped.procod = produ.procod and
                                               liped.pednum = vnum no-error.
                        if avail liped
                        then do:
                            liped.lipent = liped.lipent + v-ped.
                        end.
                   end.
                   else do:
                        liped.lipent = liped.lipent + w-movim.movqtm.
                   end.
                end.
            end.
        end.

        delete w-movim.
    end.
    
    for each wfped:
        
        find pedid where recid(pedid) = wfped.rec no-lock.
        
        find plaped where plaped.pedetb = pedid.etbcod and
                          plaped.plaetb = plani.desti  and
                          plaped.pedtdc = pedid.pedtdc and
                          plaped.pednum = pedid.pednum and
                          plaped.placod = plani.placod and
                          plaped.serie  = plani.serie  no-error.
        if not avail plaped
        then do transaction: 
            create plaped.
            assign plaped.pedetb = pedid.etbcod 
                   plaped.plaetb = plani.desti 
                   plaped.pedtdc = pedid.pedtdc 
                   plaped.pednum = pedid.pednum 
                   plaped.placod = plani.placod 
                   plaped.serie  = plani.serie 
                   plaped.numero = plani.numero 
                   plaped.forcod = forne.forcod.
        end.
    end.
 
    for each wfped:
        find pedid where recid(pedid) = wfped.rec no-error.
        if avail pedid
        then do:
            for each liped of pedid:
                do transaction:
                    liped.lipsit = "".
                    pedid.sitped = "".
                    if liped.lipent >= (liped.lipqtd - 
                                       (liped.lipqtd * 0.10)) and 
                       liped.lipent <= (liped.lipqtd + (liped.lipqtd * 0.10))
                    then liped.lipsit = "F".
                    else liped.lipsit = "P". 
                    
                    if liped.lipent = 0
                    then liped.lipsit = "A".
                end.
            end.
            
            for each liped of pedid:
    
                do transaction:
                    if liped.lipsit = "A"
                    then pedid.sitped = "A".
                    else if liped.lipsit = "P" and
                            pedid.sitped <> "A"
                         then pedid.sitped = "P".
                         else if liped.lipsit = "F" and
                                 pedid.sitped = "" 
                              then pedid.sitped = "F". 
                end.
            end.    
        end.
    end.
    

    find first wfped no-error.
    if avail wfped
    then run peddis.p (input recid(plani)).

