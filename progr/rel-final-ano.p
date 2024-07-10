/* REFERENTE A 2016 - BY LEOTE */

{admcab.i}

def var vetbcod like estab.etbcod.
def var vdti as date format "99/99/9999" init "10/17/2016".
def var vdtf as date format "99/99/9999" init today.

def var vtt-venda as dec.
def var vcatcod as int.
def var vbis as log.
def var vqtd-cup as int format ">>>>>9".
def var vqt-tot as int.
def var varquivo as char.

update vetbcod label "Filial"
    with frame f1 side-label width 80.

/*if vetbcod = 0
then do:
    message "INFORME UMA FILIAL!" view-as alert-box.
	undo, retry.
end.*/
    
update vdti at 1 label "Data inicial"
       vdtf label "Data final"
with frame f1.

if vdti < 10/17/2016
then do:
    message "PROMOCAO INICIADA EM 17/10/2016!" view-as alert-box.
	undo, retry.
end.

if opsys = "UNIX"
then varquivo = "/admcom/relat/rel-final-ano." + string(time).
else varquivo = "l:~\relat~\rel-final-ano." + string(time).

{mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "63" 
        &Cond-Var  = "120"  
        &Page-Line = "66"
        &Nom-Rel   = ""rel-final-ano""  
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO ELDORADO DO SUL"""  
        &Tit-Rel   = """ CUPONS EMITIDOS PROMOCAO FINAL DE ANO 2016 """
        &Width     = "80"
        &Form      = "frame f-cabcab"}

disp with frame f1.
pause 0.

if vetbcod <> 0 then do:

	for each plani where plani.etbcod = vetbcod and
						 plani.pladat >= vdti and
						 plani.pladat <= vdtf and 
						 plani.movtdc = 5 no-lock.

	find clien where clien.clicod = plani.desti no-lock no-error.

	vtt-venda = plani.protot.
	vqtd-cup = 0.

	if vtt-venda >= 200 
	    then do:
	    	vbis = no.
			if plani.pedcod = 	110	or plani.pedcod = 	112	or
			plani.pedcod = 	113	or plani.pedcod = 	115	or
			plani.pedcod = 	116	or plani.pedcod = 	120	or
			plani.pedcod = 	121	or plani.pedcod = 	125	or
			plani.pedcod = 	126	or plani.pedcod = 	310	or
			plani.pedcod = 	312	or plani.pedcod = 	313	or
			plani.pedcod = 	314	or plani.pedcod = 	315	or
			plani.pedcod = 	316	or plani.pedcod = 	317	or
			plani.pedcod = 	318	or plani.pedcod = 	320	or
			plani.pedcod = 	321	or plani.pedcod = 	323	or
			plani.pedcod = 	324	or plani.pedcod = 	325	or
			plani.pedcod = 	326	or plani.pedcod = 	410	or
			plani.pedcod = 	418	or plani.pedcod = 	421	or
			plani.pedcod = 	422	or plani.pedcod = 	613	or
			plani.pedcod = 	614	or plani.pedcod = 	617	or
			plani.pedcod = 	716	or plani.pedcod = 	718	or
			plani.pedcod = 	721	or plani.pedcod = 	722	or
			plani.pedcod = 	723	or plani.pedcod = 	724	or
			plani.pedcod = 	15	or plani.pedcod = 	17	or
			plani.pedcod = 	21	or plani.pedcod = 	24	or
			plani.pedcod = 	42	or plani.pedcod = 	43	or
			plani.pedcod = 	66	or plani.pedcod = 	67	or
			plani.pedcod = 	68	or plani.pedcod = 	69	or
			plani.pedcod = 	76	or plani.pedcod = 	77	or
			plani.pedcod = 	80	or plani.pedcod = 	89	or
			plani.pedcod = 	90	or plani.pedcod = 	91	or
			plani.pedcod = 	98	or plani.pedcod = 	100	or
			plani.pedcod = 	122	or plani.pedcod = 	123	or
			plani.pedcod = 	124	or plani.pedcod = 	200	or
			plani.pedcod = 	201	or plani.pedcod = 	202	or
			plani.pedcod = 	322	or plani.pedcod = 	414	or
			plani.pedcod = 	419	or plani.pedcod = 	424	or
			plani.pedcod = 	426	or plani.pedcod = 	514	or
			plani.pedcod = 	517	or plani.pedcod = 	519	or
			plani.pedcod = 	523	or plani.pedcod = 	524	or
			plani.pedcod = 	525	or plani.pedcod = 	530	or
			plani.pedcod = 	531	or plani.pedcod = 	610	or
			plani.pedcod = 	612	or plani.pedcod = 	717 or
			plani.pedcod = 	610	or plani.pedcod = 	111	or
			plani.pedcod = 	311	or plani.pedcod = 	710	or
			plani.pedcod = 	510	or plani.pedcod = 	612	or
			plani.pedcod = 	714	or plani.pedcod = 	414	or
			plani.pedcod = 	615	or plani.pedcod = 	515	or
			plani.pedcod = 	717	or plani.pedcod = 	417	or
			plani.pedcod = 	720	or plani.pedcod = 	420	or
			plani.pedcod = 	620	or plani.pedcod = 	520	or
			plani.pedcod = 	622	or plani.pedcod = 	522	or
			plani.pedcod = 	626	or plani.pedcod = 	526	or
			plani.pedcod = 	725	or plani.pedcod = 	525
			then vbis = yes.
		end.
	       
	vcatcod = 0.
	vtt-venda = 0.

	for each movim where movim.etbcod = plani.etbcod and
	                     movim.placod = plani.placod and
	                     movim.movtdc = plani.movtdc and
	                     movim.movdat = plani.pladat
	                     no-lock:
							find produ where produ.procod = movim.procod no-lock no-error.
							if not avail produ then next.
							vtt-venda = vtt-venda + (movim.movpc * movim.movqtm).
							if vcatcod = 0
							then vcatcod = produ.catcod.
							if vcatcod = 41 and
	               			produ.catcod = 31
	            			then vcatcod = produ.catcod. 

	vqt-tot = int(substr(string(vtt-venda / 200,">>>9.999"),1,4)).
	if vbis = no 
		then vqtd-cup = vqt-tot.
	else vqtd-cup = vqt-tot * 3. 
	end.

	if vqtd-cup > 0 and avail clien and clien.dtcad = today
		then vqtd-cup = vqtd-cup + 1.

	if vqtd-cup > 0 then
	disp 
		plani.etbcod(count) format ">>>9" column-label "Filial"
		plani.desti format ">>>>>>>>>>9" column-label "Cod. Cliente"
		clien.clinom column-label "Nome cliente"
		plani.numero format ">>>>>>9" column-label "NF"
		plani.serie column-label "Serie"
		plani.pedcod column-label "Plano"
		plani.protot(total) column-label "Total"
		plani.pladat column-label "Data"
		vqtd-cup(total) column-label "Cupons"
		with width 200.
	end.
	output close.

	if opsys = "UNIX"
	then do:
	    run visurel.p(varquivo,"").
	end.
	else do:
	   {mrod.i}
	end.

end.

/*************************************************************************************/

if vetbcod = 0 then do:
	for each plani where plani.etbcod >= 1 and
						 plani.etbcod < 200 and
						 plani.pladat >= vdti and
						 plani.pladat <= vdtf and 
						 plani.movtdc = 5 no-lock.

	find clien where clien.clicod = plani.desti no-lock no-error.

	vtt-venda = plani.protot.
	vqtd-cup = 0.

	if vtt-venda >= 200 
	    then do:
	    	vbis = no.
			if plani.pedcod = 	110	or plani.pedcod = 	112	or
			plani.pedcod = 	113	or plani.pedcod = 	115	or
			plani.pedcod = 	116	or plani.pedcod = 	120	or
			plani.pedcod = 	121	or plani.pedcod = 	125	or
			plani.pedcod = 	126	or plani.pedcod = 	310	or
			plani.pedcod = 	312	or plani.pedcod = 	313	or
			plani.pedcod = 	314	or plani.pedcod = 	315	or
			plani.pedcod = 	316	or plani.pedcod = 	317	or
			plani.pedcod = 	318	or plani.pedcod = 	320	or
			plani.pedcod = 	321	or plani.pedcod = 	323	or
			plani.pedcod = 	324	or plani.pedcod = 	325	or
			plani.pedcod = 	326	or plani.pedcod = 	410	or
			plani.pedcod = 	418	or plani.pedcod = 	421	or
			plani.pedcod = 	422	or plani.pedcod = 	613	or
			plani.pedcod = 	614	or plani.pedcod = 	617	or
			plani.pedcod = 	716	or plani.pedcod = 	718	or
			plani.pedcod = 	721	or plani.pedcod = 	722	or
			plani.pedcod = 	723	or plani.pedcod = 	724	or
			plani.pedcod = 	15	or plani.pedcod = 	17	or
			plani.pedcod = 	21	or plani.pedcod = 	24	or
			plani.pedcod = 	42	or plani.pedcod = 	43	or
			plani.pedcod = 	66	or plani.pedcod = 	67	or
			plani.pedcod = 	68	or plani.pedcod = 	69	or
			plani.pedcod = 	76	or plani.pedcod = 	77	or
			plani.pedcod = 	80	or plani.pedcod = 	89	or
			plani.pedcod = 	90	or plani.pedcod = 	91	or
			plani.pedcod = 	98	or plani.pedcod = 	100	or
			plani.pedcod = 	122	or plani.pedcod = 	123	or
			plani.pedcod = 	124	or plani.pedcod = 	200	or
			plani.pedcod = 	201	or plani.pedcod = 	202	or
			plani.pedcod = 	322	or plani.pedcod = 	414	or
			plani.pedcod = 	419	or plani.pedcod = 	424	or
			plani.pedcod = 	426	or plani.pedcod = 	514	or
			plani.pedcod = 	517	or plani.pedcod = 	519	or
			plani.pedcod = 	523	or plani.pedcod = 	524	or
			plani.pedcod = 	525	or plani.pedcod = 	530	or
			plani.pedcod = 	531	or plani.pedcod = 	610	or
			plani.pedcod = 	612	or plani.pedcod = 	717 or
			plani.pedcod = 	610	or plani.pedcod = 	111	or
			plani.pedcod = 	311	or plani.pedcod = 	710	or
			plani.pedcod = 	510	or plani.pedcod = 	612	or
			plani.pedcod = 	714	or plani.pedcod = 	414	or
			plani.pedcod = 	615	or plani.pedcod = 	515	or
			plani.pedcod = 	717	or plani.pedcod = 	417	or
			plani.pedcod = 	720	or plani.pedcod = 	420	or
			plani.pedcod = 	620	or plani.pedcod = 	520	or
			plani.pedcod = 	622	or plani.pedcod = 	522	or
			plani.pedcod = 	626	or plani.pedcod = 	526	or
			plani.pedcod = 	725	or plani.pedcod = 	525
			then vbis = yes.
		end.
	       
	vcatcod = 0.
	vtt-venda = 0.

	for each movim where movim.etbcod = plani.etbcod and
	                     movim.placod = plani.placod and
	                     movim.movtdc = plani.movtdc and
	                     movim.movdat = plani.pladat
	                     no-lock:
							find produ where produ.procod = movim.procod no-lock no-error.
							if not avail produ then next.
							vtt-venda = vtt-venda + (movim.movpc * movim.movqtm).
							if vcatcod = 0
							then vcatcod = produ.catcod.
							if vcatcod = 41 and
	               			produ.catcod = 31
	            			then vcatcod = produ.catcod. 

	vqt-tot = int(substr(string(vtt-venda / 200,">>>9.999"),1,4)).
	if vbis = no 
		then vqtd-cup = vqt-tot.
	else vqtd-cup = vqt-tot * 3. 
	end.

	if vqtd-cup > 0 and avail clien and clien.dtcad = today
		then vqtd-cup = vqtd-cup + 1.

	if vqtd-cup > 0 then
	disp 
		plani.etbcod(count) format ">>>9" column-label "Filial"
		plani.desti format ">>>>>>>>>>9" column-label "Cod. Cliente"
		clien.clinom column-label "Nome cliente"
		plani.numero format ">>>>>>9" column-label "NF"
		plani.serie column-label "Serie"
		plani.pedcod column-label "Plano"
		plani.protot(total) column-label "Total"
		plani.pladat column-label "Data"
		vqtd-cup(total) column-label "Cupons"
		with width 200.
	end.
	output close.

	if opsys = "UNIX"
	then do:
	    run visurel.p(varquivo,"").
	end.
	else do:
	   {mrod.i}
	end.
end.