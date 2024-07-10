/*    Emite Plani Fiscal de Sa¡da   -    emitnf.p                            */
{admcab.i}

def input param  par-rec     as recid.
def output param par-ok      as log.
par-ok = no.

def stream saida.

def buffer bplani for plani.
def buffer cplani for plani.
def buffer bmovim for movim.
def buffer bfunc    for func.
def var recatu2 as recid.
def var vcrecod    like crepl.crecod.
def var vtotal      like Plani.platot.
def var vsubtot     like Plani.platot.
def var vtotpar     like Plani.platot.
def var vtotfin     like Plani.platot.
def var vacfin      like Plani.platot.
def var vnottot     like Plani.platot.
def var vbaseicms   like Plani.bicms.
def var vtot        like plani.platot.
def var vad         like movim.movacfin.
def var vicms       like Plani.icms.
def var vctm        like Plani.cusmed.
def var vtotmov     like movim.movicms.
def var vvalpar     like Plani.platot extent 24.
def var vplacod     like Plani.placod.
def var vnumero     like plani.numero.
def var valicms     as dec.
def var vmeddia     as dec.
def var vmens       as char format "x(20)".
def var i           as int.
def var vdeve       like plani.platot.
def var vsen        as int.
def var vend        as logical format "Sim/Nao".
def var vatraso     as log.

find plani where recid(plani) = par-rec.
find tipmov of plani.

form clien.clicod   colon 20
     clien.clinom             no-label
     crepl.crecod  colon 20 label "Plano de Cr‚dito"
     crepl.crenom           no-label
     func.funcod   colon 20 label "Vendedor"
     func.funnom   no-label
     Plani.Platot  colon 20
     with frame f-Plani1 centered color black/cyan side-label row 9 overlay.
def shared frame f-subcab.
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
pause 0.
do on error undo with frame f-Plani1:
    find clien where clien.clicod = plani.desti no-lock.
    find func where func.funcod = plani.vencod no-lock.
    find crepl where crepl.crecod = plani.crecod no-lock.
    plani.protot = 0.
    for each movim  of plani:
	plani.protot = plani.protot +
			    (movim.movqtm * (movim.movpc - movim.movdes)).
    end.
    plani.platot = plani.protot.

    display
	plani.desti @ clien.clicod
	clien.clinom
	plani.protot @ Plani.platot
	plani.crecod @ crepl.crecod
	crepl.crenom
	plani.vencod @ func.funcod
	func.funnom.
    do on endkey undo on error undo :
	prompt-for plani.numero
		   with frame f-subcab.
	prompt-for plani.serie
		   with frame f-subcab.

	find bplani where bplani.movtdc = plani.movtdc and
			  bplani.emite  = plani.emite  and
			  bplani.numero = input plani.numero and
			  bplani.serie  = input plani.serie no-lock no-error.
	if avail bplani
	then do on endkey undo:
	    message "Nota Fiscal Ja Cadastrada".
	    pause.
	    undo.
	end.
	bell.
	pause 2 no-message.
	sresp = no.
	message "Confirma o Numero da Nota ?" update sresp.
	if sresp = no
	then undo.
    end.

    vtotpar = vsubtot + if vacfin >= 0
			then vacfin
			else 0.
    /*
    if vacfin >= 0
    then display vacfin       @ Plani.acfprod.
    else display vacfin * -1  @ Plani.descprod.
	display
	    plani.protot
	    vtotpar.
    do on endkey undo, return:
	prompt-for Plani.descprod.
	pause 3 no-message.
	vtotal = plani.protot - input Plani.descprod +
		 /*(if input Plani.respfre then 0 else input Plani.frete) +
		 input Plani.seguro + */ input Plani.acfprod.
	if vtotal < 0
	then do:
	    bell.
	    message "Desconto nÆo pode ser maior que o valor da Plani Fiscal".
	    pause.
	    undo.
	end.
    end.
   assign
	   Plani.descprod    = input Plani.descprod
	   Plani.acfprod    = vacfin.

    */
    assign
	Plani.ufemi = "RS"
	Plani.ufdes = clien.ufecod[1].

    assign Plani.usercod     = userid("ger")
	   Plani.dtinclu     = today
	   Plani.horincl     = time
	   Plani.notfat      = clien.clicod
	   /*Plani.notobs[1]   = input Plani.notobs[1]
	   Plani.notobs[2]   = input Plani.notobs[2]
	   Plani.notobs[3]   = input Plani.notobs[3]
	   Plani.respfre     = input Plani.respfre
	   Plani.notped      = input Plani.notped*/
	   Plani.serie       = input plani.serie
	   plani.numero      = input plani.numero.

    vatraso = no.
    for each titulo where titulo.clifor     = clien.clicod no-lock:
	if titulo.titnat = no and
	  (titulo.titsit = "IMP" or
	   titulo.titsit = "LIB")
	then do:
	    vdeve = vdeve + titulo.titvlcob.
	if titulo.titdtven < today
	then
	    vatraso = yes.
	end.
    end.

    if (plani.platot + vdeve > clien.limcrd or
	vatraso              = yes) and
	plani.crecod > 1
    then do:
	bell.
	hide frame f-plani1 no-pause.
	pause 0.
	if vatraso
	then
	    display skip(1)
		" Cliente com Parcelas Atrasadas "
		skip
		with frame fpend overlay
		     centered color white/red row 9 .
	if plani.platot + vdeve > clien.limcrd
	then
	    display
		" Limite de Credito Ultrapassado "
		skip(1)
		with frame fpend.

	    pause 0.
	if plani.platot + vdeve > clien.limcrd
	then
	    display plani.platot    column-label "Total Nota"
		    vdeve           column-label "Total Devido"
		    clien.limcrd    column-label "Limite"
		    with frame fdeve overlay row 14 color white/cyan centered
			title "LIMITE DE CREDITO".
	 pause 0.
	run senha.p (output sresp).
	if not sresp
	then undo, leave.
    end.
    hide frame fpend  no-pause.
    hide frame fdeve  no-pause.

    for each movim of plani:
	find produ of movim no-lock.
	assign vtotmov      =  movim.movqtm * movim.movpc
	       /*movim.movacfin = round((vtotmov / plani.platot) *
				    (vacfin - Plani.descprod),3)*/
	       vad          =  vad + movim.movacfin
	       vnottot      =  vnottot + vtotmov + movim.movacfin
	       Plani.cusmed  =  Plani.cusmed + (movim.movqtm * movim.movctm).

	/*if opcom.opctrib
	then do:*/
	    find first tribu where  tribu.ufemi    = Plani.ufemi
			       and  tribu.ufdes    = Plani.ufdes
			       and  tribu.procod   = movim.procod
			       and  tribu.dtivig  <= today
			       and (tribu.dtfvig  >= today or
				    tribu.dtfvig   = ?)
				    no-lock no-error.
	    if not avail tribu
	    then do:
		find first tribu where  tribu.ufemi    = Plani.ufemi
				   and  tribu.ufdes    = Plani.ufdes
				   and  tribu.procod   = 0
				   /*and  tribu.dtivig  <= today
				   and (tribu.dtfvig  >= today or
					tribu.dtfvig   = ?)*/
					no-lock no-error.
		if not avail tribu
		then do:
		    bell.
		    message
			"NÆo existe Tributa‡Æo Cadastrada para relacionamento".
		    message "entre " Plani.ufemi " e  " Plani.ufdes.
		    pause.
		    undo, return.
		end.
	    end.
	    /*if agcom.indctr
	    then */
	    movim.movalicms = tribu.contr.
	    /*else movim.movalicms = tribu.ncontr.*/

	    assign vbaseicms      = (vtotmov + movim.movacfin) *
				    ( /*if opcom.opcred
				     then (1 - (opcom.opcper / 100))
				     else */ 1)
		   Plani.bicms     = Plani.bicms + vbaseicms
		   movim.movicms = vbaseicms * movim.movalicms / 100
		   Plani.icms      = Plani.icms + movim.movicms.
	/*end.*/
	run atuest.p (input recid(movim)).
    end.

    /*if Plani.platot <> (vnottot + Plani.seguro + Plani.frete)
    then do:
	find first bmovim where bmovim.numero = plani.numero.
	movim.movacfin = movim.movacfin + (Plani.notvl - vnottot - nota.seguro -
				       Plani.frete).
    end.
    */

    find metven where
	    metven.etbcod = plani.etbcod and
	    metven.funcod = 0 and
	    metven.mescomp = month(plani.pladat) and
	    metven.anocomp = year(plani.pladat) no-error.
    if not available metven
    then create metven.
    assign
	metven.etbcod = plani.etbcod
	metven.funcod = 0
	metven.mescomp = month(plani.pladat)
	metven.anocomp = year(plani.pladat)
	metven.vlreal[day(plani.pladat)]  = metven.vlreal[day(plani.pladat)] +
							    plani.platot.
    find metven where
	    metven.etbcod = plani.etbcod and
	    metven.funcod = plani.vencod and
	    metven.mescomp = month(plani.pladat) and
	    metven.anocomp = year(plani.pladat) no-error.
    if not available metven
    then create metven.
    assign
	metven.etbcod = plani.etbcod
	metven.funcod = plani.vencod
	metven.mescomp = month(plani.pladat)
	metven.anocomp = year(plani.pladat)
	metven.vlreal[day(plani.pladat)]  = metven.vlreal[day(plani.pladat)] +
							plani.platot.

end.
hide frame f-Plani1 no-pause.
do transaction:
    plani.notsit = no.
end.
hide frame fpend  no-pause.
hide frame fdeve  no-pause.
par-ok = yes.
