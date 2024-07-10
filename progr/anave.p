/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/anave.p                         Analise de Vendas - Grafica */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
{graficd.i}
def var wmd as l format "Meses/Dias" label "Periodo".
def var wano as i format "9999" label "Ano".
def var wini as da label "Data Inicial".
def var wfim as da label "Data Final".
def var wmeses as c format "!!!" extent 12
	initial ["JAN","FEV","MAR","ABR","MAI","JUN",
		 "JUL","AGO","SET","OUT","NOV","DEZ"].
def var i as i.
repeat with side-labels 1 down width 80 title " Analise de Vendas ":
    prompt-for estab.etbcod colon 18.
    find estab using estab.etbcod.
    display etbnom no-label colon 30.
    do on error undo:
	prompt-for fabri.fabcod colon 18.
	if input fabri.fabcod <> 0
	    then do:
	    find fabri using fabri.fabcod.
	    display fabri.fabnom no-label.
	    end.
    end.
    do on error undo:
	prompt-for clase.clacod colon 18.
	if input clase.clacod <> 0
	    then do:
	    find clase using clase.clacod.
	    display space(3) clase.clanom no-label.
	    end.
    end.
    do on error undo:
	prompt-for produ.procod colon 18 with no-validate.
	if input produ.procod <> 0
	    then do:
	    find estoq where estoq.etbcod = estab.etbcod and
			     estoq.procod = input produ.procod.
	    display estoq.pronomc + "-" + estoq.fabfant format "x(34)"
		    no-label colon 30.
	    end.
    end.
    update wmd colon 18.
    if wmd
	then do:
	update wano colon 18 with frame fmeses width 80 side-labels.
	nx = 12.
	do i = 1 to nx:
	    lx[i] = wmeses[i].
	end.
	end.
	else do:
	if wini = ?
	    then wini = date(month(today),01,year(today)).
	update wini colon 18
	       wfim colon 18 with frame fdias width 80 side-labels.
	if wfim = ?
	    then wfim = today.
	nx = wfim - wini + 1.
	if nx > 60
	    then do:
	    message "Numero de dias para analise nao deve exceder 60.".
	    undo.
	    end.
	do i = 0 to nx - 1:
	    lx[i + 1] = string(day(wini + i),">9") +
			substr(wmeses[month(wini + i)],1,1).
	end.
	end.
    if available clase
	then if input fabri.fabcod <> 0
	    then for each produ of clase where produ.fabcod = fabri.fabcod,
		     each estoq of produ where estoq.etbcod = estab.etbcod:
		     {anave.i}
		 end.
	    else for each produ of clase,
		     each estoq of produ where estoq.etbcod = estab.etbcod:
		     {anave.i}
		 end.
	else if input fabri.fabcod <> 0
	    then for each produ of fabri,
		     each estoq of produ where estoq.etbcod = estab.etbcod:
		     {anave.i}
		 end.
	    else if available estoq
		    then {anave.i}
		    else for each estoq where estoq.etbcod = estab.etbcod:
			    {anave.i}
			 end.
    {graficp.i " Analise de Vendas " "Venda" "Periodo"}
end.
