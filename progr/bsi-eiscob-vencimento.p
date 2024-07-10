def var vTitvlcob as char.
def var vTitvlpag as char.
def var vTipoParcela as int.
def var statusfeirao as int.
def var varquivo as char.

                                                                                                                                    
for each estab where estab.etbcod >= 1 and estab.etbcod <= 999 no-lock.         output to value("/admcom/lebesintel/vencimentos/" + string(estab.etbcod) + ".csv").                                  
                                          
output close.
end.
                                                                               

                                                                               

for each estab where estab.etbcod >= 1 and estab.etbcod <= 999 no-lock.

output to value("/admcom/lebesintel/vencimentos/" + string(estab.etbcod) + ".csv"). 


  for each fin.titulo where
     fin.titulo.empcod = 19 and
        fin.titulo.titnat = no and
             fin.titulo.etbcod = estab.etbcod  and 
                  fin.titulo.modcod = "CRE" and 
                       fin.titulo.titdtven >= today - 130 and
                       fin.titulo.titdtven <= today + 31
                                no-lock.
                                          pause 0.



          vTitvlcob = string(fin.titulo.titvlcob).
                    vTitvlpag   = string(fin.titulo.titvlpag).     


          if  fin.titulo.tpcontrato = "L" then do:
                        vTipoParcela = 1.
                                 end.
                                else do:
                         vTipoParcela = 0.
                                end.


                    /*
          if string(fin.titulo.titobs[1]) matches "*RENOVACAO=SIM*" then do:   
                               vTipoParcela = 1.                            
                        end.                               
                    */




              if string(titobs[1]) matches "*FEIRAO-NOME-LIMPO=SIM*" then do:                               statusfeirao = 1.                                                                   end.                                           
                             else do:                                           
                            statusfeirao = 0.                                                     end.                                                     


                                                                              
  
                             put etbcod ";" titnum ";" clifor ";" titpar ";" etbcobra ";" empcod ";"        YEAR(titdtven) format "9999"  "-" MONTH(titdtven) format "99" "-" DAY(titdtven) format "99" ";"
  vTitvlcob ";"
      YEAR(titdtpag) format "9999"  "-" MONTH(titdtpag) format "99" "-"
            DAY(titdtpag) format "99" ";"
                    vTitvlpag ";" titsit ";"
                              moecod ";" vTipoParcela ";"
                                           YEAR(titdtemi) format "9999"  "-" MONTH(titdtemi) format "99" "-"
                DAY(titdtemi) format "99" ";"
                                  modcod ";" titdes ";" statusfeirao ";"
                            substr(string(int(titulo.cxmhora), "hh:mm:ss"),1,2)                                             skip.

                                                                   end.  
                                                                                   
                                                                                   
                   
                   
                                   
                                   
                                                   
                                                   
                                                                   
                                                    for each fin.titulo where
                                                       fin.titulo.empcod = 19 and
   fin.titulo.titnat = no and
        fin.titulo.etbcod = estab.etbcod  and 
             fin.titulo.modcod = "CP0" and 
                 fin.titulo.titdtven >= today - 130 and
                    fin.titulo.titdtven <= today + 31   
                           no-lock.
                                     pause 0.



          vTitvlcob = string(fin.titulo.titvlcob).
                    vTitvlpag   = string(fin.titulo.titvlpag).     


          if fin.titulo.tpcontrato = "L" then do:
                        vTipoParcela = 1.
                       end.
                       else do:
                        vTipoParcela = 0.
                       end.

                        /*
                 if string(fin.titulo.titobs[1]) matches "*RENOVACAO=SIM*" then do:   
                                 vTipoParcela = 1.                            
                                     end.                               
                          */                                                    
                                                                              
  
                                                                              put etbcod ";" titnum ";" clifor ";" titpar ";" etbcobra ";" empcod ";"        YEAR(titdtven) format "9999"  "-" MONTH(titdtven) format "99" "-" DAY(titdtven) format "99" ";"
  vTitvlcob ";"
      YEAR(titdtpag) format "9999"  "-" MONTH(titdtpag) format "99" "-"
            DAY(titdtpag) format "99" ";"
                    vTitvlpag ";" titsit ";"
                              moecod ";" vTipoParcela ";"
                                           YEAR(titdtemi) format "9999"  "-" MONTH(titdtemi) format "99" "-"
                DAY(titdtemi) format "99" ";"
                                  modcod ";" titdes ";0;"
                       substr(string(int(titulo.cxmhora), "hh:mm:ss"),1,2)                            
                                                   skip.

                                                                   end.  
                                                                                   
                                                                                   
                   
                   
                                   
                                   
                                                   
                                                   
                                   for each fin.titulo where
                                        fin.titulo.empcod = 19 and
   fin.titulo.titnat = no and
        fin.titulo.etbcod = estab.etbcod  and 
             fin.titulo.modcod = "CP1" and 
             fin.titulo.titdtven >= today - 130 and
                 fin.titulo.titdtven <= today + 31              
                         no-lock.
                                     pause 0.



          vTitvlcob = string(fin.titulo.titvlcob).
                    vTitvlpag   = string(fin.titulo.titvlpag).     


          if fin.titulo.tpcontrato = "L" then do:
                        vTipoParcela = 1.
                                  end.
                                            else do:
                                   vTipoParcela = 0.
                               end.

  
                            /*                                                   ~      if string(titobs[1]) matches "*RENOVACAO=SIM*" then do:
                  vTipoParcela = 1.
                            end.
                             */
                                                                              

  
  
                               put etbcod ";" titnum ";" clifor ";" titpar ";" etbcobra ";" empcod ";"        YEAR(titdtven) format "9999"  "-" MONTH(titdtven) format "99" "-" DAY(titdtven) format "99" ";"
  vTitvlcob ";"
      YEAR(titdtpag) format "9999"  "-" MONTH(titdtpag) format "99" "-"
            DAY(titdtpag) format "99" ";"
                    vTitvlpag ";" titsit ";"
                              moecod ";" vTipoParcela ";"
                                           YEAR(titdtemi) format "9999"  "-" MONTH(titdtemi) format "99" "-"
                DAY(titdtemi) format "99" ";"
                                  modcod ";" titdes ";0;"
                    substr(string(int(titulo.cxmhora), "hh:mm:ss"),1,2)
                                                   
                                                   skip.

                                                                   end.                
                                                                                   
                       
                   
                                       


    
output close.

        end.
