/*----------------------------------------------------------------------------*/
/* /usr/admger/zempre.p                                       Zoom de Veiculo */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var vprocura as char extent 3 format "x(12)"
	initial ["Fantasia","Razao Social","CPF/CGC."].
display vprocura
    with frame fprocura no-labels row 4 column 40 overlay color yellow/black.
choose field vprocura
    with frame fprocura.
hide frame fprocura no-pause.

if frame-index = 1
then run zfant2.p.
if frame-index = 2
then run znome2.p.
if frame-index = 3
then run zcgc.p.
