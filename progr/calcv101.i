
IF VFABCOD = 0
THEN DO:
 for each tipmov where movtdc = 5 or tipmov.movtdc = 12 no-lock,
    each estab where estab.etbcod = (if vetbcod = 0 
                                     then estab.etbcod
                                     else vetbcod) 
                 and estab.etbcod <= 900 no-lock, 
    each plani where plani.movtdc = tipmov.movtdc
                 and plani.etbcod = estab.etbcod
                 and plani.pladat >= vdti
                 and plani.pladat <= vdtf no-lock,
            each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat no-lock,
            first produ where produ.procod = movim.procod no-lock,
            first sclase where sclase.clacod = produ.clacod no-lock,
            first clase where clase.clacod = sclase.clasup no-lock:
            
            if {conv_igual.i estab.etbcod}
            then next.

            v-valor = (movim.movpc * movim.movqtm).

            find first ttsetor where ttsetor.etbcod = plani.etbcod 
                                 and ttsetor.setcod = produ.catcod
                                 use-index setor no-error.
            if not avail ttsetor
            then do:
                create ttsetor.
                assign  ttsetor.setcod = produ.catcod
                        ttsetor.etbcod = plani.etbcod.
            end.

            if not tipmov.movtdc = 12 then do:
                if v-valor = ? 
                then do :
                    ttsetor.platot = ttsetor.platot + 
                                     (movim.movqtm * movim.movpc).
                    v-valor = movim.movqtm * movim.movpc.                 
                end.
                else ttsetor.platot = ttsetor.platot + v-valor.
                ttsetor.qtd = ttsetor.qtd + movim.movqtm.
                if plani.pladat = vdtf
                then ttsetor.pladia = ttsetor.pladia + v-valor.
            end.    
            find first ttsetor where ttsetor.etbcod = 0
                                 and ttsetor.setcod = produ.catcod
                                 use-index setor no-error.
            if not avail ttsetor then do:
                create ttsetor.
                assign  ttsetor.setcod = produ.catcod
                        ttsetor.etbcod = 0.
            end.
            if tipmov.movtdc <> 12 then do:
                ttsetor.platot = ttsetor.platot + v-valor.
                ttsetor.qtd = ttsetor.qtd + movim.movqtm.
                if plani.pladat = vdtf
                then ttsetor.pladia = ttsetor.pladia + v-valor.
            end.    

            find first ttclase where ttclase.etbcod = plani.etbcod 
                                 and ttclase.clacod = clase.clacod
                               use-index clase no-error.
            if not avail ttclase
            then do:
                create ttclase.
                assign  ttclase.clacod = clase.clacod
                        ttclase.clasup = produ.catcod
                        ttclase.etbcod = plani.etbcod.
            end.
            if tipmov.movtdc <> 12
            then do :
                assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                       ttclase.platot = ttclase.platot + v-valor.
                if plani.pladat = vdtf
                then ttclase.pladia = ttclase.pladia + v-valor.
            end.    
            
            find first ttclase where ttclase.etbcod = 0 
                                 and ttclase.clacod = clase.clacod
                               use-index clase no-error.
            if not avail ttclase
            then do:
                create ttclase.
                assign  ttclase.clacod = clase.clacod
                        ttclase.clasup = produ.catcod
                        ttclase.etbcod = 0.
            end.
            if tipmov.movtdc <> 12
            then do :
                assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                       ttclase.platot = ttclase.platot + v-valor.
                if plani.pladat = vdtf
                then ttclase.pladia = ttclase.pladia + v-valor.
            end.    
                        
            find first ttsclase where ttsclase.etbcod = plani.etbcod 
                                  and ttsclase.clacod = sclase.clacod
                                use-index sclase no-error.
            if not avail ttsclase
            then do:
                create ttsclase.
                assign ttsclase.clacod = sclase.clacod
                       ttsclase.clasup = clase.clacod
                       ttsclase.etbcod = plani.etbcod.
            end.
            if tipmov.movtdc <> 12 then do:
                assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                        ttsclase.platot = ttsclase.platot + v-valor.
                if plani.pladat = vdtf
                then ttsclase.pladia = ttsclase.pladia + v-valor.
            end.    

            find first ttsclase where ttsclase.etbcod = 0
                                  and ttsclase.clacod = sclase.clacod
                                use-index sclase no-error.
            if not avail ttsclase
            then do:
                create ttsclase.
                assign  ttsclase.clacod = sclase.clacod
                        ttsclase.clasup = clase.clacod
                        ttsclase.etbcod = 0.
            end.
            if tipmov.movtdc <> 12 then do:
                assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                        ttsclase.platot = ttsclase.platot + v-valor.
                if plani.pladat = vdtf
                then ttsclase.pladia = ttsclase.pladia + v-valor.
            end.    

            find first ttprodu where ttprodu.etbcod = plani.etbcod 
                                 and ttprodu.procod = produ.procod
                                 and ttprodu.clacod = sclase.clacod
                               use-index produ no-error.
            if not avail ttprodu
            then do:
                create ttprodu.
                assign  ttprodu.procod = produ.procod
                        ttprodu.clacod = sclase.clacod
                        ttprodu.etbcod = plani.etbcod.
            end.
            if tipmov.movtdc <> 12 then do:
                assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                        ttprodu.platot = ttprodu.platot + v-valor.
                if plani.pladat = vdtf
                then ttprodu.pladia = ttprodu.pladia + v-valor.
            end.    

            find first ttprodu where ttprodu.etbcod = 0
                                 and ttprodu.procod = produ.procod 
                                 and ttprodu.clacod = sclase.clacod
                               use-index produ no-error.
            if not avail ttprodu
            then do:
                create ttprodu.
                assign  ttprodu.procod = produ.procod
                        ttprodu.clacod = sclase.clacod
                        ttprodu.etbcod = 0.
            end.
            if tipmov.movtdc <> 12
            then do:
                assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                        ttprodu.platot = ttprodu.platot + v-valor.
                if plani.pladat = vdtf
                then ttprodu.pladia = ttprodu.pladia + v-valor.
            end.    
 end.
END.
ELSE DO:
    do v-data-aux = vdti to vdtf:
      disp  v-data-aux format "99/99/9999"
            with frame f-moxtr1s. pause 0.
      for each produ use-index iprofab where produ.fabcod = vfabcod no-lock:  
        if vetbcod <> 0 
        then do:
            for each movim use-index icurva 
                       where movim.etbcod = vetbcod
                         and movim.movtdc = 5
                         and movim.procod = produ.procod
                         and movim.movdat = v-data-aux no-lock:

                find plani where plani.etbcod = movim.etbcod
                             and plani.placod = movim.placod 
                             and plani.pladat = movim.movdat
                             and plani.movtdc = movim.movtdc no-lock.
        
                find estab where estab.etbcod = plani.etbcod no-lock.
             
                find sclase where sclase.clacod = produ.clacod no-lock.
                find clase where clase.clacod = sclase.clasup no-lock.
            
                v-valor = (movim.movpc * movim.movqtm).

                find first ttsetor where ttsetor.etbcod = plani.etbcod 
                                     and ttsetor.setcod = produ.catcod
                                     use-index setor no-error.
                if not avail ttsetor
                then do:
                    create ttsetor.
                    assign  ttsetor.setcod = produ.catcod
                            ttsetor.etbcod = plani.etbcod.
                end.

                if not movim.movtdc = 12 then do:
                    if v-valor = ? then do:
                        ttsetor.platot = ttsetor.platot + 
                                         (movim.movqtm * movim.movpc).
                        v-valor = movim.movqtm * movim.movpc.                 
                    end.
                    else ttsetor.platot = ttsetor.platot + v-valor.
                    ttsetor.qtd = ttsetor.qtd + movim.movqtm.
                    if plani.pladat = vdtf
                    then ttsetor.pladia = ttsetor.pladia + v-valor.
                end.    

                find first ttsetor where ttsetor.etbcod = 0
                                     and ttsetor.setcod = produ.catcod
                                     use-index setor no-error.
                if not avail ttsetor
                then do:
                    create ttsetor.
                    assign  ttsetor.setcod = produ.catcod
                            ttsetor.etbcod = 0.
                end.

                if movim.movtdc <> 12 then do:
                    ttsetor.platot = ttsetor.platot + v-valor.
                    ttsetor.qtd = ttsetor.qtd + movim.movqtm.
                    if plani.pladat = vdtf
                    then ttsetor.pladia = ttsetor.pladia + v-valor.
                end.    

                /************ gerando vendas para a clase *******/

                find first ttclase where ttclase.etbcod = plani.etbcod 
                                     and ttclase.clacod = clase.clacod
                                     use-index clase no-error.
                if not avail ttclase
                then do:
                    create ttclase.
                    assign  ttclase.clacod = clase.clacod
                            ttclase.clasup = produ.catcod
                            ttclase.etbcod = plani.etbcod.
                end.
                if movim.movtdc <> 12 then do:
                    assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                           ttclase.platot = ttclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttclase.pladia = ttclase.pladia + v-valor.
                end.    
            
                find first ttclase where ttclase.etbcod = 0 
                                     and ttclase.clacod = clase.clacod
                                   use-index clase no-error.
                if not avail ttclase
                then do:
                    create ttclase.
                    assign  ttclase.clacod = clase.clacod
                            ttclase.clasup = produ.catcod
                            ttclase.etbcod = 0.
                end.
                if movim.movtdc <> 12 then do:
                    assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                           ttclase.platot = ttclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttclase.pladia = ttclase.pladia + v-valor.
                end.    

                /******** gerando vendas para a sclase *******/
                            
                find first ttsclase where ttsclase.etbcod = plani.etbcod 
                                      and ttsclase.clacod = sclase.clacod
                                      use-index sclase no-error.
                if not avail ttsclase
                then do:
                    create ttsclase.
                    assign  ttsclase.clacod = sclase.clacod
                            ttsclase.clasup = clase.clacod
                            ttsclase.etbcod = plani.etbcod.
                end.
                if movim.movtdc <> 12 then do:
                    assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                            ttsclase.platot = ttsclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttsclase.pladia = ttsclase.pladia + v-valor.
                end.    

                find first ttsclase where ttsclase.etbcod = 0
                                      and ttsclase.clacod = sclase.clacod
                                      use-index sclase no-error.
                if not avail ttsclase
                then do:
                    create ttsclase.
                    assign  ttsclase.clacod = sclase.clacod
                            ttsclase.clasup = clase.clacod
                            ttsclase.etbcod = 0.
                end.
                if movim.movtdc <> 12 then do:
                    assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                            ttsclase.platot = ttsclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttsclase.pladia = ttsclase.pladia + v-valor.
                end.    
                        
                /************ gerando vendas para os produtos ********/

                find first ttprodu where ttprodu.etbcod = plani.etbcod 
                                     and ttprodu.procod = produ.procod
                                     and ttprodu.clacod = sclase.clacod
                                   use-index produ no-error.
                if not avail ttprodu
                then do:
                    create ttprodu.
                    assign  ttprodu.procod = produ.procod
                            ttprodu.clacod = sclase.clacod
                            ttprodu.etbcod = plani.etbcod.
                end.
                if movim.movtdc <> 12 then do:
                    assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                            ttprodu.platot = ttprodu.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttprodu.pladia = ttprodu.pladia + v-valor.
                end.    

                find first ttprodu where ttprodu.etbcod = 0
                                     and ttprodu.procod = produ.procod 
                                     and ttprodu.clacod = sclase.clacod
                                     use-index produ no-error.
                if not avail ttprodu
                then do:
                    create ttprodu.
                    assign  ttprodu.procod = produ.procod
                            ttprodu.clacod = sclase.clacod
                            ttprodu.etbcod = 0.
                end.
            
                if movim.movtdc <> 12 then do:
                    assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                            ttprodu.platot = ttprodu.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttprodu.pladia = ttprodu.pladia + v-valor.
                end.    
        
            end.
        end.
        else do:
            for each movim use-index datsai where movim.procod = produ.procod
                                      and movim.movtdc = 5
                                      and movim.movdat = v-data-aux no-lock:
                find plani where plani.etbcod = movim.etbcod
                     and plani.placod = movim.placod 
                     and plani.pladat = movim.movdat
                     and plani.movtdc = movim.movtdc no-lock.
                find estab where estab.etbcod = plani.etbcod no-lock.
                find sclase where sclase.clacod = produ.clacod no-lock.
                find clase where clase.clacod = sclase.clasup no-lock.
            
            v-valor = (movim.movpc * movim.movqtm).
            find first ttsetor where ttsetor.etbcod = plani.etbcod 
                                     and ttsetor.setcod = produ.catcod
                                     use-index setor no-error.
                if not avail ttsetor
                then do:
                    create ttsetor.
                    assign  ttsetor.setcod = produ.catcod
                            ttsetor.etbcod = plani.etbcod.
                end.

                if not movim.movtdc = 12 then do:
                    if v-valor = ? then do:
                        ttsetor.platot = ttsetor.platot + 
                                         (movim.movqtm * movim.movpc).
                        v-valor = movim.movqtm * movim.movpc.                 
                    end.
                    else ttsetor.platot = ttsetor.platot + v-valor.
                    ttsetor.qtd = ttsetor.qtd + movim.movqtm.
                    if plani.pladat = vdtf
                    then ttsetor.pladia = ttsetor.pladia + v-valor.
                end.    

                find first ttsetor where ttsetor.etbcod = 0
                                     and ttsetor.setcod = produ.catcod
                                     use-index setor no-error.
                if not avail ttsetor
                then do:
                    create ttsetor.
                    assign  ttsetor.setcod = produ.catcod
                            ttsetor.etbcod = 0.
                end.

                if movim.movtdc <> 12 then do:
                    ttsetor.platot = ttsetor.platot + v-valor.
                    ttsetor.qtd = ttsetor.qtd + movim.movqtm.
                    if plani.pladat = vdtf
                    then ttsetor.pladia = ttsetor.pladia + v-valor.
                end.    

                /************ gerando vendas para a clase *******/

                find first ttclase where ttclase.etbcod = plani.etbcod 
                                     and ttclase.clacod = clase.clacod
                                     use-index clase no-error.
                if not avail ttclase
                then do:
                    create ttclase.
                    assign  ttclase.clacod = clase.clacod
                            ttclase.clasup = produ.catcod
                            ttclase.etbcod = plani.etbcod.
                end.
                if movim.movtdc <> 12 then do:
                    assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                           ttclase.platot = ttclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttclase.pladia = ttclase.pladia + v-valor.
                end.    
            
                find first ttclase where ttclase.etbcod = 0 
                                     and ttclase.clacod = clase.clacod
                                   use-index clase no-error.
                if not avail ttclase
                then do:
                    create ttclase.
                    assign  ttclase.clacod = clase.clacod
                            ttclase.clasup = produ.catcod
                            ttclase.etbcod = 0.
                end.
                if movim.movtdc <> 12 then do:
                    assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                           ttclase.platot = ttclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttclase.pladia = ttclase.pladia + v-valor.
                end.    

                /******** gerando vendas para a sclase *******/
                            
                find first ttsclase where ttsclase.etbcod = plani.etbcod 
                                      and ttsclase.clacod = sclase.clacod
                                      use-index sclase no-error.
                if not avail ttsclase
                then do:
                    create ttsclase.
                    assign  ttsclase.clacod = sclase.clacod
                            ttsclase.clasup = clase.clacod
                            ttsclase.etbcod = plani.etbcod.
                end.
                if movim.movtdc <> 12 then do:
                    assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                            ttsclase.platot = ttsclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttsclase.pladia = ttsclase.pladia + v-valor.
                end.    

                find first ttsclase where ttsclase.etbcod = 0
                                      and ttsclase.clacod = sclase.clacod
                                      use-index sclase no-error.
                if not avail ttsclase
                then do:
                    create ttsclase.
                    assign  ttsclase.clacod = sclase.clacod
                            ttsclase.clasup = clase.clacod
                            ttsclase.etbcod = 0.
                end.
                if movim.movtdc <> 12 then do:
                    assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                            ttsclase.platot = ttsclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttsclase.pladia = ttsclase.pladia + v-valor.
                end.    
                        
                /************ gerando vendas para os produtos ********/

                find first ttprodu where ttprodu.etbcod = plani.etbcod 
                                     and ttprodu.procod = produ.procod
                                     and ttprodu.clacod = sclase.clacod
                                   use-index produ no-error.
                if not avail ttprodu
                then do:
                    create ttprodu.
                    assign  ttprodu.procod = produ.procod
                            ttprodu.clacod = sclase.clacod
                            ttprodu.etbcod = plani.etbcod.
                end.
                if movim.movtdc <> 12 then do:
                    assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                            ttprodu.platot = ttprodu.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttprodu.pladia = ttprodu.pladia + v-valor.
                end.    

                find first ttprodu where ttprodu.etbcod = 0
                                     and ttprodu.procod = produ.procod 
                                     and ttprodu.clacod = sclase.clacod
                                     use-index produ no-error.
                if not avail ttprodu
                then do:
                    create ttprodu.
                    assign  ttprodu.procod = produ.procod
                            ttprodu.clacod = sclase.clacod
                            ttprodu.etbcod = 0.
                end.
            
                if movim.movtdc <> 12 then do:
                    assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                            ttprodu.platot = ttprodu.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttprodu.pladia = ttprodu.pladia + v-valor.
                end.         
            /***

            find first ttsetor where ttsetor.etbcod = plani.etbcod 
                                 and ttsetor.setcod = produ.catcod
                                 use-index setor no-error.
            if not avail ttsetor
            then do:
                create ttsetor.
                assign  ttsetor.setcod = produ.catcod
                        ttsetor.etbcod = plani.etbcod.
            end.

            if not movim.movtdc = 12 then do:
                if v-valor = ? 
                then do :
                    ttsetor.platot = ttsetor.platot + 
                                     (movim.movqtm * movim.movpc).
                    v-valor = movim.movqtm * movim.movpc.                 
                end.
                else ttsetor.platot = ttsetor.platot + v-valor.
                ttsetor.qtd = ttsetor.qtd + movim.movqtm.
                if plani.pladat = vdtf
                then ttsetor.pladia = ttsetor.pladia + v-valor.
            end.    

            find first ttsetor where ttsetor.etbcod = 0
                                 and ttsetor.setcod = produ.catcod
                                 use-index setor no-error.
            if not avail ttsetor
            then do:
                create ttsetor.
                assign  ttsetor.setcod = produ.catcod
                        ttsetor.etbcod = 0.
            end.

            if movim.movtdc <> 12
            then do :
                ttsetor.platot = ttsetor.platot + v-valor.
                ttsetor.qtd = ttsetor.qtd + movim.movqtm.
                if plani.pladat = vdtf
                then ttsetor.pladia = ttsetor.pladia + v-valor.
            end.    

            /************ gerando vendas para a clase *******/

            find first ttclase where ttclase.etbcod = plani.etbcod 
                                 and ttclase.clacod = clase.clacod
                               use-index clase no-error.
            if not avail ttclase
            then do:
                create ttclase.
                assign  ttclase.clacod = clase.clacod
                        ttclase.clasup = produ.catcod
                        ttclase.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                       ttclase.platot = ttclase.platot + v-valor.
                if plani.pladat = vdtf
                then ttclase.pladia = ttclase.pladia + v-valor.
            end.    
            
            find first ttclase where ttclase.etbcod = 0 
                                 and ttclase.clacod = clase.clacod
                               use-index clase no-error.
            if not avail ttclase
            then do:
                create ttclase.
                assign  ttclase.clacod = clase.clacod
                        ttclase.clasup = produ.catcod
                        ttclase.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                       ttclase.platot = ttclase.platot + v-valor.
                if plani.pladat = vdtf
                then ttclase.pladia = ttclase.pladia + v-valor.
            end.    

            /******** gerando vendas para a sclase *******/
                        
            find first ttsclase where ttsclase.etbcod = plani.etbcod 
                                  and ttsclase.clacod = sclase.clacod
                                use-index sclase no-error.
            if not avail ttsclase
            then do:
                create ttsclase.
                assign  ttsclase.clacod = sclase.clacod
                        ttsclase.clasup = clase.clacod
                        ttsclase.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12
            then do :
                assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                        ttsclase.platot = ttsclase.platot + v-valor.
                if plani.pladat = vdtf
                then ttsclase.pladia = ttsclase.pladia + v-valor.
            end.    

            find first ttsclase where ttsclase.etbcod = 0
                                  and ttsclase.clacod = sclase.clacod
                                use-index sclase no-error.
            if not avail ttsclase
            then do:
                create ttsclase.
                assign  ttsclase.clacod = sclase.clacod
                        ttsclase.clasup = clase.clacod
                        ttsclase.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do :
                assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                        ttsclase.platot = ttsclase.platot + v-valor.
                if plani.pladat = vdtf
                then ttsclase.pladia = ttsclase.pladia + v-valor.
            end.    
                        
            /************ gerando vendas para os produtos ********/

            find first ttprodu where ttprodu.etbcod = plani.etbcod 
                                 and ttprodu.procod = produ.procod
                                 and ttprodu.clacod = sclase.clacod
                               use-index produ no-error.
            if not avail ttprodu
            then do:
                create ttprodu.
                assign  ttprodu.procod = produ.procod
                        ttprodu.clacod = sclase.clacod
                        ttprodu.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12
            then do :
                assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                        ttprodu.platot = ttprodu.platot + v-valor.
                if plani.pladat = vdtf
                then ttprodu.pladia = ttprodu.pladia + v-valor.
            end.    

            find first ttprodu where ttprodu.etbcod = 0
                                 and ttprodu.procod = produ.procod 
                                 and ttprodu.clacod = sclase.clacod
                               use-index produ no-error.
            if not avail ttprodu
            then do:
                create ttprodu.
                assign  ttprodu.procod = produ.procod
                        ttprodu.clacod = sclase.clacod
                        ttprodu.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do:
                assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                        ttprodu.platot = ttprodu.platot + v-valor.
                if plani.pladat = vdtf
                then ttprodu.pladia = ttprodu.pladia + v-valor.
            end.    
            ***/
        end.
      end.
    end.
    hide frame f-moxtr1s no-pause.
END.
