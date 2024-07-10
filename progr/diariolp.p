   
def temp-table tt-debito
    field dt-debito      as date format "99/99/9999"
    field total-debito   as dec  format ">>>,>>>,>>9.99"
    index dt dt-debito.
    
def temp-table tt-credito 
    field dt-credito     as date format "99/99/9999"
    field total-credito  as dec  format ">>>,>>>,>>9.99"
    index dt dt-credito.
    
def temp-table tt-juros
    field dt-juros       as date format "99/99/9999" 
    field total-juros    as dec format ">>>,>>>,>>9.99"
    index dt dt-juros.
    
    
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

    def var vdt as date.
    def var ii as int.
    do vdt = vdtini to vdtfin: 
    for each lanca where lanca.landat = vdt:


        ii = ii + 1.
        if ii mod 10000 = 0
        then disp ii with frame fff 1 down. pause 0.        
        
        if lanca.lannat = "V"
        then do:
            
            find first tt-debito use-index dt where tt-debito.dt-debito = lanca.landat no-error.
            if not avail tt-debito
            then do:
                create tt-debito.
                assign tt-debito.dt-debito = lanca.landat.
            end.
            assign tt-debito.total-debito = tt-debito.total-debito + lanca.lanval.
            
        end.
        
        
        if lanca.lannat = "P"
        then do:
            
            find first tt-credito use-index dt where tt-credito.dt-credito = lanca.landat no-error.
            if not avail tt-credito
            then do:
                create tt-credito.
                assign tt-credito.dt-credito = lanca.landat.
            end.
            assign tt-credito.total-credito = tt-credito.total-credito + lanca.lanval.
            
        end.
        

        if lanca.lannat = "J"
        then do:
            
            find first tt-juros use-index dt where tt-juros.dt-juros = lanca.landat no-error.
            if not avail tt-juros
            then do:
                create tt-juros.
                assign tt-juros.dt-juros = lanca.landat.
            end.
            assign tt-juros.total-juros = tt-juros.total-juros + lanca.lanval.
            
        end.
        

        
        
    end.        
    end.            
    
    
     

    for each clien /* where clien.dtcad >= 01/01/2003 and
                         clien.dtcad <> ? */ no-lock by clicod desc:   

        display clien.clicod with frame f3 1 down centered. 
        pause 0.
        
        for each d.titulo use-index iclicod 
            where d.titulo.clifor = clien.clicod and
                  d.titulo.titnat = no and
                  d.titulo.modcod = "cre" no-lock:
        
            if (d.titulo.titdtemi >= vdtini and
                d.titulo.titdtemi <= vdtfin) 
            then do:
                find first finctb.diario where finctb.diario.data = d.titulo.titdtemi no-error.
                if not avail finctb.diario
                then next.
                
                find first tt-debito where tt-debito.dt-debito = d.titulo.titdtemi no-error.
                if not avail tt-debito
                then do:
                    create tt-debito.
                    assign tt-debito.dt-debito = d.titulo.titdtemi.
                end.

                if tt-debito.total-debito < finctb.diario.venda
                then do:
                
                    assign tt-debito.total-debito = tt-debito.total-debito + 
                                                    d.titulo.titvlcob.

                    find lanca where lanca.empcod = d.titulo.empcod and
                                     lanca.titnat = d.titulo.titnat and
                                     lanca.modcod = d.titulo.modcod and
                                     lanca.etbcod = d.titulo.etbcod and
                                     lanca.clifor = d.titulo.clifor and
                                     lanca.titnum = d.titulo.titnum and
                                     lanca.titpar = d.titulo.titpar and
                                     lanca.lannat = "V"           and
                                     lanca.landat = d.titulo.titdtemi no-error.
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
                               lanca.lannat = "V"            
                               lanca.landat = d.titulo.titdtemi
                               lanca.lanval = if tt-debito.total-debito > 
                                                 finctb.diario.venda 
                                              then d.titulo.titvlcob - 
                                              (tt-debito.total-debito -
                                               finctb.diario.venda)
                                              else d.titulo.titvlcob. 
                                               
                        lanca.lanobs = d.titulo.titvlcob - lanca.lanval.

                    
                    end.

                 
                end.
            end.
                              
            if (d.titulo.titdtpag >= vdtini and
                d.titulo.titdtpag <= vdtfin)
            then do:
            
            
                find first diario where finctb.diario.data = d.titulo.titdtpag no-error.
                if not avail diario
                then next.
                
                find first tt-credito where tt-credito.dt-credito = d.titulo.titdtpag no-error.
                if not avail tt-credito
                then do:
                    create tt-credito.
                    assign tt-credito.dt-credito = d.titulo.titdtpag.
                end.

                if tt-credito.total-credito < finctb.diario.pagamento
                then do:
                
                    assign tt-credito.total-credito = tt-credito.total-credito + 
                                                      d.titulo.titvlcob.

                    
                    find lanca where lanca.empcod = d.titulo.empcod and
                                     lanca.titnat = d.titulo.titnat and
                                     lanca.modcod = d.titulo.modcod and
                                     lanca.etbcod = d.titulo.etbcod and
                                     lanca.clifor = d.titulo.clifor and
                                     lanca.titnum = d.titulo.titnum and
                                     lanca.titpar = d.titulo.titpar and
                                     lanca.lannat = "P"           and
                                     lanca.landat = d.titulo.titdtpag no-error.
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
                
                
                if d.titulo.titvlpag > d.titulo.titvlcob
                then do:
                
                    find first tt-juros where tt-juros.dt-juros = d.titulo.titdtpag no-error.
                    if not avail tt-juros
                    then do:
                        create tt-juros.
                        assign tt-juros.dt-juros = d.titulo.titdtpag.
                    end.

                    if tt-juros.total-juros < finctb.diario.juro
                    then do:
                
                        assign tt-juros.total-juros = tt-juros.total-juros + 
                                                      (d.titulo.titvlpag - d.titulo.titvlcob).

                    
                        find lanca where lanca.empcod = d.titulo.empcod and
                                         lanca.titnat = d.titulo.titnat and
                                         lanca.modcod = d.titulo.modcod and
                                         lanca.etbcod = d.titulo.etbcod and
                                         lanca.clifor = d.titulo.clifor and
                                         lanca.titnum = d.titulo.titnum and
                                         lanca.titpar = d.titulo.titpar and
                                         lanca.lannat = "J"           and
                                         lanca.landat = d.titulo.titdtpag no-error.
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
                                                  then (d.titulo.titvlpag -
                                                        d.titulo.titvlcob) -  
                                                  (tt-juros.total-juros -
                                                   finctb.diario.juro)
                                                  else (d.titulo.titvlpag -
                                                        d.titulo.titvlcob). 

                         lanca.lanobs = (d.titulo.titvlpag - d.titulo.titvlcob)
                                        - lanca.lanval.
                        
                        end.          
                    end.

                end.
                
                
                
                /*************************************************************/
                                    
            end.          
        end.
    end.

end.    
    
