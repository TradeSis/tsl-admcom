/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/invge.p           Gera Posicao de inventario                */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var wmes as i format "99" label "Mes Inventario".
def var wano as i format "9999" label "Ano Inventario".
def var wdatlim as date.
def var wetbcod like estab.etbcod.
def var whimdata like himov.himdata.
def var winvdata as date.
def var westoq like himov.himestfim.
def var wctmed as de.
repeat with row 4 frame f1 width 80 side-labels 1 down:
    update wetbcod colon 18.
    find estab where estab.etbcod = wetbcod.
    display space(4) etbnom no-label.
    update wmes colon 18 validate(wmes > 0 and wmes <= 12,"Mes Invalido.")
	   wano colon 18.
    assign wdatlim = date(wmes,01,wano)
	   winvdata = date(wmes,day(date(if wmes = 12 then 1 else wmes + 1,
			   01,if wmes = 12 then wano + 1 else wano) - 1),
			   wano).
    {confir.i 1 "geracao de Posicao de Inventario"}
    l0:
    for each estoq of estab:
	l1:
	repeat:
	    find first himov where himov.etbcod = estoq.etbcod and
				   himov.procod = estoq.procod and
				   himov.himctmfim = ? no-error.
	    if not available himov
		then leave l1.
		else if himov.himdata > wdatlim
		    then leave l1.
		    else do:
		    whimdata = himov.himdata.
		    find last himov where himov.etbcod = estoq.etbcod and
					  himov.procod = estoq.procod and
					  himov.himdata < whimdata and
					  himov.himctmfim <> ? no-error.
		    if available himov
			then assign westoq = himov.himestfim
				    wctmed = himov.himctmfim.
			else assign westoq = 0
				    wctmed = 0.
		    end.
	    find first himov where himov.etbcod = estoq.etbcod and
				   himov.procod = estoq.procod and
				   himov.himdata = whimdata.
	    himov.himctmfim = wctmed.
	    for each movim where (movim.etbcod = estoq.etbcod or
				 movim.etbdes = estoq.etbcod) and
				 movim.procod = estoq.procod and
				 date(month(movdat),01,year(movdat)) = whimdata
				 by movdat by movseq:
		if movtdc = 1
		    then himctmfim = (westoq * himctmfim + movqtm * movpc) /
				     (westoq + movqtm).
		if movtdc = 1 or
		   movtdc = 9
		    then westoq = westoq + movqtm.
		    else if movtdc = 2 or
			    movtdc = 0
			then westoq = westoq - movqtm.
			else if movtdc = 3
			    then if movim.etbcod = estoq.etbcod
				then westoq = westoq - movqtm.
				else westoq = westoq + movqtm.
	    end.
	end.
	find last himov where himov.etbcod = estoq.etbcod and
			      himov.procod = estoq.procod and
			      himov.himdata <= wdatlim no-error.
	if available himov
	    then assign estoq.estinvdat = winvdata
			estoq.estinvqtd = himov.himestfim
			estoq.estinvctm = himov.himctmfim.
	    else assign estoq.estinvdat = winvdata
			estoq.estinvqtd = 0
			estoq.estinvctm = 0.
    end.
    message "Geracao de Posicao de Inventario encerrada.".
end.
