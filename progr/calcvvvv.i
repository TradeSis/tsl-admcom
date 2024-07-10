def var val_acr like plani.platot.
def var val_des like plani.platot.
def var val_dev like plani.platot.
def var val_com like plani.platot.
def var val_fin like plani.platot.



vquant = 0.
if vetbcod = 999
then vetbcod = 0.

IF VFABCOD = 0
THEN DO:
for each tipmov where tipmov.movtdc = 5 no-lock,
    each estab where estab.etbcod = (if vetbcod = 0 
                                     then estab.etbcod
                                     else vetbcod )
                 and estab.etbcod <= 999 no-lock,
        each plani where plani.movtdc = tipmov.movtdc 
                     and plani.etbcod = estab.etbcod 
                     and plani.pladat >= vdti
                     and plani.pladat <= vdtf no-lock:
                
        disp "Processando Vendedores ..."
             plani.pladat
             estab.etbnom
             with frame f-mostr2 1 down row 10 centered
             no-labels. pause 0.
           
        for each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod  
                         and movim.movtdc = plani.movtdc 
                         and movim.movdat = plani.pladat no-lock :
                find produ where produ.procod = movim.procod no-lock.
                
                if vfabcod <> 0
                then if produ.fabcod <> vfabcod then next.
                
                if v-etccod > 0 and
                    produ.etccod <> v-etccod
                then next.
                if v-carcod > 0 and v-subcod > 0
                then do:
                    find first procar where procar.procod = produ.procod and
                                 procar.subcod = v-subcod
                                 no-lock no-error.
                    if not avail procar 
                    then next.
                end. 
                
                if vcomcod > 0
                then do:
                    release liped.
                    release pedid.
                    find last liped where liped.procod = produ.procod
                                      and liped.pedtdc = 1
                                   no-lock use-index liped2 no-error.

                    find first pedid of liped no-lock no-error.
    
                    if (avail pedid and pedid.comcod <> vcomcod)
                        or not avail pedid
                    then next.
                    
                end.
                    
                
                val_fin = 0.                   
                val_des = 0.  
                val_dev = 0.  
                val_acr = 0. 
                         
                val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.acfprod.
                val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.descprod.
                val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.vlserv.
    
                if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
                then
                val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des) /
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).

                val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + val_acr + 
                          val_fin. 

   
 
                
                v-valor = val_com.
                
                vquant = movim.movqtm.
                
                find first ttvend where ttvend.etbcod = plani.etbcod
                                    and ttvend.funcod = plani.vencod
                                  no-error.
                if not avail ttvend
                then do:
                    create ttvend.
                    assign 
                        ttvend.funcod = plani.vencod
                        ttvend.etbcod = plani.etbcod.
                end. 
               
                ttvend.platot = ttvend.platot + v-valor. 
                ttvend.qtd    = ttvend.qtd + vquant. 
                if plani.pladat = vdtf 
                then ttvend.pladia = ttvend.pladia + v-valor.
                
                find first ttvend where ttvend.etbcod = 999
                                    and ttvend.funcod = plani.vencod
                                  no-error.
                if not avail ttvend
                then do:
                    create ttvend.
                    assign 
                        ttvend.funcod = plani.vencod
                        ttvend.etbcod = 999.
                end. 
                ttvend.platot = ttvend.platot + v-valor. 
                ttvend.qtd    = ttvend.qtd + vquant. 
                if plani.pladat = vdtf 
                then ttvend.pladia = ttvend.pladia + v-valor.
        end. 
        hide frame f-mostra2 no-pause.  
end.

END.
ELSE DO:

    do v-data-aux1 = vdti to vdtf:
      disp "Processando Vendedores ..."
           v-data-aux1
                 with frame f-mostr2s 1 down row 10 centered
                 no-labels. pause 0.
    
      for each produ where produ.fabcod = vfabcod no-lock:
        if v-etccod > 0 and
           produ.etccod <> v-etccod
        then next.
        if v-carcod > 0 and v-subcod > 0
        then do:
            find first procar where procar.procod = produ.procod and
                                 procar.subcod = v-subcod
                                 no-lock no-error.
            if not avail procar 
            then next.
        end. 
        if vcomcod > 0
        then do:
            release liped.
            release pedid.
            find last liped where liped.procod = produ.procod
                              and liped.pedtdc = 1
                                no-lock use-index liped2 no-error.

            find first pedid of liped no-lock no-error.
    
            if (avail pedid and pedid.comcod <> vcomcod)
                or not avail pedid
            then next.
                    
        end.
        
        for each movim where movim.procod = produ.procod
                         and movim.movtdc = 5
                         and movim.movdat = v-data-aux1 no-lock:
    
            if vetbcod <> 0
            then if movim.etbcod <> vetbcod then next.
            /*
            if movim.etbcod > 99  then next.
            */
            find plani where plani.etbcod = movim.etbcod
                         and plani.placod = movim.placod 
                         and plani.pladat = movim.movdat
                         and plani.movtdc = movim.movtdc no-lock.
     
                
                val_fin = 0.                   
                val_des = 0.  
                val_dev = 0.  
                val_acr = 0. 
                         
                val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.acfprod.
                val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.descprod.
                val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.vlserv.
    
                if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
                then
                val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des) /
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).

                val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + val_acr + 
                          val_fin. 

   
 
                
                v-valor = val_com.
                
                
                
                vquant = movim.movqtm.
                
                find first ttvend where ttvend.etbcod = plani.etbcod
                                    and ttvend.funcod = plani.vencod
                                  no-error.
                if not avail ttvend
                then do:
                    create ttvend.
                    assign 
                        ttvend.funcod = plani.vencod
                        ttvend.etbcod = plani.etbcod.
                end.
                if movim.movtdc = 5
                then do :
                    ttvend.platot = ttvend.platot + v-valor.
                    ttvend.qtd    = ttvend.qtd + vquant.
                    if plani.pladat = vdtf
                    then ttvend.pladia = ttvend.pladia + v-valor.
                end.    

                find first ttvend where ttvend.etbcod = 999
                                    and ttvend.funcod = plani.vencod
                                  no-error.
                if not avail ttvend
                then do:
                    create ttvend.
                    assign 
                        ttvend.funcod = plani.vencod
                        ttvend.etbcod = 999.
                end.
                if movim.movtdc = 5
                then do :
                    ttvend.platot = ttvend.platot + v-valor.
                    ttvend.qtd    = ttvend.qtd + vquant.
                    if plani.pladat = vdtf
                    then ttvend.pladia = ttvend.pladia + v-valor.
                end.     
        end. 
      end.
    end.
    hide frame f-mostr2s no-pause.  

END.
