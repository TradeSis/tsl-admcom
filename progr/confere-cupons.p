
def var vetbcod     as integer.
def var vcxacod     as integer.
def var vpladat     as date.

def var vtotal      as decimal.

assign vetbcod = 108
       vpladat = 01/25/2012
       vcxacod = 3.

for each plani where plani.movtdc = 5  and
                     plani.etbcod = vetbcod and
                     plani.pladat = vpladat  
                  and plani.cxacod = vcxacod    
                    
               /* and plani.platot = 100.00 */
                     
                    /* plani.ufemi = vser and
                     plani.cxacod =  mapctb.de1
                     plani.ufemi = mapctb.ch1*/
                                 exclusive-lock:
                                    /*
    if substr(plani.notped,1,1) = "C"
    then.
    else next.
                                      */
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat
                                     no-lock:

        assign vtotal = vtotal + (movim.movqt * movim.movpc).

    end.
    /*                                               
    if plani.placod = 2130244585
    then update plani.notped.
    assign plani.ufemi = "BE050675600610000497". */
    .               
                    
    if plani.notped = ""
    then update plani.notped.

    if plani.ufemi = "" 
    then update plani.ufemi with no-validate.

    display plani.placod format ">>>>>>>>>9" plani.platot (total) ufemi format "x(21)" notped format "x(20)".


end.


display vtotal.    