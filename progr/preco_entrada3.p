/* por Lucas Leote */
 
def var Frete as decimal.
def var Estab as int format ">>9".
def var Datini as date.
def var Datfim as date.
                                                                
/* Formulario */                                                          
form Estab label "Estabelecimento"
     Datini label "Data inicial"
     Datfim label "Data final"                                       
with frame f01 title "Informe os dados abaixo:" with 1 col width 80.  
                                                                          
/* Atualiza a variavel */                                                 
update Estab
       Datini
       Datfim                                               
with frame f01.                                                           
     
message "Gerando arquivo...".
                                                                    
output to /admcom/relat/preco_venda_geral.csv.

for each movim where movim.movtdc = 4 and
                     movim.desti = Estab and
                     movim.movdat >= Datini and
                     movim.movdat <= Datfim 
                     no-lock by movdat desc:

find forne where forcod = movim.emite no-lock.
                                                                         
find plani where plani.etbcod = movim.etbcod and                          
                 plani.placod = movim.placod and                            
                 plani.movtdc = movim.movtdc no-lock.                 

frete = plani.frete * ((movim.movpc * movim.movqtm) / plani.protot).
frete = frete / movim.movqtm.

disp movim.procod movdat movpc movqtm movim.emite forne.ufecod plani.numero 
format ">>>>>>>>9" movim.movipi platot plani.frete Frete with frame f down width 200.
down with frame f.                                                        

/*pause.*/                                                                  

end.
output close.

message "ARQUIVO 'preco_venda_geral.csv' GERADO COM SUCESSO EM L:/relat" view-as alert-box.
