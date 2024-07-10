def var vTitvlcob as char.
def var vTitvlpag as char.
def var vTipoParcela as int.

                 def var totaldias as int.                                                        totaldias = 0.
                 
                 if (time > 42000 and time < 45000) then do:                 
                   totaldias = 4.                                           
                      end.                                                
                  else do:                                            
                  totaldias = 0.                                           
                  end.                                            
                                                                             
                                                                                                                                        
       output to "/admcom/lebesintel/bi_cargatitulodiario.csv".         
                                                           
for each estab where estab.etbcod >= 1 and estab.etbcod <= 999 no-lock.


  for each fin.titulo where
   fin.titulo.empcod = 19 and
   fin.titulo.titnat = no and
     fin.titulo.etbcod = estab.etbcod  and 
     fin.titulo.modcod = "CRE" and 
     fin.titulo.titdtven >= 10/01/2016 and
      fin.titulo.titdtven <= 01/31/2017
   no-lock.
          pause 0.


         if fin.titulo.titdtven < 01/01/2014 then next.


          vTitvlcob = string(fin.titulo.titvlcob).
          vTitvlpag   = string(fin.titulo.titvlpag).     


          if string(titobs[1]) matches "*RENOVACAO=SIM*" then do:
              vTipoParcela = 1.
          end.
          else do:
              vTipoParcela = 0.
          end.

          
  
put etbcod ";" titnum ";" clifor ";" titpar ";" etbcobra ";" empcod ";"        YEAR(titdtven) format "9999"  "-" MONTH(titdtven) format "99" "-" DAY(titdtven) format "99" ";"
  vTitvlcob ";"
    YEAR(titdtpag) format "9999"  "-" MONTH(titdtpag) format "99" "-"
      DAY(titdtpag) format "99" ";"
        vTitvlpag ";" titsit ";"
          moecod ";" vTipoParcela ";"
             YEAR(titdtemi) format "9999"  "-" MONTH(titdtemi) format "99" "-"
                DAY(titdtemi) format "99" ";"
                  modcod ";"
                 
                 skip.

                end.  
                
                
                
                
                
                
                
                
                
 for each fin.titulo where
   fin.titulo.empcod = 19 and
   fin.titulo.titnat = no and
     fin.titulo.etbcod = estab.etbcod  and 
     fin.titulo.modcod = "CP0" and 
     fin.titulo.titdtven >= 10/01/2016 and
      fin.titulo.titdtven <= 01/31/2017
   no-lock.
          pause 0.


         if fin.titulo.titdtven < 01/01/2014 then next.


          vTitvlcob = string(fin.titulo.titvlcob).
          vTitvlpag   = string(fin.titulo.titvlpag).     


          if string(titobs[1]) matches "*RENOVACAO=SIM*" then do:
              vTipoParcela = 1.
          end.
          else do:
              vTipoParcela = 0.
          end.

          
  
put etbcod ";" titnum ";" clifor ";" titpar ";" etbcobra ";" empcod ";"        YEAR(titdtven) format "9999"  "-" MONTH(titdtven) format "99" "-" DAY(titdtven) format "99" ";"
  vTitvlcob ";"
    YEAR(titdtpag) format "9999"  "-" MONTH(titdtpag) format "99" "-"
      DAY(titdtpag) format "99" ";"
        vTitvlpag ";" titsit ";"
          moecod ";" vTipoParcela ";"
             YEAR(titdtemi) format "9999"  "-" MONTH(titdtemi) format "99" "-"
                DAY(titdtemi) format "99" ";"
                  modcod ";"
                 
                 skip.

                end.  
                
                
                
                
                
                
                
                
  for each fin.titulo where
   fin.titulo.empcod = 19 and
   fin.titulo.titnat = no and
     fin.titulo.etbcod = estab.etbcod  and 
     fin.titulo.modcod = "CP1" and 
     fin.titulo.titdtven >= 10/01/2016 and
      fin.titulo.titdtven <= 01/31/2017
   no-lock.
          pause 0.


         if fin.titulo.titdtven < 01/01/2014 then next.


          vTitvlcob = string(fin.titulo.titvlcob).
          vTitvlpag   = string(fin.titulo.titvlpag).     


          if string(titobs[1]) matches "*RENOVACAO=SIM*" then do:
              vTipoParcela = 1.
          end.
          else do:
              vTipoParcela = 0.
          end.

          
  
put etbcod ";" titnum ";" clifor ";" titpar ";" etbcobra ";" empcod ";"        YEAR(titdtven) format "9999"  "-" MONTH(titdtven) format "99" "-" DAY(titdtven) format "99" ";"
  vTitvlcob ";"
    YEAR(titdtpag) format "9999"  "-" MONTH(titdtpag) format "99" "-"
      DAY(titdtpag) format "99" ";"
        vTitvlpag ";" titsit ";"
          moecod ";" vTipoParcela ";"
             YEAR(titdtemi) format "9999"  "-" MONTH(titdtemi) format "99" "-"
                DAY(titdtemi) format "99" ";"
                  modcod ";"
                 
                 skip.

                end.                
                
                
                
                


    

    end.
    output close.  