{admcab.i}

def var varquivo as char.
def var datini as date format "99/99/9999".
def var pagto as char.
def var fora as int init 0.

/* Formulario */
form datini label "Data inicial"
with frame f01 title " Informe os dados abaixo: " with 1 col width 80.
          
/* Atualiza variaveis */
update datini
with frame f01.

message "Aguarde! Gerando relatorio...".

/* Inicia o gerenciador de Impressao*/
if opsys = "UNIX"
 then
 varquivo = "/admcom/relat/entrada-paga-depois." + string(time).
 else
 varquivo = "l:\relat\entrada-paga-depois." + string(day(today)).
    
 {mdad.i
  &Saida     = "value(varquivo)"
  &Page-Size = "64"
  &Cond-Var  = "135"
  &Page-Line = "66"
  &Nom-Rel   = ""entrada-paga-depois""
  &Nom-Sis   = """SISTEMA GERENCIAL"""
  &Tit-Rel   = """ENTRADA PAGA DEPOIS"""
  &Width     = "135"
  &Form      = "frame f-cabcab"
 }

 for each titulo use-index Por-Dtemi-Uo-Modal where 
  empcod = 19 and
  titnat = no and                             
  modcod = "CRE" and                          
  titsit = "PAG" and                          
  titdtemi >= datini and                  
  titpar = 0 no-lock:
  if titdtpag <> titdtemi then do: 
    pagto = "NAO".
    fora = fora + 1.
  end.
  else pagto = "SIM".

  disp etbcod(count) format ">>>>>>>9" clifor titnum titpar titdtemi titdtven titdtpag titvlcob format "->,>>>,>>>,>>9.99" titvlpag format "->,>>>,>>>,>>9.99" titsit pagto column-label "Pago no Dia?" with width 200.
 end.

 disp "NAO = " fora no-label.

output close.
   if opsys = "UNIX"
   then do:
   run visurel.p (input varquivo, input "ENTRADA PAGA DEPOIS").
   end.
   else do:
   {mrod.i}
   end.
/* Finaliza o gerenciador de Impressao */

message "RELATORIO GERADO COM SUCESSO!" view-as alert-box.
