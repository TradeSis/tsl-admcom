def var vetbcod         as int.
def var vdti            as date.
def var vdtf            as date.
def var vokpagamento    as log init yes .
def var vemite          as int.

procedure gera-fiscal:
    for each tipmov where tipmov.movtdc = 4 or
                          tipmov.movtdc = 10 or
                          tipmov.movtdc = 11 or
                          tipmov.movtdc = 12 or
                          tipmov.movtdc = 15 or
                          tipmov.movtdc = 27 or
                          tipmov.movtdc = 28 or
                          tipmov.movtdc = 32 or
                          tipmov.movtdc = 35 or
                          tipmov.movtdc = 47 or
                          tipmov.movtdc = 51 or
                          tipmov.movtdc = 53 or
                          tipmov.movtdc = 57 or
                          tipmov.movtdc = 60 or
                          tipmov.movtdc = 61 or
                          tipmov.movtdc = 62 or
                          tipmov.movtdc = 65 
        or can-find (first tipmovaux where
                            tipmovaux.movtdc = tipmov.movtdc and
                            tipmovaux.nome_campo = "PROGRAMA-NF" AND
                            tipmovaux.valor_campo = "nfentall")
        no-lock :
        for each estab where if vetbcod = 0
                             then true 
                             else estab.etbcod = vetbcod no-lock:
        
        for each plani where plani.movtdc = tipmov.movtdc and
                             plani.etbcod = estab.etbcod  and
                             plani.dtinclu >= vdti        and
                             plani.dtinclu <= vdtf
                                    no-lock:

                                    
            /**********************
            Notsit: Yes = Aberta, No = Fechada
            Descarta notas abertas de todos os tipos exceto devolução.
            ***********************/
            
            if plani.movtdc <> 12 and plani.emite <> plani.desti
            then do:
                /*
                find forne where forne.forcod = plani.emite no-lock no-error.
                if not avail forne
                then next.
                */
                if plani.notsit = no
                then next.
                
            end.
            /*                        
            if plani.numero = 0
            then next.
            */
            if plani.emite = 5027
            then next.
        
            if plani.movtdc = 12 and
               plani.serie <> "1"
            then next.
            
            run pagamento.
            if not vokpagamento
            then next.
            
            vemite = plani.emite.
            if plani.emite = 998
            then vemite = 900 /*95*/.
            find fiscal where fiscal.emite  = vemite and
                              fiscal.desti  = plani.desti and
                              fiscal.movtdc = plani.movtdc and
                              fiscal.numero = plani.numero and
                              fiscal.serie  = plani.serie 
                                exclusive-lock no-error.
            if not avail fiscal
            then do:

                create fiscal.
                assign  fiscal.emite  = vemite
                        fiscal.desti  = plani.desti
                        fiscal.movtdc = plani.movtdc
                        fiscal.numero = plani.numero
                        fiscal.serie  = plani.serie
                        fiscal.outras = plani.outras
                        fiscal.plaemi = plani.pladat
                        fiscal.plarec = plani.dtinclu
                        fiscal.platot = plani.platot 
                        fiscal.bicms  = plani.bicms     
                        fiscal.icms   = plani.icms   
                        fiscal.ipi    = plani.ipi
                        fiscal.opfcod = int(plani.opccod).
                if plani.movtdc = 12 
                then fiscal.opfcod = plani.hiccod.
                
                if avail forne
                then do:
                    if forne.ufecod = "RS" 
                    then assign fiscal.alicms = 17.
                    else assign fiscal.alicms = 12.
                end.
                else do:
                    assign fiscal.alicms = 12.
                end.    
                
            end.
            else do:
            
                if fiscal.outras <> plani.outras
                then assign fiscal.outras = plani.outras.
                
                if fiscal.plaemi <> plani.pladat
                then assign fiscal.plaemi = plani.pladat.
                
                if fiscal.plarec <> plani.dtinclu
                then assign fiscal.plarec = plani.dtinclu.

                if fiscal.platot <> plani.platot
                then assign fiscal.platot = plani.platot.
                        
                if fiscal.bicms <> plani.bicms
                then assign fiscal.bicms  = plani.bicms.

                if fiscal.icms <> plani.icms
                then assign fiscal.icms   = plani.icms.

                if fiscal.ipi <> plani.ipi
                then assign fiscal.ipi    = plani.ipi.
                
                if fiscal.opfcod <> int(plani.opccod)
                then assign fiscal.opfcod = int(plani.opccod).
                
                if fiscal.alicms <> plani.AlICMS
                then do:                
                    if avail forne
                    then do:
                        if forne.ufecod = "RS" 
                        then assign fiscal.alicms = 17.
                        else assign fiscal.alicms = 12.
                    end.
                    else do:
                        assign fiscal.alicms = 12.
                    end.    
                end.
                
            end.
        end.
        end.
    end.        
end procedure.


procedure pagamento:
    vokpagamento = yes.
    if plani.movtdc = 37
    then do:
        find first titulo where titulo.empcod = 19 and
                          titulo.titnat = yes and
                          titulo.modcod = "LUZ" and
                          titulo.etbcod = plani.etbcod and
                          titulo.clifor = plani.emite and
                          titulo.titnum = string(plani.numero) and
                          titulo.titvlcob = plani.platot /*and
                          titulo.titsit = "PAG"            */
                          no-lock no-error.
        if not avail titulo
        then vokpagamento = no.
    end.
end.

