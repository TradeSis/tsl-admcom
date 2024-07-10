/*
*
*    plani Fiscal de Entrada         -  nfent.p
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," Listagem "].
def var esqcom2         as char format "x(10)" extent 3
	    initial [" Produtos "," Finaliza " ,"" ].
def var esqhel1         as char format "x(12)" extent 5
    initial [" Inclusao  de Nota Fiscal de SAIDA ",
	     " Alteracao da Nota Fiscal de SAIDA ",
	     " Exclusao  da Nota Fiscal de SAIDA ",
	     " Consulta  da Nota Fiscal de SAIDA ",
	     " Listagem "].
def var esqhel2         as char format "x(12)" extent 3
   initial [" Produtos da Nota Fiscal de SAIDA ",
	    " Finaliza a Nota Fiscal de saida ",
	    ""].

{admcab.i}
def input parameter par-movtdc as char.
def buffer bplani           for  plani.
def buffer vplani           for  plani.
def new shared var notori   like plani.numero extent 10.
def var vnumero             like plani.numero.
def var vmovtdc             like plani.movtdc.
def var vserie              like plani.serie.
def var c-munic             like clien.cidade[1] extent 0.
def var c-ufed              like clien.ufecod[1] extent 0.
def var vtotal              like plani.platot.
def var vemitente           like clien.clinom.
def var vok                 as log.
def var vrectit             as recid.
    form
	esqcom1
	    with frame f-com1
		 row 3 no-box no-labels side-labels column 1 centered.
    form
	esqcom2
	    with frame f-com2
		 row screen-lines no-box no-labels side-labels column 1
		 centered.
    assign
	esqregua  = yes
	esqpos1  = 1
	esqpos2  = 1.
    view frame f-com2.

find tipmov where tipmov.movtdc = int(par-movtdc) no-lock.
vemitente = estab.etbnom.

bl-princ:
repeat:
    form
	plani.movtdc column-label "TM"
	plani.emite  column-label "Emite."
	vemitente format "x(15)"
	plani.serie   column-label "Sr"
	plani.numero  column-label "Num"
	plani.desti column-label "Desti."
	clien.clinom    format "x(15)"
	plani.platot
	plani.notsit format "A/F" column-label ""
	with frame frame-a 14 down centered color white/red row 4.
    form
	plani.emite     colon 20
	vemitente       no-label
	plani.desti     colon 20
	clien.clinom         no-label
	plani.serie     colon 20
	plani.numero        label "No."
	plani.pladat        colon 20
	opfis.opfcod        colon 20
	opfis.opfnom        no-label
	plani.crecod        colon 20
	crepl.crenom       no-label
	with frame f-plani1 width 80
	color black/cyan side-label row 4 centered.
    form
	plani.biss
	plani.aliss          label "Al.ISS"
	plani.iss                                                        skip
	plani.vlserv         label "Serviáos"
	plani.descserv       label "Desc.Serv"
	plani.acfserv        label "Acre.Serv"
	plani.bicms
	plani.icms                                                        skip
	plani.bsubst             label "B.Subst"
	plani.icmssubst                                                   skip
	plani.protot             label "Produtos"
	plani.descpro            label "Desc.Prod"
	plani.acfprod            label "Acre.Prod"                        skip
	plani.frete
	plani.seguro                                                      skip
	plani.desacess           label "Desp.Aces."
	plani.ipi
	plani.platot
	with frame f-plani2 width 80 color black/cyan side-label
			row 12 centered title " Valores " 3 column.

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
	find first plani of tipmov where plani.etbcod = setbcod
			   and plani.emite  = estab.etbcod
			       no-lock no-error.
    else
	find plani where recid(plani) = recatu1 no-lock.
    if not available plani
    then do:
	hide frame f-plani1 no-pause.
	hide frame f-plani2 no-pause.
	do on error undo with frame f-plani1:
	    color display messages esqcom1[1]           with frame f-com1.
	    display caps(esqcom1[1]) @ esqcom1[1] with frame f-com1.
	    {notsaib4.in}
	    if recatu2 = ?
	    then undo.
	    find plani where recid(plani) = recatu2 no-lock.
	    find tipmov of plani no-lock.
	    if tipmov.movtlin
	    then do on error undo:
		hide frame f-com1 no-pause.
		hide frame f-com2 no-pause.
		hide frame f-plani1 no-pause.
		hide frame f-plani2 no-pause.
		run notsal.p ( input recid(plani)).
		if not can-find(first movim where movim.etbcod = plani.etbcod
					      and movim.placod = plani.placod)
		then do:
		    delete plani.
		    clear frame f-plani1 all.
		    clear frame f-plani2 all.
		    next.
		end.
		view frame f-com2.
	    end.
	end.
    end.
    clear frame frame-a all no-pause.
    find clien where clien.clicod = plani.desti .
    find tipmov of plani no-lock.
    display
	plani.movtdc
	plani.emite
	vemitente
	plani.serie
	plani.numero
	plani.desti
	clien.clinom
	plani.platot
	plani.notsit
	with frame frame-a 14 down centered color white/red.
    recatu1 = recid(plani).
    color display message
	esqcom1[esqpos1]
	    with frame f-com1.
    repeat:
	find next plani of tipmov where plani.etbcod = setbcod
			  and plani.emite  = estab.etbcod
			      no-lock no-error.
	if not available plani
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	down
	    with frame frame-a.
	find clien where clien.clicod = plani.desti.
	find tipmov of plani no-lock.
	display
	    plani.movtdc
	    plani.emite
	    vemitente
	    plani.serie
	    plani.numero
	    plani.desti
	    clien.clinom
	    plani.platot
	    plani.notsit
	    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:
	find plani where recid(plani) = recatu1 no-lock.

	status default
	    if esqregua
	    then esqhel1[esqpos1] + if esqpos1 > 1
				    then "Numero " + string(plani.numero)
				    else ""
	    else esqhel2[esqpos2] + "Numero " + string(plani.numero) .

	choose field plani.desti help ""
	    go-on(cursor-down cursor-up
		  cursor-left cursor-right
		  page-down   page-up
		  tab PF4 F4 ESC return).

	status default "".

	color display white/red plani.desti.
	if keyfunction(lastkey) = "TAB"
	then do:
	    if esqregua
	    then do:
		color display normal
		    esqcom1[esqpos1]
		    with frame f-com1.
		color display message
		    esqcom2[esqpos2]
		    with frame f-com2.
	    end.
	    else do:
		color display normal
		    esqcom2[esqpos2]
		    with frame f-com2.
		color display message
		    esqcom1[esqpos1]
		    with frame f-com1.
	    end.
	    esqregua = not esqregua.
	end.
	if keyfunction(lastkey) = "cursor-right"
	then do:
	    if esqregua
	    then do:
		color display normal
		    esqcom1[esqpos1]
		    with frame f-com1.
		esqpos1 = if esqpos1 = 5
			  then 5
			  else esqpos1 + 1.
		color display messages
		    esqcom1[esqpos1]
		    with frame f-com1.
	    end.
	    else do:
		color display normal
		    esqcom2[esqpos2]
		    with frame f-com2.
		esqpos2 = if esqpos2 = 6
			  then 6
			  else esqpos2 + 1.
		color display messages
		    esqcom2[esqpos2]
		    with frame f-com2.
	    end.
	    next.
	end.
	if keyfunction(lastkey) = "cursor-left"
	then do:
	    if esqregua
	    then do:
		color display normal
		    esqcom1[esqpos1]
		    with frame f-com1.
		esqpos1 = if esqpos1 = 1
			  then 1
			  else esqpos1 - 1.
		color display messages
		    esqcom1[esqpos1]
		    with frame f-com1.
	    end.
	    else do:
		color display normal
		    esqcom2[esqpos2]
		    with frame f-com2.
		esqpos2 = if esqpos2 = 1
			  then 1
			  else esqpos2 - 1.
		color display messages
		    esqcom2[esqpos2]
		    with frame f-com2.
	    end.
	    next.
	end.
	if keyfunction(lastkey) = "page-down"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find next plani of tipmov where plani.etbcod = setbcod
				  and plani.emite  = estab.etbcod
				      no-lock no-error.
		if not avail plani
		then leave.
		recatu1 = recid(plani).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "page-up"
	then do:
	    do reccont = 1 to frame-down(frame-a):
		find prev plani of tipmov where plani.etbcod = setbcod
				  and plani.emite  = estab.etbcod
				      no-lock no-error.
		if not avail plani
		then leave.
		recatu1 = recid(plani).
	    end.
	    leave.
	end.
	if keyfunction(lastkey) = "cursor-down"
	then do:
	    find next plani of tipmov where plani.etbcod = setbcod
			      and plani.emite  = estab.etbcod
				  no-lock no-error.
	    if not avail plani
	    then next.
	    color display white/red plani.desti.
	    if frame-line(frame-a) = frame-down(frame-a)
	    then scroll with frame frame-a.
	    else down with frame frame-a.
	end.
	if keyfunction(lastkey) = "cursor-up"
	then do:
	    find prev plani of tipmov where plani.etbcod = setbcod
			      and plani.emite  = estab.etbcod
				  no-lock no-error.
	    if not avail plani
	    then next.
	    color display white/red plani.desti.
	    if frame-line(frame-a) = 1
	    then scroll down with frame frame-a.
	    else up with frame frame-a.
	end.
	if keyfunction(lastkey) = "end-error"
	then leave bl-princ.

	if keyfunction(lastkey) = "return"
	then do on error undo:
	    find plani where recid(plani) = recatu1.
	  hide frame frame-a no-pause.
	  clear frame f-plani1 all.
	  clear frame f-plani2 all.
	  if esqregua
	  then do:
	    display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
		with frame f-com1.
	    if esqcom1[esqpos1] = " Inclusao "
	    then do on error undo, retry on endkey undo, leave
			with frame f-plani1.

		{notsaib4.in}
		if recatu2 = ?
		then undo.
		do on error undo:
		    find plani where recid(plani) = recatu2 no-lock .
		    find tipmov of plani no-lock.
		    if tipmov.movtlin
		    then do:
			hide frame f-com1 no-pause.
			hide frame f-com2 no-pause.
			hide frame f-plani1 no-pause.
			hide frame f-plani2 no-pause.
			run notsal.p (input recid(plani)).
			if not can-find
			    (first movim where movim.etbcod = plani.etbcod
					   and movim.placod = plani.placod)
			then do:
			    delete plani.
			    clear frame f-plani1 all.
			    clear frame f-plani2 all.
			    undo bl-princ, retry bl-princ.
			end.
			view frame f-com2.
		    end.
		end.
		recatu1 = recid(plani).
		leave.
	    end.
	    if esqcom1[esqpos1] = " Consulta " or
	       esqcom1[esqpos1] = " Exclusao " or
	       esqcom1[esqpos1] = " Listagem " or
	       esqcom1[esqpos1] = " Alteracao "
	    then do with frame f-plani1.
		{notab4.ico &emite = "ESTAB"}
	    end.
	    if esqcom1[esqpos1] = " Alteracao " /*and
	       plani.notsit                     */
	    then do on error undo, retry on endkey undo, leave
			with frame f-plani1.
		run senha.p (output sresp).
		if sresp
		then do:
		    {notsaib4.in}
		end.
	    end.
	    if esqcom1[esqpos1] = " Exclus∆o "  and
	       plani.notsit
	    then do on error undo, retry on endkey undo, leave
			with frame f-plani1.
		message "Confirma Exclusao de NF" plani.numero update sresp.
		if not sresp
		then undo, leave.
		find next plani of tipmov where plani.etbcod = setbcod
				  and plani.emite  = estab.etbcod
				      no-lock no-error.
		if not available plani
		then do:
		    find plani where recid(plani) = recatu1 no-lock.
		    find prev plani of tipmov where plani.etbcod = setbcod
				      and plani.emite  = estab.etbcod
					  no-lock no-error.
		end.
		recatu2 = if available plani
			  then recid(plani)
			  else ?.
		find plani where recid(plani) = recatu1.
		for each movim where movim.etbcod = plani.etbcod and
				     movim.placod = plani.placod:
		    delete movim.
		end.
		delete plani.
		recatu1 = recatu2.
		leave.
	    end.
	    if esqcom1[esqpos1] = " Listagem "
	    then do with frame f-Lista  row 4 1 column centered.
		message "Confirma Impressao de plani" update sresp.
	    end.
	  end.
	  else do:
	    display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
		    with frame f-com2.
	    if esqcom2[esqpos2] = " Produtos "
	    then do:
		if not tipmov.movtlin
		then do:
		    bell.
		    message "plani Fiscal n∆o possui Produtos".
		    pause.
		end.
		else do:
		    hide frame f-com1 no-pause.
		    hide frame f-com2 no-pause.
		    run notsal.p ( input recid(plani)).
		    if not can-find(first movim
					where movim.etbcod = plani.etbcod
					  and movim.placod = plani.placod)
		    then do on error undo:
			find next plani of tipmov where plani.etbcod = setbcod
					  and plani.emite  = estab.etbcod
					      no-lock no-error.
			if not available plani
			then do:
			    find plani where recid(plani) = recatu1 no-lock .
			    find prev plani of tipmov where
				plani.etbcod = setbcod
					      and plani.emite  = estab.etbcod
						  no-lock no-error.
			end.
			recatu2 = if available plani
				  then recid(plani)
				  else ?.
			find plani where recid(plani) = recatu1.
			for each movim where movim.etbcod = plani.etbcod and
					     movim.placod = plani.placod:
			    delete movim.
			end.
			delete plani.
			recatu1 = recatu2.
			leave.
		    end.
		    view frame f-com2.
		end.
	    end.
	    if esqcom2[esqpos2] = " Finaliza " and
	       plani.notsit
	    then do on error undo:
		run venfecb4.p ( input recid(plani),
				 output vok,
				 output vrectit).
	    end.
	  end.
	end.
	display esqcom1[esqpos1] with frame f-com1.
	display esqcom2[esqpos2] with frame f-com2.
	find clien where clien.clicod = plani.desti.
	find tipmov of plani no-lock.
	display
	    plani.movtdc
	    plani.emite
	    vemitente
	    plani.serie
	    plani.numero
	    plani.desti
	    clien.clinom
	    plani.platot
	    plani.notsit
	    with frame frame-a.
	recatu1 = recid(plani).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
	view frame fc1.
	view frame fc2.
    end.
end.
