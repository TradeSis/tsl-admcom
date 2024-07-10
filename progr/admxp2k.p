{admcab.i}

def var flini like estab.etbcod.
def var flfim like estab.etbcod.
def var dtini as date.
def var dtfim as date.

def var vendaadm as int init 0 format ">>>>>>>9".
def var vendap2k as int init 0 format ">>>>>>>9".
def var vendatotal as int init 0 format ">>>>>>>9".
def var percadm as int init 0.
def var percp2k as int init 0.

def var varquivo as char.

def temp-table tt-venda
	field etbcod like estab.etbcod
	field etbnom like estab.etbnom
	field vendaadm as int init 0 format ">>>>>>>9" label "Venda ADM"
	field vendap2k as int init 0 format ">>>>>>>9" label "Venda P2K"
	field percadm as int init 0 label "% ADM"
	field percp2k as int init 0 label "% P2k"
	field vendatotal as int init 0 format ">>>>>>>9" label "Venda TOTAL".

assign flini = 1
	   flfim = 999.

assign dtini = date(month(today),1,year(today))
	   dtfim = today.

update 
flini column-label "Filial inicial"
flfim column-label "Filial final"
dtini label "Data inicial" format "99/99/9999"
dtfim label "Data final" format "99/99/9999"
with frame f1 centered title "  Informe os dados  ".

message "Gerando relatorio...".

for each plani where movtdc = 5 and etbcod >= flini and etbcod <= flfim and pladat >= dtini and pladat <= dtfim no-lock break by etbcod:
	if etbcod = 140 then vendap2k = vendap2k + 1.
	else do:
		if serie = "3" then vendaadm = vendaadm + 1.
		if serie >= "31" then vendap2k = vendap2k + 1.
	end.

	find first estab where estab.etbcod = plani.etbcod no-lock no-error.

	if last-of(etbcod) then do:
		vendatotal = vendaadm + vendap2k.
		
		percadm = (vendaadm * 100) / vendatotal.
		percp2k = (vendap2k * 100) / vendatotal.
		
		create tt-venda.
		assign tt-venda.etbcod = estab.etbcod
			   tt-venda.etbnom = estab.etbnom when avail estab 
			   tt-venda.vendaadm = vendaadm
			   tt-venda.percadm = percadm
			   tt-venda.vendap2k = vendap2k
			   tt-venda.percp2k = percp2k
			   tt-venda.vendatotal = vendatotal.
		assign vendaadm = 0
			   vendap2k = 0.
	end.
end.

/* Inicia o gerenciador de Impressao*/
if opsys = "UNIX" then varquivo = "/admcom/relat/admxp2k." + string(time).
else varquivo = "l:\relat\admxp2k" + string(day(today)).
{mdad.i
    &Saida     = "value(varquivo)"
    &Page-Size = "64"
    &Cond-Var  = "135"
    &Page-Line = "66"
    &Nom-Rel   = ""admxp2k""
    &Nom-Sis   = """SISTEMA GERENCIAL"""
    &Tit-Rel   = """VENDAS ADMCOM vs VENDAS P2K"""
    &Width     = "135"
    &Form      = "frame f-cabcab"
}

for each tt-venda no-lock by tt-venda.percadm desc:
	disp 
		tt-venda.etbcod(count)
		tt-venda.etbnom
		tt-venda.vendaadm(total)
		tt-venda.percadm " %"
		tt-venda.vendap2k(total)
		tt-venda.percp2k " %"
		tt-venda.vendatotal(total)
	with width 150.
end.

output close.
if opsys = "UNIX" then do: run visurel.p (input varquivo, input "VENDAS ADMCOM vs VENDAS P2K"). end.
else do: {mrod.i} end.
/* Finaliza o gerenciador de Impressao */

message "RELATORIO GERADO COM SUCESSO!" view-as alert-box title "  ATENCAO!  ".