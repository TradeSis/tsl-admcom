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

message "Aguarde! Gerando relatorio...".

/* Inicia o gerenciador de Impressao*/
if opsys = "UNIX"
 then
 varquivo = "/admcom/relat/venda_por_vendedor." + string(time).
 else
 varquivo = "l:\relat\venda_por_vendedor" + string(day(today)).
    
 {mdad.i
  &Saida     = "value(varquivo)"
  &Page-Size = "64"
  &Cond-Var  = "135"
  &Page-Line = "66"
  &Nom-Rel   = ""venda_por_vendedor""
  &Nom-Sis   = """SISTEMA GERENCIAL"""
  &Tit-Rel   = """VENDA POR VENDEDOR"""
  &Width     = "135"
  &Form      = "frame f-cabcab"
 }

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

disp plani.etbcod format ">>>9"      
     plani.vencod      
     plani.pladat     
     plani.numero     
     plani.platot
     plani.biss
     movim.procod format ">>>>>>>9"
     produ.pronom format "x(35)"
     movim.movqtm 
     movim.movpc with width 200.
end.
end.
end.

output close.
   if opsys = "UNIX"
   then do:
   run visurel.p (input varquivo, input "NF PO IMPOSTO").
   end.
   else do:
   {mrod.i}
   end.
/* Finaliza o gerenciador de Impressao */

message "RELATORIO GERADO COM SUCESSO!" view-as alert-box.
