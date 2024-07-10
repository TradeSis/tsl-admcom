def var contandoestoque as int.                                                def var contandoencomendado as int.
def var contandoentregue as int.
def var estabtemporario as int.
def var varhora as char.
def var varquivo as char.
def var datainicial as date.
def var datafinal as date.
def var precodopedido as dec.
def var diferenca as int.

message "GERANDO ARQUIVO...".

varquivo = "/admcom/lebesintel/bi_compras.csv". 

output to "/admcom/lebesintel/bi_compras.csv".                    
                  
put  "pedid.pednum ;
      pedid.clfcod ;
      pedid.peddat ;   
     produ.procod ;          
     produ.pronom ;
     contandoencomendado ;   
     contandoentregue ;     
     precodopedido ;    
     diferenca ;                                
     datainicial ;                              
     datafinal"  skip.                             
                    
                    
                    
                              
                    
for each produ 

/* where produ.procod = 401329 */
/*   where produ.fabcod = 112141 */

no-lock.


if produ.catcod <> 31 and produ.catcod <> 41 then next.
         
if produ.catcod = 31 then estabtemporario = 999.
if produ.catcod = 41 then estabtemporario = 996.


contandoestoque = 0.                                                           
/*                                                                              
for each estoq where estoq.procod = produ.procod and estoq.estatual > 0 no-lock.
contandoestoque = contandoestoque + estoq.estatual.                             end.                                                                          */
  
contandoentregue = 0.
contandoencomendado = 0.


for each liped where liped.procod = produ.procod and liped.etbcod =estabtemporario
no-lock. 
 
  /*
if liped.lipsit = "F" then next.
  */

precodopedido = liped.lippreco.

find first pedid where pedid.etbcod = liped.etbcod             
                  and  pedid.pedtdc = liped.pedtdc             
                  and  pedid.pednum = liped.pednum no-lock.   
  /*
if pedid.sitped = "F" then next.
if pedid.pedsit = no then next. 
  */

/* if pedid.pedtdc <> 1 then next. */

   
            /*     if not avail pedid.peddti then next. */

            if pedid.peddtf < today - 730 then next.
    
            if pedid.peddtf = ? then next.  
                    

contandoencomendado = liped.lipqtd.
contandoentregue =  liped.lipent.

diferenca = contandoentregue - contandoencomendado.

                         /*
message contandoentregue.
message contandoencomendado.                       
                       
message diferenca.
pause.
                        */
                          
datainicial = pedid.peddti.
datafinal = pedid.peddtf.
                                                                                                                                              

if (contandoencomendado = 0) then next.   

/* if diferenca >= 0 then next. */                                                  
      
if datafinal < today - 730 then next.
     
                                                                
put  pedid.pednum format ">>>>>>>>>9" ";"
     pedid.clfcod format ">>>>>>>>>9" ";"
     pedid.peddat format "99/99/9999" ";"
     produ.procod format ">>>>>>>>9"  ";"
     produ.pronom ";"
     contandoencomendado format ">>>>>>>>9" ";"
     contandoentregue format ">>>>>>>>>9" ";"
     precodopedido format ">>>,>>>,>>9.99" ";"
     diferenca ";"
     datainicial ";"
     datafinal  skip.                             


end.
pause 0.
end.                

output close.
message "Arquivo Gerado:" varquivo.
pause.
