/******************************************************************************
* Programa  - anaven.p                                                        *
*                                                                             *
* Funcao    - 
*                                                                             *
* Data       Autor          Caracteristica                                    *
* ---------  -------------  ------------------------------------------------- *
******************************************************************************/

{admcab.i}

def var vmovtdc like tipmov.movtdc.    
def var sal-atu like estoq.estatual.
def var vmovtnom like tipmov.movtnom.
def var vtot like plani.platot.
def var vtotal like plani.platot.
def var vtip as char format "x(20)" extent 3 
        initial ["Numerico","Alfabetico","Nota Fiscal"].
def var vv as char format "x".

def temp-table tt-produ 
    field procod like produ.procod
    field pronom as char format "x(20)"
    field prorec as recid
    field numero like plani.numero
    field movtdc like tipmov.movtdc
    field tipemite as log label "Estoque" format "Saida/Entrada"

    index i1 procod
    index i2 pronom
    index i3 numero procod
    index i4 prorec.

def var varquivo as char format "x(20)".
def var vtipmov like tipmov.movtnom.
def var vcatcod like categoria.catcod.
def var vetbcod like estab.etbcod.
def var vdata1  like plani.pladat label "Data".
def var vdata2  like plani.pladat label "Data".
def var vtotmovim   like movim.movpc.
def var vdata   as date.
def var vtotpro like plani.platot.

do on error undo with frame f1 side-label.
    vtotmovim = 0.
    
    for each tt-produ.
        delete tt-produ.
    end.
    
    update vetbcod label "Estabelecimento" colon 18.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Filial nao cadastrada".
        undo.
    end.
    display estab.etbnom no-label.

    update vdata1 label "Periodo"  colon 18
           vdata2 label "ate".
           
    vmovtdc = 0.
    update vmovtdc label "Tipo de Movimento"  colon 18 format ">>9".
    if vmovtdc = 0
    then display "GERAL" @ tipmov.movtnom no-label.
    else do:
        find tipmov where tipmov.movtdc = vmovtdc no-lock.
        disp tipmov.movtnom no-label.
    end. 
    
    update vcatcod label "Departamento"  colon 18.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label.
    
    display vtip with frame f-tip no-label.
    choose field vtip with frame f-tip centered.
    if frame-index = 1
    then vv = "N".
    else if frame-index = 2
         then vv = "A".
         else vv = "F".
end.
    
       varquivo = "/admcom/relat/rlmovim" + string(time).
       {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "63"
            &Cond-Var  = "140" 
            &Page-Line = "66" 
            &Nom-Rel   = ""rlmovim"" 
            &Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
            &Tit-Rel   = """CONFERENCIA DAS NOTAS NA FILIAL "" +
                          string(vetbcod) +
                          "" - Data: "" + string(vdata1) + "" A "" +
                          string(vdata2)"
            &Width     = "140"
            &Form      = "frame f-cabcab"} 

    if vcatcod > 0
    then disp categoria.catcod label "Departamento"
              categoria.catnom no-label with frame f-dep2 side-label.

    for each tipmov where (if vmovtdc = 0
                           then true
                           else tipmov.movtdc = vmovtdc) no-lock.
        if tipmov.movtdc =  5 or
           tipmov.movtdc = 30
        then next.
/***
           tipmov.movtdc = 12 or
           tipmov.movtdc = 16 or
           tipmov.movtdc = 22 or
***/
        do vdata = vdata1 to vdata2.
            /*
                Desti
            */
            for each plani use-index plasai
                           where plani.movtdc = tipmov.movtdc
                             and plani.desti  = vetbcod
                             and plani.dtincl = vdata
                           no-lock.
                run processa.
            end.

            /*
                Emite
            */
            for each plani where 
                         plani.movtdc = tipmov.movtdc and
                         plani.etbcod = vetbcod       and
                         plani.pladat = vdata
                         no-lock.
                run processa.
            end.
        end.
    end.

    if vv = "A"
    then
        for each tt-produ use-index i2:
            find movim where recid(movim) = tt-produ.prorec no-lock.
            find produ where produ.procod = movim.procod no-lock.
            
            sal-atu = 0.
            run sal-atu.p (input estab.etbcod,
                           input movim.procod,
                           input vdata1,
                           input vdata2,
                           output sal-atu).
             
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

            find tipmov where tipmov.movtdc = plani.movtdc no-lock no-error.
            if not avail tipmov
            then next.

            if tipmov.movttra
            then if plani.emite = vetbcod
                 then vtipmov = tipmov.movtnom + " DE SAIDA".
                 else vtipmov = tipmov.movtnom + " DE ENTRADA".
            else vtipmov = string(tipmov.movtnom,"x(18)").

            vtotpro = movim.movpc * movim.movqtm.
        
            display plani.pladat format "99/99/99" 
                    plani.numero format ">>>>>>>>9"
                    plani.emite column-label "Emite"
                    plani.desti column-label "Dest" format ">>>>>>>>>9"
                    movim.procod
                    produ.pronom when avail produ format "x(25)"
                    movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
                    movim.movpc  column-label "Pr.Custo" format "->>,>>9.99" 
                    vtotpro  column-label "Total"
                    vtipmov column-label "Movimento" format "x(25)"
                    sal-atu column-label "saldo" format "->>>>>9"
                                with frame f-val1 down no-box width 140.
                    down with frame f-val1.
                    vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).
        end.
    
    if vv = "N"
    then
        for each tt-produ use-index i1:
            find movim where recid(movim) = tt-produ.prorec no-lock.
            find produ where produ.procod = movim.procod no-lock no-error.
            
            sal-atu = 0.            
            run sal-atu.p (input estab.etbcod,
                           input movim.procod,
                           input vdata1,
                           input vdata2,
                           output sal-atu).
            
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

            find tipmov where tipmov.movtdc = plani.movtdc no-lock no-error.
            if not avail tipmov
            then next.

            if tipmov.movttra
            then if plani.emite = vetbcod
                 then vtipmov = tipmov.movtnom + " DE SAIDA".
                 else vtipmov = tipmov.movtnom + " DE ENTRADA".
            else vtipmov = string(tipmov.movtnom,"x(18)").

            vtotpro = (movim.movpc * movim.movqtm).

            display plani.pladat format "99/99/99"
                    plani.numero format ">>>>>>>>9" 
                    plani.emite column-label "Emite"
                    plani.desti column-label "Dest" format ">>>>>>>>>9"
                    movim.procod
                    produ.pronom when avail produ format "x(25)"
                    movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
                    movim.movpc  column-label "Pr.Custo" format "->>,>>9.99" 
                    vtotpro column-label "Total"
                    vtipmov column-label "Movimento" format "x(25)"
                    sal-atu column-label "Saldo" format "->>>>>9"
                    with frame f-val2 down no-box width 140.
             down with frame f-val2.
             vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).
        end.
    
    if vv = "F"
    then
        for each tt-produ use-index i3:
            find movim where recid(movim) = tt-produ.prorec no-lock.                        find produ where produ.procod = movim.procod no-lock no-error.
            
            sal-atu = 0.
            run sal-atu.p (input estab.etbcod,
                           input movim.procod,
                           input vdata1,
                           input vdata2,
                           output sal-atu).
            
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

            find tipmov where tipmov.movtdc = plani.movtdc no-lock no-error.
            if not avail tipmov
            then next.
            vtipmov = string(tipmov.movtdc) + "-" + tipmov.movtnom.

            vtotpro = (movim.movpc * movim.movqtm).        

            display plani.pladat format "99/99/99"
                    plani.numero format ">>>>>>>>>9"
                    plani.emite column-label "Emitente" format ">>>>>>>>>9"
                    plani.desti column-label "Destinat" format ">>>>>>>>>9"
                    movim.procod format ">>>>>>>>>9"
                    produ.pronom when avail produ format "x(25)"
                    movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
                    movim.movpc  column-label "Pr.Custo" format "->>,>>9.99" 
                    vtotpro  column-label "Total"   format ">>>>>>>>>9"
                    vtipmov  column-label "Movimento" format "x(25)"
                    sal-atu  column-label "saldo" format "->>>>>9"
                    with frame f-val3 down no-box width 140.
            down with frame f-val3.
            vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).
        end.

    display vtotmovim label "Total" with frame f-tot3 side-label.

    for each tt-produ break by tt-produ.movtdc
                            by tt-produ.tipemite:
        find movim where recid(movim) = tt-produ.prorec no-lock.

        vmovtnom = "".
        find tipmov where tipmov.movtdc = tt-produ.movtdc no-lock no-error.
        if avail tipmov
        then vmovtnom = tipmov.movtnom.

        vtot = vtot + (movim.movpc * movim.movqtm).
        vtotal = vtotal + (movim.movpc * movim.movqtm).
        
        if last-of(tt-produ.tipemite)
        then do:
            display tt-produ.movtdc
                    vmovtnom format "x(29)"
                    tt-produ.tipemite format "SAIDA/ENTRADA"
                    vtot(total) no-label with frame f-tot down.
            vtot = 0.
        end.
    end.    

    disp skip(5)
        "Quem fez:" space(30)
        "Quem conferiu:"
        skip(4)
        fill("-",30) format "x(30)"
        space(9)
        fill("-",30) format "x(30)"
        skip
        "Assinatura"         at 11
        "Assinatura Gerente" at 47        
        with frame f-ass.

    output close.

    display vtotmovim label "Total"
                      with frame ftot side-label centered.
        
    run visurel.p (input varquivo, input "").
    
    
procedure processa.
    {nf-situacao.i}
    if ind-cancelada = "S"
    then return.

                for each movim where
                             movim.movtdc = plani.movtdc and
                             movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movdat = plani.pladat no-lock:
                    find produ where produ.procod = movim.procod
                               no-lock no-error.
                    if not avail produ
                    then next.
                    if produ.catcod <> vcatcod and vcatcod > 0
                    then next.

                    find first tt-produ where tt-produ.prorec = recid(movim)
                                     no-error.
                    if not avail tt-produ
                    then do:            
                        create tt-produ.
                        assign tt-produ.procod = produ.procod
                               tt-produ.pronom = produ.pronom
                               tt-produ.prorec = recid(movim)
                               tt-produ.numero = plani.numero
                               tt-produ.movtdc = plani.movtdc
                               tt-produ.tipemite = if tipmov.movttra
                                                   then plani.emite = vetbcod
                                                   else tipmov.tipemite.
                    end.        
                end.
    
end procedure.
