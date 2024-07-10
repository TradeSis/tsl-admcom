/******************************************************************************
* Programa  - relmov                                                          *
*                                                                             *
* Funcao    - relatorio de conferencia das notas de devolucao de vendas       *
*                                                                             *
* Data       Autor          Caracteristica                                    *
* ---------  -------------  ------------------------------------------------- *
*******************************************************************************/

{admcab.i}
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
              /**** Campo usado para guardar o no. da planilha ****/


repeat:
    vtotmovim = 0.
    vtotgeral = 0.
    update vetbcod
           vdata1
           vdata2 label "A " with frame f1 side-labe centered
           color blue/cyan  title "Periodo" row 4.

    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.


    {mdadmcab.i
        &Saida     = "i:\admcom\relat\mov"
        &Page-Size = "63"
        &Cond-Var  = "120"
        &Page-Line = "66"
        &Nom-Rel   = ""RELMOV""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
        &Tit-Rel   = """CONFERENCIA DAS NOTAS DE TRANSFERENCIA NA "" +
                    ""FILIAL "" + string(vetbcod) +
                    ""  - Data: "" + string(vdata1) + "" A "" +
                        string(vdata2)"
        &Width     = "120"
        &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label.


    for each plani where plani.etbcod = vetbcod and
                         plani.DATEXP >= vdata1     and
                         plani.DATEXP <= vdata2 no-lock,
                         each movim WHERE MOVIM.etbcod = plani.etbcod and
                                          movim.placod = plani.placod
                                             break by MOVIM.movtdc
                                                   by plani.pladat
                                                   by plani.numero:

        if first-of(movim.movtdc)
        then do:
            find tipmov where tipmov.movtdc = movim.movtdc no-lock.
            disp tipmov.movtdc format ">>"
                 tipmov.movtnom no-label with frame f-tip side-label.
        end.
        find produ where produ.procod = movim.procod no-lock no-error.
        if not avail produ
        then next.

        if produ.catcod <> vcatcod
        then next.

        display
            plani.dtinclu column-label "Receb."
            plani.pladat
            plani.numero
            plani.serie
            plani.emite column-label "Emitente"
            plani.desti column-label "Destino" format ">>>>>>>>>9"
            movim.procod
            produ.pronom when avail produ format "x(35)"
            movim.movqtm format ">>>>9"
            movim.movpc
            (movim.movpc * movim.movqtm)
            column-label "Total"
                         with frame f-val down no-box width 200.
            vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).

        if last-of(movim.movtdc)
        then do:
            put skip(1) "Total =>  " at 95 vtotmovim.
            vtotmovim = 0.
        end.
    end.

    for each plani where plani.movtdc = 6 and
                         plani.desti = vetbcod and
                         plani.DATEXP >= vdata1     and
                         plani.DATEXP <= vdata2 no-lock,
                         each movim where movim.placod = plani.placod and
                                          movim.etbcod = plani.etbcod
                                             break by MOVIM.movtdc
                                                   by plani.pladat
                                                   by plani.numero:

            find produ where produ.procod = movim.procod no-lock no-error.
            if avail produ
            then do:
                if produ.catcod <> vcatcod
                then next.
            end.
            if first-of(movim.movtdc)
            then do:
                find tipmov where tipmov.movtdc = movim.movtdc no-lock.
                disp tipmov.movtdc format ">>"
                     tipmov.movtnom no-label with frame f-tip2 side-label.
            end.
            display
                plani.pladat
                plani.numero
                plani.serie
                plani.emite column-label "Emitente"
                plani.desti column-label "Destino"
                movim.procod
                produ.pronom when avail produ format "x(43)"
                movim.movqtm format ">>>>9"
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
    message "Deseja Imprimir Relatorio" update sresp.
    if sresp
    then dos silent value(" type i:\admcom\relat\mov > prn ") .
end.
