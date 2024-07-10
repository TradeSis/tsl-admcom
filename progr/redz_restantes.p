/*por Lucas Leote*/

{admcab.i}

def var filialini as int init 1.
def var filialfim as int init 134.
def var dtbase as date init today.
def var varquivo as char.

/* Formulario */
form filialini label "Filial inicial"
     filialfim label "Filial final"
     dtbase label "Data base"
                                        
with frame f01 title "Informe os dados abaixo:" with 1 col width 80.

/* Atualiza variaveis */
update filialini 
       filialfim
       dtbase 
with frame f01.

message "Gerando relatorio...".

/* Inicia o gerenciador de Impressao*/
if opsys = "UNIX"
 then
 varquivo = "/admcom/relat/redz_restantes." + string(time).
 else
 varquivo = "l:\relat\redz_restantes" + string(day(today)).
      
 {mdad.i
  &Saida     = "value(varquivo)"
  &Page-Size = "64"
  &Cond-Var  = "135"
  &Page-Line = "66"
  &Nom-Rel   = ""redz_restantes""
  &Nom-Sis   = """SISTEMA GERENCIAL"""
  &Tit-Rel   = """REDUCOES Z RESTANTES"""
  &Width     = "135"
  &Form      = "frame f-cabcab"
 }

for each mapcxa where etbcod >= filialini and
                      etbcod <= filialfim and
                      datmov = dtbase no-lock by de3.

disp mapcxa.etbcod column-label "Fil"
             mapcxa.cxacod column-label "Cxa"
             int(mapcxa.de1)    column-label "Equip" format ">>9"
             mapcxa.ch1 column-label "Serie"  format "x(25)"
             int(mapcxa.de3) column-label "Red!Restantes"
             mapcxa.nrored
             mapcxa.nroseq
            /*mapcxa.cooini
            mapcxa.coofin*/ 
            .
end.

output close.

   if opsys = "UNIX"
        then do:
                run visurel.p (input varquivo, input "VENDAS NFCE").
        end.
        else do:
                {mrod.i}
        end.
/* Finaliza o gerenciador de Impressao */

message "RELATORIO GERADO!" view-as alert-box.
