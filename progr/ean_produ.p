{admcab.i}

def var vforcod  like forne.forcod init 0.
def var vclasse  like produ.clacod init 0.

/* FORMULARIO */
update vforcod  label "Fornecedor" 
	   vclasse  label "Classe"
with frame f01 with 1 col width 80

title " Informe os dados abaixo: " no-validate.

if vforcod = 0 and vclasse = 0 then do:
	message "Informe ao menos um dos campos para continuar!" view-as alert-box.
	undo, retry.
end.
	
/*************************************************************************************************************************************/

if vforcod <> 0 and vclasse = 0 then do:
	output to /admcom/relat/ean_produ.csv.
			for each forne where forcod = vforcod no-lock.
			for each produ where produ.fabcod = vforcod no-lock.
			find clase where clase.clacod = produ.clacod no-lock.
			disp forne.forcod column-label "Cod forne;"
				 ";" forne.fornom column-label "Nome forne;"
				 ";" produ.procod format ">>>>>>>>9" column-label "Cod produ;"
				 ";" produ.pronom column-label "Nome produ;"
				 ";" produ.proindice column-label "EAN;"
				 ";" produ.clacod column-label "Cod classe;"
				 ";" clase.clanom column-label "Nome classe;"
			with width 200.
		end.
	output close.
	message "Arquivo ean_produ.csv gerado em L:/relat" view-as alert-box.
end.
end.

/*************************************************************************************************************************************/

if vforcod = 0 and vclasse <> 0 then do:
	output to /admcom/relat/ean_produ.csv.
			for each produ where produ.clacod = vclasse no-lock.
			find clase where clase.clacod = produ.clacod no-lock.
			find forne where forne.forcod = produ.fabcod no-lock.
			disp forne.forcod column-label "Cod forne;"
				 ";" forne.fornom column-label "Nome forne;"
				 ";" produ.procod format ">>>>>>>>9" column-label "Cod produ;"
				 ";" produ.pronom column-label "Nome produ;"
				 ";" produ.proindice column-label "EAN;"
				 ";" produ.clacod column-label "Cod classe;"
				 ";" clase.clanom column-label "Nome classe;"
			with width 200.
		end.
	output close.
	message "Arquivo ean_produ.csv gerado em L:/relat" view-as alert-box.
end.

/*************************************************************************************************************************************/

if vforcod <> 0 and vclasse <> 0 then do:
	output to /admcom/relat/ean_produ.csv.
			for each forne where forcod = vforcod no-lock.
			for each produ where produ.fabcod = vforcod and produ.clacod = vclasse no-lock.
			find clase where clase.clacod = produ.clacod no-lock.
			disp forne.forcod column-label "Cod forne;"
				 ";" forne.fornom column-label "Nome forne;"
				 ";" produ.procod format ">>>>>>>>9" column-label "Cod produ;"
				 ";" produ.pronom column-label "Nome produ;"
				 ";" produ.proindice column-label "EAN;"
				 ";" produ.clacod column-label "Cod classe;"
				 ";" clase.clanom column-label "Nome classe;"
			with width 200.
		end.
	output close.
	message "Arquivo ean_produ.csv gerado em L:/relat" view-as alert-box.
end.
end.