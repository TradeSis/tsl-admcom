def var elegivel as dec.
def var inadimplente as dec.
def var percentual as dec.

output to "/admcom/TI/joao/visao_creCompleta.csv".

for each estab where etbcod < 305 no-lock. 

elegivel = 0.
inadimplente = 0.
percentual = 0.

for each plani where movtdc = 5 and pladat >= 05/01/2016 and pladat <=        
05/31/2016 and plani.etbcod = estab.etbcod no-lock.                                     
                                                                              
find first contnf where contnf.etbcod = plani.etbcod                          
                           and contnf.placod = plani.placod no-lock no-error. 
      
                if not avail contnf                                           
                then next.                                                    
                        for each titulo where                                 
                                 titulo.empcod = 19  and                      
                                 titulo.titnat = no   and                     
                                 titulo.modcod = "CRE" and                    
                                 titulo.etbcod = plani.etbcod and             
                                 titulo.clifor = plani.desti and              
                                 titulo.titnum = string(contnf.contnum) and   
                                 (titulo.titdtven >= 06/01/2016 and           
                                  titulo.titdtven <= 06/30/2016)              
                      no-lock.                   
                           
                            elegivel= elegivel + titvlcob.
          
                             if titsit = "LIB" then do:
                              inadimplente = inadimplente + titvlcob.                                                             end.


                 if titsit = "PAG" and titulo.titdtpag >= 07/01/2016 then do:
                             inadimplente = inadimplente + titvlcob.
                             end.


                                                   
                                                      pause 0.
     /*      disp plani.Desti titnum titdtemi titdtven titsit titvlcob titpar.         */
end.
end.           
              percentual = inadimplente / elegivel.
              percentual = percentual * 100.
                 put  estab.etbcod ";" elegivel format ">>>>>>>>>9.99" ";" inadimplente format ">>>>>>>>>>>>9.99" ";" percentual format ">>>>>>>9.99" skip.

                 end.

                 output close.