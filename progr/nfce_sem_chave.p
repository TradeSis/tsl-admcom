/*por Lucas Leote*/

{admcab.i}

def var filialini as int init 1.
def var filialfim as int init 134.
def var dataini as date init today.
def var datafim as date init today.
def var varquivo as char.
def var inut as int.
def var semchave as int.

/* Formulario */
form filialini label "Filial inicial"
     filialfim label "Filial final"
     dataini label "Data inicial"
     datafim label "Data final"
                                        
with frame f01 title "Informe os dados abaixo:" with 1 col width 80.

/* Atualiza variaveis */
update filialini 
       filialfim
       dataini
       datafim 
with frame f01.

message "Gerando relatorio...".

/* Inicia o gerenciador de Impressao*/
if opsys = "UNIX"
 then
 varquivo = "/admcom/relat/nfce_sem_chave." + string(time).
 else
 varquivo = "l:\relat\nfce_sem_chave" + string(day(today)).
      
 {mdad.i
  &Saida     = "value(varquivo)"
  &Page-Size = "64"
  &Cond-Var  = "135"
  &Page-Line = "66"
  &Nom-Rel   = ""nfce_sem_chave""
  &Nom-Sis   = """SISTEMA GERENCIAL"""
  &Tit-Rel   = """NFCE SEM CHAVE"""
  &Width     = "135"
  &Form      = "frame f-cabcab"
 }

for each plani where pladat >= dataini and
                     pladat <= datafim and
                     etbcod >= filialini and
                     etbcod <= filialfim and
                     serie = "3" and
					 (plani.ufdes = "" or 
					 plani.ufdes = "C" or 
					 plani.ufdes = "S")
					 no-lock by etbcod.

/*if plani.movtdc = 76 then inut = inut + 1.
if (plani.ufdes = "" or plani.ufdes = "C" or plani.ufdes = "S") then semchave = semchave + 1.*/

find estab where estab.etbcod = plani.emite no-lock.
if not avail estab then next.

find tipmov where tipmov.movtdc = plani.movtdc no-lock.
if not avail tipmo then next.
                     
disp plani.emite(count) column-label "Emitente"
estab.munic column-label "Cidade"
estab.etbcgc column-label "CNPJ"
plani.desti column-label "Destinatario" format ">>>>>>>>>>9" 
plani.cxacod column-label "Caixa" 
plani.numero format ">>>>>>>>>9" column-label "Nro NFCE" 
plani.serie column-label "Serie"
plani.pladat column-label "Data"
plani.platot(total) column-label "Valor NFCE"
tipmov.movtnom column-label "Movimento"
plani.ufdes column-label "Chave NFCE" format "x(44)" 
with width 400.
end.

/*message "Notas inutilizadas: "inut.
message "Notas sem chave: "semchave.*/

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
