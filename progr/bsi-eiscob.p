
def var vTitvlcob as char.
def var vTitvlpag as char.

output to "/admcom/lebesintel/bsi-eiscob.csv".        
                                                                            
for each estab where estab.etbcod >= 9 and estab.etbcod <= 9 no-lock.                                                               
                                                                
for each fin.titulo where fin.titulo.titsit = "LIB"                                             and fin.titulo.etbcod = estab.etbcod                                            and fin.titulo.modcod = "CRE"                                                  and fin.titulo.titnat = no and
                     fin.titulo.titdtven >= 09/01/0100 no-lock.               
          pause 0.                                                                    
vTitvlcob = string(fin.titulo.titvlcob).
vTitvlpag   = string(fin.titulo.titvlpag).         
       
put etbcod ";"            
  titnum ";"            
  clifor ";"            
  titpar ";"            
  etbcobra ";"            
  empcod ";"            
 YEAR(titdtven) format "9999"  "-" MONTH(titdtven) format "99" "-" DAY(titdtven) format "99" ";"             
  vTitvlcob ";"            
  YEAR(titdtpag) format "9999"  "-" MONTH(titdtpag) format "99" "-"  
               DAY(titdtpag) format "99" ";"  
  vTitvlpag ";"            
  titsit ";"            
  moecod ";1;"                
   YEAR(titdtemi) format "9999"  "-" MONTH(titdtemi) format "99" "-"     
                                         DAY(titdtemi) format "99" ";" skip.                            
                          
end. 
              
                     
                     
for each fin.titulo where fin.titulo.titsit = "PAG"            
            and fin.titulo.etbcod = estab.etbcod 
            and fin.titulo.titdtpag >= 06/01/2015
            and fin.titulo.titdtven >= 06/01/2015      
            and fin.titulo.modcod = "CRE"               
            and fin.titulo.titnat = no  no-lock.        
          pause 0.


vTitvlcob = string(fin.titulo.titvlcob). 
vTitvlpag   = string(fin.titulo.titvlpag).               
                                                               
                                                                 
put etbcod ";"             
    titnum ";"             
    clifor ";"             
    titpar ";"             
    etbcobra ";"             
    empcod ";"             
    YEAR(titdtven) format "9999"  "-" MONTH(titdtven) format "99" "-"    
                              DAY(titdtven) format "99" ";"                          vTitvlcob ";"             
     YEAR(titdtpag) format "9999"  "-" MONTH(titdtpag) format "99" "-"    
                                DAY(titdtpag) format "99" ";"                           
    vTitvlpag ";"             
    titsit ";"             
    moecod ";1;"
   YEAR(titdtemi) format "9999"  "-" MONTH(titdtemi) format "99" "-"     
                DAY(titdtemi) format "99" ";"                            
           
                    skip.                              
                                                          
                                                          end.                       
                     
                     
                     
                     
                     
                     
                     
                     
                     
                     
                     
                     
                     
end.                      
output close.    
                                                              
 connect dragao -H "database" -S sdragao -N tcp -ld dragao no-error.   
  
run /admcom/progr/bsi_eiscob_d.p.          
