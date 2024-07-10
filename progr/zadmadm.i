/*----------------------------------------------------------------------------*/
/* /usr/admger/zadmadm.i                           Zoom para Admcom Banco ADM */
/*                                                                            */
/* Data       Autor     Caracteristica                                        */
/* ---------- -------   ------------------                                    */
/* 21/03/2016 Laureano  Criacao                                               */
/*----------------------------------------------------------------------------*/

if frame-field matches "*tipviv*"
then run zoomtipviv.p.   

if frame-field matches "*codviv*"
then run zoomcodviv.p.



