{admcab.i new}

def var vetbcod as int init 1.
def var vfilial as char.

message "Executando...".

output to /admcom/TI/leote/busca_plani_a01.csv.

	put "Filial ; Ult. plani ; Ult. a01_infnfe" skip.

	repeat:

		if vetbcod < 10 then vfilial = "filial0" + string(vetbcod).
		else vfilial = "filial" + string(vetbcod).

		if (vetbcod = 22 or vetbcod = 65 or vetbcod = 107) then vetbcod = vetbcod + 1.

		/* ------- BANCO COM ------- */
		if connected ("comloja")
		then disconnect comloja.
		
		connect com -H value(vfilial) -S sdrebcom -N tcp -ld comloja no-error.
		
		if not connected ("comloja") then
		next.
		
		find last com.plani where plani.etbcod = vetbcod and 
								  plani.movtdc = 5 and 
								  plani.serie = "3" no-lock no-error.
		put vetbcod ";" plani.numero format ">>>>>>>>>>9" ";".

		if connected ("comloja")
		then disconnect comloja.
		/* ------------------------- */

		/* ------- BANCO NFE ------- */
		connect nfe -H value(vfilial) -S sdrebnfe -N tcp -ld nfeloja no-error.
		
		if not connected ("nfeloja") then
		next.
		
		find last a01_infnfe where a01_infnfe.emite = vetbcod and 
								   a01_infnfe.serie = "3" no-lock no-error.
		put a01_infnfe.numero format ">>>>>>>>>>9" skip.

		if connected ("nfeloja")
		then disconnect nfeloja.
		/* ------------------------- */

		vetbcod = vetbcod + 1.

		if vetbcod = 151 then leave.

	end.

output close.