/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/anagi.p                                     Analise de Giro */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var wqcp like movqtm format "->,>>>,>>9.99" label "Q.C.P.".
def var wqvp like movqtm format "->,>>>,>>9.99" label "Q.V.P.".
def new shared var perini as date format "99/99/9999".
def new shared var perfin as date format "99/99/9999".
define new shared variable wclacod like clase.clacod.
define new shared variable wfabri like fabri.fabcod.
define new shared variable wetb like estoq.etbcod.
define new shared variable wprocod like produ.procod.
l1:
repeat with side-labels 1 down width 80 frame f1 title " Dados para Emissao ":
    form skip(1)
	 estab.etbcod colon 19 etbnom at 28 no-label
	 fabri.fabcod colon 19 fabnom at 28 no-label
	 clase.clacod colon 19 clanome at 28 no-label
	 produ.procod colon 19 produ.pronom at 28 no-label
	 perini label "Periodo" colon 19
	 " A " perfin no-label skip(1).
    display " " @ clase.clacod
	    " " @ clase.clanome.
    display " " @ produ.procod
	    " " @ produ.pronom.
    prompt-for estab.etbcod.
    find estab using etbcod.
    display etbnom.
    do on error undo:
	prompt-for fabri.fabcod.
	find fabri using fabri.fabcod.
	display fabri.fabnom.
    end.
    do on error undo:
	prompt-for clase.clacod.
	if input clase.clacod <> 0
	    then do:
	    find clase using clase.clacod.
	    display clase.clanom.
	    wclacod = clase.clacod.
	    end.
    end.
    if not available clase
	then do on error undo:
	prompt-for produ.procod.
	if input produ.procod <> 0
	    then do:
	    find produ using produ.procod.
	    display produ.pronom.
	    find estoq where estoq.etbcod = estab.etbcod
			and estoq.procod = produ.procod no-error.
	    if not available estoq
	      then do:
		message "Registro de Estoque Inexistente.".
		undo.
	      end.
	  end.
    end.
    do on endkey undo, next l1:
	perini = date(01,01,year(today)).
	perfin = today.
	update perini
	       perfin.
	if perfin not entered
	then do:
	   perfin = today.
	   display perfin.
	end.
	if available produ
	then do:
	     for each movim where movim.procod = produ.procod and
				  (movim.etbcod = estab.etbcod or
				  movim.etbdes = estab.etbcod) and
				  movim.movdat >= perini and
				  movim.movdat <= perfin and
				  movim.movtdc < 6:
		 if movtdc = 1
		 then wqcp = wqcp + movqtm.
		 if movtdc = 2
		 then wqcp = wqcp - movqtm.
		 if movtdc = 5
		 then wqvp = wqvp - movqtm.
		 if movtdc = 3 or
		    movtdc = 4
		 then wqvp = wqvp + movqtm.
	    end.
	    display skip(1) space(4) prounven
		    space(5) estatual
		    space(5) wqcp
		    space(5) wqvp
		    space(5) wqvp * 100 / wqcp format "->>9.99 %"
					       label " % Giro"
		    skip(1) with title " Analise do Produto "
				    with frame fdet width 80.
	    wqcp = 0.
	    wqvp = 0.
	end.
	else do:
	    {confir.i 1 "Impressao da Analise de Giro"}
	    assign wfabri  = fabri.fabcod
		   wetb    = estab.etbcod.
	    message "Emitindo Analise de Giro.".
	    run es/anagirli.p.
	    hide message no-pause.
	    message "Emissao de Analise de Giro Encerrada.".
	end.
   end.
end.
