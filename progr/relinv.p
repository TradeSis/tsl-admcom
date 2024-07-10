{admcab.i}

def stream stela.
def var ac  as i.
def var tot as i.
def var de  as i.
def var vdata like plani.pladat.
def var est like estoq.estatual.
def var vtip as char format "x(20)" extent 2 initial ["Numerico","Alfabetico"].
def var varquivo as char.
def var lEtiqueta       as logi form "Sim/Nao"        init no        no-undo.
def var iContEtq        as inte form ">>>>>9"         init 0         no-undo.   

def temp-table tt-etiqueta                 no-undo
    field rProdu    as recid
    field qtd-etq   as inte  form ">>>>>9"
    field procod    like produ.procod
    field pronom    like produ.pronom
    field qtdest    like estoq.estatual.

repeat:
    prompt-for estab.etbcod
                with frame f1 side-label centered color white/red row 7.
    find estab using estab.etbcod no-lock.
    disp estab.etbnom no-label skip(1) with frame f1.

    prompt-for categoria.catcod
                with frame f1.
    update vdata with frame f1.
    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label with frame f1.


    display vtip with frame f-tip no-label.
    choose field vtip with frame f-tip centered row 4.

    if opsys = "UNIX"
    then do:
            assign varquivo = "/admcom/relat/inv" + STRING(day(vdata)) +
                              string(month(vdata)) +
                              string(estab.etbcod,">>9").
    end.
    else do:
            assign varquivo = "l:\relat\inv" + STRING(day(vdata)) +
                              string(month(vdata)) +
                              string(estab.etbcod,">>9").
    end.
 
    output stream stela to terminal.
    
    {mdad_l.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"  /* 86 */
        &Cond-Var  = "147"
        &Page-Line = "64" /* 86 */
        &Nom-Rel   = """relinv"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE - "" + estab.etbnom + ""  "" +
                        categoria.catnom + "" Data: "" +
                        string(vdata,""99/99/9999"")"
        &Width     = "147"
        &Form      = "frame f-cab"}

    if frame-index = 1
    then do:
        for each produ no-lock.

            if produ.catcod <> categoria.catcod
            then next.

            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.
            est = estoq.estatual.
            
            
            for each movim where movim.etbcod = estab.etbcod and
                                 movim.procod = produ.procod and
                                 movim.movtdc = 08           and
                                 movim.movdat > vdata no-lock:
            
            
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat 
                                         use-index plani no-lock no-error.

                if not avail plani 
                then next.
            

                est = est + movim.movqtm.
            
            end.
            
            
            for each movim where movim.etbcod = estab.etbcod and
                                 movim.procod = produ.procod and
                                 movim.movtdc = 07           and
                                 movim.movdat > vdata no-lock:
            
            
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat 
                                         use-index plani no-lock no-error.

                if not avail plani 
                then next.
            
                est = est - movim.movqtm.

            end.
            
            for each movim where movim.procod = produ.procod and
                                 movim.emite  = estab.etbcod and
                                 movim.datexp > vdata no-lock:
            
                if movim.movtdc = 7 or
                   movim.movtdc = 8
                then next.

            
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat 
                                         use-index plani no-lock no-error.

                if not avail plani 
                then next.
            
                if plani.etbcod <> estab.etbcod and 
                   plani.desti  <> estab.etbcod
                then next.

                if plani.emite = 22 and 
                   plani.serie = "m1" 
                then next.

                if plani.movtdc = 5 and 
                   plani.emite  <> estab.etbcod 
                then next.

                if movim.movtdc = 5 or
                   movim.movtdc = 13 or
                   movim.movtdc = 14 or
                   movim.movtdc = 16 or
                   movim.movtdc = 8  or
                   movim.movtdc = 18
                then do: 
                    if movim.movdat >= vdata
                    then est = est + movim.movqtm.
                end.

                if movim.movtdc = 4 or
                   movim.movtdc = 1 or
                   movim.movtdc = 7 or 
                   movim.movtdc = 12 or 
                   movim.movtdc = 15 or 
                   movim.movtdc = 17 
                then do: 
                    if movim.movdat >= vdata
                    then est = est - movim.movqtm.
                end.

                if movim.movtdc = 6
                then do:
                    if plani.etbcod = estab.etbcod
                    then do:
                        if movim.movdat >= vdata
                        then est = est + movim.movqtm.
                    end.
                    if plani.desti = estab.etbcod
                    then do:
                        if movim.movdat >= vdata
                        then est = est - movim.movqtm.
                    end.
                end.
            end.
        
            for each movim where movim.procod = produ.procod and
                                 movim.desti  = estab.etbcod and
                                 movim.datexp > vdata no-lock:

                if movim.movtdc = 7 or
                   movim.movtdc = 8
                then next.

             
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat
                                           no-lock no-error.

                if not avail plani
                then next.
            
                if avail plani
                then do:
                    if plani.emite = 22 and desti = 996
                    then next.
                
                end.
            
                if movim.movtdc = 5  or  
                   movim.movtdc = 12 or  
                   movim.movtdc = 13 or  
                   movim.movtdc = 14 or  
                   movim.movtdc = 16 
                then next.
            
            
                if plani.etbcod <> estab.etbcod and
                   plani.desti  <> estab.etbcod
                then next.

                if plani.emite = 22 and
                   plani.serie = "m1"
                then next.

                if plani.movtdc = 5 and
                   plani.emite  <> estab.etbcod
                then next.
                if movim.movtdc = 5 or
                   movim.movtdc = 13 or
                   movim.movtdc = 14 or
                   movim.movtdc = 16 or
                   movim.movtdc = 8  
                then do:
                    if movim.movdat >= vdata
                    then est = est + movim.movqtm.
                end.

                if movim.movtdc = 4 or
                   movim.movtdc = 1 or
                   movim.movtdc = 7 or
                   movim.movtdc = 12 or
                   movim.movtdc = 15 
                then do:
                    if movim.movdat >= vdata
                    then est = est - movim.movqtm.
                end.

                if movim.movtdc = 6
                then do:
                    if plani.etbcod = estab.etbcod
                    then do:
                        if movim.movdat >= vdata
                        then est = est + movim.movqtm.
                    end.
                    if plani.desti = estab.etbcod
                    then do:
                        if movim.movdat >= vdata
                        then est = est - movim.movqtm.
                    end.
                end.
            end.    
            
                
            if est = 0
            then next.
            
            display produ.procod column-label "Codigo"
                    produ.pronom FORMAT "x(35)"
                    est (TOTAL) column-label "Qtd." format "->>>>>9"
                    estoq.estcusto column-label "Pc.Custo" format "->>>,>>9.99"
                    (estoq.estcusto * EST)(total)
                          column-label "Total Custo" format "->>>,>>9.99"
                          
                    estoq.estvenda column-label "Pc.Venda" format "->>>,>>9.99"
                    (estoq.estvenda * EST)(total)
                          column-label "Total Venda" format "->>>,>>9.99"
                          
                                with frame f2 down width 200.
            

            display stream stela 
                    est(total) label "Total em Pecas" format "->>>>>9"
                    (estoq.estcusto * est)(total) label "Total em Valor"
                            format "->>,>>>,>>9.99"
                            with frame ftot1 side-label centered row 10.
            pause 0.
            
            /* ETIQUETAS *************************** */
            if est > 0
            then do:
                    create tt-etiqueta.
                    assign tt-etiqueta.rprodu  = recid(produ)
                           tt-etiqueta.qtd-etq = est
                           tt-etiqueta.procod  = produ.procod
                           tt-etiqueta.pronom  = produ.pronom
                           tt-etiqueta.qtdest  = est.
            end.               
            /* ************************************* */ 
            
        end.

    end.
    
    else do:
        for each produ use-index catpro
                where produ.catcod = categoria.catcod no-lock.
                
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.
            
            est = estoq.estatual.
            
            
            for each movim where movim.etbcod = estab.etbcod and
                                 movim.procod = produ.procod and
                                 movim.movtdc = 08           and
                                 movim.movdat > vdata no-lock:
            
            
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat 
                                         use-index plani no-lock no-error.

                if not avail plani 
                then next.
            

                est = est + movim.movqtm.
            
            end.
            
            
            for each movim where movim.etbcod = estab.etbcod and
                                 movim.procod = produ.procod and
                                 movim.movtdc = 07           and
                                 movim.movdat > vdata no-lock:
            
            
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat 
                                         use-index plani no-lock no-error.

                if not avail plani 
                then next.
            
                est = est - movim.movqtm.

            end.
            
            for each movim where movim.procod = produ.procod and
                                 movim.emite  = estab.etbcod and
                                 movim.datexp > vdata no-lock:
 
                if movim.movtdc = 7 or
                   movim.movtdc = 8
                then next.

                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat 
                                         use-index plani no-lock no-error.

                if not avail plani 
                then next.
            
                if plani.etbcod <> estab.etbcod and 
                   plani.desti  <> estab.etbcod
                then next.

                if plani.emite = 22 and 
                   plani.serie = "m1" 
                then next.

                if plani.movtdc = 5 and 
                   plani.emite  <> estab.etbcod 
                then next.

                if movim.movtdc = 5 or
                   movim.movtdc = 13 or
                   movim.movtdc = 14 or
                   movim.movtdc = 16 or
                   movim.movtdc = 8  or
                   movim.movtdc = 18
                then do: 
                    if movim.movdat >= vdata
                    then est = est + movim.movqtm.
                end.

                if movim.movtdc = 4 or
                   movim.movtdc = 1 or
                   movim.movtdc = 7 or 
                   movim.movtdc = 12 or 
                   movim.movtdc = 15 or 
                   movim.movtdc = 17 
                then do: 
                    if movim.movdat >= vdata
                    then est = est - movim.movqtm.
                end.

                if movim.movtdc = 6
                then do:
                    if plani.etbcod = estab.etbcod
                    then do:
                        if movim.movdat >= vdata
                        then est = est + movim.movqtm.
                    end.
                    if plani.desti = estab.etbcod
                    then do:
                        if movim.movdat >= vdata
                        then est = est - movim.movqtm.
                    end.
                end.
            end.
        
            for each movim where movim.procod = produ.procod and
                                 movim.desti  = estab.etbcod and
                                 movim.datexp > vdata no-lock:

                if movim.movtdc = 7 or
                   movim.movtdc = 8
                then next.

                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat
                                           no-lock no-error.

                if not avail plani
                then next.
            
                if avail plani
                then do:
                    if plani.emite = 22 and desti = 996
                    then next.
                
                end.
            
                if movim.movtdc = 5  or  
                   movim.movtdc = 12 or  
                   movim.movtdc = 13 or  
                   movim.movtdc = 14 or  
                   movim.movtdc = 16 
                then next.
            
            
                if plani.etbcod <> estab.etbcod and
                   plani.desti  <> estab.etbcod
                then next.

                if plani.emite = 22 and
                   plani.serie = "m1"
                then next.

                if plani.movtdc = 5 and
                   plani.emite  <> estab.etbcod
                then next.
                if movim.movtdc = 5 or
                   movim.movtdc = 13 or
                   movim.movtdc = 14 or
                   movim.movtdc = 16 or
                   movim.movtdc = 8  
                then do:
                    if movim.movdat >= vdata
                    then est = est + movim.movqtm.
                end.

                if movim.movtdc = 4 or
                   movim.movtdc = 1 or
                   movim.movtdc = 7 or
                   movim.movtdc = 12 or
                   movim.movtdc = 15 
                then do:
                    if movim.movdat >= vdata
                    then est = est - movim.movqtm.
                end.

                if movim.movtdc = 6
                then do:
                    if plani.etbcod = estab.etbcod
                    then do:
                        if movim.movdat >= vdata
                        then est = est + movim.movqtm.
                    end.
                    if plani.desti = estab.etbcod
                    then do:
                        if movim.movdat >= vdata
                        then est = est - movim.movqtm.
                    end.
                end.
            end.    
            
            if est = 0
            then next.

            display produ.procod column-label "Codigo"
                    produ.pronom FORMAT "x(35)"
                    est (TOTAL) column-label "Qtd." format "->>>>>9"
                    estoq.estcusto column-label "Pc.Custo" 
                            format "->>>,>>9.99"
                    (estoq.estcusto * EST)(total)
                            column-label "Total Custo" format "->>,>>>,>>9.99"
                            
                    estoq.estvenda column-label "Pc.Venda" format "->>>,>>9.99"
                    (estoq.estvenda * EST)(total)
                          column-label "Total Venda" format "->>>,>>9.99"
                          
                            
                            
                                    with frame f3 down width 200.
        
            display stream stela 
                    est(total)   label "Total em Pecas" format "->>>>>>9"
                    (estoq.estcusto * est)(total) label "Total em Valor" 
                            format "->>,>>>,>>9.99"
                            with frame ftot2 side-label centered row 10.
            pause 0.
            
            /* ETIQUETAS *************************** */
            if est > 0
            then do:
                 create tt-etiqueta.
                 assign tt-etiqueta.rprodu  = recid(produ)
                        tt-etiqueta.qtd-etq = est
                        tt-etiqueta.procod  = produ.procod
                        tt-etiqueta.pronom  = produ.pronom
                        tt-etiqueta.qtdest  = est.
            end. 
            /* ************************************* */ 
           
        end.
    end.

    output close.
    output stream stela close.

    if opsys = "WIN32"
    then do:
            {mrod_l.i}.
    end.
    if opsys = "UNIX"
    then do:        
           run visurel.p (input varquivo,"").
    end.

    update lEtiqueta label "Geracao Etiquetas "
           with frame f-1 side-labels 1 col width 40
                row 15 col 10 title "GERA ETIQUETAS".
    if lEtiqueta = yes
    then do:
          
             run etq3cl1a.p (input table tt-etiqueta,
                             input "relinv").
    end. 

end.
