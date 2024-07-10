{admcab.i}

def var i-estab like estab.etbcod.
def var d-dtini as date format "99/99/99" label "Dt inicial".
def var d-dtfim as date format "99/99/99" label "Dt final".
def var varquivo as char.
def var i-produ as int init 0 label "Qtd produtos".
def var i-pecas as int init 0 label "Qtd pecas".

d-dtini = date(month(today),1,year(today)).
d-dtfim = today.

update i-estab help "Loja de destino da NF. Informe 0 para todas." label "Destino" with frame f-data side-label 1 down width 80 title " Informe os dados abaixo ".

if i-estab <> 0 then do:
	find estab where estab.etbcod = i-estab no-lock no-error.
	if not avail estab
	then do:
	    bell.
	    message color red/with
	    "Estabelecimento nao cadastrado"
	    view-as alert-box title " ATENCAO! ".
	    undo, retry.
	end.
end.
disp estab.etbnom format "x(24)" no-label with frame f-data.

update d-dtini help "Data de emissao da NF."
	   d-dtfim help "Data de emissao da NF."
with frame f-data.

if d-dtfim < d-dtini then do:
	bell.
    message color red/with
    "Data final nao pode ser menor que data inicial"
    view-as alert-box title " ATENCAO! ".
    undo, retry.
end.

message "Gerando relatorio...".

/* Inicia o gerenciador de Impressao*/
if opsys = "UNIX"
 then
 varquivo = "/admcom/relat/relat-gaiola." + string(time).
 else
 varquivo = "l:\relat\relat-gaiola" + string(day(today)).
      
 {mdad.i
  &Saida     = "value(varquivo)"
  &Page-Size = "64"
  &Cond-Var  = "135"
  &Page-Line = "66"
  &Nom-Rel   = ""relat-gaiola""
  &Nom-Sis   = """SISTEMA GERENCIAL"""
  &Tit-Rel   = """RELATORIO NFs DE MODA"""
  &Width     = "135"
  &Form      = "frame f-cabcab"
 }

if i-estab = 0 then do:

	for each plani where plani.emite = 900 and
						 plani.etbcod = 900 and
						 plani.pladat >= d-dtini and 
						 plani.pladat <= d-dtfim and 
						 plani.serie = "1" and 
						 plani.movtdc = 6 no-lock by plani.pladat DESC.
		
		find tipmov where tipmov.movtdc = plani.movtdc no-lock no-error.
		find estab where estab.etbcod = plani.desti no-lock no-error.

		for each movim where movim.movtdc = plani.movtdc and
	                     	 movim.etbcod = plani.etbcod and
	                     	 movim.movdat = plani.pladat and
	                     	 movim.placod = plani.placod no-lock.

			/*disp 
				movim.movseq 
				movim.procod 
				movim.movpc 
				movim.movqtm 
				movim.movpc * movim.movqtm(total).*/

			i-produ = i-produ + 1.
			i-pecas = i-pecas + movim.movqtm.
		end.

		if acha("Gaiola",plani.notped) <> ? then do:
			disp 
				plani.desti column-label "Desti" 
				estab.etbnom column-label "Desti"
				estab.munic column-label "Cidade"
				plani.numero column-label "Nro"
				plani.serie column-label "Serie"
				tipmov.movtnom column-label "Tipo"
				plani.pladat column-label "Emissao"
				plani.platot column-label "Total NF"
				i-produ
				i-pecas
				acha("Gaiola",plani.notped) format "x(10)" column-label "Gaiola"
				acha("Arquivo",plani.notped) format "x(20)" column-label "Arquivo"
				with width 200.
		end.

		i-produ = 0.
		i-pecas = 0.

	end.

end.

if i-estab <> 0 then do:

	for each plani where plani.emite = 900 and
						 plani.etbcod = 900 and
						 plani.desti = i-estab and
						 plani.pladat >= d-dtini and 
						 plani.pladat <= d-dtfim and 
						 plani.serie = "1" and 
						 plani.movtdc = 6 no-lock by plani.pladat DESC.
		
		find tipmov where tipmov.movtdc = plani.movtdc no-lock no-error.
		find estab where estab.etbcod = plani.desti no-lock no-error.

		for each movim where movim.movtdc = plani.movtdc and
	                     	 movim.etbcod = plani.etbcod and
	                     	 movim.movdat = plani.pladat and
	                     	 movim.placod = plani.placod no-lock.

			/*disp 
				movim.movseq 
				movim.procod 
				movim.movpc 
				movim.movqtm 
				movim.movpc * movim.movqtm(total).*/

			i-produ = i-produ + 1.
			i-pecas = i-pecas + movim.movqtm.
		end.

		if acha("Gaiola",plani.notped) <> ? then do:
			disp 
				plani.desti column-label "Desti" 
				estab.etbnom column-label "Desti"
				estab.munic column-label "Cidade"
				plani.numero column-label "Nro"
				plani.serie column-label "Serie"
				tipmov.movtnom column-label "Tipo"
				plani.pladat column-label "Emissao"
				plani.platot column-label "Total NF"
				i-produ
				i-pecas
				acha("Gaiola",plani.notped) format "x(10)" column-label "Gaiola"
				acha("Arquivo",plani.notped) format "x(20)" column-label "Arquivo"
				with width 200.
		end.

		i-produ = 0.
		i-pecas = 0.

	end.

end.

output close.

   if opsys = "UNIX"
        then do:
                run visurel.p (input varquivo, input "RELATORIO NFs DE MODA").
        end.
        else do:
                {mrod.i}
        end.
/* Finaliza o gerenciador de Impressao */

message "RELATORIO GERADO!" view-as alert-box title " ATENCAO! ".