/*****************************************************************************
**  Programa         : venlojb4
**  Ultima Alteracao : 25/09/95
**
*****************************************************************************/
{admcab.i}

def input parameter     vmovtdc as char initial 5.
def var vrectit         AS RECID.
def var recatu1         as recid.
def var recatu2         as recid.
def var r-regno         as recid                                no-undo.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
  initial [" Fechamento "," Inclusao "," Alteracao "," Exclusao "," Consulta "].

def var esqcom2         as char format "x(12)" extent 5
	    initial [" "," ","","",""].
def buffer bmovim       for movim.
def buffer bplani       for plani.
def buffer bestoq       for estoq.
def buffer bfunc        for func.

def var vpar as char.
def var vsenha          like func.senha.
def var vsen            as   int.
def var vmovseq         like movim.movseq.
def var totpro          like Plani.PlaTot.
def var vqtd            like movim.movqtm.
def var vunid           like movim.movqtm.
def var vunit           like Plani.PlaTot.
def var vprotot         like Plani.PlaTot.
def var vprocod         like produ.procod.
def var vclacod         like clase.clacod.
def var vprocla         like produ.procla.
def var i               as int.
def var vseq            like movim.movseq.
def var vmovqtm         like movim.movqtm.
def var vcont           as int.
def var vrecClF         as recid.
def var vpercdes        as dec format ">>9.99%" label "Desc".
def var vok             as log.
def buffer bclien       for clien.
def buffer bmoeda       for moeda.
def var vsaldo          like salcxa.saldo.
def var vevecod         like event.evecod.
DEF VAR VDIVIDA         LIKE TITULO.TITVLCOB.
def var vplacod         like plani.placod.
def var vi              as int.
def var par-sel as char initial "m".

form vmovqtm label "Quantidade de Produtos"
     plani.platot label "Total da Venda " to 75
     with frame f-subtot centered row 20 width 78 overlay no-box
			      side-labels 1 down color message.
form esqcom1 with frame f-com1
	     row screen-lines - 1
	     no-labels side-labels column 1 centered no-box.
form esqcom2 with frame f-com2
	     row 9 no-labels side-labels column 1 centered no-box.
form
      "Produto:"         at  8
      produ.procod       no-label            help "C¢digo do Produto"
      vprocla            help "Classifica‡Æo ou Cor"
      produ.pronom       format "x(25)"              skip
     "Quantidade:"       at  5
      movim.movqtm       to 30                       skip
     "Pre‡o Unit rio:"
      movim.movpc        to 30                       skip
     "Pre‡o Total:"      at  4
      vprotot            to 30
      with frame f-linha centered color black/cyan row 4 no-label overlay
			 width 78.


def new shared frame f-subcab.
form
     crepl.crecod   colon 11 label "Pl.Credito"
     crepl.crenom         no-label
     clien.clicod   colon 11 label "Cliente" help "Codigo do Cliente"
     clien.clinom         no-label                     skip
     func.funcod             label "Vendedor"  colon 11 help "Digite seu Codigo"
     func.funnom          no-label
     plani.numero            label "Nota"
     plani.serie             label "Ser"
     with frame f-subcab color message side-label overlay centered
			 row 4 width 80.
find caixa where
     caixa.etbcod = setbcod and
     caixa.cxacod = scxacod no-lock.
if  caixa.cxdata > today then do on endkey undo:
    message "Data da Maquina Incorreta".
    pause.
    return.
end.
if  caixa.cxdata  < today and
    caixa.situacao = yes   then do on endkey undo:
    bell.
    message "Caixa Nao Foi Fechada no dia Anterior".
    pause.
    return.
end.
if  caixa.cxdata  <= today and
    caixa.situacao = no then do:
    message "Caixa Fechado. Deseja Abrir ?" update sresp.
    if  sresp then
	run abrecxa.p.
    else return.
end.
if  caixa.cxdata  <= today and
    caixa.situacao = no    then
    return.

find tipmov where
     tipmov.movtdc = int(vmovtdc) no-lock.
repeat:
    ASSIGN
	recatu1  = ?
	esqregua = yes
	esqpos1  = 2
	esqpos2  = 1.
    clear frame f-subcab all.
    prompt-for crepl.crecod
	       with frame f-subcab.
    find crepl using crepl.crecod no-lock.
    display crepl.crenom with frame f-subcab.
    if crepl.crecod = 2
    then do:
	prompt-for clien.clicod
	    with frame f-subcab.
	find clien where clien.clicod = input clien.clicod no-lock no-error.
	if  not avail clien
	then do on error undo:
	    message "cliente nao cadastrado".
	    next.
	    /*
	    run Cliout.p (input-output vrecClF).
	    find clien where recid(clien) = vrecClF.
	    */
	end.
	display clien.clinom with frame f-subcab.
	find first titulo where titulo.clifor    = clien.clicod and
			       (titulo.titsit    = "LIB" or
				titulo.titsit    = "IMP") and
				titulo.titnat    = no  and
				titulo.titdtven <= today no-lock no-error.
	if avail titulo
	then
	    run cotitb4.p (input recid(clien)).
    end.
    else
	find clien where clien.clicod = 1 no-lock.
bl-vend:
repeat:
    prompt-for func.funcod with frame f-subcab.
    find func using func.funcod no-lock no-error.
    if  not avail func then do:
	message "Funcionario Invalido".
	undo.
    end.
    display func.funnom
	    with frame f-subcab.

    find estab where estab.etbcod  = setbcod no-lock no-error.
    do for bplani on endkey undo, leave:
       find last bplani where
		 bplani.etbcod =  estab.etbcod and
		 bplani.placod <> ? exclusive-lock no-error.
       assign vplacod = if  available bplani then
			    bplani.placod + 1 else 1.
    end.
    do on error undo:
       create plani.
       assign
	   plani.etbcod  = estab.etbcod
	   plani.placod   = vplacod
	   plani.cxacod = scxacod.
       assign
	   plani.movtdc   = tipmov.movtdc
	   plani.emite    = estab.etbcod
	   plani.desti    = clien.clicod
	   plani.Vencod   = func.funcod
	   plani.pladat   = today
	   plani.crecod   = crepl.crecod
	   plani.modcod   = tipmov.modcod
	   r-regno        = recid(plani).
    end.
    find plani where
	 plani.etbcod = estab.etbcod and
	 plani.placod = vplacod.
    find tipmov of plani no-lock.
    display plani.platot with frame f-subtot.
    bl-princ:
    repeat:
	form produ.procod column-label "Cod."
	     produ.pronom format "x(20)"
	     movim.movqtm column-label "Qtd"
	     movim.movpc  column-label "Preco" format ">,>>9.99"
	     vpercdes     column-label "Desc"
	     vprotot      column-label "Total"
	     with frame frame-a 6 down centered color white/red row 10 width 78.
	display esqcom1 with frame f-com1.
	display esqcom2 with frame f-com2.
	if  recatu1 = ? then
	    find first movim of plani no-error.
	else
	    find movim where recid(movim) = recatu1.
	if  not available movim then do:
	    color display messages esqcom1[esqpos1] with frame f-com1.
	    display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1] with frame f-com1.
	    do  with frame frame-a on endkey undo, leave.
		clear frame f-linha all.
		assign vclacod = 0 vprocod = 0.
		{venlojb4.in}
		down with frame frame-a.
	    end.
	    if  not can-find(first movim of plani) then do:
		hide frame f-linha no-pause.
		hide frame f-com1  no-pause.
		undo bl-princ, leave bl-princ.
	    end.
	    color display normal esqcom1[esqpos1] with frame f-com1.
	    esqpos1 = 1.
	    next.
	end.
	clear frame frame-a all no-pause.
	find produ of movim no-lock.
	vprotot  = movim.movqtm * (movim.movpc - movim.movdes).
	vpercdes = movim.movdes / movim.movpc * 100.
	display
	    produ.procod
	    produ.pronom
	    movim.movqtm
	    movim.movpc
	    vpercdes
	    vprotot
	    with frame frame-a.
	recatu1 = recid(movim).
	find movim where recid(movim) = recatu1.
	display esqcom1[esqpos1] with frame f-com1.
	color display message esqcom1[esqpos1] with frame f-com1.
	repeat:
	    find next movim of plani no-error.
	    if  not available movim then
		leave.
	    if  frame-line(frame-a) = frame-down(frame-a) then
		leave.
	    down with frame frame-a.
	    find produ of movim no-lock.
	    vprotot = movim.movqtm * (movim.movpc - movim.movdes).
	    vpercdes = movim.movdes / movim.movpc * 100.
	    display
		produ.procod
		produ.pronom
		movim.movqtm
		movim.movpc
		vprotot
		with frame frame-a.
	end.
	up frame-line(frame-a) - 1 with frame frame-a.
	display plani.platot with frame f-subtot.
	repeat with frame frame-a:
	    find movim where recid(movim) = recatu1.
	    find produ of movim.
	    disp produ.procod with frame frame-a.
	    choose field produ.procod
	    go-on(cursor-down cursor-up
		  cursor-left cursor-right
		  page-down   page-up TAB
		  PF4 F4 ESC return).
	    color display white/red produ.procod.
	    if  keyfunction(lastkey) = "TAB" then do:
		if  esqregua then do:
		    color display normal  esqcom1[esqpos1] with frame f-com1.
		    color display message esqcom2[esqpos2] with frame f-com2.
		end.
		else do:
		    color display normal  esqcom2[esqpos2] with frame f-com2.
		    color display message esqcom1[esqpos1] with frame f-com1.
		end.
		esqregua = not esqregua.
	    end.
	    if  keyfunction(lastkey) = "cursor-right" then do:
		if  esqregua then do:
		    color display normal  esqcom1[esqpos1] with frame f-com1.
		    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
		    color display messages esqcom1[esqpos1] with frame f-com1.
		end.
		else do:
		    color display normal  esqcom2[esqpos2] with frame f-com2.
		    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
		    color display messages esqcom2[esqpos2] with frame f-com2.
		end.
		next.
	    end.
	    if  keyfunction(lastkey) = "cursor-left" then do:
		if  esqregua then do:
		    color display normal  esqcom1[esqpos1] with frame f-com1.
		    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
		    color display messages esqcom1[esqpos1] with frame f-com1.
		end.
		else do:
		    color display normal  esqcom2[esqpos2] with frame f-com2.
		    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
		    color display messages esqcom2[esqpos2] with frame f-com2.
		end.
		next.
	    end.
	    if  keyfunction(lastkey) = "page-down" then do:
		do reccont = 1 to frame-down(frame-a):
		    find next  movim of plani no-error.
		    if  not avail movim then
			leave.
		    recatu1 = recid(movim).
		end.
		leave.
	    end.
	    if  keyfunction(lastkey) = "page-up" then do:
		do  reccont = 1 to frame-down(frame-a):
		    find prev  movim of plani no-error.
		    if  not avail movim then
			leave.
		    recatu1 = recid(movim).
		end.
		leave.
	    end.
	    if  keyfunction(lastkey) = "cursor-down" then do:
		find next  movim of plani no-error.
		if  not avail movim then
		    next.
		color display white/red produ.procod.
		if  frame-line(frame-a) = frame-down(frame-a) then
		    scroll with frame frame-a.
		else
		    down with frame frame-a.
	    end.
	    if  keyfunction(lastkey) = "cursor-up" then do:
		find prev  movim of plani no-error.
		if  not avail movim then
		    next.
		color display white/red produ.procod.
		if  frame-line(frame-a) = 1 then
		    scroll down with frame frame-a.
		else
		    up with frame frame-a.
	    end.
	    if  keyfunction(lastkey) = "end-error" then do:
		hide frame frame-a no-pause.
		hide frame f-subtot no-pause.
		bell. bell.
		leave bl-princ.
	    end.
	    if  keyfunction(lastkey) = "return" then do on error undo, retry:
		hide frame frame-a no-pause.
		clear frame f-linha all.
		if  esqregua then do:
		    display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
			with frame f-com1.
		if  esqcom1[esqpos1] = " Inclusao " and
		    par-sel          = "m"  then do:
		    clear frame frame-a all no-pause.
		    do with frame frame-a on endkey undo, leave.
			{venlojb4.in}
			display vmovqtm plani.platot with frame f-subtot.
			recatu1 = recid(movim).
			down with frame frame-a.
		    end.
		    if  not can-find(first movim of plani) then do:
			hide frame f-linha no-pause.
			hide frame f-com1  no-pause.
			undo, leave.
		    end.
		    leave.
		end.
		if  esqcom1[esqpos1] = " Consulta " or
		    esqcom1[esqpos1] = " Exclusao " or
		    esqcom1[esqpos1] = " Listagem " or
		    esqcom1[esqpos1] = " Alteracao " then do with frame f-linha.
		    clear frame f-linha all.
		    find produ of movim no-lock.
		    find fabri of produ no-lock.
		    assign vprocla = if  produ.procla <> "" then
					 produ.procla
				     else produ.corcod.
		    display fabri.fabcod
			    fabri.fabnom
			    produ.procod
			    vprocla
			    produ.pronom
			    movim.movqtm
			    movim.movpc
			    vprotot.
		    display vmovqtm plani.platot with frame f-subtot.
		end.
		if  esqcom1[esqpos1] = " Alteracao " and
		    par-sel = "m"      then do with frame frame-a on error undo:
		/*
		    find estoq  where
		      estoq.procod = movim.procod and
		      estoq.etbcod  = movim.etbcod no-error.
		    assign  estoq.estatual =  estoq.estatual +  movim.movqtm
		*/
		    assign plani.platot   =  plani.platot   - (movim.movqtm *
							     movim.movpc)
			 vmovqtm        = vmovqtm - movim.movqtm.
		/*{buspro.i &Frame = "f-linha"}*/
		    assign movim.procod = produ.procod.
		    disp movim.movqtm.
		    update movim.movpc.
		/*
		    find estoq  where
			 estoq.procod = movim.procod and
			 estoq.etbcod  = movim.etbcod no-error.
		    if  not available estoq then do:
			bell.
			message "Produto sem Estoque".
			pause.
			undo.
		    end.
		    if  estoq.estatual < movim.movqtm then do:
			bell.
			message "Estoque dispon¡vel ‚ de " estoq.estatual.
			pause.
			undo.
		    end.
		    assign  estoq.estatual =  estoq.estatual - movim.movqtm
			/*  estoq.estreser =  estoq.estreser + movim.movqtm*/ .
		*/
		    assign vprotot      = movim.movqtm * movim.movpc
			   plani.platot = plani.platot + vprotot
			 vmovqtm        = vmovqtm + movim.movqtm.
		    display movim.movpc
			  vprotot.
		    display vmovqtm plani.platot with frame f-subtot.
		    pause 0.
		    leave.
		end.
		if  esqcom1[esqpos1] = " Exclusao " and
		    par-sel = "m"                   then do
		    with frame f-exclui on endkey undo, leave.
		    vcont = 0.
		    for each bmovim of plani no-lock:
			vcont = vcont + 1.
		    end.
		    if  vcont = 1 then do:
			bell.
			message
		     "Este ‚ o ultimo produto. Confirma exclusao da Requisi‡Æo"
			update sresp.
			if  not sresp then
			    undo, leave.
		    end.
		    else do:
		    message "Confirma Exclusao de" movim.movseq update sresp.
		    if  not sresp then
			undo, leave.
		end.
		find next movim of plani no-error.
		if  not available movim then do:
		    find movim where recid(movim) = recatu1.
		    find prev movim of plani no-error.
		end.
		recatu2 = if  available movim then
			      recid(movim)
			  else ?.
		find movim  where recid(movim) = recatu1.
		find estoq  where
		     estoq.procod = movim.procod and
		     estoq.etbcod  = movim.etbcod no-error.
		assign  estoq.estatual =  estoq.estatual +  movim.movqtm
			/*estoq.estreser =  estoq.estreser -  movim.movqtm*/
			plani.platot   =  plani.platot   - (movim.movqtm *
							    movim.movpc).
		recatu1 = recatu2.
		vseq = 0.
		for each bmovim of plani:
		    assign vseq          = vseq + 1
			   bmovim.movseq = vseq.
		end.
		if  vseq = 0 then
		    return.
		clear frame f-linha  all.
		clear frame f-subtot all.
		hide  frame f-linha  no-pause.
		hide  frame f-subtot no-pause.
		leave .
	    end.
	    if  esqcom1[esqpos1] = " Fechamento " then do
		with frame f-Lista overlay row 4 1 column centered.
		hide frame f-subtot no-pause.
		run venfecb4.p ( input recid(plani), output vok).
		if  plani.crecod = 1 then do:
		    run gertitb4.p   (input recid(plani)).
		end.
		find event of tipmov no-lock.
		view frame f-subcab.
		recatu1 = ?.
		disp "Nota Fiscal Encerrada"
		    with centered frame f
			 color messages.
		leave  bl-princ.
	    end.
	end.
	else do:
	    display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
		    with frame f-com2.
	    if  esqcom2[esqpos2] = " Contrato " then do:
		hide frame f-com1 no-pause.
		hide frame f-com2 no-pause.
		vpar = "5" + string(recid(clien)).
		run escsai.p (input vpar).
		view frame f-subcab.
		view frame f-com1.
		view frame f-com2.
	    end.
	    if  esqcom2[esqpos2] = " Caixa " then do:
		hide frame f-com1 no-pause.
		hide frame f-com2 no-pause.
		run titcxab4.p (input string(recid(clien))).
		view frame f-subcab.
		view frame f-com1.
		view frame f-com2.
	    end.
	end.
	end.
	if  keyfunction(lastkey) = "end-error" then
	    view frame frame-a.
	find produ of movim no-lock.
	vprotot = movim.movqtm * (movim.movpc - movim.movdes).
	vpercdes = movim.movdes / movim.movpc * 100.
	display
		produ.procod
		produ.pronom
		movim.movqtm
		movim.movpc
		vpercdes
		vprotot       with frame frame-a.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	else display esqcom2[esqpos2] with frame f-com2.
	recatu1 = recid(movim).
   end.
end.
if  plani.numero = ? then do:
    delete plani.
    leave bl-vend.
end.
end.
vpar = "5" + string(recid(clien)).
message "Fim da Nota".
pause 2 no-message.
run escsaib4.p(input vpar).
run titcxab4.p(input string(recid(clien))).
end.
hide frame f-subcab no-pause.
hide frame f-subtot no-pause.
hide frame f-linha  no-pause.
hide frame frame-a  no-pause.
pause 0.
