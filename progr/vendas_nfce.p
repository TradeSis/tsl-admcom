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
 varquivo = "/admcom/relat/vendas_nfce." + string(time).
 else
 varquivo = "l:\relat\vendas_nfce" + string(day(today)).
      
 {mdad.i
  &Saida     = "value(varquivo)"
  &Page-Size = "64"
  &Cond-Var  = "135"
  &Page-Line = "66"
  &Nom-Rel   = ""vendas_nfce""
  &Nom-Sis   = """SISTEMA GERENCIAL"""
  &Tit-Rel   = """VENDAS NFCE"""
  &Width     = "135"
  &Form      = "frame f-cabcab"
 }

for each plani where pladat >= dataini and
                     pladat <= datafim and
                     etbcod >= filialini and
                     etbcod <= filialfim and
					 etbcod <> 140 and /* PDV fiscal */
						(length(serie) = 2 or /* Descata recargas */ 
						 serie = "3") and /* NFC-e ADMCOM */
					 movtdc = 5 /* venda */
					 no-lock by etbcod.
					 
	/* Atualizado para ler NFC-e P2K Serie > 29 */
	if integer(serie) > 29 or integer(serie) = 3 then do:
		if plani.movtdc = 76 then inut = inut + 1.
		if (plani.ufdes = "" or plani.ufdes = "C" or plani.ufdes = "S") then semchave = semchave + 1.

		find estab where estab.etbcod = plani.emite no-lock.
		if not avail estab then next.

		find tipmov where tipmov.movtdc = plani.movtdc no-lock.
							 
		disp plani.emite(count) estab.munic estab.etbcgc plani.desti format ">>>>>>>>>>9" plani.cxacod plani.numero plani.serie plani.pladat plani.platot(total) plani.movtdc format ">>9" tipmov.movtnom plani.ufdes label "Chave" format "x(44)" with width 400.
	end.

end.

message "Notas inutilizadas: "inut.
message "Notas sem chave: "semchave.

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
