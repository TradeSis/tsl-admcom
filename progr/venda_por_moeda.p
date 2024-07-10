/*por Lucas Leote*/

{admcab.i}

def var filialini as int.
def var filialfim as int.
def var dataini as date.
def var datafim as date.
def var moeda as char.
def var varquivo as char.

message "OPCOES DE MOEDA: CAR (Cartao), REA (Dinheiro), CHV (Cheque a vista), PRE (Cheque pre) e ALL (Todas)!" view-as alert-box.

/* Formulario */
form filialini label "Filial inicial"
     filialfim label "Filial final"
     dataini label "Data inicial"
     datafim label "Data final"
     moeda label "Moeda"
                                        
with frame f01 title "Informe os dados abaixo:" with 1 col width 80.

/* Atualiza variaveis */
update filialini
       filialfim
       dataini
       datafim
       moeda
with frame f01.

message "Gerando relatorio...".

/* Inicia o gerenciador de Impressao*/
if opsys = "UNIX"
 then
 varquivo = "/admcom/relat/venda_por_moeda." + string(time).
 else
 varquivo = "l:\relat\venda_por_moeda" + string(day(today)).
      
 {mdad.i
  &Saida     = "value(varquivo)"
  &Page-Size = "64"
  &Cond-Var  = "135"
  &Page-Line = "66"
  &Nom-Rel   = ""venda_por_moeda""
  &Nom-Sis   = """SISTEMA GERENCIAL"""
  &Tit-Rel   = """VENDA POR MOEDA"""
  &Width     = "135"
  &Form      = "frame f-cabcab"
 }

/* CAR  */
if moeda matches "*CAR*"
then
    for each titulo where moecod = "CAR" and 
                          titdtpag >= dataini and 
                          titdtpag <= datafim and 
                          etbcod >= filialini and 
                          etbcod <= filialfim and
                          titsit = "PAG" and 
                          titpar < 2 no-lock.
    disp etbcod(count) clifor titnum titpar titvlcob(total) titvlpag(total) moecod with width 100.
end.

/* REA  */
if moeda matches "*REA*"
then
    for each titulo where moecod = "REA" and
                          titdtpag >= dataini and
                          titdtpag <= datafim and
                          etbcod >= filialini and
                          etbcod <= filialfim and
                          titsit = "PAG" and
                          titpar < 2 no-lock.
    disp etbcod(count) clifor titnum titpar titvlcob(total) titvlpag(total) moecod with width 100.
end.

/* CHV  */
if moeda matches "*CHV*"
then
    for each titulo where moecod = "CHV" and
                          titdtpag >= dataini and
                          titdtpag <= datafim and
                          etbcod >= filialini and
                          etbcod <= filialfim and
                          titsit = "PAG" and
                          titpar < 2 no-lock.
    disp etbcod(count) clifor titnum titpar titvlcob(total) titvlpag(total) moecod with width 100.
end.

/* PRE  */
if moeda matches "*PRE*"
then
    for each titulo where moecod = "PRE" and
                          titdtpag >= dataini and
                          titdtpag <= datafim and
                          etbcod >= filialini and
                          etbcod <= filialfim and
                          titsit = "PAG" and
                          titpar < 2 no-lock.
    disp etbcod(count) clifor titnum titpar titvlcob(total) titvlpag(total) moecod with width 100.
end.

/* ALL  */
if moeda matches "*ALL*"
then
    for each titulo where moecod = "CAR" or 
                          moecod = "REA" or
                          moecod = "CHV" or 
                          moecod = "PRE" and
                          titdtpag >= dataini and
                          titdtpag <= datafim and
                          etbcod >= filialini and
                          etbcod <= filialfim and
                          titsit = "PAG" and
                          titpar < 2 no-lock.
    disp etbcod(count) clifor titnum titpar titvlcob(total) titvlpag(total) moecod with width 100.
end.

output close.

   if opsys = "UNIX"
        then do:
                run visurel.p (input varquivo, input "VENDA POR MOEDA").
        end.
        else do:
                {mrod.i}
        end.
/* Finaliza o gerenciador de Impressao */

message "RELATORIO GERADO!" view-as alert-box.
