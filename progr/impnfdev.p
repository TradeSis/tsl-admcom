{admcab.i}
def var i as i.
def var vimp_cab    as log no-undo.
def var vsub-total  like titulo.titvlcob no-undo.
def input parameter par-rec as recid.
def var recatu2             as recid.
def var contlin             as int.
def var vserviss            as dec format "zz,z99.99".
def var vrespfre            as int format "9".
def var vtitnum             like titulo.titnum extent 4 initial 0.
def var vtitpar             like titulo.titpar extent 4 initial 0.
def var vtitdtven           like titulo.titdtven extent 4.
def var vtitvlcob           like titulo.titvlcob extent 4 initial 0.
def var c                   as int.
def buffer bplani for plani.

contlin = 18.

{mdadmcab.i
    &Saida     = "printer" /* value(varqsai)"*/
    &Page-Size = "66"
    &Cond-Var  = "160"
    &Page-Line = "66"
    &Nom-Rel   = ""emitnfd""
    &Nom-Sis   = """emissao da nota fiscal  - unica """
    &Tit-Rel   = """  """
    &Width     = "160"
    &disp      = "nao"
    &Form      = "frame f-cabcab"}



find plani where recid(plani) = par-rec no-lock.
/*run leclf.p ( input plani.desti,
	      output recatu2). */
find clifor where clifor.clfcod = plani.notfat no-lock no-error.

find opfis where opfis.opfcod = plani.opfcod no-lock no-error.


put unformatted skip(3)
    "X"             at 106
    plani.numero    at 145 skip(3)
    opfis.opfnom    at 2
    plani.opfcod    at 59 skip(1)
    clifor.clfnom   at 2
    clifor.cgccpf   at 108
    plani.pladat    at 145 skip
    clifor.endereco at 2
    clifor.bairro   at 90
    clifor.cep      at 123
    plani.pladat    at 145 skip(1)
    clifor.cidade   at 2
    clifor.fone     at 75
    clifor.ufecod   at 100
    clifor.ciinsc   at 108
    string(time,"hh:mm")
	    format "x(5)" at 145 skip(2).


    c = 0.

    for each titulo where titulo.titnat = no and
			  titulo.etbcod = plani.etbcod and
			  titulo.placod = plani.placod
			    break by titulo.titdtven:

	c = c + 1.
	vtitnum[c]   = titulo.titnum.
	vtitpar[c]   = titulo.titpar.
	vtitdtven[c] = titulo.titdtven.
	vtitvlcob[c] = titulo.titvlcob.
    end.

    put skip(3).

    for each movim of plani no-lock:
	find produ of movim no-lock.

	contlin = contlin - 1.
	put unformatted
	    produ.procod    at 2
	    produ.pronom    at 13
	    "00"            at 74
	    produ.prounven  at 80
	    movim.movqtm    at 88
	    movim.movpc     to 109   format ">>,>>9.99"
	    movim.movqtm * movim.movpc  to 125 format "zz,zz9.99"
	    movim.movalicms at 134 format ">9%" skip.

    end.

    put unformatted skip(contlin)
	plani.bicms         at 4 format "zz,zz9.99"
	plani.icms          at 40
	plani.protot        at 140 format "zz,zz9.99" skip
	plani.platot        at 140 format "zz,zz9.99" skip(6).

    find func where func.funcod = plani.vencod no-lock no-error.
    put skip(1)
	 "Funcionario"   at 2 plani.vencod
	 func.funnom    at 20 skip.

    put skip
	"Devolucao ref. a NF." at 2 space(1)
	 plani.plaass  space(2)
	 "Data :" plani.dtexp.

    put skip(13)
	plani.numero     at 145.
{mdadmrod.i &Saida     = "printer"
	    &NomRel    = """ """
	    &Page-Size = "31"
	    &Width     = "160"
	    &Traco     = "50"
	    &disp      = "NAO"
	    &Form      = "frame f-rod3"}.
