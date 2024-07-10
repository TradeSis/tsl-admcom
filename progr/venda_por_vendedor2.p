{admcab.i}

def var varquivo as char.
def var filial as int format "999".
def var vendedor as int format "999".
def var datini as date format "99/99/9999".
def var datfim as date format "99/99/9999".

/* Formulario */
form filial label "Filial"
     vendedor label "Vendedor"
     datini label "Data inicial"
     datfim label "Data final"
          
with frame f01 title "Informe os dados abaixo:" with 1 col width 80.
          
/* Atualiza variaveis */
update filial
       vendedor
       datini
       datfim
with frame f01.

message "Aguarde! Gerando arquivo...".

output to /admcom/relat/venda_por_vendedor.csv.

for each plani where etbcod = filial and                     
                     vencod = vendedor and                     
                     pladat >= datini and                     
                     pladat <= datfim and                     
                     serie = "V" and                     
                     movtdc = 5 no-lock by pladat desc.

for each movim where movim.movtdc = plani.movtdc and
                     movim.etbcod = plani.etbcod and
                     movim.movdat = plani.pladat and
                     movim.placod = plani.placod no-lock.

for each produ where produ.procod = movim.procod no-lock.

disp plani.etbcod format ">>>9" ";"      
     plani.vencod ";"     
     plani.pladat ";"    
     plani.numero ";"    
     plani.platot ";"
     plani.biss ";"
     movim.procod format ">>>>>>>9" ";"
     produ.pronom format "x(35)" ";"
     movim.movqtm ";"
     movim.movpc with width 200.
end.
end.
end.

output close.

message "ARQUIVO 'venda_por_vendedor.csv' GERADO COM SUCESSO NO RELAT!" view-as alert-box.
