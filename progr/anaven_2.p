/******************************************************************************
* Programa  - confdev1.p                                                      *
*                                                                             *
* Funcao    - relatorio de conferencia das notas de devolucao de vendas       *
*                                                                             *
* Data       Autor          Caracteristica                                    *
* ---------  -------------  ------------------------------------------------- *
*******************************************************************************/

{admcab.i}
    
def var vmovtnom like tipmov.movtnom.
def var vtot like plani.platot.
def var vtotal like plani.platot.
def var vtip as char format "x(20)" extent 3 
        initial ["Numerico","Alfabetico","Nota Fiscal"].
def var vv as char format "x".
def var fila as char.

def workfile tt-produ 
    field procod like produ.procod
    field pronom as char format "x(20)"
    field prorec as recid
    field numero like plani.numero
    field movtdc like tipmov.movtdc.
    
def var varquivo as char format "x(20)".
def stream stela.
def var vtipmov like tipmov.movtnom.
def var vcatcod like categoria.catcod.
def var vetbcod like estab.etbcod.
def var vtotdia like plani.platot.
def var vtotg like movim.movpc.
def var vtotgeral like plani.platot.
def var vdata1 like plani.pladat label "Data".
def var vdata2 like plani.pladat label "Data".
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
    
    for each tt-produ.
        delete tt-produ.
    end.
    
    update vetbcod
           vdata1
           vdata2 label "A " with frame f1 side-labe centered
           color blue/cyan  title "Periodo" row 4.

    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.
    
    display vtip with frame f-tip no-label.
    choose field vtip with frame f-tip centered row 4.
    if frame-index = 1
    then vv = "N".
    else if frame-index = 2
         then vv = "A".
         else vv = "F".

    
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

            
    for each tipmov no-lock,
        each plani where plani.pladat >= vdata1       and
                         plani.pladat <= vdata2       and
                         plani.movtdc = tipmov.movtdc and
                         plani.desti  = vetbcod       no-lock,
     
        each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock:
    
        find produ where produ.procod = movim.procod no-lock no-error.
        if not avail produ
        then next.
        if produ.catcod <> vcatcod
        then next.
        
        if plani.movtdc = 05   or
           plani.movtdc = 12   or
           plani.movtdc = 16
        then next.
            
        if (plani.movtdc = 4 or
            plani.movtdc = 1) and vetbcod < 96
        then next.

        
        find first tt-produ where tt-produ.prorec = recid(movim) no-error.
        if not avail tt-produ
        then do:
            
            create tt-produ.
            assign tt-produ.procod = produ.procod
                   tt-produ.pronom = produ.pronom
                   tt-produ.prorec = recid(movim)
                   tt-produ.numero = plani.numero
                   tt-produ.movtdc = plani.movtdc.
        
            if tt-produ.movtdc = 06
            then tt-produ.movtdc = 09.
            
        end.
        
    end.
            
    for each tipmov no-lock,
        each plani where plani.pladat >= vdata1       and
                         plani.pladat <= vdata2       and
                         plani.movtdc = tipmov.movtdc and
                         plani.etbcod = vetbcod no-lock,
     
        each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock:
    
        find produ where produ.procod = movim.procod no-lock no-error.
        if not avail produ
        then next.
        if produ.catcod <> vcatcod
        then next.
        
        if (plani.movtdc = 4 or
            plani.movtdc = 1) and vetbcod < 96
        then next.

        
        find first tt-produ where tt-produ.prorec = recid(movim) no-error.
        if not avail tt-produ
        then do:
                         
            create tt-produ.
            assign tt-produ.procod = produ.procod
                   tt-produ.pronom = produ.pronom
                   tt-produ.prorec = recid(movim)
                   tt-produ.numero = plani.numero
                   tt-produ.movtdc = plani.movtdc.
        end.
        
    end.

     
    
    if vv = "A"
    
    then do:
        for each tt-produ by tt-produ.pronom:
            find movim where recid(movim) = tt-produ.prorec no-lock.
            
            find produ where produ.procod = movim.procod no-lock no-error.
            find first plani where plani.movtdc = movim.movtdc and
                                   plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.pladat = movim.movdat 
                                no-lock no-error.

            if not avail plani
            then next.
            if plani.emite <> vetbcod and
               plani.desti <> vetbcod
            then next.


            if (plani.movtdc = 4 or
                plani.movtdc = 1) and vetbcod < 96
            then next.

            find tipmov where tipmov.movtdc = plani.movtdc no-lock no-error.
            if not avail tipmov
            then next.

            if plani.movtdc = 6
            then if plani.emite = vetbcod
                 then vtipmov = "TRANSFERENCIA DE SAIDA".
                 else vtipmov = "TRANSFERENCIA DE ENTRADA".
            else vtipmov = string(tipmov.movtnom,"x(18)").

            vtotpro = (movim.movpc * movim.movqtm).
        
            display plani.pladat format "99/99/9999"
                    plani.numero format ">>>>>>9"
                    plani.emite column-label "Emite"
                    plani.desti column-label "Dest" format ">>>>>>>>>9"
                    movim.procod
                    produ.pronom when avail produ format "x(40)"
                    movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
                    movim.movpc
                    vtotpro  column-label "Total"
                    vtipmov column-label "Movimento" format "x(18)"
                                with frame f-val1 down no-box width 200.
                    down with frame f-val1.
                    vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).
        end.
        display vtotmovim label "Total" with frame f-tot1 side-label.
    end.
    
    if vv = "N"
    then do:
        for each tt-produ by tt-produ.procod:
            find movim where recid(movim) = tt-produ.prorec no-lock.
            
            find produ where produ.procod = movim.procod no-lock no-error.
            find first plani where plani.movtdc = movim.movtdc and
                                   plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.pladat = movim.movdat 
                                no-lock no-error.

            if not avail plani
            then next.
           
            if plani.emite <> vetbcod and
               plani.desti <> vetbcod
            then next.


            if (plani.movtdc = 4 or
                plani.movtdc = 1) and vetbcod < 96
            then next.

            find tipmov where tipmov.movtdc = plani.movtdc no-lock no-error.
            if not avail tipmov
            then next.

            if plani.movtdc = 6
            then if plani.emite = vetbcod
                 then vtipmov = "TRANSFERENCIA DE SAIDA".
                 else vtipmov = "TRANSFERENCIA DE ENTRADA".
            else vtipmov = string(tipmov.movtnom,"x(18)").

            vtotpro = (movim.movpc * movim.movqtm).
        

            display plani.pladat format "99/99/9999"
                    plani.numero format ">>>>>>9"
                    plani.emite column-label "Emite"
                    plani.desti column-label "Dest" format ">>>>>>>>>9"
                    movim.procod
                    produ.pronom when avail produ format "x(40)"
                    movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
                    movim.movpc
                    vtotpro  column-label "Total"
                    vtipmov column-label "Movimento" format "x(18)"
                                with frame f-val2 down no-box width 200.
                    down with frame f-val2.
                    vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).
        end.
        display vtotmovim label "Total" with frame f-tot2 side-label.
    end.

    
    if vv = "F"
    then do:
        for each tt-produ by tt-produ.numero
                          by tt-produ.procod:
            find movim where recid(movim) = tt-produ.prorec no-lock.
            
            find produ where produ.procod = movim.procod no-lock no-error.
            find first plani where plani.movtdc = movim.movtdc and
                                   plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.pladat = movim.movdat 
                                no-lock no-error.

            if not avail plani
            then next.
           
            if plani.emite <> vetbcod and
               plani.desti <> vetbcod
            then next.


            if (plani.movtdc = 4 or
                plani.movtdc = 1) and vetbcod < 96
            then next.

            find tipmov where tipmov.movtdc = plani.movtdc no-lock no-error.
            if not avail tipmov
            then next.

            if plani.movtdc = 6
            then if plani.emite = vetbcod
                 then vtipmov = "TRANSFERENCIA DE SAIDA".
                 else vtipmov = "TRANSFERENCIA DE ENTRADA".
            else vtipmov = string(tipmov.movtnom,"x(18)").

            vtotpro = (movim.movpc * movim.movqtm).
        

            display plani.pladat format "99/99/9999"
                    plani.numero format ">>>>>>9"
                    plani.emite column-label "Emite"
                    plani.desti column-label "Dest" format ">>>>>>>>>9"
                    movim.procod
                    produ.pronom when avail produ format "x(40)"
                    movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
                    movim.movpc
                    vtotpro  column-label "Total"
                    vtipmov column-label "Movimento" format "x(18)"
                                with frame f-val3 down no-box width 200.
                    down with frame f-val3.
                    vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).
        end.
        display vtotmovim label "Total" with frame f-tot3 side-label.
    end.



    output stream stela to terminal.
        display stream stela vtotmovim label "Total "
                        with frame fstream side-label centered.
    output stream stela close.

    for each tt-produ break by tt-produ.movtdc:
        find movim where recid(movim) = tt-produ.prorec no-lock.
        find tipmov where tipmov.movtdc = tt-produ.movtdc no-lock no-error.
        if not avail tipmov
        then vmovtnom = "".
        else vmovtnom = tipmov.movtnom.
        if tt-produ.movtdc = 9
        then vmovtnom = "TRANSFERENCIA DE ENTRADA".
        if tt-produ.movtdc = 6
        then vmovtnom = "TRANSFERENCIA DE SAIDA  ".
        
        vtot = vtot + (movim.movpc * movim.movqtm).
        vtotal = vtotal + (movim.movpc * movim.movqtm).
        
        if last-of(tt-produ.movtdc)
        then do:
            display vmovtnom
                    vtot(total) no-label with frame f-tot down.
            vtot = 0.
        end.
    end.    
    
    
    output close.
    
    
    message "Deseja imprimir relatorio" update sresp.
    if sresp
    then do:
        
        if opsys = "unix"
        then os-command silent lpr value(fila + " " + varquivo).
        else os-command silent type value(varquivo) > prn.
    end.

end.
