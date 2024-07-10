/* PROGRAMA PARA ENVIAR EMAIL DE UM RELATORIO 
AUTOR: CASSIO LAGO */

/* Recebe a variavel de estabelecimento */
def input parameter p-estab  like estab.etbcod.

/* Recebe a variavel de arquivo */
def input parameter  varquivo as char.



def var lEmail      as logi form "Sim/Nao"        init yes        no-undo.



update lEmail label "Envia Email? "
 	      with frame f-11 side-labels 1 col width 40
               row 15 col 10 title "ENVIA EMAIL".
if lEmail = yes
then do:

	unix /admcom/progr/mail.sh Inventario value(varquivo) cassio@lebes.com.br  > /tmp/mail.sh_inv.log 2>&1.

end. 


