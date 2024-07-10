def var vTitvlcob as char.
def var vTitvlpag as char.
def var vTipoParcela as int.
def var statusfeirao as int.
def var minutoatual as char.

                 def var totaldias as int.                                                        totaldias = 0.
                 
                       minutoatual = string(time,"hh:mm:ss").
                       minutoatual = substr(minutoatual,4,2).
             
                       totaldias = 0.
                
                        
    if (time >= 43200 and time <= 46800 and (int(minutoatual) < 30) ) then do:                                totaldias = 3.                                                               end.                                    
                           
    if (time >= 57600 and time <= 61200 and (int(minutoatual) < 30) ) then do: 
                             totaldias = 3.                                    
                          end. 
                                                                          
    if (time >= 21600 and time <= 25200 and (int(minutoatual) < 30) ) then do: 
                             totaldias = 3.                                    
                           end.                                                 
   if (time >= 0 and time <= 3600 and (int(minutoatual) < 30) ) then do: 
                                totaldias = 3.                                                               end.                                                 

                           
       output to "/admcom/lebesintel/bi_titulodiario_pagador.csv".         
                                                           
for each estab where estab.etbcod >= 111 and estab.etbcod <= 320 no-lock.


  for each fin.titulo use-index iclicod where
   fin.titulo.empcod = 19 and
   fin.titulo.titnat = no and
     fin.titulo.etbcod = estab.etbcod  and 
     (fin.titulo.modcod = "CRE" or
      fin.titulo.modcod = "CP1" or
     fin.titulo.modcod = "CP0") and
      fin.titulo.titdtpag >= 09/01/2017 and
      fin.titulo.titdtpag <= today - 1 
   no-lock.
          pause 0.


         if fin.titulo.titdtven < 01/01/2014 then next.


          vTitvlcob = string(fin.titulo.titvlcob).
          vTitvlpag   = string(fin.titulo.titvlpag).     


          if fin.titulo.tpcontrato = "L" then do:
              vTipoParcela = 1.
          end.
          else do:
              vTipoParcela = 0.
          end.

         if string(titobs[1]) matches "*FEIRAO-NOME-LIMPO=SIM*" then do:   
                      statusfeirao = 1.                                     
                               end.                                                                       else do:                                                                     statusfeirao = 0.                                                              end.                                                      


          
  
put etbcod ";" titnum ";" clifor ";" titpar ";" etbcobra ";" empcod ";"        YEAR(titdtven) format "9999"  "-" MONTH(titdtven) format "99" "-" DAY(titdtven) format "99" ";"
  vTitvlcob ";"
    YEAR(titdtpag) format "9999"  "-" MONTH(titdtpag) format "99" "-"
      DAY(titdtpag) format "99" ";"
        vTitvlpag ";" titsit ";"
          moecod ";" vTipoParcela ";"
             YEAR(titdtemi) format "9999"  "-" MONTH(titdtemi) format "99" "-"
                DAY(titdtemi) format "99" ";"
                  modcod ";" titdes ";" statusfeirao ";" substr(string(int(titulo.cxmhora), "hh:mm:ss"),1,2)   

                                  skip.

                end.  


    

    end.
    output close.  