{admcab.i }
def var ii as int.
def var vmes as int format "99".
def var vano as int format "9999".
def var dtfim like plani.pladat.
repeat:

    update vmes label "Mes"
           vano label "Ano" with frame f1 side-label width 80.
    
    find first movcre where movcre.titano = vano and
                            movcre.titmes = vmes no-lock no-error.
    if avail movcre and movcre.fechado
    then do:
        message "Mes ja foi fechado".
        undo, retry.
    end.
    
    dtfim = date(vmes, 1, vano) - 1.
    ii    = 0.

    for each titulo where titulo.empcod = 19       and
                          titulo.titnat = yes      and
                          titulo.modcod = "DUP"    and
                          titulo.titdtemi <= dtfim no-lock: 
                          
        ii = ii + 1.
        
        display "Gerando Saldos....." ii 
                    no-label with 1 down centered. pause 0.
        
        find movcre where movcre.titano = vano and
                          movcre.titmes = vmes and
                          movcre.etbcod = titulo.etbcod and
                          movcre.clifor = titulo.clifor and
                          movcre.titnum = titulo.titnum and
                          movcre.titpar = titulo.titpar no-error.
        if not avail movcre 
        then do transaction:
            create movcre.
            assign movcre.etbcod   = titulo.etbcod 
                   movcre.CliFor   = titulo.CliFor 
                   movcre.titnum   = titulo.titnum 
                   movcre.titpar   = titulo.titpar 
                   movcre.titdtemi = titulo.titdtemi 
                   movcre.titdtven = titulo.titdtven 
                   movcre.titvlcob = titulo.titvlcob 
                   movcre.titdtpag = titulo.titdtpag 
                   movcre.titvlpag = titulo.titvlpag 
                   movcre.titsit   = titulo.titsit 
                   movcre.titman   = "GERADO" 
                   movcre.titdtinc = today 
                   movcre.titmes   = vmes 
                   movcre.titano   = vano
                   movcre.fechado  = no.

            if titulo.titdtpag > dtfim
            then assign movcre.titdtpag = ?  
                        movcre.titvlpag = 0  
                        movcre.titsit   = "LIB". 
        end.
    end.
end.
