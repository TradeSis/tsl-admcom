
def var varqcsv as char format "x(65)".
                
for each titulo where titnat = no and titdtpag = ? and titdtven < today - 60 no-lock.
    if (titulo.modcod = "CRE" and titulo.tpcontrato = "") or titulo.modcod = "CP1" or titulo.modcod = "CP2"
    then.
    else next.
    if titulo.titsit = "LIB"
    then.
    else next.


    find clien where clien.clicod = titulo.clifor no-lock no-error.
    if not avail clien then next.
    if clien.ciccgc = "" or clien.ciccgc = ? then next.
    find neuclien where neuclien.clicod = clien.clicod no-lock no-error.
    if not avail neuclien then next.
    
    find serasacli where serasacli.clicod = titulo.clifor no-lock no-error.
    if avail serasacli then next.
    
    create serasacli.
    serasacli.clicod = titulo.clifor.
    
end.


varqcsv = "/admcom/tmp/serasa/" + 
           "CA_" + string(today,"99999999") + "_001" + ".csv".

                
output to value(varqcsv).
put unformatted  "CNPJ_CREDOR;" 
                 "DOCUMENTO;"
                 skip.



for each serasacli where serasacli.dtenvio = ? NO-LOCK.

    FIND clien OF serasacli NO-LOCK.
    
    put unformatted
        "96662168000131" ";"
        clien.ciccgc ";"
        skip.
   
end.  

output close.

do on error undo:
    for each serasacli where serasacli.dtenvio = ?.
        serasacli.dtenvio = today.
    end.
end.





