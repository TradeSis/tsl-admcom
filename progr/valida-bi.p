{admcab.i new}

input from value("/admcom/work/lista.csv").
                       /*
def stream str-csv.

output stream str-csv to value("/admcom/work/lista-erro.csv").
                         */
def var vlinha as character.
def var vetbcod as integer.
def var vplacod as integer.
def var vpladat       as date.
def var vplatot-imp       as dec.
def var vplatot-atual       as dec.
def var vplatot-movim as dec.
def var vcont  as integer.
def var val_des    as decimal.
def var val_acr    as decimal.


repeat:

    import vlinha.
    
    assign vetbcod = integer(entry(1,vlinha,";"))
           vplacod = integer(entry(2,vlinha,";"))
           vpladat = date(entry(3,vlinha,";"))
           vplatot-imp = decimal(entry(5,vlinha,";"))
           vplatot-atual = 0.
    
    assign vcont = 0
            val_des = 0
            val_acr = 0.

    find first plani where plani.etbcod = vetbcod
                       and plani.placod = vplacod
                       and plani.pladat = vpladat no-lock.
                        
    if avail plani
    then do:
     
        if plani.biss > (plani.platot - plani.vlserv)
        then assign val_acr = plani.biss -
                      (plani.platot - plani.vlserv).
        else val_acr = plani.acfprod.
            
        if val_acr < 0 or val_acr = ?
        then val_acr = 0.
                                    
        assign val_des = plani.descprod.

        assign
          vplatot-atual = (plani.platot - /* plani.vlserv -*/
                             val_des + val_acr).

        if vplatot-imp <> vplatot-atual
        then do:
    
                          /*
        put stream str-csv unformatted
            vlinha skip.
                             */
        
        assign vplatot-movim = 0.
        
        for each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movdat = plani.pladat no-lock.
                     
            assign vcont = vcont + 1.             
                         
            assign vplatot-movim = vplatot-movim + (movim.movpc * movim.movqtm).                 
                         
        end.
        
        display vplatot-imp (total) vplatot-atual (total) plani.biss (total) vplatot-movim (total) plani.placod format ">>>>>>>>>9" (count) vcont format ">>9" plani.numero with frame f01 down.
        end.
    end.


end.
