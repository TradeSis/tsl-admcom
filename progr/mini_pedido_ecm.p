{admcab.i}

def var mini_pedido as log format "Sim/Nao".
def var reserva_ecom as int.
def var varquivo as char.

varquivo = "/admcom/relat-crm/mini_pedido_ecm_" + string(time) + ".csv".

def temp-table tt-produ
	field etbcod like estoq.etbcod column-label "Estab"
	field procod like estoq.procod column-label "Codigo"
	field pronom like produ.pronom column-label "Nome" format "x(40)"
	field estatual like estoq.estatual column-label "Estoque"
	field reserva_ecom as int column-label "Reserva ECM"
	field mini_pedido as log format "Sim/Nao" column-label "Mini pedido"
.

message "Gerando relatorio...".

output to value(varquivo).
	
	put "Estab ; Codigo ; Nome ; Estoque ; Reserva ECM ; Mini pedido" skip.

	for each estoq where estoq.etbcod = 900 no-lock.

		find produ where produ.procod = estoq.procod no-lock no-error.
		if not avail produ then next.

		find first produaux where produaux.procod = estoq.procod and
		                          produaux.nome_campo = "exporta-e-com" and
		                          produaux.valor_campo = "yes" no-lock no-error.
		if not avail produaux then next.

		run reserv_ecom.p (input estoq.procod, output reserva_ecom).

		if produ.proipival = 1 then mini_pedido = yes.
		else mini_pedido = no.

		/*create tt-produ.
		assign tt-produ.etbcod = estoq.etbcod
		tt-produ.procod = estoq.procod 
		tt-produ.pronom = produ.pronom  
		tt-produ.estatual = estoq.estatual 
		tt-produ.reserva_ecom = reserva_ecom 
		tt-produ.mini_pedido = mini_pedido.*/

		/*disp estoq.etbcod column-label "Estab"
			 estoq.procod column-label "Codigo"
			 produ.pronom column-label "Nome" format "x(40)"
			 estoq.estatual column-label "Estoque"
			 reserva_ecom column-label "Reserva ECM"
			 mini_pedido column-label "Mini pedido"
		with width 200.*/

		put estoq.etbcod ";" 
			estoq.procod ";" 
			produ.pronom ";" 
			estoq.estatual format "->>,>>9.99" ";" 
			reserva_ecom ";" 
			mini_pedido skip.

	end.
output close.

message "Arquivo mini_pedido_ecm.csv gerado com sucesso em L:/relat-crm" view-as alert-box.

/*for each tt-produ.
	disp tt-produ.
end.*/