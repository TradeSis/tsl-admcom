{admcab.i}
def workfile wftot
    field etbcobra  like titulo.etbcobra
    field cxmdat    like titulo.cxmdat
    field titdtpag  like titulo.titdtpag.


for each titulo where titulo.empcod = wempre.empcod and
                      titulo.titnat = no and
                      titulo.modcod = "CRE" and
                      titulo.titdtpag >= 05/15/1996 no-lock.
    if titulo.cxacod <> 99
    then
        next.
    find first wftot where wftot.etbcobra = titulo.etbcobra and
                           wftot.cxmdat   = titulo.cxmdat   and
                           wftot.titdtpag = titulo.titdtpag no-error.
    if not avail wftot
    then do:
        create wftot.
        assign wftot.etbcobra = titulo.etbcobra
               wftot.cxmdat   = titulo.cxmdat
               wftot.titdtpag = titulo.titdtpag.
    end.
    disp wftot.titdtpag titulo.titnum with 1 down. pause 0.
end.
output to printer page-size 64.
for each wftot break by wftot.etbcobra
                     by wftot.titdtpag.
    if first-of(wftot.etbcobra)
    then
        disp wftot.etbcobra column-label "Cobradora".
    disp wftot.titdtpag     column-label "Dt.Pagto"
         wftot.cxmdat       column-label "Digitacao".
end.
