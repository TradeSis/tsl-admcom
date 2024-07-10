{admcab.i}
def var vtipo as log format "Vista/Prazo" initial no.
def stream stela.
def var vetbcod like estab.etbcod.
def var vdata       like titulo.titdtemi.
def var vdt1        as   date  format "99/99/9999" initial today. 
def var vdt2        as   date  format "99/99/9999" initial today.
def var vlote       as char format "xxxx".
def var totval like fiscal.platot.
def stream tela.
def temp-table tt-lanca
    field tip  as char format "x(01)"
    field cre  as int format "99999"  
    field val  as dec format ">,>>>,>>9.99" 
    field cod  as int format "999"
    field his  as char format "x(50)". 
        


repeat with 1 down side-label width 80 row 4 color blue/white:

    for each tt-lanca:
        delete tt-lanca.
    end.
    
    update vtipo   label "Notas" colon 20
           vetbcod label "Filial".
           
    find estab where estab.etbcod = vetbcod no-lock.
    
    disp estab.etbnom no-label.
    
    update vdt1 label "Data Inicial" colon 20
           vdt2 label "Data Final" 
           vlote label "Lote" colon 20.
   
    for each tt-lanca:
        delete tt-lanca.
    end.

    totval = 0.
    output stream stela to terminal.
    for each fiscal where fiscal.movtdc = 4       and
                          fiscal.desti  = estab.etbcod and
                          fiscal.plarec >= vdt1   and
                          fiscal.plarec <= vdt2 no-lock.
        
        if fiscal.emite = 5027
        then next.
       
        if fiscal.opfcod <> 1102 and
           fiscal.opfcod <> 2102
        then next.
           
        find forne where forne.forcod = fiscal.emite no-lock no-error.

        disp stream stela fiscal.numero
                          fiscal.plarec format "99/99/9999" 
                                with 1 down. pause 0.
        
        if vtipo  and 
           (fiscal.emite <> 533 and
            fiscal.emite <> 100071)
        then next.
 
        if vtipo = no and
           (fiscal.emite = 533 or
            fiscal.emite = 100071)
        then next.

        create tt-lanca.
        assign tt-lanca.tip  = "C"
               tt-lanca.val  = fiscal.platot.
 
        if vtipo
        then do:
            assign tt-lanca.cre  = 13  
                   tt-lanca.cod  = 37. 
                   tt-lanca.his = "PG.NF.N. " + string(fiscal.numero,"999999") 
                                  + " " + string(forne.fornom).
        end.
        else do:
            assign tt-lanca.cre  = 30003  
                   tt-lanca.cod  = 42. 
                   tt-lanca.his = "S/NT.N. " + string(fiscal.numero,"999999") 
                                  + " " + string(forne.fornom).
        end.
        totval = totval + fiscal.platot.
    end.
    output stream stela close.
    
    if totval > 0
    then do:
        create tt-lanca.
        assign tt-lanca.tip  = "D".
   
        if vtipo
        then do:

            if estab.etbcod = 22
            then tt-lanca.cre = 2720.
        
            if estab.etbcod = 95
            then tt-lanca.cre = 4001.
        
            if estab.etbcod = 996
            then tt-lanca.cre  = 7343.
    
            if estab.etbcod = 997
            then tt-lanca.cre  = 32768.
    
            if estab.etbcod = 98
            then tt-lanca.cre  = 36467.
        
            if estab.etbcod = 999
            then tt-lanca.cre  = 7330.

            tt-lanca.cod  = 06. 
            tt-lanca.his = "COMPRAS A VISTA CONF.REG.DE ENTRADAS".
            
        end.
        else do:

            if estab.etbcod = 22
            then tt-lanca.cre = 2924.
        
            if estab.etbcod = 95
            then tt-lanca.cre = 4002.
        
            if estab.etbcod = 996
            then tt-lanca.cre  = 2940.
    
            if estab.etbcod = 997
            then tt-lanca.cre  = 32771.
    
            if estab.etbcod = 98
            then tt-lanca.cre  = 36470.
        
            if estab.etbcod = 999
            then tt-lanca.cre  = 2952.

            tt-lanca.cod  = 99. 
            tt-lanca.his = "COMPRAS A PRAZO CONF.REG.DE ENTRADAS".
            
        end.

        tt-lanca.val  = totval.
    end.
    if totval = 0
    then do:
        message "Nao existe movimento".
        undo, retry.
    end.
    output to value("m:\simy\lanca" + string(estab.etbcod,">>9")).
        
    for each tt-lanca:
        put vlote 
            day(vdt2)       format "99"
            month(vdt2)     format "99"
            year(vdt2)      format "9999"
            tt-lanca.tip 
            ( totval * 100) format "999999999999999"  
            tt-lanca.cre    format "99999"   
            ( tt-lanca.val * 100) format "999999999999999"  
            tt-lanca.cod 
            tt-lanca.his skip.
    end.
    output close.
    /* dos silent ved value("m:\lanca" + string(estab.etbcod,">>9")).  */ 
end.
