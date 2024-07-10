    def input parameter par-rec as recid.
    
    find neuclien where recid(neuclien) = par-rec no-lock.
    
    def var vtemnovacao as log.
    vtemnovacao = no.
    for each titulo where titulo.empcod = 19
                          and titulo.titnat = no
                          and titulo.clifor = neuclien.clicod
                          and titulo.titdtpag = ?
                          and titulo.titsit = "LIB" 
                        no-lock
                        use-index por-clifor.
        if titulo.modcod <> "CRE" and
           titulo.modcod <> "CP0" and
           titulo.modcod <> "CP1" and
           titulo.modcod <> "CPN"
        then next.    

        if titulo.tpcontrato <> ""
        then do.
            vtemnovacao = yes.
            leave.
        end.
    end.
    if vtemnovacao      
    then do:
        if neuclien.vlrlimite > 1500 and neuclien.vctolimite >= today 
        then do on error undo:
            find current neuclien exclusive no-wait no-error.
            if avail neuclien
            then do:
                neuclien.vctolimite = today - 3.
            end.
        end.
    end.    
