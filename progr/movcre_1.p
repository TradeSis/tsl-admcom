{admcab.i}
def var ii as int.
def var vmes as int format "99".
def var vano as int format "9999".
def var dtfim like plani.pladat.
def var dtini like plani.pladat.
def buffer bsalcre for salcre.
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
    find last salcre no-lock.
    do transaction:
        create bsalcre.
        assign bsalcre.salano = vano
               bsalcre.salmes = vmes
               bsalcre.salini = salcre.salini
               bsalcre.salfin = salcre.salfin.
    end.
    
    if vmes = 12
    then dtfim = date(1 , 1 , vano + 1).
    else dtfim = date(vmes + 1,1,vano).
    dtfim = dtfim - 1.
    dtini = date(vmes,1,vano).

 
    ii    = 0.
 
    for each fiscal where fiscal.movtdc = 4       and
                          fiscal.plarec >= dtini  and
                          fiscal.plarec <= dtfim no-lock.
        
        if fiscal.emite = 5027
        then next.
       
        if fiscal.opfcod <> 112 and
           fiscal.opfcod <> 212
        then next.
           
        if (fiscal.emite = 101689 or
            fiscal.emite = 101690)
        then next.
        
        find movcre where movcre.titano = vano          and
                          movcre.titmes = vmes          and
                          movcre.etbcod = fiscal.desti  and
                          movcre.clifor = fiscal.emite  and
                          movcre.titnum = string(fiscal.numero) and
                          movcre.titpar = 0 no-error.
        if not avail movcre 
        then do transaction:
            create movcre.
            assign movcre.etbcod   = fiscal.desti
                   movcre.CliFor   = fiscal.emite
                   movcre.titnum   = string(fiscal.numero)
                   movcre.titpar   = 0
                   movcre.titdtemi = dtfim
                   movcre.titdtven = dtfim
                   movcre.titvlcob = fiscal.platot
                   movcre.titdtpag = ? 
                   movcre.titvlpag = 0
                   movcre.titsit   = "LIB"
                   movcre.titman   = "GERADO"
                   movcre.titdtinc = today
                   movcre.titmes   = vmes
                   movcre.titano   = vano
                   movcre.fechado  = no.

            find salcre where salcre.salano = vano and
                              salcre.salmes = vmes no-error.
            if not avail salcre 
            then do: 
                create salcre. 
                assign salcre.salano = vano 
                       salcre.salmes = vmes. 
            end. 
            assign salcre.salfin = salcre.salfin + fiscal.platot.
        end.
    end.
 

    
     for each lancxa where lancxa.datlan >= dtini and
                           lancxa.datlan <= dtfim and
                           lancxa.lantip = "C"    and
                           lancxa.lancod = 100 no-lock:
                          
        ii = ii + 1.
        
        display "    Gerando saldo em " dtfim no-label "..........." 
                ii no-label with frame f1. 
        pause 0.
        
        find movcre where movcre.titano = vano          and
                          movcre.titmes = vmes          and
                          movcre.etbcod = 999            and
                          movcre.clifor = lancxa.forcod and
                          movcre.titnum = lancxa.titnum and
                          movcre.titpar = lancxa.numlan no-error.
        if not avail movcre 
        then do transaction:
            create movcre.
            assign movcre.etbcod   = 999
                   movcre.CliFor   = lancxa.forcod
                   movcre.titnum   = lancxa.titnum
                   movcre.titpar   = lancxa.numlan
                   movcre.titdtemi = lancxa.datlan
                   movcre.titdtven = lancxa.datlan
                   movcre.titvlcob = lancxa.vallan
                   movcre.titdtpag = lancxa.datlan
                   movcre.titvlpag = lancxa.vallan
                   movcre.titsit   = "PAG"
                   movcre.titman   = "GERADO"
                   movcre.titdtinc = today
                   movcre.titmes   = vmes
                   movcre.titano   = vano
                   movcre.fechado  = no.

            find salcre where salcre.salano = vano and
                              salcre.salmes = vmes no-error.
            if not avail salcre 
            then do: 
                create salcre. 
                assign salcre.salano = vano 
                       salcre.salmes = vmes. 
            end. 
            assign salcre.salfin = salcre.salfin - lancxa.vallan.
        end.
    end. 
end.
