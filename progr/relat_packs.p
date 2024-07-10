/*por Lucas Leote*/

{admcab.i}

def var varquivo as char.

message "Gerando relatorio...".

/* Inicia o gerenciador de Impressao*/
if opsys = "UNIX"
 then
 varquivo = "/admcom/relat/relat_packs." + string(time).
 else
 varquivo = "l:\relat\relat_packs" + string(day(today)).
      
 {mdad.i
  &Saida     = "value(varquivo)"
  &Page-Size = "64"
  &Cond-Var  = "135"
  &Page-Line = "66"
  &Nom-Rel   = ""relat_packs""
  &Nom-Sis   = """SISTEMA GERENCIAL"""
  &Tit-Rel   = """RELATORIO DE PACKS"""
  &Width     = "135"
  &Form      = "frame f-cabcab"
 }

for each produaux 
	where nome_campo = "Pack" and 
	valor_campo > "0" no-lock.

	disp 
		procod 
		valor_campo column-label "Pack".
end.

output close.

   if opsys = "UNIX"
        then do:
                run visurel.p (input varquivo, input "RELATORIO DE PACKS").
        end.
        else do:
                {mrod.i}
        end.
/* Finaliza o gerenciador de Impressao */
