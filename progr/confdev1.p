/******************************************************************************
* Programa  - confdev1.p                                                      *
*                                                                             *
* Funcao    - relatorio de conferencia das notas de devolucao de vendas       *
*                                                                             *
* Data       Autor          Caracteristica                                    *
* ---------  -------------  ------------------------------------------------- *
* 15/01/97   Jeanine        Manutencao-relatorio tbem em tela                 *
*******************************************************************************/

{admcab.i}
def var vetbcod like estab.etbcod.
def var vtotdia like plani.platot.
def var vtot  like movim.movpc.
def var vtotg like movim.movpc.
def var vtotgeral like plani.platot.
def var vdata1 like plani.pladat label "Data".
def var vdata2 like plani.pladat label "Data".
def var vtotal like plani.platot.
def var vtoticm like plani.icms.
	      /**** Campo usado para guardar o no. da planilha ****/


repeat:
    vtotgeral = 0.
    update vetbcod
	   vdata1
	   vdata2 label "A " with frame f1 side-labe centered
	   color blue/cyan  title "Periodo" row 4.


    {mdadmcab.i
	&Saida     = "printer"
	&Page-Size = "63"
	&Cond-Var  = "120"
	&Page-Line = "66"
	&Nom-Rel   = ""CONFDEV1""
	&Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
	&Tit-Rel   = """CONFERENCIA DAS NOTAS DE DEVOLUCAO DE VENDAS NA "" +
		    ""FILIAL "" + string(vetbcod) +
		    ""  - Data: "" + string(vdata1) + "" A "" +
			string(vdata2)"
	&Width     = "120"
	&Form      = "frame f-cabcab"}


    for each plani where plani.movtdc = 12 and
			 plani.etbcod = vetbcod and
			 plani.pladat >= vdata1     and
			 plani.pladat <= vdata2 no-lock,
			 each movim where movim.etbcod = plani.etbcod and
					  movim.placod = plani.placod and
					  movim.movtdc = plani.movtdc and
					  movim.movdat = plani.pladat no-lock
					    break by plani.pladat
						  by plani.numero:


	    find produ where produ.procod = movim.procod.

	    display
		plani.pladat
		plani.numero
		plani.serie
		produ.procod
		produ.pronom
		movim.movqtm format ">>9"
		movim.movpc
		(movim.movpc * movim.movqtm) (TOTAL)
		column-label "Total"
			     with frame f-val down no-box width 200.
    end.
    output close.
end.
