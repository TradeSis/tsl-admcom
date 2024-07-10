/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/anafi.p                                  Analise Financeira */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
define new shared variable wclacod like clase.clacod.
define new shared variable wfabri like fabri.fabcod.
define new shared variable wetb like estoq.etbcod.
l1:
repeat with side-labels 1 down width 80 frame f1 title " Dados para Emissao ":
    form skip(1)
	 estab.etbcod colon 19 etbnom at 28 no-label
	 fabri.fabcod colon 19 fabnom at 28 no-label
	 clase.clacod colon 19 clanome at 28 no-label
	 produ.procod colon 19 produ.pronom at 28 no-label skip(1).
    display " " @ clase.clacod
	    " " @ clanome.
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
    if available produ
      then do:
	     view frame fcab.
	     display skip(1) prounven colon 16
		     estatual colon 16 skip(1)
		     estinvctm label "C.Medio" at 3
		     estcusto label "Ult.Custo"
		     estvenda label "Pr.Venda" skip
		     space(2) estinvctm * estatual format ">>>,>>>,>>9.99"
			      label "Total  "
		     space(1) estcusto * estatual format ">>>,>>>,>>9.99"
			      label "Total    "
		     space(1) estvenda * estatual format ">>>,>>>,>>9.99"
			      label "Total   "
		     skip(1) with side-labels title " Analise do Produto "
			       frame fdet width 80.
    end.
    else do:
	 {confir.i 1 "Impressao da Analise Financeira de Estoque"}
	 assign wfabri  = fabri.fabcod
		wetb    = estab.etbcod.
	 message "Emitindo Analise Financeira.".
	 run es/anafinli.p.
	 hide message no-pause.
	 message "Emissao de Analise Financeira Encerrada.".
     end.
end.
