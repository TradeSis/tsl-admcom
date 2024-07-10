def var contandoestoque as int.                                                def var contandoencomendado as int.
def var contandoentregue as int.
def var varhora as char.
def var varquivo as char.
def var varquivo_copia_bi as char.
def var datainicial as date.
def var datafinal as date.
def var precodopedido as dec.
def var diferenca as int.
def var nova_data_final as date.
def var vsp as char initial ";".

def stream str-csv.


varquivo = "/admcom/relat/exp_compras_pedidos.csv". 

varquivo_copia_bi = "/admcom/lebesintel/exp_compras_pedidos_bi.csv".

/************** Arquivo do BI ****************/
output stream str-csv to value(varquivo_copia_bi).

put stream str-csv unformatted
    "pedid_pednum;produ_procod;precodopedido;"
    "diferenca;codfornecedor;nomefornecedor;nova_data_final" skip.


/************** Arquivo Luciano *************/
output to "/admcom/relat/exp_compras_pedidos.csv".                    
                  
put  "pedid_pednum;"         
     "produ_procod;"          
     "produ_pronom;"                             
     "contandoestoque;"     
     "contandoencomendado;"   
     "contandoentregue;"     
     "precodopedido;"   
     "diferenca;"                                
     "datainicial;"                              
     "datafinal;"
     "codfornecedor;"
     "nomefornecedor;"
     "nova_data_final"  skip.                             
                              
                    
for each produ 
  /*    where produ.procod = 420481 */   
/* where produ.fabcod = 1                */
no-lock.

if produ.catcod <> 31 then next.
           
contandoestoque = 0.                                                                                                                                         
for each estoq where estoq.procod = produ.procod and estoq.estatual > 0 no-lock.
contandoestoque = contandoestoque + estoq.estatual.                             end.                                                                            
contandoentregue = 0.
contandoencomendado = 0.


for each liped where liped.procod = produ.procod
                 and liped.etbcod = 999

no-lock. 

if liped.lipsit = "F" then next.


precodopedido = liped.lippreco.

find first pedid where pedid.etbcod = liped.etbcod             
                  and  pedid.pedtdc = liped.pedtdc             
                  and  pedid.pednum = liped.pednum no-lock.   
 
if pedid.sitped = "F" then next.
if pedid.pedsit = no then next. 
 
 
/* if pedid.pedtdc <> 1 then next. */

   
            /*     if not avail pedid.peddti then next. */

            if pedid.peddti < 01/01/2009 then next.
    
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
if diferenca >= 0 then next.                                                        
if datafinal <= 02/01/2013 then next.

if datafinal < today
then assign nova_data_final = today.
else assign nova_data_final = datafinal.
     
     find first forne where forne.forcod =  produ.fabcod no-lock no-error.  
                                                                
put unformatted  pedid.pednum format ">>>>>>>>>9" ";"
     produ.procod ";"
     produ.pronom ";"
     contandoestoque format ">>>>>>>>>>9" ";"
     contandoencomendado format ">>>>>>>>9" ";"
     contandoentregue format ">>>>>>>>>9" ";"
     precodopedido format ">>>>>>>>9.99" ";"
     diferenca ";"
     datainicial ";"
     datafinal ";"
     produ.fabcod ";"
     (if avail forne
      then forne.fornom 
      else "FORNECEDOR NAO CADASTRADO") ";"
     nova_data_final 
      skip.                             

    put stream str-csv unformatted
        pedid.pednum
        vsp
        produ.procod
        vsp
        precodopedido
        vsp
        diferenca * -1
        vsp
        produ.fabcod
        vsp
       (if avail forne
        then forne.fornom
        else "FORNECEDOR NAO CADASTRADO")
        vsp
        nova_data_final skip.


end.
pause 0.
end.                

output stream str-csv close.

output close.

pause 0.
