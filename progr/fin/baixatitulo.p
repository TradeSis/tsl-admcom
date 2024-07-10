/* helio 18042023 - CSLOG - Importação de Contrato - Qualitor 23211 marcar contrato.datexp para subir contrato no cslog */
 /* helio 28022022 - iepro */
  
 {/admcom/progr/acha.i}
 def input param precpdvdoc as recid.
 def input param prectitulo as recid.
 
 
 def var prec as recid.
                    def var vtpcontrato as char.
 
            find pdvdoc where recid(pdvdoc) = precpdvdoc.
            find pdvmov of pdvdoc no-lock.
            find titulo where recid(titulo) = prectitulo
                exclusive no-wait no-error.
            if not avail titulo
            then if locked titulo
                 then do:
                    pdvdoc.acha1 = "operacao de baixa nao completada porque registro esta locado".
                    message pdvdoc.acha1.
                    pause 1 no-message.
                    return error "TITULO_RECID=" + string(prectitulo) + " LOCADO".
                 end.
                    
            
            if titulo.contnum = ?
            then titulo.contnum  = int(pdvdoc.contnum).
            
                    if   acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and           
                         acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM" 
                    then vtpcontrato = "F". 
                    else vtpcontrato = titulo.tpcontrato.
                                      
            if pdvdoc.valor < 0 /* Estorno */
            then do:
                    assign
                    titulo.tittotpag = titulo.tittotpag + pdvdoc.titvlcob.
                     /* BAIXA DO NOMINAL */
                    if titulo.titjuro >= pdvdoc.valor_encargo * -1
                    then titulo.titjuro  = titulo.titjuro  + pdvdoc.valor_encargo.
                    
                    if titulo.titpagdesc >= pdvdoc.desconto * -1
                    then titulo.titpagdesc  = titulo.titpagdesc  + pdvdoc.desconto.
                    
                    titulo.titvlpag = titulo.titvlpag + pdvdoc.valor. /* TOTAL */
                    titulo.titdtpag = if titulo.dtultpgparcial = ?
                                      then if titulo.titvlcob - titulo.tittotpag <= 0
                                           then pdvdoc.datamov
                                           else ?
                                      else if titulo.titvltot - titulo.tittotpag <= 0
                                           then pdvdoc.datamov
                                           else ?.
                    if titulo.titdtpag = ?
                    then do:
                        titulo.titsit = "LIB".
                        titulo.moecod = "".
                        titulo.etbcobra = ?.
                        
                        /* helio 18042023 - CSLOG - Importação de Contrato - Qualitor 23211
                                marcar contrato.datexp para subir contrato no cslog */
                        find contrato where contrato.contnum = int(titulo.titnum) exclusive no-wait no-error. 
                        if avail contrato
                        then do:
                            contrato.datexp = today.
                        end.       
                    end.    
                    else titulo.titsit = "PAG".
                    
                    if titulo.dtultpgparcial = ? /* NUNCA TEVE PARCIAL */
                    then titulo.titvltot = titulo.titvlcob. /* Guarda Total */
                    else do:
                        if titulo.titvltot - titulo.tittotpag <= 0
                        then titulo.titvlcob = titulo.titvltot.
                        else titulo.titvlcob = titulo.titvltot - titulo.tittotpag.
                    end.
                    
                    titulo.dtultpgparcial = today.  /* MARCA PARCIAL */
                    pdvdoc.pago_parcial   = "S".

            end.
            else do.
                assign

                    titulo.tittotpag = titulo.tittotpag + pdvdoc.titvlcob /* BAIXA DO NOMINAL */
                    
                    titulo.titjuro  = titulo.titjuro  + pdvdoc.valor_encargo
                    titulo.titpagdesc  = titulo.titpagdesc  + pdvdoc.desconto

                    titulo.titvlpag = titulo.titvlpag + pdvdoc.valor /* TOTAL */
                    
                    titulo.titdtpag = if titulo.dtultpgparcial = ?
                                      then if titulo.titvlcob - titulo.tittotpag <= 0
                                           then pdvdoc.datamov
                                           else ?
                                      else if titulo.titvltot - titulo.tittotpag <= 0
                                           then pdvdoc.datamov
                                           else ?.
                    titulo.etbcobra = pdvdoc.etbcod.
                    
    
                if titulo.titdtpag <> ?
                then do:
                    titulo.titsit = "PAG".
                    titulo.moecod = pdvmov.ctmcod.
                              
                    if  titulo.dtultpgparcial <> ? /* JA TEVE PARCIAL */
                    then do:
                        titulo.titvlcob = titulo.titvltot. /* RETORNA VALOR TOTAL */
                        
                        /*titulo.dtultpgparcial = today. */
                        pdvdoc.pago_parcial   = "N".
                    end.
                    
                end.    
                else do:
                    /* parcial roda poscart, 
                       senao é por trigger */
                    
                    titulo.titsit = "LIB".
                     
                    if titulo.dtultpgparcial = ? /* NUNCA TEVE PARCIAL */
                    then titulo.titvltot = titulo.titvlcob. /* Guarda Total */
                    
                    titulo.dtultpgparcial = today.  /* MARCA PARCIAL */
                    pdvdoc.pago_parcial   = "S".

                    titulo.titvlcob       = titulo.titvltot - titulo.tittotpag. /* BAIXA SALDO A PAGAR */
                    

    
                end.
                
                find titprotparc where 
                        titprotparc.operacao = "IEPRO" and
                        titprotparc.contnum  = int(titulo.titnum) and
                        titprotparc.titpar   = titulo.titpar
                        no-lock no-error.
                if avail titprotparc
                then do:
                    run iep/pcancbaixado.p (recid(titprotparc), input pdvdoc.datamov).
                end.
                                        
                                        
                
                
            end.
            
                pdvdoc.pstatus = YES.
                
                find cobra of titulo no-lock.
                if cobra.sicred and pdvdoc.ctmcod <> "RFN" /* "REFIN" */
                then run /admcom/progr/fin/sicrepagam_create.p (recid(pdvdoc),int(pdvdoc.contnum), pdvdoc.titpar,output prec).

                /**  DESCONTINUADO HELIO 15022022 
                run /admcom/progr/fin/gerahisposcart.p   
                        (recid(titulo),  
                         "pagamento",  
                         pdvmov.datamov,
                         vtpcontrato,
                         pdvdoc.titvlcob,
                         titulo.cobcod,
                         titulo.cobcod). 
                 ***/
        
 