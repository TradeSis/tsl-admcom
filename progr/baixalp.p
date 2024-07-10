{admbatch.i new}

def buffer btitulo for fin.titulo.
def var vetbcod like estab.etbcod.
def temp-table tt-contrato
    field rec-con as recid.

def temp-table tt-titulo like fin.titulo.
def temp-table tt-titudesp like titudesp.

def temp-table wmodal like fin.modal.

for each wmodal:
    delete wmodal.
end.
for each fin.modal where fin.modal.modcod <> "DEV"
                     and fin.modal.modcod <> "BON"
                     and fin.modal.modcod <> "CHP"
                     no-lock:
    create wmodal.
    assign wmodal.modcod = fin.modal.modcod
           wmodal.modnom = fin.modal.modnom.
end.

/***** Migração Dragão ******
def temp-table tt-estab like estab
    field migrou-dragao as logical format "SIM/NAO".

for each estab no-lock.

    create tt-estab.
    buffer-copy estab to tt-estab.

    find tabaux where
         tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
         tabaux.nome_campo = "MIGROU-DRAGAO" no-error.
    if avail tabaux
    then tt-estab.migrou-dragao = (tabaux.valor_campo = "SIM").
    else tt-estab.migrou-dragao = no.

end.
********/

output to baixalp.log.
repeat:
    
    /***** Migração Dragão ******
    for each estab no-lock:
        for each d.titulo where d.titulo.empcod = 19 and
                        d.titulo.titnat = no and
                        d.titulo.modcod = "CRE" and
                        d.titulo.etbcod = estab.etbcod and 
                        d.titulo.titpar = 0 and
                        d.titulo.titdtpag = ? and
                        d.titulo.titsit = "LIB"
                        .
            find fin.titulo where 
                fin.titulo.empcod = d.titulo.empcod and
                fin.titulo.titnat = d.titulo.titnat and
                fin.titulo.modcod = d.titulo.modcod and
                fin.titulo.etbcod = d.titulo.etbcod and
                fin.titulo.clifor = d.titulo.clifor and
                fin.titulo.titnum = d.titulo.titnum and
                fin.titulo.titpar = d.titulo.titpar
                no-lock no-error.
            if avail fin.titulo and
                 fin.titulo.titdtpag <> ? and
                 fin.titulo.titsit = "PAG" and 
                 fin.titulo.etbcod <> 189 
            then do transaction:
             
                find first tt-estab where tt-estab.etbcod = fin.titulo.etbcod
                                no-lock no-error.
                if avail tt-estab and tt-estab.migrou-dragao = false                            then do:
                    buffer-copy fin.titulo to d.titulo.            
                end.    
            end.
        end.
    end.
    **************/
    
    for each fin.modal no-lock:
        find first banfin.modal where
                   banfin.modal.modcod = fin.modal.modcod
                   no-lock no-error.
        if not avail banfin.modal
        then do:
            create banfin.modal.
            buffer-copy fin.modal to banfin.modal.
        end.           
    end.

    for each wmodal where wmodal.modcod <> "DUP" no-lock:
        for each fin.titulo where fin.titulo.empcod = 19 and
                                  fin.titulo.titnat = yes   and
                                  fin.titulo.modcod = wmodal.modcod and
                                  fin.titulo.titdtpag >= today - 15  and
                                  fin.titulo.titsit   =   "PAG" no-lock:
            create tt-titulo.
            buffer-copy fin.titulo to tt-titulo.
        end.
        for each fin.titulo where fin.titulo.datexp >= today - 15 and
                                  fin.titulo.empcod = 19 and
                                  fin.titulo.titnat = yes   and
                                  fin.titulo.modcod = wmodal.modcod and
                                  fin.titulo.titdtpag >= today - 15 and
                                  fin.titulo.titsit   =  "PAG" no-lock:
            find first tt-titulo of fin.titulo no-lock no-error.
            if not avail tt-titulo
            then do:
                create tt-titulo.
                buffer-copy fin.titulo to tt-titulo.
            end.
        end.

        for each banfin.titulo where banfin.titulo.empcod = 19 and
                                  banfin.titulo.titnat = yes   and
                                  banfin.titulo.modcod = wmodal.modcod and
                                  banfin.titulo.titdtpag >= today - 15  and
                                  banfin.titulo.titsit   =   "PAG" no-lock:
            create tt-titulo.
            buffer-copy banfin.titulo to tt-titulo.                          
        end.
        for each banfin.titulo where banfin.titulo.datexp >= today - 15 and
                                  banfin.titulo.empcod = 19 and
                                  banfin.titulo.titnat = yes   and
                                  banfin.titulo.modcod = wmodal.modcod and
                                  banfin.titulo.titdtpag >= today - 15 and
                                  banfin.titulo.titsit   =   "PAG" no-lock:
            find first tt-titulo where
                       tt-titulo.empcod = banfin.titulo.empcod and
                       tt-titulo.titnat = banfin.titulo.titnat and
                       tt-titulo.modcod = banfin.titulo.modcod and
                       tt-titulo.etbcod = banfin.titulo.etbcod and
                       tt-titulo.clifor = banfin.titulo.clifor and
                       tt-titulo.titnum = banfin.titulo.titnum and
                       tt-titulo.titpar = banfin.titulo.titpar and
                       tt-titulo.titdtemi = banfin.titulo.titdtemi
                       no-lock no-error.
            if not avail tt-titulo
            then do:
                create tt-titulo.
                buffer-copy banfin.titulo to tt-titulo.     
            end.                     
        end.                               
    end.
    for each tt-titulo:    
        for each wmodal where wmodal.modcod <> "DUP" no-lock:
            for each titudesp where
                     titudesp.empcod = tt-titulo.empcod and
                     titudesp.titnat = tt-titulo.titnat and
                     titudesp.modcod = wmodal.modcod and
                     titudesp.clifor = tt-titulo.clifor and
                     titudesp.titnum = tt-titulo.titnum and
                     titudesp.titpar = tt-titulo.titpar and
                     titudesp.titdtemi = tt-titulo.titdtemi /*and
                     titudesp.titdtven = tt-titulo.titdtven   */
                     :
                assign
                    titudesp.titdtpag = tt-titulo.titdtpag
                    titudesp.titvlpag = titudesp.titvlcob
                    titudesp.titsit   = tt-titulo.titsit
                    titudesp.titdtven = tt-titulo.titdtven.

            end.
            for each tituctb where
                     tituctb.empcod = tt-titulo.empcod and
                     tituctb.titnat = tt-titulo.titnat and
                     tituctb.modcod = wmodal.modcod and
                     tituctb.clifor = tt-titulo.clifor and
                     tituctb.titnum = tt-titulo.titnum and
                     tituctb.titpar = tt-titulo.titpar and
                     tituctb.titdtemi = tt-titulo.titdtemi /*and
                     tituctb.titdtven = tt-titulo.titdtven */
                     :
                assign
                    tituctb.titdtpag = tt-titulo.titdtpag
                    tituctb.titvlpag = tituctb.titvlcob
                    tituctb.titsit   = tt-titulo.titsit
                    tituctb.titdtven = tt-titulo.titdtven.

            end.

        end.
    end.        
    
    leave.
    
end.
output close.

/***** Migração Dragão ******

def buffer etitulo for fin.titulo.

for each fin.titulo where
         fin.titulo.empcod = 19 and
         fin.titulo.titnat = no and
         fin.titulo.modcod = "CRE" and
         fin.titulo.titpar >= 50  and
         fin.titulo.titsit = "LIB"
         no-lock:

    find first etitulo where
               etitulo.empcod = 19 and
               etitulo.titnat = no and
               etitulo.modcod = "CRE" and
               etitulo.etbcod = fin.titulo.etbcod and
               etitulo.clifor = fin.titulo.clifor and
               etitulo.titnum = fin.titulo.titnum and
               etitulo.titpar < 50 and
               etitulo.titpar > 30
               no-lock no-error.
    
    if avail etitulo then next.
               
    find d.titulo where d.titulo.empcod = fin.titulo.empcod and
                                d.titulo.titnat = fin.titulo.titnat and
                                d.titulo.modcod = fin.titulo.modcod and
                                d.titulo.etbcod = fin.titulo.etbcod and
                                d.titulo.clifor = fin.titulo.clifor and
                                d.titulo.titnum = fin.titulo.titnum and
                                d.titulo.titpar = fin.titulo.titpar
                                    no-error.
                                    
    if avail d.titulo          
    then do:
        if d.titulo.titsit <> "PAG"
        then do:
            {tt-titulo.i d.titulo fin.titulo}.
        end.
    end.
    else do:
        if fin.titulo.etbcod <> 189
        then do:
            find first tt-estab where tt-estab.etbcod = fin.titulo.etbcod
                                           no-lock no-error.
            if avail tt-estab and tt-estab.migrou-dragao = false
            then do:
                create d.titulo.
                {tt-titulo.i d.titulo fin.titulo}.
            end.    
        end.
    end.  
      
    find first etitulo where
               etitulo.empcod = 19 and
               etitulo.titnat = no and
               etitulo.modcod = "CRE" and
               etitulo.etbcod = fin.titulo.etbcod and
               etitulo.clifor = fin.titulo.clifor and
               etitulo.titnum = fin.titulo.titnum and
               etitulo.titpar = fin.titulo.titpar
               exclusive no-wait no-error.
    if avail etitulo
        and etitulo.etbcod <> 189
    then do:
        find first tt-estab where tt-estab.etbcod = etitulo.etbcod
                                     no-lock no-error.
        if avail tt-estab and tt-estab.migrou-dragao = false
        then do:
            delete etitulo.   
        end.
    end.
end.    

**************/
    
    



