
DEF TEMP-TABLE ttmarca NO-UNDO
    FIELD rec_id AS RECID.
    
def var varqcsv as char format "x(65)".
DEF VAR velegivel AS LOG.


for each serasacli no-lock.
    velegivel = FALSE.
    
    for each titulo where titulo.clifor = serasacli.clicod and titdtpag = ? and titdtven < today - 60 no-lock.
        if (titulo.modcod = "CRE" and titulo.tpcontrato = "") or titulo.modcod = "CP1" or titulo.modcod = "CP2"
        then.
        else next.
        if titulo.titsit = "LIB"
        then.
        else next.
        
        velegivel = TRUE.
        leave.       
    end.
    
    IF velegivel = FALSE
    THEN DO:
         CREATE ttmarca.
         ttmarca.rec_id = recid(serasacli).
    END.

end.

/* REMOCAO */ 
varqcsv = "/admcom/tmp/serasa/" + 
             "RE_" + string(today,"99999999") + "_001" + ".csv".

                
    output to value(varqcsv).
    put unformatted  "CNPJ_CREDOR;" 
                     "DOCUMENTO;"
                     skip.
                     
FOR EACH ttmarca NO-LOCK:
   FIND serasacli WHERE RECID(serasacli) = ttmarca.rec_id.                   
    
        FIND clien OF serasacli NO-LOCK NO-ERROR.
        IF AVAIL clien
        THEN DO:
            put unformatted
                "96662168000131" ";"
                clien.ciccgc ";"
                skip.
        END.

    DELETE serasacli.
END.

output close.



/* BATIMENTO */    
varqcsv = "/admcom/tmp/serasa/" + 
         "BT_" + string(today,"99999999") + "_001" + ".csv".

            
output to value(varqcsv).
put unformatted  "CNPJ_CREDOR;" 
                 "DOCUMENTO;"
                 skip.
                     
FOR EACH serasacli NO-LOCK:

    FIND clien OF serasacli NO-LOCK.

    put unformatted
        "96662168000131" ";"
        clien.ciccgc ";"
        skip.
   
END.      

output close.









