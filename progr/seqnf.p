{admcab.i}
def var vserie like plani.serie format "x(4)".
def var vetbcod  like estab.etbcod.
def var nu as int.
def var vvlcont as dec format ">>>>>.99".
def var vlannum as int.
def var i       as int.
def var wni     as int.
def var ni      as int.
def var nf      as int.
def var vdt     as date.
def var vdti    as date initial today.
def var vdtf    as date initial today.
def stream sarq.
def var d-dtini     as   date init today                            no-undo.
def var i-nota      like plani.numero                               no-undo.
def var i-seq       as   int format ">>>9"                          no-undo.
repeat:
    for each fatura:
	delete fatura.
    end.

    update vetbcod with frame f1.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update vdti label "Data Inicial" colon 16
	   vdtf label "Data Final" with frame f1 side-label width 80.


    do vdt = vdti to vdtf:
	display vdt label "data"
		    with frame ff1 side-label color message row 7.  pause 0.
	for each plani where plani.movtdc = 5       and
			     plani.etbcod = estab.etbcod and
			     plani.pladat = vdt and
			     plani.notsit  = no no-lock break by plani.crecod
							      by plani.numero:
	    /*
	    find first fatura where fatura.fatnum = plani.numero
							     no-lock no-error.
	    if not avail fatura
	    then do: */
		create fatura.
		assign fatura.fatnum = plani.numero
		       fatura.clicod = plani.placod
		       fatura.fatdat = plani.pladat.
	    /* end. */
	end.
	for each nota where nota.movtdc = 5 and
			    nota.etbcod = estab.etbcod and
			    nota.notdat = vdt no-lock.
		create fatura.
		assign fatura.fatnum = nota.notnum
		       fatura.fatdat = nota.notdat.
	end.
    end.

    hide frame ff1 no-pause.
    for each fatura by fatura.fatnum.
	find first plani where plani.placod = fatura.clicod and
			 plani.etbcod = estab.etbcod no-lock no-error.
	if avail plani
	then vserie = plani.serie.
	else vserie = "NULA".
	display fatura.fatnum
		vserie
		fatura.fatdat
		    with frame ff2 down color white/yellow centered.
    end.
end.
