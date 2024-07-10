/******************************************************************************
* Programa  - confdev1.p                                                      *
*                                                                             *
* Funcao    - relatorio de conferencia das notas de devolucao de vendas       *
*                                                                             *
* Data       Autor          Caracteristica                                    *
* ---------  -------------  ------------------------------------------------- *
*******************************************************************************/

{admcab.i}
def var vok as log.
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
def var vtotpro like plani.platot.
              /**** Campo usado para guardar o no. da planilha ****/
form plani.pladat format "99/99/9999"
     plani.numero
     plani.emite  column-label "Emite"
     plani.desti  column-label "Dest" format ">>>>>>>>>9"
     plani.platot column-label "Total"
     vtipmov column-label "Movimento" format "x(18)"
                        with frame f-val down no-box width 200.


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
        &Saida     = "printer"
        &Page-Size = "63"
        &Cond-Var  = "120"
        &Page-Line = "66"
        &Nom-Rel   = ""anaven""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""
        &Tit-Rel   = """CONFERENCIA DAS NOTAS DE TRANSFERENCIA NA "" +
                    ""FILIAL "" + string(vetbcod) +
                    ""  - Data: "" + string(vdata1) + "" A "" +
                        string(vdata2)"
        &Width     = "120"
        &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label.


    for each tipmov no-lock:
        for each plani where plani.movtdc = tipmov.movtdc and
                             plani.desti  = vetbcod  and
                             plani.pladat >= vdata1 and
                             plani.pladat <= vdata2 no-lock by plani.numero.
            if not avail plani
            then next.
            if plani.emite = 22 and
               plani.serie = "M1"
            then next.
            vok = no.
            for each movim WHERE movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat no-lock:


                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ
                then next.

                if produ.catcod <> vcatcod
                then vok = yes.

                if plani.emite <> vetbcod and
                   plani.desti <> vetbcod
                then next.
            end.

            if vok 
            then next.
            
            if (plani.movtdc = 4 or
                plani.movtdc = 1) and vetbcod < 96
            then next.

            if plani.movtdc = 6
            then if plani.emite = vetbcod
                 then vtipmov = "TRANSFERENCIA DE SAIDA".
                 else vtipmov = "TRANSFERENCIA DE ENTRADA".
            else vtipmov = string(tipmov.movtnom,"x(18)").

            display plani.pladat format "99/99/9999"
                    plani.numero
                    plani.emite  column-label "Emite"
                    plani.desti  column-label "Dest" format ">>>>>>>>>9"
                    plani.platot column-label "Total"
                    vtipmov column-label "Movimento" format "x(18)"
                                with frame f-val down no-box width 200.
            down with frame f-val.
        end.
        for each plani where plani.movtdc = tipmov.movtdc and
                             plani.etbcod = vetbcod  and
                             plani.desti  <> vetbcod and
                             plani.pladat >= vdata1 and
                             plani.pladat <= vdata2 no-lock by plani.numero.

            if not avail plani
            then next.
            if plani.emite = 22 and
               plani.serie = "M1"
            then next.
            vok = no.
            for each movim WHERE movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat no-lock:


                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ
                then next.

                if produ.catcod <> vcatcod
                then vok = yes.
            end.
            if vok 
            then next.

            if plani.emite <> vetbcod and
               plani.desti <> vetbcod
            then next.


            if (plani.movtdc = 4 or
                plani.movtdc = 1) and vetbcod < 96
            then next.

            if plani.movtdc = 6
            then if plani.emite = vetbcod
                 then vtipmov = "TRANSFERENCIA DE SAIDA".
                 else vtipmov = "TRANSFERENCIA DE ENTRADA".
            else vtipmov = string(tipmov.movtnom,"x(18)").

            display plani.pladat format "99/99/9999"
                    plani.numero
                    plani.emite column-label "Emite"
                    plani.desti column-label "Dest" format ">>>>>>>>>9"
                    plani.platot column-label "Total"
                    vtipmov column-label "Movimento" format "x(18)"
                                with frame f-val down no-box width 200.
            down with frame f-val.
        end.
    end.

    output close.

end.
