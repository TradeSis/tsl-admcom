/* por Lucas Leote */

def var Produto as int format ">>>>>9".     
def var Frete as decimal.
                                                                
/* Formulario */                                                          
form Produto label "Cod. do Produto"                                       
with frame f01 title "Informe os dados abaixo:" with 1 col width 80.  
                                                                          
/* Atualiza a variavel */                                                 
update Produto                                                              
with frame f01.                                                           
     
message "Gerando arquivo...".

output to /admcom/relat/preco_venda.csv.                                                                    
for each movim where movim.procod = Produto and movim.movtdc = 4 no-lock by movdat desc:

find forne where forcod = movim.emite no-lock.
                                                                         
find plani where plani.etbcod = movim.etbcod and                          
                 plani.placod = movim.placod and                            
                 plani.movtdc = movim.movtdc no-lock.                 

frete = plani.frete * ((movim.movpc * movim.movqtm) / plani.protot).
frete = frete / movim.movqtm.

disp Produto movdat movpc movqtm movim.emite forne.ufecod plani.numero 
format ">>>>>>>>9" movim.movipi platot plani.frete Frete with frame f down width 200.
down with frame f.                                                        

/*pause.*/                                                                  

end.

output close.

message "ARQUIVO 'preco_venda.csv' GERADO EM L:/relat" view-as alert-box.
