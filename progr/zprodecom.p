/*----------------------------------------------------------------------------*/
/* /usr/admcom/zclasecom.p                        Zoom de Classe do E-Commerce*/
/*                                                                            */
/* Data       Autor    Caracteristica                                         */
/* ---------- -------- ------------------                                     */
/* 10/06/2010 Laureano Criacao                                                */
/*----------------------------------------------------------------------------*/

define variable vcha-campo as character no-undo.
/*
assign vcha-campo = 'produaux.nome_campo = "exporta-e-com" and ProduAux.Valor_Campo = "yes"
no-lock, first produ where produ.procod = produaux.procod'.
*/



{zoomesq.i produ produ.procod produ.pronom 35 Produtos " can-find (first produaux where produaux.procod = produ.procod and produaux.nome_campo = 'exporta-e-com' and ProduAux.Valor_Campo = 'yes') " }

