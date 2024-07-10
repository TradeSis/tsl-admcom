   
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
    
    
     

    for each clien /* where clien.dtcad >= 01/01/2003 and
                         clien.dtcad <> ? */ no-lock by clicod desc:   

        display clien.clicod with frame f3 1 down centered. 
        pause 0.
        
        for each titulo use-index iclicod 
            where titulo.clifor = clien.clicod and
                  titulo.titnat = no and
                  titulo.modcod = "cre" no-lock:
        
            if (titulo.titdtemi >= vdtini and
                titulo.titdtemi <= vdtfin) 
            then do:
                find first diario where diario.data = titulo.titdtemi no-error.
                if not avail diario
                then next.
                
                find first tt-debito where tt-debito.dt-debito = titulo.titdtemi no-error.
                if not avail tt-debito
                then do:
                    create tt-debito.
                    assign tt-debito.dt-debito = titulo.titdtemi.
                end.

                if tt-debito.total-debito < diario.venda
                then do:
                
                    assign tt-debito.total-debito = tt-debito.total-debito + 
                                                    titulo.titvlcob.

                    find lanca where lanca.empcod = titulo.empcod and
                                     lanca.titnat = titulo.titnat and
                                     lanca.modcod = titulo.modcod and
                                     lanca.etbcod = titulo.etbcod and
                                     lanca.clifor = titulo.clifor and
                                     lanca.titnum = titulo.titnum and
                                     lanca.titpar = titulo.titpar and
                                     lanca.lannat = "V"           and
                                     lanca.landat = titulo.titdtemi no-error.
                    if not avail lanca
                    then do:
                      
                        create lanca.
                        assign lanca.empcod = titulo.empcod 
                               lanca.titnat = titulo.titnat  
                               lanca.modcod = titulo.modcod  
                               lanca.etbcod = titulo.etbcod  
                               lanca.clifor = titulo.clifor  
                               lanca.titnum = titulo.titnum  
                               lanca.titpar = titulo.titpar  
                               lanca.lannat = "V"            
                               lanca.landat = titulo.titdtemi
                               lanca.lanval = if tt-debito.total-debito > 
                                                 diario.venda 
                                              then titulo.titvlcob - 
                                              (tt-debito.total-debito -
                                               diario.venda)
                                              else titulo.titvlcob. 
                                               
                        lanca.lanobs = titulo.titvlcob - lanca.lanval.

                    
                    end.

                 
                end.
            end.
                              
            if (titulo.titdtpag >= vdtini and
                titulo.titdtpag <= vdtfin)
            then do:
            
            
                find first diario where diario.data = titulo.titdtpag no-error.
                if not avail diario
                then next.
                
                find first tt-credito where tt-credito.dt-credito = titulo.titdtpag no-error.
                if not avail tt-credito
                then do:
                    create tt-credito.
                    assign tt-credito.dt-credito = titulo.titdtpag.
                end.

                if tt-credito.total-credito < diario.pagamento
                then do:
                
                    assign tt-credito.total-credito = tt-credito.total-credito + 
                                                      titulo.titvlcob.

                    
                    find lanca where lanca.empcod = titulo.empcod and
                                     lanca.titnat = titulo.titnat and
                                     lanca.modcod = titulo.modcod and
                                     lanca.etbcod = titulo.etbcod and
                                     lanca.clifor = titulo.clifor and
                                     lanca.titnum = titulo.titnum and
                                     lanca.titpar = titulo.titpar and
                                     lanca.lannat = "P"           and
                                     lanca.landat = titulo.titdtpag no-error.
                    if not avail lanca
                    then do:
                      
                        create lanca.
                        assign lanca.empcod = titulo.empcod 
                               lanca.titnat = titulo.titnat  
                               lanca.modcod = titulo.modcod  
                               lanca.etbcod = titulo.etbcod  
                               lanca.clifor = titulo.clifor  
                               lanca.titnum = titulo.titnum  
                               lanca.titpar = titulo.titpar  
                               lanca.lannat = "P"            
                               lanca.landat = titulo.titdtpag
                               lanca.lanval = if tt-credito.total-credito > 
                                                 diario.pagamento 
                                              then titulo.titvlcob - 
                                              (tt-credito.total-credito -
                                               diario.pagamento)
                                              else titulo.titvlcob. 

                         lanca.lanobs = titulo.titvlcob - lanca.lanval.


                    end.          
                end.
    
                
                /******************            JUROS     **********************/
                
                
                if titulo.titvlpag > titulo.titvlcob
                then do:
                
                    find first tt-juros where tt-juros.dt-juros = titulo.titdtpag no-error.
                    if not avail tt-juros
                    then do:
                        create tt-juros.
                        assign tt-juros.dt-juros = titulo.titdtpag.
                    end.

                    if tt-juros.total-juros < diario.juro
                    then do:
                
                        assign tt-juros.total-juros = tt-juros.total-juros + 
                                                      (titulo.titvlpag - titulo.titvlcob).

                    
                        find lanca where lanca.empcod = titulo.empcod and
                                         lanca.titnat = titulo.titnat and
                                         lanca.modcod = titulo.modcod and
                                         lanca.etbcod = titulo.etbcod and
                                         lanca.clifor = titulo.clifor and
                                         lanca.titnum = titulo.titnum and
                                         lanca.titpar = titulo.titpar and
                                         lanca.lannat = "J"           and
                                         lanca.landat = titulo.titdtpag no-error.
                        if not avail lanca
                        then do:
                      
                            create lanca.
                            assign lanca.empcod = titulo.empcod 
                                   lanca.titnat = titulo.titnat  
                                   lanca.modcod = titulo.modcod  
                                   lanca.etbcod = titulo.etbcod  
                                   lanca.clifor = titulo.clifor  
                                   lanca.titnum = titulo.titnum  
                                   lanca.titpar = titulo.titpar  
                                   lanca.lannat = "J"            
                                   lanca.landat = titulo.titdtpag
                                   lanca.lanval = if tt-juros.total-juros > 
                                                  diario.juro 
                                                  then (titulo.titvlpag -
                                                        titulo.titvlcob) -  
                                                  (tt-juros.total-juros -
                                                   diario.juro)
                                                  else (titulo.titvlpag -
                                                        titulo.titvlcob). 

                         lanca.lanobs = (titulo.titvlpag - titulo.titvlcob)
                                        - lanca.lanval.
                        
                        end.          
                    end.

                end.
                
                
                
                /*************************************************************/
                                    
            end.          
        end.
    end.

end.    
    
