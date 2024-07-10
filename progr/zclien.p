/*----------------------------------------------------------------------------*/
/* /usr/admger/zclien.p                                       Zoom do Cliente */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
def new global shared var v-cli like clien.clicod.
{zoomand.i clien clicod clinom 40 Clientes true}
v-cli = int(array-cod[i]).
