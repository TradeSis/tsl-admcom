/*----------------------------------------------------------------------------*/
/* /usr/admcom/zcotin.p                       Zoom de Fornecedores na cotacao */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
def shared var zcond as i.
{zoomesq.i forne forcod fornom 35 Fornecedores
	 "can-find(fntos of forne where fntos.fabcod = zcond)"}
