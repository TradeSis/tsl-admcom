   
def temp-table tt-debito
    field dt-debito      as date format "99/99/9999"
    field total-debito   as dec  format ">>>,>>>,>>9.99".
    
def temp-table tt-credito 
    field dt-credito     as date format "99/99/9999"
    field total-credito  as dec  format ">>>,>>>,>>9.99".
    
def temp-table tt-juros
    field dt-juros       as date format "99/99/9999" 
    field total-juros    as dec format ">>>,>>>,>>9.99".
    
    
def var vdtini as date format "99/99/9999".
def var vdtfin as date format "99/99/9999".

    



repeat:

    
    
    update vdtini label "Periodo"
           vdtfin no-label with frame f1 width 80 side-label. 

    for each tt-debito:
        delete tt-debito.
    end.

    for each tt-credito:
        delete tt-credito.
    end.    

    for each tt-juros:
        delete tt-juros.
    end.
    
    
     

    for each clien no-lock by clicod desc:   

        display clien.clicod with frame f3 1 down centered. 
        pause 0.
       
        for each plani where plani.movtdc = 05 and
                             plani.desti  = clien.clicod and
                             plani.pladat >= vdtini      and
                             plani.pladat <= vdtfin no-lock:
        
            if plani.crecod = 1
            then next.
            
            find first finctb.diario where 
                    finctb.diario.data = plani.pladat no-error.
            if not avail diario 
            then next.
                
            find first tt-debito where tt-debito.dt-debito = plani.pladat 
                    no-error.
            if not avail tt-debito 
            then do: 
                create tt-debito.
                assign tt-debito.dt-debito = plani.pladat.
            end.

            if tt-debito.total-debito < finctb.diario.venda 
            then do:
                
                assign tt-debito.total-debito = tt-debito.total-debito + 
                                                plani.platot.

                find lanca where lanca.empcod = 19 and
                                 lanca.titnat = no and
                                 lanca.modcod = plani.serie  and
                                 lanca.etbcod = plani.etbcod and
                                 lanca.clifor = clien.clicod and
                                 lanca.titnum = string(plani.numero) and
                                 lanca.titpar = plani.placod  and
                                 lanca.lannat = "V"           and
                                 lanca.landat = plani.pladat no-error.
                if not avail lanca
                then do:
                      
                    create lanca.
                    assign lanca.empcod = 19 
                           lanca.titnat = no  
                           lanca.modcod = plani.serie  
                           lanca.etbcod = plani.etbcod  
                           lanca.clifor = clien.clicod  
                           lanca.titnum = string(plani.numero)
                           lanca.titpar = plani.placod   
                           lanca.lannat = "V"             
                           lanca.landat = plani.pladat 
                           lanca.lanval = if tt-debito.total-debito > 
                                             finctb.diario.venda 
                                          then plani.platot - 
                                              (tt-debito.total-debito -
                                               finctb.diario.venda)
                                              else plani.platot.
                                               
                        lanca.lanobs = plani.platot - lanca.lanval.

                    
                end.

                 
            end.
        end.
        


        for each finctb.titulo use-index iclicod 
            where finctb.titulo.clifor = clien.clicod and
                  finctb.titulo.titnat = no and
                  finctb.titulo.modcod = "cre" no-lock:
        
                      
            if (finctb.titulo.titdtpag >= vdtini and
                finctb.titulo.titdtpag <= vdtfin)
            then do:
            
            
                find first finctb.diario 
                    where finctb.diario.data = finctb.titulo.titdtpag no-error.
                if not avail finctb.diario
                then next.
                
                find first tt-credito 
                 where tt-credito.dt-credito = finctb.titulo.titdtpag no-error.
                if not avail tt-credito
                then do:
                    create tt-credito.
                    assign tt-credito.dt-credito = finctb.titulo.titdtpag.
                end.

                if tt-credito.total-credito < finctb.diario.pagamento
                then do:
                
                    assign tt-credito.total-credito = 
                                            tt-credito.total-credito + 
                                                      finctb.titulo.titvlcob.

                    
                    find lanca where lanca.empcod = finctb.titulo.empcod and
                                     lanca.titnat = finctb.titulo.titnat and
                                     lanca.modcod = finctb.titulo.modcod and
                                     lanca.etbcod = finctb.titulo.etbcod and
                                     lanca.clifor = finctb.titulo.clifor and
                                     lanca.titnum = finctb.titulo.titnum and
                                     lanca.titpar = finctb.titulo.titpar and
                                     lanca.lannat = "P"           and
                                     lanca.landat = finctb.titulo.titdtpag 
                                     no-error.
                    if not avail lanca
                    then do:
                      
                        create lanca.
                        assign lanca.empcod = finctb.titulo.empcod 
                               lanca.titnat = finctb.titulo.titnat  
                               lanca.modcod = finctb.titulo.modcod  
                               lanca.etbcod = finctb.titulo.etbcod  
                               lanca.clifor = finctb.titulo.clifor  
                               lanca.titnum = finctb.titulo.titnum  
                               lanca.titpar = finctb.titulo.titpar  
                               lanca.lannat = "P"            
                               lanca.landat = finctb.titulo.titdtpag
                               lanca.lanval = if tt-credito.total-credito > 
                                                 finctb.diario.pagamento 
                                              then finctb.titulo.titvlcob - 
                                              (tt-credito.total-credito -
                                               finctb.diario.pagamento)
                                              else finctb.titulo.titvlcob. 

                         lanca.lanobs = finctb.titulo.titvlcob - lanca.lanval.


                    end.          
                end.
    
                
                /******************            JUROS     **********************/
                
                
                if finctb.titulo.titjuro > 0
                then do:
                
                    find first tt-juros where tt-juros.dt-juros = 
                                              finctb.titulo.titdtpag no-error.
                    if not avail tt-juros
                    then do:
                        create tt-juros.
                        assign tt-juros.dt-juros = finctb.titulo.titdtpag.
                    end.

                    if tt-juros.total-juros < finctb.diario.juro
                    then do:
                
                        assign tt-juros.total-juros = tt-juros.total-juros + 
                                                  finctb.titulo.titjuro.

                    
                        find lanca where lanca.empcod = finctb.titulo.empcod and
                                         lanca.titnat = finctb.titulo.titnat and
                                         lanca.modcod = finctb.titulo.modcod and
                                         lanca.etbcod = finctb.titulo.etbcod and
                                         lanca.clifor = finctb.titulo.clifor and
                                         lanca.titnum = finctb.titulo.titnum and
                                         lanca.titpar = finctb.titulo.titpar and
                                         lanca.lannat = "J"           and
                                         lanca.landat = finctb.titulo.titdtpag 
                                                            no-error.
                        if not avail lanca
                        then do:
                      
                            create lanca.
                            assign lanca.empcod = finctb.titulo.empcod 
                                   lanca.titnat = finctb.titulo.titnat  
                                   lanca.modcod = finctb.titulo.modcod  
                                   lanca.etbcod = finctb.titulo.etbcod  
                                   lanca.clifor = finctb.titulo.clifor  
                                   lanca.titnum = finctb.titulo.titnum  
                                   lanca.titpar = finctb.titulo.titpar  
                                   lanca.lannat = "J"            
                                   lanca.landat = finctb.titulo.titdtpag
                                   
                                   lanca.lanval = if tt-juros.total-juros > 
                                                  finctb.diario.juro 
                                                  then finctb.titulo.titjuro -  
                                  (tt-juros.total-juros - finctb.diario.juro)
                                                  else finctb.titulo.titjuro. 


                        lanca.lanobs = finctb.titulo.titjuro - lanca.lanval.
                        
                        end.          
                    end.

                end.
                
                
                
                /*************************************************************/
                                    
            end.          
        end.
        
        
        /*********************** lp *******************/
        
        
        
        for each d.titulo use-index iclicod 
            where d.titulo.clifor = clien.clicod and
                  d.titulo.titnat = no and
                  d.titulo.modcod = "cre" no-lock:
        
                      
            if (d.titulo.titdtpag >= vdtini and
                d.titulo.titdtpag <= vdtfin)
            then do:
            
            
                find first finctb.diario where 
                        finctb.diario.data = d.titulo.titdtpag no-error.
                if not avail finctb.diario
                then next.
                
                find first tt-credito where 
                    tt-credito.dt-credito = d.titulo.titdtpag no-error.
                if not avail tt-credito
                then do:
                    create tt-credito.
                    assign tt-credito.dt-credito = d.titulo.titdtpag.
                end.

                if tt-credito.total-credito < finctb.diario.pagamento
                then do:
                
                    assign tt-credito.total-credito = 
                                        tt-credito.total-credito + 
                                        d.titulo.titvlcob.

                    
                    find lanca where lanca.empcod = d.titulo.empcod and
                                     lanca.titnat = d.titulo.titnat and
                                     lanca.modcod = d.titulo.modcod and
                                     lanca.etbcod = d.titulo.etbcod and
                                     lanca.clifor = d.titulo.clifor and
                                     lanca.titnum = d.titulo.titnum and
                                     lanca.titpar = d.titulo.titpar and
                                     lanca.lannat = "P"           and
                                     lanca.landat = d.titulo.titdtpag 
                                         no-error.
                    if not avail lanca
                    then do:
                      
                        create lanca.
                        assign lanca.empcod = d.titulo.empcod 
                               lanca.titnat = d.titulo.titnat  
                               lanca.modcod = d.titulo.modcod  
                               lanca.etbcod = d.titulo.etbcod  
                               lanca.clifor = d.titulo.clifor  
                               lanca.titnum = d.titulo.titnum  
                               lanca.titpar = d.titulo.titpar  
                               lanca.lannat = "P"            
                               lanca.landat = d.titulo.titdtpag
                               lanca.lanval = if tt-credito.total-credito > 
                                                 finctb.diario.pagamento 
                                              then d.titulo.titvlcob - 
                                              (tt-credito.total-credito -
                                               finctb.diario.pagamento)
                                              else d.titulo.titvlcob. 

                         lanca.lanobs = d.titulo.titvlcob - lanca.lanval.


                    end.          
                end.
    
                
                /******************            JUROS     **********************/
                
                
                if d.titulo.titjuro > 0
                then do:
                
                    find first tt-juros where 
                        tt-juros.dt-juros = d.titulo.titdtpag no-error.
                    if not avail tt-juros
                    then do:
                        create tt-juros.
                        assign tt-juros.dt-juros = d.titulo.titdtpag.
                    end.

                    if tt-juros.total-juros < finctb.diario.juro
                    then do:
                
                        assign tt-juros.total-juros = tt-juros.total-juros + 
                                                      d.titulo.titjuro.

                    
                        find lanca where lanca.empcod = d.titulo.empcod and
                                         lanca.titnat = d.titulo.titnat and
                                         lanca.modcod = d.titulo.modcod and
                                         lanca.etbcod = d.titulo.etbcod and
                                         lanca.clifor = d.titulo.clifor and
                                         lanca.titnum = d.titulo.titnum and
                                         lanca.titpar = d.titulo.titpar and
                                         lanca.lannat = "J"           and
                                         lanca.landat = d.titulo.titdtpag                                                                no-error.
                        if not avail lanca
                        then do:
                      
                            create lanca.
                            assign lanca.empcod = d.titulo.empcod 
                                   lanca.titnat = d.titulo.titnat  
                                   lanca.modcod = d.titulo.modcod  
                                   lanca.etbcod = d.titulo.etbcod  
                                   lanca.clifor = d.titulo.clifor  
                                   lanca.titnum = d.titulo.titnum  
                                   lanca.titpar = d.titulo.titpar  
                                   lanca.lannat = "J"            
                                   lanca.landat = d.titulo.titdtpag
                                   lanca.lanval = if tt-juros.total-juros > 
                                                     finctb.diario.juro 
                                                  then d.titulo.titjuro - 
                                    (tt-juros.total-juros - finctb.diario.juro)
                                                  else d.titulo.titjuro. 

                                    lanca.lanobs = d.titulo.titjuro - 
                                                   lanca.lanval.
                        
                        end.          
                
                    end.

                end.
                
                
                
                /*************************************************************/
                                    
            end.          
        end.
        
        
        
        
        
        
    end.

end.    
    
