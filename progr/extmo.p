/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/extmo.p                             Extrato de Movimentacao */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var perini as date format "99/99/9999".
def var perfin as date format "99/99/9999".
def var doctype as char extent 8 label "Tipo"
    initial ["NFFOR","NFDVC","NFVCL","NFVCO","NFDVV","NFTRA","PLENT","PLSAI"].
def var wtotin as dec format ">>,>>>,>>>,>>9.99" label "Total Entradas".
def var wtotout as dec format ">>,>>>,>>>,>>9.99" label "Total Retiradas".
def var woper as log format "Entr./Saida" label "Oper.".
def var descrc as c format "x(52)".
l1:
repeat with side-labels 1 down width 80 frame f1:
    form estab.etbcod colon 17 etbnom at 26 no-label
	 produ.procod colon 17 descrc no-label
	 perini label "Periodo" colon 17
	 " A " perfin no-label.
    wtotin = 0.
    wtotout = 0.
    prompt-for estab.etbcod.
    find estab using etbcod.
    display etbnom.
    prompt-for produ.procod.
    find produ using produ.procod.
    find fabri of produ.
    display pronom + "-" + fabfant @ descrc.
    find estoq where estoq.etbcod = estab.etbcod
		 and estoq.procod = produ.procod no-error.
    if not available estoq
    then do:
	   message "Registro de Estoque Inexistente.".
	   undo.
    end.
    prompt-for perini validate(perini entered,"Data Inicial Obrigatoria.")
	       perfin.
    if perfin not entered
    then do:
	   perfin = today.
	   display perfin.
    end.
    for each movim where (movim.etbcod = estab.etbcod or
			  movim.etbdes = estab.etbcod)
		     and movim.procod = produ.procod
		     and movim.movdat >= input perini
		     and movim.movdat <= input perfin
		     with width 80 title " Movimentos ":
	 if movtdc = 1 or
	    movtdc = 5 or
	    movtdc = 7 or
	    (movtdc = 6 and
	    movim.etbdes = estab.etbcod)
	    then do:
		woper = yes.
		wtotin = wtotin + movqtm.
	    end.
	    else do:
		woper = no.
		wtotout = wtotout + movqtm.
	    end.
	 find nota where nota.movndc = movim.movndc
		     and nota.movsdc = movim.movsdc
		     and nota.etbcod = estab.etbcod
		     and nota.movtdc = 2
			 no-error .

	 display space(1) if avail nota
			  then nota.notnum
			  else movim.movndc  @ movim.movndc
		 space(1) if avail nota
			  then nota.notser
			  else movim.movsdc  @ movim.movsdc.
	 if movim.clifor > 0
	     then display space(1) movim.clifor.
	 display space(2) movim.movdat
		 space(1) woper
		 space(2) doctype[movim.movtdc]
		 space(2) movim.movqtm
		 space(1) movim.movpc.
    end.
    display skip(1) space(2) wtotin
	    skip(1) space(2) wtotout skip(1)
	    with frame ftots title " Quantidade - Totais "
		       side-labels overlay row 14 column 42.
    message "Extrato de Movimento Encerrado.".
end.
