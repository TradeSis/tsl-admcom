{admcab.i}
def stream stela.
def var ac  as i.
def var tot as i.
def var de  as i.
def var est like estoq.estatual.
def var vtip as char format "x(20)" extent 2 initial ["Numerico","Alfabetico"].
def var varquivo as char.
def var vforcod like forne.forcod.
def temp-table tt-estac like estac.
def var vesc as log format "Sim/Nao".

form estac.etccod
     estac.etcnom with frame fesc down.
    
 
repeat:
    prompt-for estab.etbcod
                with frame f1 side-label width 80.
    find estab using estab.etbcod no-lock.
    disp estab.etbnom no-label with frame f1.

    prompt-for categoria.catcod colon 16 with frame f1.
    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label with frame f1.
    update vforcod label "Fornecedor" colon 16 with frame f1.
    find forne where forne.forcod = vforcod no-lock no-error.
    display forne.fornom no-label with frame f1.
    
    for each tt-estac.
        delete tt-estac.
    end.
    clear frame fesc all.
    for each estac no-lock.
    
        display estac.etccod
                estac.etcnom with frame fesc down centered.
    
    end.            
                
                
    for each estac no-lock:
        vesc = no.
        display estac.etccod
                estac.etcnom with frame fesc.
        update vesc label "Imprimir " with frame fesc.
        down with frame fesc.
        if vesc = yes 
        then do:
            find first tt-estac where tt-estac.etccod = estac.etccod 
                            no-error.
            if not avail tt-estac
            then do:
                create tt-estac.
                assign tt-estac.etccod = estac.etccod
                       tt-estac.etcnom = estac.etcnom.
            end.
        end.
    end.   
    hide frame fesc no-pause.
            
        
    
    
    


    display vtip with frame f-tip no-label.
    choose field vtip with frame f-tip centered row 4.

    varquivo = "l:\relat\inv" + STRING(day(today)) +
                                STRING(month(today)) +
                                string(estab.etbcod,">>9").

 
    output stream stela to terminal.
    
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """inv-free"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE - "" + estab.etbnom + ""  "" +
                        forne.fornom"
        &Width     = "160"
        &Form      = "frame f-cab"}

    if frame-index = 1
    then do:
        
        for each tt-estac,
            each produ where produ.catcod = tt-estac.etccod 
                            no-lock by produ.procod.
            if produ.catcod <> categoria.catcod
            then next.
            if produ.fabcod <> vforcod
            then next.

            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.
            if estoq.estatual <= 0
            then next.
            
            display produ.procod column-label "Codigo"
                    produ.pronom 
                    estoq.estatual(TOTAL) column-label "Qtd." format "->>>>9"
                    estoq.estcusto column-label "Pc.Custo" format ">,>>9.99"
                    (estoq.estcusto * estoq.estatual)(total)
                            column-label "Total Custo" format "->>,>>9.99"
                    estoq.estvenda column-label "Pc.Venda" format ">,>>9.99"
                    (estoq.estvenda * estoq.estatual)(total)
                            column-label "Total Venda" format "->>,>>9.99"
                                with frame f2 down width 200.
            

            display stream stela 
                    estoq.estatual(total) 
                            label "Total em Pecas" format "->>>>>9"
                    (estoq.estcusto * estoq.estatual)(total) 
                        label "Total Custo" format "->>,>>>,>>9.99"
                    (estoq.estvenda * estoq.estatual)(total) 
                        label "Total Venda" format "->>,>>>,>>9.99"
                            with frame ftot1 side-label centered row 10.
            pause 0.
        end.

    end.
    
    else do:
        for each tt-estac,
            each produ use-index catpro
                where produ.catcod = categoria.catcod and
                      produ.etccod = tt-estac.etccod  and
                      produ.fabcod = vforcod no-lock.
                
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.

            if estoq.estatual <= 0
            then next.
            
            display produ.procod column-label "Codigo"
                    produ.pronom 
                    estoq.estatual(TOTAL) column-label "Qtd." format "->>>>9"
                    
                    estoq.estcusto column-label "Pc.Custo" 
                            format "->>,>>>,>>9.99"
                    (estoq.estcusto * estoq.estatual)(total)
                            column-label "Total Custo" format "->>,>>>,>>9.99"
                                    
                    estoq.estvenda column-label "Pc.Venda" 
                            format "->>,>>>,>>9.99"
                    (estoq.estvenda * estoq.estatual)(total)
                            column-label "Total Venda" format "->>,>>>,>>9.99"
                                    with frame f3 down width 200.
        
            display stream stela 
                    estoq.estatual(total) 
                        label "Total em Pecas" format "->>>>>9"
                    (estoq.estcusto * estoq.estatual)(total) 
                            label "Total Custo" 
                            format "->>,>>>,>>9.99"
                    (estoq.estvenda * estoq.estatual)(total) 
                            label "Total Venda"  format "->>,>>>,>>9.99"
                            with frame ftot2 side-label centered row 10.
            pause 0.

        end.
    end.

    output close.
    output stream stela close.
 
    {confir.i 1 "Listagem de Inventario"}
     
    dos silent value("type " + varquivo + " > prn").
    

end.
