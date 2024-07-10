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
    for each estab where estab.etbcod = (if vetbcod = 0  
                                         then estab.etbcod 
                                         else vetbcod ) no-lock:
        if estab.etbcod > 99 then next.
                 
        for each plani where plani.movtdc = 5
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
                
                find first tt-filtro where
                     tt-filtro.procod = produ.procod  
                     no-lock no-error.
                if not avail tt-filtro
                then next.
                
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
                val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des)~ /
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).

                val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + va~l_acr + 
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
        for each movim where movim.procod = produ.procod
                         and movim.movtdc = 5
                         and movim.movdat = v-data-aux1 no-lock:
    
            if vetbcod <> 0
            then if movim.etbcod <> vetbcod then next.
            
            if movim.etbcod > 99 then next.
            
            find plani where plani.etbcod = movim.etbcod
                         and plani.placod = movim.placod 
                         and plani.pladat = movim.movdat
                         and plani.movtdc = movim.movtdc no-lock.
                
                find first tt-filtro where
                     tt-filtro.procod = produ.procod  
                     no-lock no-error.
                if not avail tt-filtro
                then next.
                
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
                val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des)~ /
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).

                val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + va~l_acr + 
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
