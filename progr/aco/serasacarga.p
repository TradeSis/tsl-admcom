def var vi as int.
for each serasacli.
    delete serasacli.
end.    
for each titulo where titnat = no and titdtpag = ? and titdtven < today - 30 no-lock.
    if titulo.modcod = "CRE" and titulo.tpcontrato = ""
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
    vi = vi + 1.
        
    if vi > 15
    then leave.
    
end.


