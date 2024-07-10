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
def var vloja like movim.etbcod. /* TESTE */
              /**** Campo usado para guardar o no. da planilha ****/

/* Busca codigo estab */	
/*		  
def var funcao as char format "x(20)".
def var parametro as char format "x(20)".

input from ./admcom.ini no-echo.
repeat:
    set funcao parametro.
    if funcao = "ESTAB"
    then setbcod = int(parametro).
end.
input close.
/* Busca codigo estab */
*/
/* setbcod = 13. */
repeat:
    vtotmovim = 0.
    vtotgeral = 0.
	
	update vloja = setbcod.  /* atribui codigo estab obtido */
						
    update vprocod with frame f-pro centered width 80 color blue/cyan row 4
                        side-label.
    find produ where produ.procod = vprocod no-lock.
    disp produ.pronom vloja no-label with frame f-pro.
    update vdata1
           vdata2 label "A " with frame f1 side-labe centered
           color blue/cyan  title "Periodo" row 8.


    for each movim where movim.procod = produ.procod and
                         movim.DATEXP >= vdata1     and
                         movim.DATEXP <= vdata2 
						 and  /* TESTE */
						 movim.etbcod = vloja  /* TESTE */
						 no-lock
                                 break by movim.movtdc
                                       by movim.movdat:

        if first-of(movim.movtdc)
        then do:
            find tipmov where tipmov.movtdc = movim.movtdc no-lock no-error.
            if avail tipmov
            then
            /*disp tipmov.movtdc format ">>"
                 tipmov.movtnom no-label with frame f-tip side-label.*/
        end.
        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               plani.pladat = movim.movdat and
                               plani.movtdc = movim.movtdc
                                        no-lock no-error.
        if not avail plani
        then next.
		
		find first tipmov where tipmov.movtdc = plani.movtdc no-lock no-error.
		
        display
            movim.movdat
            plani.numero FORMAT "999999999"
            plani.serie  
            tipmov.movtnom format "x(10)"  column-label "Tip. Mov."          
            movim.movqtm format ">>>9" column-label "Qtd"
            movim.movpc column-label "Valor UN."
            (movim.movpc * movim.movqtm)(total by movim.movtdc)
            column-label "Total"
                         with frame f-val down no-box width 200.
            vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).

        /*
        if last-of(movim.movtdc)
        then do:
            put skip(1) "Total =>  " at 95 vtotmovim.
                    vtotmovim = 0.
        end.
        */
    end.
   
end.	