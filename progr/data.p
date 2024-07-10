for each titulo where titulo.empcod = 19    and
                      titulo.modcod = "CRE" and
                      titulo.titnat = no:

    if year(titdtemi) <= 1950
    then titdtemi =  date(month(titdtemi),
                          day(titdtemi),
                          year(titdtemi) + 100).
    
    if year(titdtven) <= 1950
    then titdtven =  date(month(titdtven),
                          day(titdtven),
                          year(titdtven) + 100).
    
    if year(titdtpag) <= 1950
    then titdtpag =  date(month(titdtpag),
                          day(titdtpag),
                          year(titdtpag) + 100).
    
   
   disp titdtemi titdtven titdtpag titsit titnum etbcod with 1 down. pause 0.

end.