/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/anave.i                   Acumulador de Vendas para ANAVE.P */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
	if wmd
	    then for each movim of estoq where year(movdat) = wano and
					       movtdc = 5 no-lock:
		    vx[month(movdat)] = vx[month(movdat)] + movpc * movqtm.
		end.
	    else for each movim of estoq where movdat >= wini and
					       movdat <= wfim and
					       movtdc = 5 no-lock:
		 vx[movdat - wini + 1] = vx[movdat - wini + 1] + movpc * movqtm.
		end.
