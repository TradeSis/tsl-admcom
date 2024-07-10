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
def var vprocod like produ.procod.
def var vtotdia like plani.platot.
def var vtot  like movim.movpc.
def var vtotg like movim.movpc.
def var vtotgeral like plani.platot.
def var vdata1 like plani.pladat label "Data".
def var vdata2 like plani.pladat label "Data".
def var vtotal like plani.platot.
def var vtoticm like plani.icms.
def var vtotmovim   like movim.movpc.
def var vmovtnom  like tipmov.movtnom.
def var vsalant   like estoq.estatual.
	      /**** Campo usado para guardar o no. da planilha ****/


repeat:
    vtotmovim = 0.
    vtotgeral = 0.
    vsalant = 0.
    update vetbcod colon 18 with frame f-pro.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f-pro.
    update vprocod colon 18
	    with frame f-pro centered width 80 color blue/cyan row 4 side-label.
    find produ where produ.procod = vprocod no-lock.
    disp produ.pronom no-label with frame f-pro.
    update vdata1
	   vdata2 label "A " with frame f1 side-labe centered
	   color blue/cyan  title "Periodo" row 8.

    find estoq where estoq.etbcod = estab.etbcod and
		     estoq.procod = produ.procod no-lock no-error.

    vsalant = estoq.estatual.

    for each movim where movim.procod = produ.procod and
			 movim.movdat >= vdata1     and
			 movim.movdat <= vdata2  no-lock
				 break by movim.movdat
				       by movim.movtdc:

	find plani where plani.etbcod = movim.etbcod and
			 plani.placod = movim.placod no-lock no-error.
	if not avail plani
	then next.
	if movim.movtdc <> plani.movtdc
	then next.

	if plani.etbcod = vetbcod or
	   plani.desti  = vetbcod
	then do:

	vmovtnom = "".
	find tipmov of movim no-lock.
	if movim.movtdc = 1
	then vmovtnom = "ORCAMENTO DE ENTRADA".
	if movim.movtdc = 4
	then vmovtnom = "ENTRADA".
	if movim.movtdc = 5
	then vmovtnom = "VENDA".
	if movim.movtdc = 12
	then vmovtnom = "DEV.VENDA".
	if movim.movtdc = 13
	then vmovtnom = "DEV.FORN.".
	if movim.movtdc = 15
	then vmovtnom = "ENT.CONSERTO".
	if movim.movtdc = 16
	then vmovtnom = "REM.CONSERTO".
	if movim.movtdc = 7
	then vmovtnom = "BAL.AJUS.ACR".
	if movim.movtdc = 8
	then vmovtnom = "BAL.AJUS.DEC".
	if movim.movtdc = 6 and
	   plani.etbcod = vetbcod
	then vmovtnom = "TRANSF.SAIDA".
	if movim.movtdc = 6 and
	   plani.desti  = vetbcod
	then vmovtnom = "TRANSF.ENTRA".

	if movim.movtdc = 17
	then vmovtnom = "TROCA DE ENTRADA".
	if movim.movtdc = 18
	then vmovtnom = "TROCA DE SAIDA".

	if movim.movtdc <> 6
	then do:
	if tipmov.movtdeb
	then vsalant = vsalant + movim.movqtm.
	else vsalant = vsalant - movim.movqtm.
	end.
	else do:
	if plani.etbcod = vetbcod
	then vsalant = vsalant + movim.movqtm.
	if plani.desti = vetbcod
	then vsalant = vsalant - movim.movqtm.
	end.

	display
	    movim.movdat format "99/99/99"
	    VMOVTNOM column-label "Operacao" format "x(12)"
	    plani.numero
	    plani.emite column-label "Emitente" format ">>>>>>"
	    plani.DESTI column-label "Desti" format ">>>>>>>>"
	    movim.movqtm (total) format ">>>9" column-label "Quant"
	    movim.movpc format ">,>>9.99" column-label "Valor"
	    (movim.movpc * movim.movqtm)
	    column-label "Total"
			 with frame f-val down ROW 8 CENTERED color white/gray.
	end.
    end.


    disp vsalant label "Saldo Anterior" format "->>,>>9"
	 estoq.estatual label "Saldo Atual" format "->>,>>9"
	 with frame f-sal centered row 15 side-label
				    color white/red overlay.


    /*
    for each movim where movim.movtdc = 6 and
			 movim.desti = vetbcod and
			 movim.datEXP >= vdata1     and
			 plani.DATEXP <= vdata2 no-lock,
			 each movim of plani break by MOVIM.movtdc
						   by plani.pladat
						   by plani.numero:

	    if movim.procod <> produ.procod
	    then next.

	    if first-of(movim.movtdc)
	    then do:
		find tipmov where tipmov.movtdc = movim.movtdc no-lock.
		disp tipmov.movtdc format ">>"
		     tipmov.movtnom no-label with frame f-tip2 side-label.
	    end.

	    display
		movim.movdat
		plani.numero
		plani.serie
		plani.emite column-label "Emitente"
		plani.desti column-label "Destino"
		movim.movqtm format ">>>9" column-label "Quant"
		movim.movpc
		(movim.movpc * movim.movqtm)
		column-label "Total"
			     with frame f-val2 down no-box width 200.
		vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).

	    if last-of(movim.movtdc)
	    then do:
		put skip(1) "Total =>  " at 95 vtotmovim.
		vtotmovim = 0.
	    end.

    end.
    output close.
    */

end.
