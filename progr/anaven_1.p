/******************************************************************************
* Programa  - confdev1.p                                                      *
*                                                                             *
* Funcao    - relatorio de conferencia das notas de devolucao de vendas       *
*                                                                             *
* Data       Autor          Caracteristica                                    *
* ---------  -------------  ------------------------------------------------- *
*******************************************************************************/

{admcab.i}
def var fila as char.
def var varquivo as char format "x(20)".
def stream stela.
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
     plani.numero format ">>>>>>9"
     plani.emite column-label "Emite"
     plani.desti column-label "Dest" format ">>>>>>>>>9"
     movim.procod
     produ.pronom format "x(40)"
     movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
     movim.movpc  format ">,>>9.99"
     vtotpro column-label "Total"
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
                with frame f-dep centered side-label color blue/cyan.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.
        
    if opsys = "unix"
    then do:
        find first impress where impress.codimp = setbcod no-lock no-error.
        if avail impress
        then assign fila = string(impress.dfimp) 
                    varquivo = "/admcom/relat/aud" + string(time).
    end.                    
    else assign fila = "" 
                varquivo = "l:\relat\aud" + string(time).

 
    {mdadmcab.i
        &Saida     = "value(varquivo)"
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
                             plani.pladat >= vdata1  and
                             plani.pladat <= vdata2 no-lock by plani.numero.
            if not avail plani
            then next.
            if plani.emite = 22 and
               plani.serie = "M1"
            then next.

            for each movim WHERE movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat no-lock:


                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ
                then next.

                if produ.catcod <> vcatcod
                then next.

                if plani.emite <> vetbcod and
                   plani.desti <> vetbcod
                then next.
                
                if plani.movtdc = 16 and
                   plani.desti  = vetbcod
                then next.
                
                if ( plani.movtdc = 05   or 
                     plani.movtdc = 12 ) and 
                     plani.desti  = vetbcod 
                then next.
         
        

                if (plani.movtdc = 4 or
                    plani.movtdc = 1) and vetbcod < 96
                then next.

                if plani.movtdc = 6
                then if plani.emite = vetbcod
                     then vtipmov = "TRANSFERENCIA DE SAIDA".
                     else vtipmov = "TRANSFERENCIA DE ENTRADA".
                else vtipmov = string(tipmov.movtnom,"x(18)").

                vtotpro = (movim.movpc * movim.movqtm).

                display
                    plani.pladat format "99/99/9999"
                    plani.numero format ">>>>>>9"
                    plani.emite column-label "Emite"
                    plani.desti column-label "Dest" format ">>>>>>>>>9"
                    movim.procod
                    produ.pronom when avail produ format "x(40)"
                    movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
                    movim.movpc
                    vtotpro  column-label "Total"
                    vtipmov column-label "Movimento" format "x(18)"
                                with frame f-val down no-box width 200.
                    down with frame f-val.
                    vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).
            end.
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

            for each movim WHERE movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat no-lock:


                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ
                then next.

                if produ.catcod <> vcatcod
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

                vtotpro = (movim.movpc * movim.movqtm).


                display
                    plani.pladat format "99/99/9999"
                    plani.numero format ">>>>>>9"
                    plani.emite column-label "Emite"
                    plani.desti column-label "Dest" format ">>>>>>>>>9"
                    movim.procod
                    produ.pronom when avail produ format "x(40)"
                    movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
                    movim.movpc
                    vtotpro column-label "Total"
                    vtipmov column-label "Movimento" format "x(18)"
                                with frame f-val down no-box width 200.
                    down with frame f-val.
                    vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).
            end.
        end.
    end.
    output stream stela to terminal.
        display stream stela vtotmovim label "Total "
                        with frame fstream side-label centered.
    output stream stela close.
    output close.
    message "Deseja imprimir relatorio" update sresp.
    if sresp
    then do:
            
        if opsys = "unix"
        then os-command silent lpr value(fila + " " + varquivo).
        else os-command silent type value(varquivo) > prn.
    
    end.

end.
