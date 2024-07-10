def shared temp-table wf-plani like com.plani.
def shared temp-table wf-movim like com.movim.

def var vplacod like plani.placod.
         
def buffer bplani for com.plani.
def var vplani-ok as log.
for each wf-plani:
    find first com.plani where
               com.plani.movtdc = 5 and
               com.plani.etbcod = wf-plani.etbcod and
               com.plani.emite  = wf-plani.emite and
               com.plani.serie  = wf-plani.serie and
               com.plani.numero = wf-plani.numero 
               no-lock no-error.
    if not avail com.plani
    then do:
        vplani-ok = yes.
        for each bplani where
                 bplani.movtdc = 5 and
                 bplani.etbcod = wf-plani.etbcod and
                 bplani.emite  = wf-plani.emite and 
                 bplani.pladat = wf-plani.pladat
                 no-lock:
            if  num-entries(bplani.notped,"|") > 1 and
                int(entry(2,bplani.notped,"|")) = wf-plani.numero
            then do:
                vplani-ok = no.
                leave.
            end.
        end.         
        if vplani-ok
        then do:
        if wf-plani.movtdc = 45
        then do:
            find first com.plani where
               com.plani.movtdc = wf-plani.movtdc and
               com.plani.etbcod = wf-plani.etbcod and
               com.plani.emite  = wf-plani.emite and
               com.plani.serie  = "V" and
               com.plani.numero = wf-plani.numero
               no-lock no-error.
            if not avail com.plani
            then do:
                find first com.plani where
                           com.plani.movtdc = wf-plani.movtdc and
                           com.plani.etbcod = wf-plani.etbcod and
                           com.plani.emite  = wf-plani.emite and
                           com.plani.serie  = "V1" and
                           com.plani.numero = wf-plani.numero
                           no-lock no-error.
                if not avail plani
                then do:
                    create com.plani.
                    buffer-copy wf-plani to com.plani.
                    for each wf-movim where
                         wf-movim.etbcod = wf-plani.etbcod and
                         wf-movim.movtdc = wf-plani.movtdc and
                         wf-movim.placod = wf-plani.placod 
                         :
                        create com.movim.
                        buffer-copy wf-movim to com.movim.
                    end.
                end.
            end.
        end.
        else do:
            vplacod = int("115" + string(wf-plani.numero,"9999999")).
            for each wf-movim where
                     wf-movim.etbcod = wf-plani.etbcod and
                     wf-movim.movtdc = wf-plani.movtdc and
                     wf-movim.placod = wf-plani.placod 
                     :
                find first com.movim where 
                           com.movim.etbcod = wf-movim.etbcod and
                           com.movim.movtdc = wf-movim.movtdc and
                           com.movim.placod = vplacod and
                           com.movim.procod = wf-movim.procod
                           no-lock no-error.
                if not avail com.movim
                then do:           
                    wf-movim.placod = vplacod.
                    create com.movim.
                    buffer-copy wf-movim to com.movim.
                end.
            end.
 
            find first com.plani where
                       com.plani.etbcod = wf-plani.etbcod and
                       com.plani.placod = vplacod and
                       com.plani.movtdc = wf-plani.movtdc
                       no-lock no-error.
            if not avail com.plani
            then do:           
                wf-plani.placod = vplacod.
                wf-plani.serie = "V1"  .

                create com.plani.
                buffer-copy wf-plani to com.plani.
            end.
        end.
        end.    
    end. 
    else do:
        if com.plani.cxacod <> wf-plani.cxacod 
        then do:
            vplacod = int("116" + string(wf-plani.numero,"9999999")).
            for each wf-movim where
                     wf-movim.etbcod = wf-plani.etbcod and
                     wf-movim.movtdc = wf-plani.movtdc and
                     wf-movim.placod = wf-plani.placod 
                     :
                find first com.movim where 
                           com.movim.etbcod = wf-movim.etbcod and
                           com.movim.movtdc = wf-movim.movtdc and
                           com.movim.placod = vplacod and
                           com.movim.procod = wf-movim.procod
                           no-lock no-error.
                if not avail com.movim
                then do:           
                    wf-movim.placod = vplacod.
                    create com.movim.
                    buffer-copy wf-movim to com.movim.
                end.
            end.
 
            find first com.plani where
                       com.plani.etbcod = wf-plani.etbcod and
                       com.plani.placod = vplacod and
                       com.plani.movtdc = wf-plani.movtdc
                       no-lock no-error.
            if not avail com.plani
            then do:           
                wf-plani.placod = vplacod.
                wf-plani.serie = "V1"  .

                create com.plani.
                buffer-copy wf-plani to com.plani.
            end.
 
        end. 
        else
        if wf-plani.platot <> com.plani.platot
        then do:
            
            vplacod = int("115" + string(wf-plani.numero,"9999999")).
            for each wf-movim where
                     wf-movim.etbcod = wf-plani.etbcod and
                     wf-movim.movtdc = wf-plani.movtdc and
                     wf-movim.placod = wf-plani.placod 
                     :
                find first com.movim where 
                           com.movim.etbcod = wf-movim.etbcod and
                           com.movim.placod = wf-movim.placod and
                           com.movim.procod = wf-movim.procod and
                           com.movim.movtdc = wf-movim.movtdc
                           no-lock no-error.
                if not avail com.movim
                then do:           
                    wf-movim.placod = vplacod.
                    create com.movim.
                    buffer-copy wf-movim to com.movim.
                end.
            end.
        end.
        else do:
            vplacod = com.plani.placod.
            if wf-plani.movtdc <> 45
            then do:
            for each wf-movim where
                     wf-movim.etbcod = wf-plani.etbcod and
                     wf-movim.movtdc = wf-plani.movtdc and
                     wf-movim.placod = wf-plani.placod 
                     :
                find first com.movim where 
                           com.movim.etbcod = wf-movim.etbcod and
                           com.movim.placod = com.plani.placod and
                           com.movim.procod = wf-movim.procod and
                           com.movim.movtdc = com.plani.movtdc
                           no-lock no-error.
                if not avail com.movim
                then do:           
                    wf-movim.placod = vplacod.
                    wf-movim.movtdc = com.plani.movtdc.
                    create com.movim.
                    buffer-copy wf-movim to com.movim.
                end.
            end.
            end.
            else do:
                for each wf-movim where
                     wf-movim.etbcod = wf-plani.etbcod and
                     wf-movim.movtdc = wf-plani.movtdc and
                     wf-movim.placod = wf-plani.placod 
                     :
                    find first com.movim where 
                           com.movim.etbcod = wf-movim.etbcod and
                           com.movim.placod = wf-movim.placod and
                           com.movim.procod = wf-movim.procod and
                           com.movim.movtdc = 5
                            no-error.
                    if avail com.movim
                    then do:           
                        com.movim.movtdc = 45.
                    end.
                end.
                com.plani.movtdc = 45.
            end.
        end.
    end.           
end.               
                                                  
