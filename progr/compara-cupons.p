def var vtotal as dec.

for each plani where plani.movtdc = 5  and
                     plani.etbcod = 82 and
                     plani.pladat = 04/20/2012 and
                     plani.cxacod = 1
                   /*  plani.ufemi = "BE050775600700012507" *//*and
                     plani.cxacod =  mapctb.de1
                     plani.ufemi = mapctb.ch1*/
                     and plani.platot = 69.80
                           exclusive-lock:
                                     /*
    if substr(plani.notped,1,1) = "C"
    then.
    else next.                         */
    
    update plani.notped format "x(30)" plani.ufemi format "x(20)" with no-validate.

    display plani.platot (total). 


end.