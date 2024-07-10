def var vTitvlcob as char.      
def var vTitvlpag as char.      

output to "/admcom/lebesintel/cob_titulos-lib-geral-dragao.csv".

for each estab where estab.etbcod >= 1 and estab.etbcod <= 999 no-lock.

for each dragao.titulo where dragao.titulo.titsit = "LIB"
                   and dragao.titulo.etbcod = estab.etbcod
                   and dragao.titulo.modcod = "CRE"
                   and dragao.titulo.titnat = no  no-lock.
pause 0.                                                                  


vTitvlcob = string(dragao.titulo.titvlcob).     
vTitvlcob = replace(vTitvlcob,",","").       
vTitvlcob = replace(vTitvlcob,".",",").      
                                             
vTitvlpag   = string(dragao.titulo.titvlpag).   
vTitvlpag   = replace(vTitvlpag,",","").     
vTitvlpag   = replace(vTitvlpag,".",",").    



put etbcod ";"
    titnum ";"
    clifor ";"
    titpar ";"
  etbcobra ";"
    empcod ";"
  titdtven ";"
  vTitvlcob ";"
  titdtpag ";"
  vTitvlpag ";"
    titsit ";"
    moecod ";
    LP;"
     skip.

end.

for each dragao.titulo where dragao.titulo.titsit = "PAG"          
                   and dragao.titulo.etbcod = estab.etbcod         
                   and dragao.titulo.modcod = "CRE"                                                 and dragao.titulo.titdtpag >= today - 708
                   and dragao.titulo.titnat = no  no-lock.         
                          pause 0.                                             
vTitvlcob = string(dragao.titulo.titvlcob).     
vTitvlcob = replace(vTitvlcob,",","").       
vTitvlcob = replace(vTitvlcob,".",",").      
                                             
vTitvlpag   = string(dragao.titulo.titvlpag).   
vTitvlpag   = replace(vTitvlpag,",","").     
vTitvlpag   = replace(vTitvlpag,".",",").    
                                                        
                                                        
                put etbcod ";"                
                    titnum ";"                
                    clifor ";"                
                    titpar ";"                
                    etbcobra ";"                
                    empcod ";"                
                    titdtven ";"                
                    vTitvlcob ";"                
                    titdtpag ";"                
                    vTitvlpag ";"                
                    titsit ";"                
                    moecod ";LP;"        
               skip.                    
        
       end.                          



end.
output close. 
