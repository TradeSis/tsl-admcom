/*----------------------------------------------------------------------------*/
/* /usr/admfin/zmodal.p                               Zoom Modalidade         */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
def new global shared var sretorno      as char.
{zoomesq.i modal modcod modnom 30 Modalidades true}
sretorno = frame-value.
