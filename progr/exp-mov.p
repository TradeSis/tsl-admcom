def stream stela.
output to c:\dados\movim.d.
output stream stela to terminal.

for each plani where plani.datexp >= 02/01/2002 and       
                     plani.datexp <= 02/28/2002 no-lock.
                           
    if plani.desti = 28 or
       plani.emite = 28
    then do:
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod no-lock.
            export movim.
            
        end.
        display stream stela
                plani.pladat
                plani.movtdc format "99"
                plani.numero with 1 down. pause 0.
    end.

end.

output close.
output stream stela close.
     
