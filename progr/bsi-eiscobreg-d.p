
def var vTitvlcob as char.
def var vTitvlpag as char.

output to "/admcom/lebesintel/bsi-eiscob-regular-d.csv".        
                                                                            
                            
                    
                  
  for each estab where estab.etbcod >= 1 and estab.etbcod <= 999 no-lock.

  for each dragao.titulo where
 dragao.titulo.empcod = 19 and
  dragao.titulo.etbcod = estab.etbcod                                            and dragao.titulo.modcod = "CRE"                                                  and
 dragao.titulo.titnat = no and

                     dragao.titulo.titdtven >= 12/01/1900 
  no-lock.
          pause 0.

vTitvlcob = string(dragao.titulo.titvlcob).
vTitvlpag   = string(dragao.titulo.titvlpag).

put etbcod ";" titnum ";" clifor ";" titpar ";" etbcobra ";" empcod ";"        YEAR(titdtven) format "9999"  "-" MONTH(titdtven) format "99" "-" DAY(titdtven) format "99" ";"
  vTitvlcob ";"
  YEAR(titdtpag) format "9999"  "-" MONTH(titdtpag) format "99" "-"
  DAY(titdtpag) format "99" ";"
  vTitvlpag ";" titsit ";"
  moecod ";LP;"
   YEAR(titdtemi) format "9999"  "-" MONTH(titdtemi) format "99" "-"
   DAY(titdtemi) format "99" ";" skip.                                 

end.

end.         

output close.    
