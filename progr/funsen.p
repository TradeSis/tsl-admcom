/******************************************************************************
 Programa       : Senha para alteracao e Exclusao de Funcionario
 Nome Programa  : FunSen.p
 Programador    : Cristiano Borges Brasil
 Criacao        : 28/11/1996.
*****************************************************************************/

def input  parameter     vrec        as recid.
def output parameter     vok         as logical     initial no.
def output parameter     vfuncod     like func.funcod.
def                 var  vsenha      as char.

if vrec <> ?
then do:
    find func where recid(func) = vrec.

    if func.senha <> ""
    then do:
	vfuncod  = func.funcod.
	display skip(1)
		func.funcod label "USUARIO" with frame fsenha.
	update vsenha blank label "SENHA"
	       skip(1)
	       go-on(ESC F4 return)
	       with side-label color red/white title " SENHA "
	       centered row 11 frame fsenha overlay.

	if keyfunction(lastkey) = "END-ERROR"
	then do:
	    hide frame fsenha no-pause.
	    undo, return.
	end.
	if vsenha <> func.senha
	then do:
	    message "Senha Invalida !!".
	    undo, retry.
	end.
    end.

    hide frame fsenha no-pause.
    assign vok      = yes.
end.
else do:
     prompt-for skip(1)
	    func.funcod label "USUARIO" with frame fsenha2.
     find first func using func.funcod.
     update vsenha blank label "SENHA"
	       skip(1)
	       go-on(ESC F4 return)
	       with side-label color red/white title " SENHA "
	       centered row 11 frame fsenha2 overlay.

	if keyfunction(lastkey) = "END-ERROR"
	then do:
	    hide frame fsenha2 no-pause.
	    undo, return.
	end.
	if vsenha <> func.senha
	then do:
	    message "Senha Invalida !!".
	    undo, retry.
	end.

	hide frame fsenha2 no-pause.
	assign vok      = yes
	       vfuncod  = func.funcod.
end.
