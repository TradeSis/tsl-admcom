/*----------------------------------------------------------------------------*/
/* /usr/admcom/zclase.p                                        Zoom de Classe */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
def new global shared var v-cli like clien.clicod.
update v-cli
    with row 4 side-label col 1 overlay
	editing.
   readkey.
  if  lastkey = keycode("PF7")
    then do:
	run zclien.p.
	display v-cli.
    end.
    apply lastkey.
end.

find clien where clien.clicod = v-cli no-error.
if not available clien
then do:
    message "Cliente Nao Cadastrado".
    undo.
end.
display clinom no-label format "X(25)".

{zoomesq.i pedid pednum string(pednum)  25 PEDIDOS "pedid.clicod = v-cli"}
