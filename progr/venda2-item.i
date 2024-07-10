    /**** VARIAVEIS
    def var wval as dec.
    def var wacr as dec.
    def var wdes as dec.
    ****/
    assign
        wval = 0
        wacr = 0
        wdes = 0
        .
    if plani.crecod >= 1
    then do:
        if plani.biss > (plani.platot - plani.vlserv)
        then  wacr = (movim.movpc * movim.movqtm) *
                    ((movim.movpc * movim.movqtm) / (plani.biss - 
                                      plani.platot - plani.vlserv)).
        else wacr = (movim.movpc * movim.movqtm) *
                  ( (movim.movpc * movim.movqtm) / plani.acfprod) .
    end.
    if wacr < 0 or wacr = ?
    then wacr = 0.

    wdes = 0.
    if plani.descprod > 0
    then wdes = (movim.movpc * movim.movqtm) * 
                ((movim.movpc * movim.movqtm) / plani.descprod).
    if wdes < 0 or wdes = ?
    then wdes = 0.            
    
    wval = (movim.movpc * movim.movqtm) *
                ((movim.movpc * movim.movqtm) / (plani.platot - plani.vlserv)) 
                .
    
    if wval < 0 or wval = ?
    then wval = 0.
    
    wval = wval + wacr - wdes. 