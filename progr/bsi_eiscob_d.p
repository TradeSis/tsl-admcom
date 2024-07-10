def var vTitvlcob as char.      
def var vTitvlpag as char.      

output to "/admcom/lebesintel/bsi-eiscob-d.csv".

for each estab where estab.etbcod >= 9 and estab.etbcod <= 9 no-lock.

for each dragao.titulo where dragao.titulo.titsit = "LIB"
                   and dragao.titulo.etbcod = estab.etbcod
                   and dragao.titulo.modcod = "CRE"
                   and dragao.titulo.titnat = no
                   and dragao.titulo.titdtven >= 09/01/0100  
                                   no-lock.
pause 0.                                                                  


vTitvlcob = string(dragao.titulo.titvlcob).         
                                             
vTitvlpag   = string(dragao.titulo.titvlpag).   



put etbcod ";"
    titnum ";"
    clifor ";"
    titpar ";"
  etbcobra ";"
    empcod ";"
     YEAR(titdtven) format "9999"  "-" MONTH(titdtven) format "99" "-" DAY(titdtven) format "99" ";"                                                         vTitvlcob ";"
      YEAR(titdtpag) format "9999"  "-" MONTH(titdtpag) format "99" "-"                     DAY(titdtpag) format "99" ";"                                 
    vTitvlpag ";"
    titsit ";"
    moecod ";2;"
    
      YEAR(titdtemi) format "9999"  "-" MONTH(titdtemi) format "99" "-"    
                     DAY(titdtemi) format "99" ";"                           
    
     skip.

end.

for each dragao.titulo where dragao.titulo.titsit = "PAG"          
                   and dragao.titulo.etbcod = estab.etbcod         
                   and dragao.titulo.modcod = "CRE"                                                and dragao.titulo.titdtven >= 09/01/2015
                   and dragao.titulo.titnat = no  no-lock.         
                          pause 0.                                             
vTitvlcob = string(dragao.titulo.titvlcob).                                     vTitvlpag   = string(dragao.titulo.titvlpag).                                                        
                put etbcod ";"                
                    titnum ";"                
                    clifor ";"                
                    titpar ";"                
                    etbcobra ";"                
                    empcod ";"                
 YEAR(titdtven) format "9999"  "-" MONTH(titdtven) format "99" "-" DAY(titdtven)
format "99" ";"                                                                                     vTitvlcob ";"                
   YEAR(titdtpag) format "9999"  "-" MONTH(titdtpag) format "99" "-"         
                 DAY(titdtpag) format "99" ";"                                
                 
                    vTitvlpag ";"                
                    titsit ";"                
                    moecod ";LP;" 
                   
     YEAR(titdtemi) format "9999"  "-" MONTH(titdtemi) format "99" "-"    
                                            DAY(titdtemi) format "99" ";"                           
                           
               skip.                    
        
       end.                          



end.
output close. 
