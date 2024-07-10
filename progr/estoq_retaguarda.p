{admcab.i}

message "Este menu considera o estoque dos seguintes estabelecimentos: 900, 980, 981, 988, 990, 993 e 998!" view-as alert-box.

def var vprocod like produ.procod.
def var vestab like estab.etbcod.
def var vcatcod like produ.catcod.
def var sresp as char.
def var ordenar as char.

/* FORMULARIO */
update vprocod label "Produto" 
	   vestab  label "Estabelecimento"
	   vcatcod label "Categoria"
	   /*sresp label "Ordenar por"
	   sresp format "Data/Qtde"*/
/* with side-labels width 81 frame f1 */
with frame f01 with 1 col width 80

title " Informe os dados abaixo: " no-validate.

/*if sresp
	then assign ordenar = "movim.movdat".
	else assign ordenar = "estoq.estatual".
message ordenar.*/

if vestab < 900 and vestab > 0
	then do:
		message "Estabelecimento invalido" view-as alert-box.
    undo.
end.

if vprocod = 0 and vestab = 0 and vcatcod = 0 then
	for each estoq where (etbcod = 900 or etbcod = 980 or etbcod = 981 or etbcod = 988 or etbcod = 990 or etbcod = 993 or etbcod = 998) and estatual > 0 no-lock.
																				  
	find first produ where produ.procod = estoq.procod no-lock.                         
	if not avail produ then next.                                                 
																				  
	find first estab where estab.etbcod = estoq.etbcod no-lock.                         
	if not avail estab then next.

	find last movim where movtdc = 4 and movim.procod = vprocod no-lock.
	if not avail movim then next.
																				  
	disp estoq.etbcod(count) column-label "Etb." estab.etbnom column-label "Estab." format "x(15)" estoq.procod produ.pronom format "x(12)" produ.catcod column-label "Depto."
	estoq.estatual(total) column-label "Est. Atual" movim.movdat column-label "Ult. Entrada" with width 80.
end.

/*************************************************************************************************************************************/

if vprocod <> 0 and vestab = 0 and vcatcod = 0 then
	for each estoq where (etbcod = 900 or etbcod = 980 or etbcod = 981 or etbcod = 988 or etbcod = 990 or etbcod = 993 or etbcod = 998) and procod = vprocod and estatual > 0 no-lock.
																				  
	find first produ where produ.procod = estoq.procod no-lock.                         
	if not avail produ then next.                                                 
																				  
	find first estab where estab.etbcod = estoq.etbcod no-lock.                         
	if not avail estab then next.

	find last movim where movtdc = 4 and movim.procod = vprocod no-lock.
	if not avail movim then next.
																				  
	disp estoq.etbcod(count) column-label "Etb." estab.etbnom column-label "Estab." format "x(15)" estoq.procod produ.pronom format "x(12)" produ.catcod column-label "Depto."
	estoq.estatual(total) column-label "Est. Atual" movim.movdat column-label "Ult. Entrada" with width 80.
end.

/*************************************************************************************************************************************/

if vprocod = 0 and vestab <> 0 and vcatcod = 0 then
	for each estoq where etbcod = vestab and estatual > 0 no-lock.
																				  
	find first produ where produ.procod = estoq.procod no-lock.                         
	if not avail produ then next.                                                 
																				  
	find first estab where estab.etbcod = estoq.etbcod no-lock.                         
	if not avail estab then next.

	find last movim where movtdc = 4 and movim.procod = vprocod no-lock.
	if not avail movim then next.
																				  
	disp estoq.etbcod(count) column-label "Etb." estab.etbnom column-label "Estab." format "x(15)" estoq.procod produ.pronom format "x(12)" produ.catcod column-label "Depto."
	estoq.estatual(total) column-label "Est. Atual" movim.movdat column-label "Ult. Entrada" with width 80.
end.

/*****************************************************************************************************************************************/

if vprocod = 0 and vestab = 0 and vcatcod <> 0 then
	for each estoq where (etbcod = 900 or etbcod = 980 or etbcod = 981 or etbcod = 988 or etbcod = 990 or etbcod = 993 or etbcod = 998) and estatual > 0 no-lock.
																				  
	find produ where produ.procod = estoq.procod and produ.catcod = vcatcod no-error.                         
	if not avail produ then next.                                                 
																				  
	find first estab where estab.etbcod = estoq.etbcod no-lock.                         
	if not avail estab then next.

	find last movim where movtdc = 4 and movim.procod = vprocod no-lock.
	if not avail movim then next.
																				  
	disp estoq.etbcod(count) column-label "Etb." estab.etbnom column-label "Estab." format "x(15)" estoq.procod produ.pronom format "x(12)" produ.catcod column-label "Depto."
	estoq.estatual(total) column-label "Est. Atual" movim.movdat column-label "Ult. Entrada" with width 80.
end.

/******************************************************************************************************************************************/

if vprocod <> 0 and vestab <> 0 and vcatcod <> 0 then
	for each estoq where etbcod = vestab and estatual > 0 and procod = vprocod no-lock.
																				  
	find first produ where produ.procod = estoq.procod and produ.catcod = vcatcod no-lock.                         
	if not avail produ then next.                                                 
																				  
	find first estab where estab.etbcod = estoq.etbcod no-lock.                         
	if not avail estab then next.

	find last movim where movtdc = 4 and movim.procod = vprocod no-lock.
	if not avail movim then next.
																				  
	disp estoq.etbcod(count) column-label "Etb." estab.etbnom column-label "Estab." format "x(15)" estoq.procod produ.pronom format "x(12)" produ.catcod column-label "Depto."
	estoq.estatual(total) column-label "Est. Atual" movim.movdat column-label "Ult. Entrada" with width 80.
end.

/****************************************************************************************************************************************/

if vprocod = 0 and vestab <> 0 and vcatcod <> 0 then
	for each estoq where etbcod = vestab and estatual > 0 no-lock.
																				  
	find first produ where produ.procod = estoq.procod and produ.catcod = vcatcod no-error.                         
	if not avail produ then next.                                                 
																				  
	find first estab where estab.etbcod = estoq.etbcod no-lock.                         
	if not avail estab then next.

	find last movim where movtdc = 4 and movim.procod = vprocod no-lock.
	if not avail movim then next.
																				  
	disp estoq.etbcod(count) column-label "Etb." estab.etbnom column-label "Estab." format "x(15)" estoq.procod produ.pronom format "x(12)" produ.catcod column-label "Depto."
	estoq.estatual(total) column-label "Est. Atual" movim.movdat column-label "Ult. Entrada" with width 80.
end.

/*****************************************************************************************************************************************/

if vprocod <> 0 and vestab = 0 and vcatcod <> 0 then
	for each estoq where (etbcod = 900 or etbcod = 980 or etbcod = 981 or etbcod = 988 or etbcod = 990 or etbcod = 993 or etbcod = 998) and estatual > 0 and procod = vprocod no-lock.
																				  
	find first produ where produ.procod = estoq.procod and produ.catcod = vcatcod no-error.                         
	if not avail produ then next.                                                 
																				  
	find first estab where estab.etbcod = estoq.etbcod no-lock.                         
	if not avail estab then next.

	find last movim where movtdc = 4 and movim.procod = vprocod no-lock.
	if not avail movim then next.
																				  
	disp estoq.etbcod(count) column-label "Etb." estab.etbnom column-label "Estab." format "x(15)" estoq.procod produ.pronom format "x(12)" produ.catcod column-label "Depto."
	estoq.estatual(total) column-label "Est. Atual" movim.movdat column-label "Ult. Entrada" with width 80.
end.

/********************************************************************************************************************************************/

if vprocod <> 0 and vestab <> 0 and vcatcod = 0 then
	for each estoq where etbcod = vestab and estatual > 0 and procod = vprocod no-lock.
																				  
	find first produ where produ.procod = estoq.procod no-lock.                         
	if not avail produ then next.                                                 
																				  
	find first estab where estab.etbcod = estoq.etbcod no-lock.                         
	if not avail estab then next.

	find last movim where movtdc = 4 and movim.procod = vprocod no-lock.
	if not avail movim then next.
																				  
	disp estoq.etbcod(count) column-label "Etb." estab.etbnom column-label "Estab." format "x(15)" estoq.procod produ.pronom format "x(12)" produ.catcod column-label "Depto."
	estoq.estatual(total) column-label "Est. Atual" movim.movdat column-label "Ult. Entrada" with width 80.
end.

pause.