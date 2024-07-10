def stream stela.
output to c:\dados\plani.d.
output stream stela to terminal.

for each plani where plani.datexp >= 12/01/2001 and       
                     plani.datexp <= today no-lock.
                           
    if plani.desti = 28 or
       plani.emite = 28
    then do:
        export plani.
        display stream stela
                plani.pladat
                plani.movtdc format "99"
                plani.numero with 1 down. pause 0.
    end.

end.

output close.
output stream stela close.
     
