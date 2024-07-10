def var vTitvlcob as char.
def var vTitvlpag as char.

output to "/admcom/lebesintel/cob_titulos-lib-geral.csv".        
                                                                            
for each estab where estab.etbcod >= 1 and estab.etbcod <= 999 no-lock.            
                                                                
                                                                
                                                                
for each fin.titulo where fin.titulo.titsit = "LIB"                                               and fin.titulo.etbcod = estab.etbcod                                            and fin.titulo.modcod = "CRE"                                                  and fin.titulo.titnat = no  no-lock.                         
          pause 0.                                                                    
vTitvlcob = string(fin.titulo.titvlcob).
vTitvlcob = replace(vTitvlcob,",","").    
vTitvlcob = replace(vTitvlcob,".",",").

vTitvlpag   = string(fin.titulo.titvlpag).         
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
  titdtpag  ";"            
  vTitvlpag ";"            
  titsit ";"            
  moecod ";Admcom" ";"  skip.                
                          
                          
end. 
              
                     
                     
for each fin.titulo where fin.titulo.titsit = "PAG"            
            and fin.titulo.etbcod = estab.etbcod 
            and fin.titulo.titdtpag >= today - 218      
            and fin.titulo.modcod = "CRE"               
            and fin.titulo.titnat = no  no-lock.        
          pause 0.


vTitvlcob = string(fin.titulo.titvlcob).   
vTitvlcob = replace(vTitvlcob,",","").     
vTitvlcob = replace(vTitvlcob,".",",").    

vTitvlpag   = string(fin.titulo.titvlpag).       
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
    moecod "; Admcom;"      
                    skip.                              
                                                          
                                                          end.                       
                     
                     
                     
                     
                     
                     
                     
                     
                     
                     
                     
                     
                     
end.                      
output close.    

connect dragao -H "database" -S sdragao -N tcp -ld dragao no-error.  

run /admcom/progr/bsi_cobranca_dragao.p. 
