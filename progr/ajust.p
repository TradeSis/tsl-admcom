/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/ajust.p               Ajuste de Estoque por Balanco         */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 28/08/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def buffer zestoq for estoq.
def var wetbcod like estab.etbcod.
def var wclacod like clase.clacod.
def var wmovndc like movim.movndc.
def var wmovseq like movim.movseq.
def var west like himestfim extent 0 label "Qtd.Calculada"
	       format "->,>>>,>>9.99".
def new shared var wrecid as recid.
def new shared var westcro as l.
repeat with row 4 frame f1 width 80 side-labels 1 down:
    update wetbcod colon 18.
    find estab where estab.etbcod = wetbcod.
    display space(2) etbnom no-label.
    update wclacod colon 18.
    if wclacod <> 0
	then do:
	find clase where clase.clacod = wclacod.
	display space(2) clanom no-label.
	end.
    {confir.i 1 "Ajuste de Estoque"}
    if wclacod <> 0
	then do:
	{ajust.i}
	end.
	else for each clase:
	    {ajust.i 1}
	end.
    message "Ajuste de Estoque encerrado.".
end.
