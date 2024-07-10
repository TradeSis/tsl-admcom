{admcab.i}

def var alerta as char format "x(50)".
def var conta like clien.clicod.

alerta = "ATENCAO!!! ANTES DE EXECUTAR A LOJA PRECISA SAIR DO CADASTRO DE CLIENTE".

conta = 0.

message alerta.

form conta    label "Conta do Cliente" format ">>>>>>>>>>>9"
     with frame f-cont row 3 width 81
                     side-labels no-box.



prompt-for conta
   with frame f-cont.


conta = input frame f-cont conta.




find first neuclien where neuclien.clicod = conta no-error.

	if avail neuclien then do:
	
		update neuclien.sit_credito = 'A'.
	
		disp neuclien.clicod neuclien.cpf
		  with frame f-neucli row 4 width 81
						side-labels no-box.

		for each neuclienhist where cpfcnpj = neuclien.cpf and neuclienhist.sit_credito = 'P':
		
			update neuclienhist.sit_credito = 'A'.
		/*
			disp neuclienhist.sit_credito.
		*/
		end.



		output to "../roberto/motor/logMataPendente.log" APPEND.

		export "[" + string(today) + "-" + STRING(TIME,"HH:MM:SS") + "] Cliente " + string(neuclien.clicod) + " Sit_credito atualizada = A." format "x(90)".

		output close.


		disp "Processo Concluido."
		with frame f-fimProc row 6 width 81
					  side-labels no-box.
		pause.
	end.
	else do:
	 
		message "Cliente " + string(conta) + " nao localizado.".
		pause 2.
		message "".
		undo.
	end.
				  

