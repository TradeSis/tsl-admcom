{admcab.i}

def var varquivo as char.
def var vetbcod     like estab.etbcod.
def var vdata1       like titulo.titdtemi init 06/01/2007.
def var vdata2       like titulo.titdtemi.

def temp-table tt-promo
    field etbcod like estab.etbcod
    field qtdlav as int format ">>>>>9"
    field qtdcen as int format ">>>>>9"
    field qtdsec as int format ">>>>>9".
    
repeat:


    /*update vetbcod colon 20 
           with 1 down side-label width 80 row 4 color blue/white.

    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Filial nao cadastrada.".
        undo.
    end.

    display estab.etbnom no-label.*/
    
    update vdata1 colon 20 label "Data Inicial"
           vdata2 label "Data Final"
           with 1 down side-label width 80 row 4.

    for each movim use-index datsai
                       where movim.procod = 403128
                         and movim.movtdc = 5       
                         and movim.movdat >= vdata1 
                         and movim.movdat <= vdata2 no-lock:

        find first plani where plani.etbcod = movim.etbcod
                           and plani.placod = movim.placod
                           and plani.movtdc = movim.movtdc
                           and plani.pladat = movim.movdat no-lock no-error.
        
        if not avail plani 
        then next.                           
        
        if plani.pedcod <> 17
        then next.
        
        find tt-promo where tt-promo.etbcod = movim.etbcod no-error.
        if not avail tt-promo
        then do:
            create tt-promo.
            assign tt-promo.etbcod = movim.etbcod.
        end.
        
        assign tt-promo.qtdcen = tt-promo.qtdcen + movim.movqtm.
                           
    end.
    
    
    for each movim use-index datsai
                       where movim.procod = 402455
                         and movim.movtdc = 5       
                         and movim.movdat >= vdata1 
                         and movim.movdat <= vdata2 no-lock:

        find first plani where plani.etbcod = movim.etbcod
                           and plani.placod = movim.placod
                           and plani.movtdc = movim.movtdc
                           and plani.pladat = movim.movdat no-lock no-error.
        
        if not avail plani 
        then next.                           
        
        if plani.pedcod <> 17
        then next.
        
        find tt-promo where tt-promo.etbcod = movim.etbcod no-error.
        if not avail tt-promo
        then do:
            create tt-promo.
            assign tt-promo.etbcod = movim.etbcod.
        end.
        
        assign tt-promo.qtdsec = tt-promo.qtdsec + movim.movqtm.
                           
    end.
    
    
    for each produ where  produ.clacod = 177 no-lock.
    
        if produ.fabcod <> 32     and produ.fabcod <> 37 and
           produ.fabcod <> 101609 and produ.fabcod <> 103406
        then next.

       for each movim use-index datsai
                       where movim.procod = produ.procod
                         and movim.movtdc = 5
                         and movim.movdat >= vdata1 
                         and movim.movdat <= vdata2 no-lock:

           find first plani where plani.etbcod = movim.etbcod
                              and plani.placod = movim.placod
                              and plani.movtdc = movim.movtdc
                              and plani.pladat = movim.movdat no-lock no-error.
        
           if not avail plani 
           then next.                           
        
           find tt-promo where tt-promo.etbcod = movim.etbcod no-error.
           if not avail tt-promo 
           then do: 
               create tt-promo. 
               assign tt-promo.etbcod = movim.etbcod. 
           end.
        
           assign tt-promo.qtdlav = tt-promo.qtdlav + movim.movqtm.
       end.
       
    end.

    if opsys = "UNIX" 
    then varquivo = "/admcom/relat/projun01." + string(time). 
    else varquivo = "l:\relat\projun01." + string(time).

    {mdadmcab.i &Saida = "value(varquivo)"
                &Page-Size = "64" 
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""projun01"" 
                &Nom-Sis   = """SISTEMA CREDIARIO""" 
                &Tit-Rel   =
                        """ PROMOCAO MES DE JUNHO (LAVADORA/CENTRIFOGA/SECADORA) "" 
                             + string(vdata1) + "" ATE "" + string(vdata2) "
                &Width     = "80"
                &Form      = "frame f-cab"}

    for each tt-promo no-lock break by tt-promo.etbcod:
        find estab where estab.etbcod = tt-promo.etbcod no-lock no-error.
        
        disp tt-promo.etbcod column-label "Cod!Fil"
             estab.etbnom    column-label "Filial" when avail estab
             tt-promo.qtdlav column-label "Qtd!Lavadora" (total)
             tt-promo.qtdcen column-label "Qtd!Centrifoga" (total)
             tt-promo.qtdsec column-label "Qtd!Secadora" (total)
             with frame f-promo centered down.
             down with frame f-promo.
             
    end.
    
    if opsys = "UNIX"
    then do:
        output close.
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.

end. 