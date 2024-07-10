/*----------------------------------------------------------------------------*/
/* /usr/admcom/co/solic.p                                        Solicitacoes */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 26/02/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var wflag as l.
def buffer wsolic for solic.
def var wcha as c format "x(10)" column-label "Est  Produ".
def var wpdesc as c format "x(60)".
def var wdesrow as i.
def var wetbcod like estab.etbcod.
def var wprocod like produ.procod.
def var wmotcod like motiv.motcod.
repeat with frame f1:
    form estab.etbcod label "Estab." colon 10
	 etbnom at 19 no-label
	 produ.procod colon 10
	 wpdesc at 19 no-label
	 motiv.motcod colon 10
	 motiv.motnom at 19 no-label
	 with frame f1 1 down side-labels width 80.
    do on error undo:
	prompt-for estab.etbcod validate(true,"").
	if estab.etbcod entered or
	   input estab.etbcod <> 0
	    then if input estab.etbcod = 0
		    then display " " @ estab.etbcod
				 " " @ estab.etbnom.
		    else do:
		    find estab using etbcod.
		    display etbnom.
		    wetbcod = estab.etbcod.
		    end.
    end.
    do on error undo:
	prompt-for produ.procod.
	if input produ.procod = 0
	    then display " " @ produ.procod.
	    else do:
	    find produ using produ.procod.
	    find fabri of produ.
	    wpdesc = produ.pronom + "-" + fabfant.
	    display wpdesc.
	    wprocod = produ.procod.
	    end.
    end.
    do on error undo:
	prompt-for motiv.motcod validate(true,"").
	if motiv.motcod entered or
	   input motiv.motcod <> ""
	    then do:
	    find motiv using motcod.
	    display motiv.motnom.
	    wmotcod = motiv.motcod.
	    end.
    end.
    wflag = no.
    l1:
    for each solic where not (available estab and solic.etbcod <> wetbcod) and
			 not (available produ and solic.procod <> wprocod) and
			 not (available motiv and solic.motcod <> wmotcod),
	     produ of solic, fabri of produ
	     break by solic.procod with frame f2 9 down:
	wflag = yes.
	wcha = string(solic.etbcod,">>9 ") +
	       string(solic.procod,">>>>99").
	/*    if not available produ
		then do:
		find produ of solic.
		find fabri of produ.
		release produ.
		end.
		else do:
		find fabri of produ.
		end.               */
	    display wcha help
		"(A) Alteracao,(E) Exclusao,(C) Consulta Estoque,(D) Descricao."
		    produ.pronomc + "-" + fabfant format "x(34)"
					    column-label "Descricao"
		    vencod
		    motcod
		    solqt
		    soldt with width 80.
	if frame-line <> frame-down and
	   not last(solic.procod)
	    then down with frame f2.
	    else if wflag
		then do:
		up frame-line - 1.
/*s*/           status default "(A) Alteracao,(E) Exclusao,(C)" +
/*s*/                          " Consulta Estoque,(D) Descricao.".
		repeat with frame f2 on endkey undo l1, leave l1:
		choose row wcha auto-return go-on(D d C c A a E e PAGE-DOWN).
		hide message no-pause.
		if frame-value = ""
		    then next.
		if lastkey = keycode("D") or
		   lastkey = keycode("d")
		    then do:
		    find produ where produ.procod =
				     integer(substr(frame-value,5,6)).
		    find fabri of produ.
		    if frame-line < 9
			then wdesrow = frame-line + 10.
			else wdesrow = frame-line + 9.
		    display produ.procod
			    produ.pronom no-label
			    fabri.fabcod label "Fabric."
			    fabnom no-label with side-labels row wdesrow
				   column 13 frame fdes overlay.
		    end.
		if lastkey = keycode("e") or
		   lastkey = keycode("E")
		    then do:
		    find wsolic where wsolic.etbcod =
			       integer(substr(frame-value,1,3)) and
			       wsolic.procod = integer(substr(frame-value,5,6)).
		    {exclui.i 1 "Solicitacao"}
		    delete wsolic.
		    clear.
		    scroll from-current up.
		    next.
		    end.
		if lastkey = keycode("a") or
		   lastkey = keycode("A")
		    then do:
		    find wsolic where wsolic.etbcod =
				      integer(substr(frame-value,1,3)) and
			       wsolic.procod = integer(substr(frame-value,5,6)).
		    if wsolic.motcod = "PE"
		      then do:
			message "Pedido ja efetuado p/ Solicitacao."
				"Alteracao negada.".
			undo.
		      end.
		    prompt-for solic.motcod
			       solic.solqt.
		    assign wsolic.motcod = input solic.motcod
			   wsolic.solqt = input solic.solqt.
		next.
		end.
		if lastkey = keycode("c") or
		   lastkey = keycode("C")
		    then do:
		    for each estoq where estoq.procod =
					 integer(substr(frame-value,5,6))
					 break by estoq.procod
				   with frame fest overlay column 24 row 7
				   title " Estoque Global ":
			display space(2) estoq.etbcod column-label "Estab"
				estrep
				estideal
				estatual (total).
		    end.
		    end.
		if lastkey = keycode("PAGE-DOWN") or
		   lastkey = keycode("RETURN") or
		   lastkey = keycode("PF1")
		    then do:
		    clear frame f2 all.
		    leave.
		    end.
		end.
	end.
    end.
    if not wflag
	then message "Nenhuma Solicitacao Encontrada.".
	else message "Consulta Encerrada.".
    clear frame f1.
    release estab.
    release produ.
    release motiv.
end.
