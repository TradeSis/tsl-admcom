{admcab.i}
def stream stela.
def var vetbcod like estab.etbcod.
def var vdata       like titulo.titdtemi.
def var vdt1        as   date  format "99/99/9999" initial today. 
def var vdt2        as   date  format "99/99/9999" initial today.
def var vlote       as char format "xxxx".
def var totval like plani.platot.
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
    update vetbcod colon 20 label "Filial".
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
    for each plani where plani.movtdc = 4       and
                         plani.etbcod = estab.etbcod and
                         plani.datexp >= vdt1   and
                         plani.datexp <= vdt2 no-lock.
        if plani.emite = 5027
        then next.
        find forne where forne.forcod = plani.emite no-lock no-error.

        disp stream stela plani.numero
                          plani.datexp format "99/99/9999" 
                                with 1 down. pause 0.
        create tt-lanca.
        assign tt-lanca.tip  = "C"
               tt-lanca.cre  = 30003  
               tt-lanca.val  = plani.platot 
               tt-lanca.cod  = 42. 
        tt-lanca.his = "S/NT.N. " + string(plani.numero,"999999") + " " +
                        string(forne.fornom).
        
        totval = totval + plani.platot.
    end.
    output stream stela close.
    
    if totval > 0
    then do:
        create tt-lanca.
        assign tt-lanca.tip  = "D".
   
        if estab.etbcod = 996
        then tt-lanca.cre  = 2940.
    
        if estab.etbcod = 997
        then tt-lanca.cre  = 32771.
    
        if estab.etbcod = 98
        then tt-lanca.cre  = 36470.
        
        if estab.etbcod = 999
        then tt-lanca.cre  = 2952.
      
        tt-lanca.val  = totval.
        tt-lanca.cod  = 99. 
        tt-lanca.his = "COMPRAS A PRAZO CONF.REG.DE ENTRADAS".
    end.
    output to value("m:\lanca" + string(estab.etbcod,">>9")).
        
    for each tt-lanca:
        put vlote 
            day(vdt2)   format "99"
            month(vdt2) format "99"
            year(vdt2)  format "9999"
            tt-lanca.tip 
            ( totval * 100) format "999999999999999"  
            tt-lanca.cre    format "99999"   
            ( tt-lanca.val * 100) format "999999999999999"  
            tt-lanca.cod 
            tt-lanca.his skip.
    end.
        
    output close.
/*    dos silent ved value("m:\lanca" + string(estab.etbcod,">>9")).  */
end.
