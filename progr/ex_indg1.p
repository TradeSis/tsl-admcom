def var contandoestoque as int.                                                def var contandoencomendado as int.
def var contandoentregue as int.
def var varhora as char.
def var varquivo as char.
def var datainicial as date.
def var datafinal as date.
def var precodopedido as dec.
def var diferenca as int.


message "GERANDO ARQUIVO...".

varquivo = "/admcom/TI/joao/compras_cerveirahoje.csv". 

output to "/admcom/TI/joao/compras_cerveirahoje.csv".                    
                    
for each produ 

/* where produ.procod = 401329 */

/*   where produ.fabcod = 110289 */
     no-lock.

if produ.catcod <> 31 then next.
           
contandoestoque = 0.                                                                                                                                         
for each estoq where estoq.procod = produ.procod and estoq.estatual > 0 no-lock.
contandoestoque = contandoestoque + estoq.estatual.                             end.                                                                            
contandoentregue = 0.
contandoencomendado = 0.


for each liped where liped.procod = produ.procod and liped.etbcod = 999

no-lock. 

if liped.lipsit = "F" then next.


precodopedido = liped.lippreco.

find first pedid where pedid.etbcod = liped.etbcod             
                  and  pedid.pedtdc = liped.pedtdc             
                  and  pedid.pednum = liped.pednum no-lock.   

if pedid.sitped = "F" then next.
if pedid.pedsit = no then next. 
if pedid.pedtdc <> 1 then next.

   
            /*     if not avail pedid.peddti then next. */

            if pedid.peddti = ? then next.
            if pedid.peddtf = ? then next.  
            
            

contandoencomendado = contandoencomendado + liped.lipqtd.
contandoentregue = contandoentregue + liped.lipent.

diferenca = contandoentregue - contandoencomendado.

                         /*
message contandoentregue.
message contandoencomendado.
                        
                        
message diferenca.
pause.
                        */
                          
datainicial = pedid.peddti.
datafinal = pedid.peddtf.
                                                                                                                                                   
end.

if (contandoencomendado = 0) then next.   

            if diferenca > 0 then next.                                                     
            if datafinal <= 02/01/2013 then next.     
                                                                
put  produ.procod format ">>>>>>>>9" ";"
     produ.pronom ";"
     contandoestoque format ">>>>>>>>>>9" ";"
     contandoencomendado format ">>>>>>>>9" ";"
     contandoentregue format ">>>>>>>>>9" ";"
     precodopedido format ">>>,>>>,>>9.99" ";" 
     datainicial ";"
     datafinal  skip.                             

pause 0.

end.                

output close.
message "Arquivo Gerado:" varquivo.
pause.

