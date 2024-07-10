def stream stela.
output stream stela to terminal.
output to c:\dados\tit20.d.
for each titulo  
                where titulo.empcod = 19 and
                      titulo.modcod = "CRE" and
                      titulo.titnat = no and
                      titulo.etbcod = 46 and
                      titulo.titsit = "pag" and
                      titulo.titdtpag >= 02/01/2001 and
                      titulo.titdtpag <= today no-lock:


    display stream stela titulo.titdtpag titulo.clifor
                    with 1 down. pause 0.
    export titulo.                  

    
end.
output close.
output stream stela close.