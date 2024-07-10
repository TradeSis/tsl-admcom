{admcab.i}

def temp-table tt-produ
	field procod like produ.procod label "Cod produ" format ">>>>>>>9"
	field pronom like produ.pronom label "Nome produ"
	field clacod like produ.clacod label "Cod classe"
	field estatual like estoq.estatual column-label "Estoq 900".

def var i-componente as int init 0 label "Qtd comp.".
def var d-precocusto like estoq.estcusto column-label "Preco custo".
def var c-clanom like clase.clanom label "Nome classe".
def var c-clacodsup like clase.clasup.

message "Considera somente produtos de moveis, ativos e com estoque no 900!" view-as alert-box title "ATENCAO!".

def var varquivo as char.

message "Gerando relatorio...".

/* Inicia o gerenciador de Impressao*/
     
if opsys = "UNIX" then varquivo = "/admcom/relat/relat-componentes." + string(time).
else varquivo = "l:\relat\relat-componentes" + string(day(today)).

{mdad.i
	&Saida     = "value(varquivo)"
	&Page-Size = "64"
	&Cond-Var  = "135"
	&Page-Line = "66"
	&Nom-Rel   = ""relat-componentes""
	&Nom-Sis   = """SISTEMA GERENCIAL"""
	&Tit-Rel   = """PRODUTOS E COMPONENTES"""
	&Width     = "135"
	&Form      = "frame f-cabcab"
}

for each produ where produ.catcod = 31 and produ.proseq = 0 no-lock by produ.pronom.
	find estoq where estoq.procod = produ.procod and estoq.etbcod = 900 and estoq.estatual > 0 no-lock no-error.
	if avail estoq then do:
		create tt-produ.
		assign tt-produ.procod = produ.procod 
			   tt-produ.pronom = produ.pronom
			   tt-produ.clacod = produ.clacod
			   tt-produ.estatual = estoq.estatual.
	end.
end.

for each tt-produ.
	for each produ where string(produ.procod) matches "*" + string(tt-produ.procod) no-lock.
		if avail produ then do:
			i-componente = i-componente + 1.
		end.
		else next.
	end.

	find first estoq where estoq.procod = tt-produ.procod no-lock no-error.
		if avail estoq then d-precocusto = estoq.estcusto.
		else d-precocusto = 0.

	find clase where clase.clacod = tt-produ.clacod no-lock no-error.
		if avail clase then c-clacodsup = clase.clasup.
		else c-clacodsup = 0.

	find clase where clase.clacod = c-clacodsup no-lock no-error.
		if avail clase then c-clanom = clase.clanom.
		else c-clanom = "".

	i-componente = i-componente - 1.

	disp tt-produ.procod tt-produ.pronom d-precocusto tt-produ.clacod c-clanom i-componente tt-produ.estatual with width 200.

	i-componente = 0.
end.

output close.
if opsys = "UNIX" then do:
	run visurel.p (input varquivo, input "CONTRATO POR CLIENTE").
end.
else do:
	{mrod.i}
end.

/* Finaliza o gerenciador de Impressao */ 