{admcab.i}
def var vcomis like plani.platot.
def var varquivo as char format "x(30)".
def var vmoncod like montador.moncod.
def var vetbcod like estab.etbcod.
def var vdti like pedid.peddat.
def var vdtf like pedid.peddat.
repeat:
    vetbcod = setbcod.
    update vetbcod colon 18 with frame f1 side-label centered color white/cyan.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update vmoncod colon 18 with frame f1.
    find first montador where montador.moncod = vmoncod and
			      montador.etbcod = vetbcod no-lock no-error.
    display montador.monnom no-label with frame f1.
    update vdti label "Data Inicial" colon 18
	   vdtf label "Data Final" with frame f1.
    for each montagem where montagem.etbcod = vetbcod and
			    montagem.mondat >= vdti and
			    montagem.mondat <= vdtf and
			    montagem.moncod = montador.moncod
				    no-lock by montagem.mondat.
	    find produ where produ.procod = montagem.procod no-lock.
	    find estoq where estoq.etbcod = vetbcod and
			     estoq.procod = produ.procod no-lock.

	    display montagem.mondat
		    montagem.procod
		    produ.pronom
		    estoq.estvenda
		    montagem.monnf
		    montagem.monser
			    with no-validate
				    frame f3 color black/cyan down centered.
    end.
    message "Deseja Imprimir Listagem" update sresp.
    if not sresp
    then leave.
    varquivo = "..\relat\geral" + string(day(today)).

    {mdadmcab.i
	 &Saida     = "value(varquivo)"
	 &Page-Size = "64"
	    &Cond-Var  = "130"
	    &Page-Line = "66"
	    &Nom-Rel   = ""MONTCON""
	    &Nom-Sis   = """SISTEMA DE RH    "" +
			    estab.etbnom + "" - "" +
			    montador.monnom"
	    &Tit-Rel   = """MONTAGEM POR MONTADOR - PERIODO DE "" +
				  string(vdti,""99/99/9999"") + "" A "" +
				  string(vdtf,""99/99/9999"") "
	    &Width     = "130"
	    &Form      = "frame f-cabcab"}

    for each montagem where montagem.etbcod = vetbcod and
			    montagem.mondat >= vdti and
			    montagem.mondat <= vdtf and
			    montagem.moncod = montador.moncod
				    no-lock by montagem.mondat.
	    find produ where produ.procod = montagem.procod no-lock.
	    find estoq where estoq.etbcod = vetbcod and
			     estoq.procod = produ.procod no-lock.

	    if montagem.monnf = 0
	    then vcomis = estoq.estvenda * 0.02.
	    else vcomis = estoq.estvenda * 0.03.

	    display montagem.mondat
		    montagem.procod
		    produ.pronom
		    estoq.estvenda(total)
		    vcomis(total) column-label "Comissao" format ">>9.99"
		    montagem.monnf
		    montagem.monser
			    with no-validate
				    frame f4 down width 200.
	    vcomis = 0.
    end.
    output close.
    dos silent value("type " + varquivo + "  > prn").



end.
