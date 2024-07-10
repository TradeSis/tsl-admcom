/*----------------------------------------------------------------------------*/
/* /usr/admcom/zpedid.p              Zoom de Produtos de Fornecedor p/ Pedido */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
def shared var zcond as i.
def var array as char format "x(64)" extent 13.
def var array-cod as char format "x(10)" extent 13.
def var campo as char format "x(64)".
def var i as i.
def var j as i.
form campo with no-label frame f1 overlay column 15 row 4 title " Opcao ".
form array with no-label frame f2 overlay column 15 title " Produtos ".
view frame f1.
l1:
repeat preselect each produ
		      where can-find(fntos where fntos.fabcod = produ.fabcod and
						 fntos.forcod = zcond),
		      fabri of produ by pronom by fabfant with frame f2:
    do i = 1 to 13:
	find next produ no-error.
	if not available produ
	    then leave.
	array[i] = pronomc + "-" + fabfant.
	array-cod[i] = string(procod).
    end.
    display array.
    display array[1] @ campo with frame f1.
    color display message array[1].
    i = 1.
    prompt-for campo with frame f1 editing:
	color display message array[i].
	if lastkey = keycode("PAGE-DOWN") or
	   lastkey = keycode("PAGE-UP") or
	   lastkey = keycode("CURSOR-DOWN") or
	   lastkey = keycode("CURSOR-UP")
	    then do:
	    next-prompt campo with frame f1.
	    display array[i] @ campo with frame f1.
	    end.
	readkey.
	if lastkey = keycode("CURSOR-RIGHT") or
	   lastkey = keycode("CURSOR-LEFT")
	    then do:
	    bell.
	    next.
	    end.
	color display normal array[i].
	if lastkey = keycode("PAGE-DOWN")
	    then do:
	    if array[13] <> ""
		then do:
		find first produ where pronom + "-" + fabfant > array[13]
				 no-error.
		if available produ
		    then do:
		    array = "".
		    array[1] = pronom + "-" + fabfant.
		    array-cod[1] = string(procod).
		    do i = 2 to 13:
			find next produ no-error.
			if not available produ
			    then leave.
			array[i] = pronom + "-" + fabfant.
			array-cod[i] = string(procod).
		    end.
		    i = 1.
		    display array.
		    next.
		    end.
		end.
	    bell.
	    next.
	    end.
	if lastkey = keycode("PAGE-UP")
	    then do:
	    find last produ where pronom + "-" + fabfant < array[1] no-error.
	    if available produ
		then do:
		array = "".
		array[13] = pronom + "-" + fabfant.
		array-cod[13] = string(procod).
		do i = 12 to 1 by -1:
		    find prev produ no-error.
		    if not available produ
			then next l1.
		    array[i] = pronom + "-" + fabfant.
		    array-cod[i] = string(procod).
		end.
		i = 1.
		display array.
		next.
		end.
	    bell.
	    next.
	    end.
	if lastkey = keycode("CURSOR-UP")
	    then do:
	    if i > 1
		then i = i - 1.
		else do:
		find last produ where pronom + "-" + fabfant < array[i]
				no-error.
		if available produ
		    then do:
		    do i = 13 to 2 by -1:
			array[i] = array[i - 1].
			array-cod[i] = array-cod[i - 1].
		    end.
		    i = 1.
		    array[i] = pronom + "-" + fabfant.
		    array-cod[i] = string(procod).
		    display array.
		    end.
		    else bell.
		end.
	    next.
	    end.
	if lastkey = keycode("CURSOR-DOWN")
	    then do:
	    if i < 13
		then do:
		if array[i + 1] = ""
		    then do:
		    bell.
		    next.
		    end.
		i = i + 1.
		end.
		else do:
		find first produ where pronom + "-" + fabfant > array[i]
				 no-error.
		if available produ
		    then do:
		    do i = 1 to 12:
			array[i] = array[i + 1].
			array-cod[i] = array-cod[i + 1].
		    end.
		    i = 13.
		    array[i] = pronom + "-" + fabfant.
		    array-cod[i] = string(procod).
		    display array.
		    end.
		    else bell.
		end.
	    next.
	    end.
	if lastkey = keycode("RETURN") or
	   lastkey = keycode("PF1")
	    then leave l1.
	apply lastkey.
	if input campo >= array[1] and input campo <= array[13]
	    then do:
	    do j = 1 to 13:
		if array[j] begins input campo
		    then leave.
	    end.
	    if j <> 14
		then do:
		i = j.
		next.
		end.
	    end.
	    else do:
	    find first produ where pronom + "-" + fabfant begins input campo
			     no-error.
	    if available produ
		then do:
		array = "".
		array[1] = pronom + "-" + fabfant.
		array-cod[1] = string(procod).
		do i = 2 to 13:
		    find next produ no-error.
		    if not available produ
			then leave.
		    array[i] = pronom + "-" + fabfant.
		    array-cod[i] = string(procod).
		end.
		i = 1.
		display array.
		next.
		end.
	    end.
    bell.
    message "Nenhuma ocorrencia com esta iniciais.".
    apply keycode("BACKSPACE").
    end.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
if lastkey <> keycode("PF4")
    then frame-value = array-cod[i].
