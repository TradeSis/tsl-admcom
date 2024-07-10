/******************************************************************************
* Programa  - confdev1.p                                                      *
*                                                                             *
* Funcao    - relatorio de conferencia das notas de devolucao de vendas       *
*                                                                             *
* Data       Autor          Caracteristica                                    *
* ---------  -------------  ------------------------------------------------- *
*******************************************************************************/

{admcab.i}
def var vmovtdc like tipmov.movtdc.
def var vtipmov like tipmov.movtnom.
def var vcatcod like categoria.catcod.
def var vetbcod like estab.etbcod.
def var vtotdia like plani.platot.
def var vtot  like movim.movpc.
def var vtotg like movim.movpc.
def var vtotgeral like plani.platot.
def var vdata1 like plani.pladat label "Data".
def var vdata2 like plani.pladat label "Data".
def var vtotal like plani.platot.
def var vtoticm like plani.icms.
def var vtotmovim   like movim.movpc.
def var varquivo as char format "x(30)".

              /**** Campo usado para guardar o no. da planilha ****/


repeat:
    vtotmovim = 0.
    vtotgeral = 0.
    update vmovtdc with frame f1.
    find tipmov where tipmov.movtdc = vmovtdc no-lock.
    disp tipmov.movtnom no-label with frame f1.
    update
           vetbcod
           vdata1
           vdata2 label "A " with frame f1 side-labe centered
           color blue/cyan  title "Periodo" row 4.

    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.


    if opsys <> "UNIX"
    then varquivo = "..\relat\pla-" + string(time).        
    else varquivo = "/admcom/relat/pla-" + string(time).        
    
    {mdad_l.i            
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "120"
        &Page-Line = "66"
        &Nom-Rel   = ""AUD03""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
        &Tit-Rel   = """CONFERENCIA DAS NOTAS DE TRANSFERENCIA NA "" +
                    ""FILIAL "" + string(vetbcod) +
                    ""  - Data: "" + string(vdata1) + "" A "" +
                        string(vdata2)"
        &Width     = "120"
        &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label.



    for each movim WHERE (MOVIM.etbcod = vetbcod or
                          movim.etbcod >= 996 or
                          movim.etbcod = 998) and
                          movim.datexp >= vdata1 and
                          movim.datexp <= vdata2 and
                          movim.movtdc = tipmov.movtdc no-lock
                                break by MOVIM.procod:

        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               plani.movtdc = movim.movtdc and
                               plani.pladat = movim.movdat no-lock no-error.
        if not avail plani
        then next.
        if plani.emite = 22 and
           plani.serie = "M1"
        then next.

        find tipmov where tipmov.movtdc = movim.movtdc no-lock.

        find produ where produ.procod = movim.procod no-lock no-error.
        if not avail produ
        then next.

        if produ.catcod <> vcatcod
        then next.

        /*
        if plani.emite >= 996 and
           plani.desti <> vetbcod
        then next. */

        if plani.emite <> vetbcod and
           plani.desti <> vetbcod
        then next.


        if (plani.movtdc = 4 or
            plani.movtdc = 1) and (vetbcod < 996 and
            vetbcod <> 998)
        then next.

        if plani.movtdc = 6
        then if plani.emite = vetbcod
             then vtipmov = "TRANSFERENCIA DE SAIDA".
             else vtipmov = "TRANSFERENCIA DE ENTRADA".
        else vtipmov = string(tipmov.movtnom,"x(18)").


        display
            plani.datexp format "99/99/9999"
            plani.numero
            plani.emite column-label "Emite"
            plani.desti column-label "Dest" format ">>>>>>>>>9"
            movim.procod
            produ.pronom when avail produ format "x(40)"
            movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
            movim.movpc
            (movim.movpc * movim.movqtm) column-label "Total"
            vtipmov column-label "Movimento" format "x(18)"
                         with frame f-val down no-box width 200.
            vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).

    end.
    output close.
    
      if opsys <> "UNIX"    
      then do:        
        {mrod_l.i}     
        end.    
      else run visurel.p (input varquivo, input "").
        
end.
