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
    update
	   vdata1
	   vdata2 label "A " with frame f1 side-labe centered
	   color blue/cyan  title "Periodo" row 4.


    {mdadmcab.i
	&Saida     = "printer"
	&Page-Size = "63"
	&Cond-Var  = "120"
	&Page-Line = "66"
	&Nom-Rel   = ""CONFTRA""
	&Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
	&Tit-Rel   = """CONFERENCIA DAS NOTAS DE TRANSFERENCIA QUE "" +
		    ""ENTRARAM NO DEPOSITO "" +
		    ""  - Data: "" + string(vdata1) + "" A "" +
			string(vdata2)"
	&Width     = "120"
	&Form      = "frame f-cabcab"}

    FOR EACH ESTAB WHERE ETBCOD <= 40:
    for each plani where plani.movtdc = 6 and
			 plani.etbcod = ESTAB.ETBCOD and
			 plani.pladat >= vdata1     and
			 plani.pladat <= vdata2 no-lock,
			 each movim of plani break by plani.pladat
						   by plani.numero:


	    find produ where produ.procod = movim.procod.

	    display
		plani.etbcod column-label "Fl" FORMAT ">9"
		plani.pladat
		plani.numero
		plani.serie
		plani.desti column-label "Destino"
		produ.procod
		produ.pronom format "x(43)"
		movim.movqtm format ">>>9" column-label "Qtd."
		movim.movpc
		(movim.movpc * movim.movqtm) (TOTAL)
		column-label "Total"
			     with frame f-val down no-box width 200.
    end.
    END.
    output close.
end.
