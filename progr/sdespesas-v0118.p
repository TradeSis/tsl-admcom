    def input parameter vdti as date.
    def input parameter vdtf as date.
    def input parameter p-setcod as int.
    def shared temp-table tt-titulo like fin.titulo.
    def shared temp-table tt-titudesp like titudesp.
    def shared temp-table tt-bftitulo like banfin.titulo.
    def var wtitnat as log init yes.
    def var vsetcod as int.
    def buffer wmodal for fin.modal.
    def buffer wempre for empre.
    find first wempre no-lock.
    def var vdt as date.
    for each wmodal where
             wmodal.modcod <> "DEV" and
             wmodal.modcod <> "BON" and
             wmodal.modcod <> "CHP" and
             wmodal.modcod <> "DUP" no-lock:
        do vdt = vdti to vdtf:
            /*for each setaut where (if p-setcod > 0
                                   then setaut.setcod = p-setcod 
                                   else true) no-lock.
                vsetcod = setaut.setcod.*/
            do:    
                for each fin.titulo where fin.titulo.empcod = wempre.empcod and
                                      fin.titulo.titnat     = wtitnat   and
                                      fin.titulo.modcod     = wmodal.modcod and
                                      fin.titulo.titdtpag   =  vdt and
                                      fin.titulo.titsit     =   "PAG" no-lock:

                    find first titudesp where
                               titudesp.empcod = fin.titulo.empcod and
                               titudesp.titnat = fin.titulo.titnat and
                               titudesp.modcod = fin.titulo.modcod and
                               titudesp.etbcod = fin.titulo.etbcod and
                               titudesp.clifor = fin.titulo.clifor and
                               titudesp.titnum = fin.titulo.titnum and
                               titudesp.titdtemi = fin.titulo.titdtemi
                               no-lock no-error.
                    if avail titudesp and vdt > 06/30/13
                    then next. 

                    if fin.titulo.titbanpag > 0
                    then vsetcod = fin.titulo.titbanpag.
                    else do:
                        find first foraut where
                                   foraut.forcod = fin.titulo.clifor
                                   no-lock no-error.
                        if avail foraut 
                        then vsetcod = foraut.setcod.
                        else next.
                    end.    
                    if p-setcod > 0  and  p-setcod <> vsetcod
                    then.
                    else do:
                        /*find tt-titulo of fin.titulo no-error.
                        if not avail tt-titulo
                        then*/ do:
                            create tt-titulo.
                            buffer-copy fin.titulo to tt-titulo.
                            tt-titulo.titbanpag = vsetcod.
                        end.
                    end.
                end.
                for each titudesp where titudesp.empcod = wempre.empcod and
                                      titudesp.titnat   = wtitnat   and
                                      titudesp.modcod   = wmodal.modcod and
                                      titudesp.titdtpag =  vdt and
                                      titudesp.titsit   =   "PAG" no-lock:
                    
                    
                    if titudesp.titbanpag > 0
                    then vsetcod = titudesp.titbanpag.
                    else do:                    
                        find first foraut where
                                   foraut.forcod = titudesp.clifor
                                   no-lock no-error.
                        if avail foraut 
                        then vsetcod = foraut.setcod.
                        else next.
                    end.
                    if p-setcod > 0  and  p-setcod <> vsetcod
                    then.
                    else do:
                        create tt-titudesp.
                        buffer-copy titudesp to tt-titudesp.
                        tt-titudesp.titbanpag = vsetcod.
                    end.
                end.
                for each banfin.titulo where 
                             banfin.titulo.empcod   = wempre.empcod and
                             banfin.titulo.titnat   = wtitnat and
                             banfin.titulo.modcod   = wmodal.modcod and
                             banfin.titulo.titdtpag =  vdt  and
                             banfin.titulo.titsit   =   "PAG" no-lock:
                        
                        find first titudesp where
                               titudesp.empcod = banfin.titulo.empcod and
                               titudesp.titnat = banfin.titulo.titnat and
                               titudesp.modcod = banfin.titulo.modcod and
                               titudesp.etbcod = banfin.titulo.etbcod and
                               titudesp.clifor = banfin.titulo.clifor and
                               titudesp.titnum = banfin.titulo.titnum and
                               titudesp.titdtemi = banfin.titulo.titdtemi
                               no-lock no-error.
                        if avail titudesp and vdt > 06/30/13
                        then  next. 
                        
                        if banfin.titulo.titbanpag > 0
                        then vsetcod = banfin.titulo.titbanpag.
                        else do:
                            find first foraut where
                                   foraut.forcod = banfin.titulo.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then vsetcod = foraut.setcod.
                            else next.
                        end.
                        if p-setcod > 0  and  p-setcod <> vsetcod
                        then.
                        else do: 
                            create tt-bftitulo.
                            buffer-copy banfin.titulo to tt-bftitulo.
                            tt-bftitulo.titbanpag = vsetcod.
                        end.
                    end.
               end.
         end.
    end.

