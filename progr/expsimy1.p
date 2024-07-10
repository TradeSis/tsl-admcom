{admcab.i}
def var vtot like plani.platot.
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

    vtot = 0.

    update vdt1 label "Data Inicial" colon 20
           vdt2 label "Data Final" 
           vlote label "Lote" colon 20.
   
    for each tt-lanca:
        delete tt-lanca.
    end.

    totval = 0.
    output stream stela to terminal.
    for each fiscal where fiscal.movtdc = 12      and
                          fiscal.opfcod = 1202    and
                          fiscal.plarec >= vdt1   and
                          fiscal.plarec <= vdt2 no-lock break by fiscal.desti.
                          
        disp stream stela fiscal.emite
                          fiscal.numero
                          fiscal.plarec format "99/99/9999" 
                                with 1 down. pause 0.
        
        totval = totval + fiscal.platot.
        
        if last-of(fiscal.desti)
        then do:
            create tt-lanca.
            assign tt-lanca.tip  = "D"
                   tt-lanca.val  = totval
                   tt-lanca.cod  = 40 
                   tt-lanca.his = "DEV.N/DATA CF REG.ENTRADAS".
            
            if fiscal.emite = 1
            then tt-lanca.cre = 1760.
            
            if fiscal.emite = 2
            then tt-lanca.cre = 1786.
            
            if fiscal.emite = 3
            then tt-lanca.cre = 36751.
            
            if fiscal.emite = 4
            then tt-lanca.cre = 1799.
            
            if fiscal.emite = 5
            then tt-lanca.cre = 1806.
             
            if fiscal.emite = 6
            then tt-lanca.cre = 1819.
             
            if fiscal.emite = 7
            then tt-lanca.cre = 1821.
             
            if fiscal.emite = 8
            then tt-lanca.cre = 788.
             
            if fiscal.emite = 9
            then tt-lanca.cre = 1834.
             
            if fiscal.emite = 10
            then tt-lanca.cre = 1847.
             
            if fiscal.emite = 11
            then tt-lanca.cre = 822.
             
            if fiscal.emite = 12
            then tt-lanca.cre = 8721.
             
            if fiscal.emite = 13
            then tt-lanca.cre = 1850.
             
            if fiscal.emite = 14
            then tt-lanca.cre = 1862.
             
            if fiscal.emite = 15
            then tt-lanca.cre = 1875.
             
            if fiscal.emite = 16
            then tt-lanca.cre = 1888.
             
            if fiscal.emite = 17
            then tt-lanca.cre = 1890.
             
            if fiscal.emite = 18
            then tt-lanca.cre = 1908.
             
            if fiscal.emite = 19
            then tt-lanca.cre = 8499.
             
            if fiscal.emite = 20
            then tt-lanca.cre = 1910.
             
            if fiscal.emite = 21
            then tt-lanca.cre = 1923.
             
            if fiscal.emite = 23
            then tt-lanca.cre = 31440.
             
            if fiscal.emite = 24
            then tt-lanca.cre = 31735.
             
            if fiscal.emite = 25
            then tt-lanca.cre = 35554.
             
            if fiscal.emite = 26
            then tt-lanca.cre = 35568.
             
            if fiscal.emite = 27
            then tt-lanca.cre = 35571.
             
            if fiscal.emite = 28
            then tt-lanca.cre = 36320.
             
            if fiscal.emite = 29
            then tt-lanca.cre = 36333.
             
            if fiscal.emite = 30
            then tt-lanca.cre = 36765.
             
            if fiscal.emite = 31
            then tt-lanca.cre = 37126.
             
            if fiscal.emite = 32
            then tt-lanca.cre = 37397.
             
            if fiscal.emite = 33
            then tt-lanca.cre = 37633.
             
            if fiscal.emite = 34
            then tt-lanca.cre = 37900.
             
            if fiscal.emite = 35
            then tt-lanca.cre = 38217.
             
            if fiscal.emite = 36
            then tt-lanca.cre = 38430.
             
            if fiscal.emite = 37
            then tt-lanca.cre = 38652.
             
            if fiscal.emite = 38
            then tt-lanca.cre = 38892.
             
            if fiscal.emite = 39
            then tt-lanca.cre = 39102.
             
            if fiscal.emite = 40
            then tt-lanca.cre = 39325.
             
            if fiscal.emite = 41
            then tt-lanca.cre = 39548.
             
            if fiscal.emite = 42
            then tt-lanca.cre = 39760.
             
            if fiscal.emite = 43
            then tt-lanca.cre = 4030.
              
            if fiscal.emite = 44
            then tt-lanca.cre = 4050.
              
            if fiscal.emite = 45
            then tt-lanca.cre = 8009.
             
            if fiscal.emite = 46
            then tt-lanca.cre = 8035.
              
            if fiscal.emite = 47
            then tt-lanca.cre = 8056.
              
            if fiscal.emite = 48
            then tt-lanca.cre = 8077.
              
            if fiscal.emite = 49
            then tt-lanca.cre = 8120.
            
            if fiscal.emite = 50
            then tt-lanca.cre = 8127.
            
            if fiscal.emite = 51
            then tt-lanca.cre = 8148.
            
            
            if fiscal.emite = 52
            then tt-lanca.cre = 5035.
            
            
            if fiscal.emite = 53
            then tt-lanca.cre = 5060.


            if fiscal.emite = 54
            then tt-lanca.cre = 7520.

 
            if fiscal.emite = 55
            then tt-lanca.cre = 7541.


            if fiscal.emite = 56
            then tt-lanca.cre = 7594.
            
            if fiscal.emite = 57
            then tt-lanca.cre = 7585.
            
            if fiscal.emite = 58
            then tt-lanca.cre = 7613.
            

            if fiscal.emite = 59
            then tt-lanca.cre = 7635.
            
            if fiscal.emite = 60
            then tt-lanca.cre = 7659.
            
            if fiscal.emite = 61
            then tt-lanca.cre = 7680.
            
            if fiscal.emite = 62
            then tt-lanca.cre = 7705.
            
            if fiscal.emite = 63
            then tt-lanca.cre = 7726.

            if fiscal.emite = 64
            then tt-lanca.cre = 7747.

            if fiscal.emite = 65
            then tt-lanca.cre = 7769.
            
            if fiscal.emite = 66
            then tt-lanca.cre = 7792.
            
            if fiscal.emite = 67
            then tt-lanca.cre = 7813.
            
            if fiscal.emite = 68
            then tt-lanca.cre = 7834.
            
            if fiscal.emite = 69
            then tt-lanca.cre = 7855.
            
            if fiscal.emite = 70
            then tt-lanca.cre = 7897.

            
            totval = 0.
        end.
        vtot = vtot + fiscal.platot.
    end.
    output stream stela close.
    
    if vtot > 0
    then do:
        create tt-lanca.
        assign tt-lanca.tip  = "C"
               tt-lanca.cre  = 169.

        tt-lanca.cod  = 40. 
        tt-lanca.his = "DEV.N/DATA CF REG.ENTRADAS".

        tt-lanca.val  = vtot.
    end.
    if vtot = 0
    then do:
        message "Nao existe movimento".
        undo, retry.
    end.
    output to m:\simy\lanca99.
        
    for each tt-lanca:
        put vlote 
            day(vdt2)   format "99"
            month(vdt2) format "99"
            year(vdt2)  format "9999"
            tt-lanca.tip
            ( vtot * 100) format "999999999999999"
            tt-lanca.cre    format "99999"   
            ( tt-lanca.val * 100) format "999999999999999"  
            tt-lanca.cod 
            tt-lanca.his skip.
    end.
    output close.
    /* dos silent ved value("m:\lanca" + string(estab.etbcod,">>9")).  */ 
end.
