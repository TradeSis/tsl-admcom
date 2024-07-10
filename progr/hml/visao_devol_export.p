output to "/admcom/lebesintel/hml/bi_devolucoes.csv".
def var percimpostos as dec.                              
def var vendadaoperacao as dec.                              
def var custodaoperacao as dec.      
def var totaldev as dec.    
def var impostosdevol as dec.
def var placodorigem  as char.
def var vendedor-ori as int init 0.
def var filialorigem as int init 0.
def var filialdobonus as int init 0.

def buffer bplani for plani.

for each estab no-lock. 



for each plani where plani.etbcod = estab.etbcod and plani.movtdc = 12         
         and plani.pladat >= today - 60 no-lock.         
    
                      
                               
                               
                                                                                        find first ctdevven where ctdevven.placod = plani.placod
         and ctdevven.etbcod = plani.etbcod 
         and ctdevven.movtdc = plani.movtdc no-lock no-error.

         vendedor-ori = 0.

         placodorigem = "".
         if avail ctdevven then do:
        
         placodorigem =  string(ctdevven.placod-ori).
         
         find first bplani where bplani.placod = ctdevven.placod-ori
         and bplani.etbcod = ctdevven.etbcod-ori
         and bplani.movtdc = ctdevven.movtdc-ori no-lock no-error.
         
         if avail bplani then do:
         vendedor-ori = bplani.vencod.
         filialorigem = ctdevven.etbcod-ori.         
         end.
         else do:
         vendedor-ori = 0.
         filialorigem = 0.
         end.
                          
                  
                  
                  end.

         for each movim where movim.etbcod = plani.etbcod and                           
                              movim.movtdc = plani.movtdc and                           
                                                   movim.placod = plani.placod no-lock.                      
                        totaldev = movim.movqtm * movim.movpc.                 
                        find first produ where produ.procod = movim.procod no-lock no-error.           

find last mvcusto where mvcusto.procod = movim.procod and dativig <= plani.pladat no-lock no-error.   

if avail mvcusto then do:
custodaoperacao = 0.
custodaoperacao =  mvcusto.valctomedio * movim.movqtm.                                  end.
            else do:
   find first estoq where estoq.procod = movim.procod and estoq.etbcod = 1 no-lock no-error.
       custodaoperacao = estoq.estcusto * movim.movqtm.          
        end.

if custodaoperacao < 0 then do:
              custodaoperacao = 0.
                 end.

  vendadaoperacao = 0.
  find first estoq where estoq.procod = movim.procod and estoq.etbcod = 1 no-lock.
  vendadaoperacao = estoq.estvenda * movim.movqtm.

   percimpostos = 0.
   find last produ where produ.procod = movim.procod no-lock.
   find first clafis where clafis.codfis = produ.codfis no-lock no-error.
   
   if produ.proipiper = 99 then do:
   
   end.
   else do:
   percimpostos = percimpostos + produ.proipiper.
   end.
   
   if avail clafis then do:
   percimpostos = percimpostos + clafis.pissai + clafis.cofinssai. 
   end.

   percimpostos = percimpostos / 100.
   
impostosdevol = 0.
impostosdevol = percimpostos * totaldev.

           /* pega direto */
impostosdevol = movim.MovICMS + movim.MovPis + movim.MovCofins.


put plani.placod format ">>>>>>>>>>>>>>>>9" ";" movim.etbcod ";" produ.catcod  
";" YEAR(plani.pladat) format "9999" "-" MONTH(plani.pladat) format "99" "-" DAY(plani.pladat) format "99" ";" produ.pronom ";" produ.procod format ">>>>>>>>>>9" ";"   
movim.movqtm ";" movim.movpc format ">>>>>>>>>>9.99" ";" totaldev format       
">>>>>>>>>>>>>9.99" ";" custodaoperacao format ">>>>>>>>>>>9.99" ";" vendadaoperacao format ">>>>>>>>>>>>>9.99" ";" impostosdevol ";" percimpostos ";" placodorigem format "x(20)" ";" vendedor-ori format ">>>>>9" ";" filialorigem format ">>>>>9" ";"
 
 
 skip.                              
end.                                                                           
end.                                                                           
end. 
                                                                          




def var valorliberado as dec.
def var valorutilizado as dec.
def var valorexcluido as dec.



output to "/admcom/lebesintel/hml/bi_bonus.csv".                                    
                                                                                
 for each titulo where titulo.modcod = "BON"                                                       and titulo.titnat   = yes                                                       and titulo.titdtven >= today - 400 no-lock.                                                


       find last plani where plani.movtdc    = 5                  
                                and plani.desti    = titulo.clifor       
                                and plani.pladat   = titulo.titdtpag     
                                  no-lock no-error.                                          

        if avail plani then do:
            filialdobonus = plani.etbcod.
        end.
        else do:
            filialdobonus =  titulo.etbcod.
        end.


    
    valorutilizado = 0.
    valorliberado = 0.
    valorexcluido = 0.
    
    if titsit = "LIB" and titdtven >= today then do:
        valorliberado = fin.titulo.titvlcob.
    end.

    if titsit = "PAG" then do:
        valorutilizado = fin.titulo.titvlpag.
    end.

    if titsit = "EXC" then do:
        valorexcluido = fin.titulo.titvlcob.
    end.
    
    
    put clifor ";" titvlcob format ">>>>>>>>>>9.99" ";"                                            titvlpag format ">>>>>>>>>>9.99" ";"                          
                                                                         
                                                                            YEAR(titdtemi) format "9999" "-" MONTH(titdtemi) format "99" "-"   
DAY(titdtemi) format "99" ";"                                        
   
   
   YEAR(titdtven) format "9999" "-" MONTH(titdtven) format "99" "-" DAY(titdtven) format "99" ";".                                                                                    if titdtpag <> ? then do:                                    put YEAR(titdtpag) format "9999" "-" MONTH(titdtpag) format "99" "-"          
DAY(titdtpag) format "99" ";". 
                    end.                
                    else do:                                                                 put ";".                                                          
                    end.                                                        
                put    filialdobonus ";" titsit ";" valorliberado format ">>>>>.99" ";" valorutilizado format ">>>>>.99" ";" valorexcluido format ">>>>>.99" ";" titobs format "x(100)" ";" skip.                         
                       end.              
                         output close.      
