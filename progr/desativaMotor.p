{admcab.i} 

def var desativa as log format "Sim/Nao".
def var vl-param as char.


repeat:
	UPDATE desativa LABEL "Desativar o motor: S/N"
	WITH FRAME header-fr ROW 0 SIDE-LABELS width 80.

	if desativa = no then do:
		vl-param = "SIM".
		message "Motor Ativado".
	end.
	else do:
		vl-param = "NAO".
		message "Motor Desativado".
	end.    


	for each tab_ini where parametro = "MOTOR_NEUROTECH_ATIVO":
		update valor = vl-param.
		disp parametro valor
		WITH FRAME result-fr ROW 3 SIDE-LABELS width 80.
	end.  

end.