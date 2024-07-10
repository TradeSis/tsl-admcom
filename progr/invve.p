/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/invve.p                Verifica valor total do Inventario   */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 26/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var winv as de format ">>>,>>>,>>>,>>9.99" label "Total".
repeat with row 4 side-labels 1 down width 80 title " Estabelecimento "
	    frame f1:
    prompt-for estab.etbcod colon 18.
    find estab using etbcod.
    display etbnom no-label at 28.
    winv = 0.
    pause 0 before-hide.
    for each estoq of estab by estoq.etbcod by estoq.procod with side-labels
	     1 down width 80 title " Processamento " frame f2:
	winv = winv + estinvqtd * estinvctm.
	display estoq.procod colon 18
		winv colon 40.
    end.
    pause before-hide.
end.
