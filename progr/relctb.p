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

def var vcatcod like categoria.catcod.
def var vetbcod    like estab.etbcod.
def var vetbcodini like estab.etbcod label "Etb.Ini.".
def var vetbcodfim like estab.etbcod label "Etb.Fin.".
def var vtotdia like plani.platot.
def var vtot  like movim.movpc.
def var vtotg like movim.movpc.
def var vtotgeral like plani.platot.
def var vdata1 like plani.pladat label "Data".
def var vdata2 like plani.pladat label "Data".
def var vtotal like plani.platot.
def var vtoticm like plani.icms.
def var vtotmovim   like movim.movpc.
	      /**** Campo usado para guardar o no. da planilha ****/


repeat:
    vtotmovim = 0.
    vtotgeral = 0.
    update vetbcodini
	   vetbcodfim
	   vdata1
	   vdata2 label "A " with frame f1 side-labe centered
	   color blue/cyan  title "Periodo" row 4.

    do vetbcod = vetbcodini to vetbcodfim:

    {mdadmcab.i
	&Saida     = "PRINTER"
	&Page-Size = "63"
	&Cond-Var  = "80"
	&Page-Line = "66"
	&Nom-Rel   = ""RELCTB""
	&Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
	&Tit-Rel   = """CONFERENCIA DAS NOTAS DE TRANSFERENCIA NA "" +
		    ""FILIAL "" + string(vetbcod) +
		    ""  - Data: "" + string(vdata1) + "" A "" +
			string(vdata2)"
	&Width     = "80"
	&Form      = "frame f-cabcab"}

    disp "SAIDAS" skip(1) with frame f22.

    for each plani where plani.movtdc = 6       and
			 plani.etbcod = vetbcod and
			 plani.DATEXP >= vdata1 and
			 plani.DATEXP <= vdata2 no-lock
			 break by plani.datexp
			       by plani.numero:

	if first-of(plani.datexp)
	then do:
	    display
		plani.datexp /* pladat */
			 with frame f-val down no-box width 200.
	end.

	display
	    plani.numero
	    plani.serie
	    plani.emite column-label "Emitente"
	    plani.desti column-label "Destino"
	    plani.platot column-label "Total"
			 with frame f-val down no-box width 200.

	    vtotmovim = vtotmovim + plani.platot.

	if last-of(plani.datexp)
	then do:
	    put skip "Total =>  " at 95 vtotmovim skip(1).
	    vtotmovim = 0.
	end.
    end.

    DISP "ENTRADAS" skip(1) with frame f33.

    for each plani where plani.movtdc = 6 and
			 plani.desti = vetbcod and
			 plani.DATEXP >= vdata1     and
			 plani.DATEXP <= vdata2 no-lock
			 break by plani.datexp
			       by plani.numero:


	if first-of(plani.datexp)
	then do:
	    display
		plani.datexp
			 with frame f-val2 down no-box width 200.
	end.

	display
		plani.numero
		plani.serie
		plani.emite column-label "Emitente"
		plani.desti column-label "Destino"
		plani.platot
		column-label "Total"
			     with frame f-val2 down no-box width 200.
		vtotmovim = vtotmovim + plani.platot.

	if last-of(plani.datexp)
	then do:
	    put skip "Total =>  " at 95 vtotmovim skip(1).
	    vtotmovim = 0.
	end.

    end.
    output close.
    end.
end.
