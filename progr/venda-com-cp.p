{admcab.i}

/* Definicao das variaveis */
def var i as int init 0.
def var varquivo as char.
def var vcatcod as char.
def var cpini as int init 0.
def var cpfim as int init 0.
def var totalmoda as int init 0.
def var totalmoveis as int init 0.
def var dtini as date.
def var dtfim as date.

def temp-table tt-venda
	field etbcod like plani.etbcod
	field desti like plani.desti format ">>>>>>>>>>9"
	field numero like plani.numero format ">>>>>>>9"
	field serie like plani.serie
	field catcod as char
	field pladat like plani.pladat
	field platot like plani.platot
	field idcp as int
	field numcp as int format ">>>>>>>9"
	field valcp like plani.platot.

for each tt-venda:
	delete tt-venda.
end.

/* Atribui valores iniciais as variaveis */
cpini = 82407775.
cpfim = 82498797.
dtini = date(month(today),1,year(today)).
dtfim = today.

/* Form que recebe os dados inputados pelo usuario */
update 
	cpini label "Nro ini" format ">>>>>>>9"
	cpfim label "Nro fim" format ">>>>>>>9"
	dtini label "Dt ini" format "99/99/9999"
	dtfim label "Dt fim" format "99/99/9999"
with 2 col frame f1 title "  Informe o intervalo de Cartao Presente  " centered width 80.

message "Processando...".

/* For que percorre as vendas */
for each plani use-index pladat where plani.movtdc = 5 and plani.pladat >= dtini and plani.pladat <= dtfim no-lock:
	if acha("QTDCHQUTILIZADO",plani.notobs[3]) <> ? then do:

		find first movim where movim.movtdc = plani.movtdc and
				movim.etbcod = plani.etbcod and
				movim.movdat = plani.pladat and
				movim.placod = plani.placod no-lock no-error.
		
		find produ where produ.procod = movim.procod no-lock no-error.

		if produ.catcod = 31 then do: vcatcod = "MOVEIS". totalmoveis = totalmoveis + 1. end.
		else if produ.catcod = 41 then do: vcatcod = "MODA". totalmoda = totalmoda + 1. end.
		else vcatcod = "".

		do i = 1 to int(acha("QTDCHQUTILIZADO",plani.notobs[3])):
			if int(acha("NUMCHQPRESENTEUTILIZACAO" + string(i),plani.notobs[3])) >= cpini and int(acha("NUMCHQPRESENTEUTILIZACAO" + string(i),plani.notobs[3])) <= cpfim then do:
				create tt-venda.
				tt-venda.etbcod = plani.etbcod.
				tt-venda.desti = plani.desti.
				tt-venda.numero = plani.numero.
				tt-venda.serie = plani.serie.
				tt-venda.pladat = plani.pladat.
				tt-venda.platot = plani.platot.
				tt-venda.idcp = i.
				tt-venda.numcp = int(acha("NUMCHQPRESENTEUTILIZACAO" + string(i),plani.notobs[3])).
				tt-venda.valcp = dec(acha("VALCHQPRESENTEUTILIZACAO" + string(i),plani.notobs[3])).
				tt-venda.catcod = vcatcod.
			end.
		end.
	end.
end.

/* Inicia o gerenciador de Impressao*/
if opsys = "UNIX" then varquivo = "/admcom/relat/acha-cp." + string(time).
else varquivo = "l:\relat\acha-cp" + string(day(today)).
{mdad.i
    &Saida     = "value(varquivo)"
    &Page-Size = "64"
    &Cond-Var  = "135"
    &Page-Line = "66"
    &Nom-Rel   = ""acha-cp""
    &Nom-Sis   = """SISTEMA GERENCIAL"""
    &Tit-Rel   = """VENDAS COM CARTOES PRESENTE"""
    &Width     = "135"
    &Form      = "frame f-cabcab"
}

	for each tt-venda:	
		disp
			tt-venda.etbcod format ">>>>9" column-label "FL"
			tt-venda.desti column-label "CLIENTE"
			tt-venda.numero column-label "NOTA"
			tt-venda.serie column-label "SERIE"
			tt-venda.catcod column-label "DEPTO"
			tt-venda.pladat column-label "DATA"
			tt-venda.platot(total) column-label "TOTAL"
			tt-venda.idcp column-label "ID CP"
			tt-venda.numcp column-label "NRO CP"
			tt-venda.valcp(total) column-label "VAL CP"
		with width 150.
	end.

	disp skip(2).

	disp 
		totalmoda column-label "Total CP MODA"
		totalmoveis column-label "Total CP MOVEIS".

output close.
if opsys = "UNIX" then do: run visurel.p (input varquivo, input "VENDAS COM CARTOES PRESENTE"). end.
else do: {mrod.i} end.
/* Finaliza o gerenciador de Impressao */

message "Relatorio gerado com sucesso!" view-as alert-box title "  ATENCAO!  ".