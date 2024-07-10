def var vexp as log.
pause.

output to titulo.mat.8.
    
for each titulo where exportado = no no-lock.

    vexp = no.
    
    if titulo.titdtpag <> ? and
       titulo.titdtpag <= 10/31/2002
    then vexp = yes.
    if titulo.titdtemi <= 10/31/2002
    then vexp = yes.
    
    if vexp = yes
    then do:
        export titulo.
        titulo.exportado = yes.
    end.
    
end.

output close.


