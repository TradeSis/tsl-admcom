/*----------------------------------------------------------------------------*/
/* /usr/admfin/anati.i                   Acumulador de Titulos para ANATI.P   */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 15/12/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
if wmd
    then for each titulo where (if input estab.etbcod = 0
				   then true
				   else titulo.etbcod = input estab.etbcod) and
			       (if input modal.modcod = ""
				   then true
				   else titulo.modcod = input modal.modcod) and
			       titdtven >= date(wmesi,01,wanoi) and
			       date(month(titdtven),01,year(titdtven)) <=
			       date(wmesf,01,wanof) and
			       (titsit = "LIB" or
				titsit = "BLO"):
    if titnat
	then vx[(year(titdtven) * 12 + month(titdtven)) -
		(wanoi * 12 + wmesi) + 1] =
	     vx[(year(titdtven) * 12 + month(titdtven)) -
		(wanoi * 12 + wmesi) + 1] +
	     titvlcob.
	else vz[(year(titdtven) * 12 + month(titdtven)) -
		(wanoi * 12 + wmesi) + 1] =
	     vz[(year(titdtven) * 12 + month(titdtven)) -
		(wanoi * 12 + wmesi) + 1] +
	     titvlcob.
    end.
    else for each titulo where (if input estab.etbcod = 0
				   then true
				   else titulo.etbcod = input estab.etbcod) and
			       (if input modal.modcod = ""
				   then true
				   else titulo.modcod = input modal.modcod) and
			       titdtven >= wini and
			       titdtven <= wfim and
			       (titsit = "LIB" or
				titsit = "BLO"):
    if titnat
	then vx[titdtven - wini + 1] = vx[titdtven - wini + 1] + titvlcob.
	else vz[titdtven - wini + 1] = vz[titdtven - wini + 1] + titvlcob.
    end.
