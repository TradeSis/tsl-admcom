{admcab.i new}

def var varquivo as char.
varquivo = "/admcom/TI/leote/relmix-autom.csv". 

/*message "Gerando relatorio...".*/

output to value(varquivo).

	put "ESTAB ; COD MIX ; COD PRODUTO ; NOME PRODUTO ; DEPTO ; QTD MIX" skip.

	def var vcodigomix as int.

	for each estab where estab.etbcod < 500 no-lock.

		if estab.etbcod = 22 or estab.etbcod = 200 then next.

		find first tabmix where tabmix.etbcod = estab.etbcod no-lock no-error.

		if not avail tabmix then next.

		vcodigomix = tabmix.codmix.	                                                                          

		for each tabmix where tabmix.tipomix = "P" and tabmix.codmix = vcodigomix no-lock.

			find first produ where produ.procod = tabmix.promix no-lock no-error.

			if not avail tabmix then next.

	        if tabmix.mostruario = no then next.

			put
				estab.etbcod ";"
				tabmix.codmix ";"
				tabmix.promix format ">>>>>>>>9" ";"
				produ.pronom ";"
				produ.catcod ";"
				tabmix.qtdmix format ">>>>>>>9" skip.

		end.
	end.

output close.

/*message "Arquivo relmix.csv gerado em L:/relat!" view-as alert-box.*/