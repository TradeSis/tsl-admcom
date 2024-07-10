def var valorparcela as dec.
def var valorcontrato as dec.
valorparcela = 0.
valorcontrato = 0.


output to "/admcom/lebesintel/bi_prevendas.csv".     
                           
                           
                           
                           
      for each estab no-lock.                                                   
          for each plani where plani.etbcod = estab.etbcod and plani.movtdc= 30  
                                                                                
          and plani.pladat >= today - 2  and plani.etbcod < 20  no-lock.       
                                                                                
       for each movim where movim.etbcod = plani.etbcod and                     
                                      movim.movtdc = plani.movtdc and           
                                                                                
                             movim.placod = plani.placod no-lock.               
                                                                                
            find finan where finan.fincod = plani.pedcod no-lock no-error.      
                             
 valorparcela = (movim.movpc * movim.movqtm) * finan.finfat. 
                      
           valorcontrato = valorparcela * finan.finnpc.                                                                                                                                                    
  put  movim.etbcod ";" YEAR(plani.pladat) format "9999" "-" MONTH(plani.pladat)
format "99" "-" DAY(plani.pladat) format "99" ";" plani.placod format           
">>>>>>>>>9" ";"  movim.procod ";" movim.movpc format ">>>>>>>>>>9.99" ";"      
movim.movqtm format ">>>>>>>>>>>9" ";" plani.Vencod ";"
plani.pedcod ";" valorparcela ";" valorcontrato format ">>>>>>>>>>9.99" ";" skip .                   
                                                                          
end.                                                                      
end.                                                                      
end.                                                                       