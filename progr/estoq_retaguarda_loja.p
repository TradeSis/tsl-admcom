/*{admcab.i}*/

message "Este menu considera o estoque dos seguintes estabelecimentos: 900, 980, 981, 988, 990, 993 e 998!" view-as alert-box.

def var vprocod like commatriz.produ.procod.
def var vestab like germatriz.estab.etbcod.
def var vcatcod like commatriz.produ.catcod.
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
	for each commatriz.estoq where (commatriz.estoq.etbcod = 900 or commatriz.estoq.etbcod = 980 or commatriz.estoq.etbcod = 981 or commatriz.estoq.etbcod = 988 or commatriz.estoq.etbcod = 990 or commatriz.estoq.etbcod = 993 or commatriz.estoq.etbcod = 998) and commatriz.estoq.estatual > 0 no-lock.
																				  
	find first commatriz.produ where commatriz.produ.procod = commatriz.estoq.procod no-lock.                         
	if not avail commatriz.produ then next.                                                 
																				  
	find first germatriz.estab where germatriz.estab.etbcod = commatriz.estoq.etbcod no-lock.                         
	if not avail germatriz.estab then next.

	find last commatriz.movim where commatriz.movim.movtdc = 4 and commatriz.movim.procod = vprocod no-lock.
	if not avail commatriz.movim then next.
																				  
	disp commatriz.estoq.etbcod(count) column-label "Etb." germatriz.estab.etbnom column-label "Estab." format "x(15)" commatriz.estoq.procod commatriz.produ.pronom format "x(12)" commatriz.produ.catcod column-label "Depto."
	commatriz.estoq.estatual(total) column-label "Est. Atual" commatriz.movim.movdat column-label "Ult. Entrada" with width 80.
end.

/*************************************************************************************************************************************/

if vprocod <> 0 and vestab = 0 and vcatcod = 0 then
	for each commatriz.estoq where (commatriz.estoq.etbcod = 900 or commatriz.estoq.etbcod = 980 or commatriz.estoq.etbcod = 981 or commatriz.estoq.etbcod = 988 or commatriz.estoq.etbcod = 990 or commatriz.estoq.etbcod = 993 or commatriz.estoq.etbcod = 998) and commatriz.estoq.procod = vprocod and commatriz.estoq.estatual > 0 no-lock.
																				  
	find first commatriz.produ where commatriz.produ.procod = commatriz.estoq.procod no-lock.                         
	if not avail commatriz.produ then next.                                                 
																				  
	find first germatriz.estab where germatriz.estab.etbcod = commatriz.estoq.etbcod no-lock.                         
	if not avail germatriz.estab then next.

	find last commatriz.movim where commatriz.movim.movtdc = 4 and commatriz.movim.procod = vprocod no-lock.
	if not avail commatriz.movim then next.
																				  
	disp commatriz.estoq.etbcod(count) column-label "Etb." germatriz.estab.etbnom column-label "Estab." format "x(15)" commatriz.estoq.procod commatriz.produ.pronom format "x(12)" commatriz.produ.catcod column-label "Depto."
	commatriz.estoq.estatual(total) column-label "Est. Atual" commatriz.movim.movdat column-label "Ult. Entrada" with width 80.
end.

/*************************************************************************************************************************************/

if vprocod = 0 and vestab <> 0 and vcatcod = 0 then
	for each commatriz.estoq where commatriz.estoq.etbcod = vestab and commatriz.estoq.estatual > 0 no-lock.
																				  
	find first commatriz.produ where commatriz.produ.procod = commatriz.estoq.procod no-lock.                         
	if not avail commatriz.produ then next.                                                 
																				  
	find first germatriz.estab where germatriz.estab.etbcod = commatriz.estoq.etbcod no-lock.                         
	if not avail germatriz.estab then next.

	find last commatriz.movim where commatriz.movim.movtdc = 4 and commatriz.movim.procod = vprocod no-lock.
	if not avail commatriz.movim then next.
																				  
	disp commatriz.estoq.etbcod(count) column-label "Etb." germatriz.estab.etbnom column-label "Estab." format "x(15)" commatriz.estoq.procod commatriz.produ.pronom format "x(12)" commatriz.produ.catcod column-label "Depto."
	commatriz.estoq.estatual(total) column-label "Est. Atual" commatriz.movim.movdat column-label "Ult. Entrada" with width 80.
end.

/*****************************************************************************************************************************************/

if vprocod = 0 and vestab = 0 and vcatcod <> 0 then
	for each commatriz.estoq where (commatriz.estoq.etbcod = 900 or commatriz.estoq.etbcod = 980 or commatriz.estoq.etbcod = 981 or commatriz.estoq.etbcod = 988 or commatriz.estoq.etbcod = 990 or commatriz.estoq.etbcod = 993 or commatriz.estoq.etbcod = 998) and commatriz.estoq.estatual > 0 no-lock.
																				  
	find commatriz.produ where commatriz.produ.procod = commatriz.estoq.procod and commatriz.produ.catcod = vcatcod no-error.                         
	if not avail commatriz.produ then next.                                                 
																				  
	find first germatriz.estab where germatriz.estab.etbcod = commatriz.estoq.etbcod no-lock.                         
	if not avail germatriz.estab then next.

	find last commatriz.movim where commatriz.movim.movtdc = 4 and commatriz.movim.procod = vprocod no-lock.
	if not avail commatriz.movim then next.
																				  
	disp commatriz.estoq.etbcod(count) column-label "Etb." germatriz.estab.etbnom column-label "Estab." format "x(15)" commatriz.estoq.procod commatriz.produ.pronom format "x(12)" commatriz.produ.catcod column-label "Depto."
	commatriz.estoq.estatual(total) column-label "Est. Atual" commatriz.movim.movdat column-label "Ult. Entrada" with width 80.
end.

/******************************************************************************************************************************************/

if vprocod <> 0 and vestab <> 0 and vcatcod <> 0 then
	for each commatriz.estoq where commatriz.estoq.etbcod = vestab and commatriz.estoq.estatual > 0 and commatriz.estoq.procod = vprocod no-lock.
																				  
	find first commatriz.produ where commatriz.produ.procod = commatriz.estoq.procod and commatriz.produ.catcod = vcatcod no-lock.                         
	if not avail commatriz.produ then next.                                                 
																				  
	find first germatriz.estab where germatriz.estab.etbcod = commatriz.estoq.etbcod no-lock.                         
	if not avail germatriz.estab then next.

	find last commatriz.movim where movtdc = 4 and commatriz.movim.procod = vprocod no-lock.
	if not avail commatriz.movim then next.
																				  
	disp commatriz.estoq.etbcod(count) column-label "Etb." germatriz.estab.etbnom column-label "Estab." format "x(15)" commatriz.estoq.procod commatriz.produ.pronom format "x(12)" commatriz.produ.catcod column-label "Depto."
	commatriz.estoq.estatual(total) column-label "Est. Atual" commatriz.movim.movdat column-label "Ult. Entrada" with width 80.
end.

/****************************************************************************************************************************************/

if vprocod = 0 and vestab <> 0 and vcatcod <> 0 then
	for each commatriz.estoq where commatriz.estoq.etbcod = vestab and commatriz.estoq.estatual > 0 no-lock.
																				  
	find first commatriz.produ where commatriz.produ.procod = commatriz.estoq.procod and commatriz.produ.catcod = vcatcod no-error.                         
	if not avail commatriz.produ then next.                                                 
																				  
	find first germatriz.estab where germatriz.estab.etbcod = commatriz.estoq.etbcod no-lock.                         
	if not avail germatriz.estab then next.

	find last commatriz.movim where commatriz.movim.movtdc = 4 and commatriz.movim.procod = vprocod no-lock.
	if not avail commatriz.movim then next.
																				  
	disp commatriz.estoq.etbcod(count) column-label "Etb." germatriz.estab.etbnom column-label "Estab." format "x(15)" commatriz.estoq.procod commatriz.produ.pronom format "x(12)" commatriz.produ.catcod column-label "Depto."
	commatriz.estoq.estatual(total) column-label "Est. Atual" commatriz.movim.movdat column-label "Ult. Entrada" with width 80.
end.

/*****************************************************************************************************************************************/

if vprocod <> 0 and vestab = 0 and vcatcod <> 0 then
	for each commatriz.estoq where (commatriz.estoq.etbcod = 900 or commatriz.estoq.etbcod = 980 or commatriz.estoq.etbcod = 981 or commatriz.estoq.etbcod = 988 or commatriz.estoq.etbcod = 990 or commatriz.estoq.etbcod = 993 or commatriz.estoq.etbcod = 998) and commatriz.estoq.estatual > 0 and commatriz.estoq.procod = vprocod no-lock.
																				  
	find first commatriz.produ where commatriz.produ.procod = commatriz.estoq.procod and commatriz.produ.catcod = vcatcod no-error.                         
	if not avail commatriz.produ then next.                                                 
																				  
	find first germatriz.estab where germatriz.estab.etbcod = commatriz.estoq.etbcod no-lock.                         
	if not avail germatriz.estab then next.

	find last commatriz.movim where commatriz.movim.movtdc = 4 and commatriz.movim.procod = vprocod no-lock.
	if not avail commatriz.movim then next.
																				  
	disp commatriz.estoq.etbcod(count) column-label "Etb." germatriz.estab.etbnom column-label "Estab." format "x(15)" commatriz.estoq.procod commatriz.produ.pronom format "x(12)" commatriz.produ.catcod column-label "Depto."
	commatriz.estoq.estatual(total) column-label "Est. Atual" commatriz.movim.movdat column-label "Ult. Entrada" with width 80.
end.

/********************************************************************************************************************************************/

if vprocod <> 0 and vestab <> 0 and vcatcod = 0 then
	for each commatriz.estoq where commatriz.estoq.etbcod = vestab and commatriz.estoq.estatual > 0 and commatriz.estoq.procod = vprocod no-lock.
																				  
	find first commatriz.produ where commatriz.produ.procod = commatriz.estoq.procod no-lock.                         
	if not avail commatriz.produ then next.                                                 
																				  
	find first germatriz.estab where germatriz.estab.etbcod = commatriz.estoq.etbcod no-lock.                         
	if not avail germatriz.estab then next.

	find last commatriz.movim where commatriz.movim.movtdc = 4 and commatriz.movim.procod = vprocod no-lock.
	if not avail commatriz.movim then next.
																				  
	disp commatriz.estoq.etbcod(count) column-label "Etb." germatriz.estab.etbnom column-label "Estab." format "x(15)" commatriz.estoq.procod commatriz.produ.pronom format "x(12)" commatriz.produ.catcod column-label "Depto."
	commatriz.estoq.estatual(total) column-label "Est. Atual" commatriz.movim.movdat column-label "Ult. Entrada" with width 80.
end.