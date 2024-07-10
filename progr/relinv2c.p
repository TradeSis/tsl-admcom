{admcab.i}

{extrato12-def.i new}

def input parameter p-estab  like estab.etbcod.
def input parameter p-catcod like categoria.catcod.
def input parameter p-data   as   date format "99/99/9999".
def input parameter p-tipo   as   int.
def input parameter p-estacao as int.
def input parameter p-clase as int.

def shared temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def temp-table tt-produ
    field procod like produ.procod
    field estccod like produ.etccod
    field qtdest like estoq.estatual
    field estcusto like estoq.estcusto
    field estvenda like estoq.estvenda
    .

def temp-table tt-estacao
    field etccod like estac.etccod
    index i1 etccod.
 
find estab where estab.etbcod = p-estab no-lock no-error.
find categoria where categoria.catcod = p-catcod no-lock no-error.


def stream stela.


def var ac  as i.
def var tot as i.
def var de  as i.
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


    vdata = p-data.
    
    
    if opsys = "UNIX"
    then do:
            assign varquivo = "/admcom/relat/inv" + STRING(day(vdata)) +
                              string(month(vdata)) +
                              string(estab.etbcod,"999") +
                              "." + string(time).
    end.
    else do:
            assign varquivo = "l:\relat\inv" + STRING(day(vdata)) +
                              string(month(vdata)) +
                              string(estab.etbcod,">>9")
                              + "." + string(time).
    end.
 
    output stream stela to terminal.
    
    {mdad_l.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"  /* 86 */
        &Cond-Var  = "147"
        &Page-Line = "64" /* 86 */
        &Nom-Rel   = """relinv2"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE - "" + estab.etbnom + ""  "" +
                        categoria.catnom + "" Data: "" +
                        string(vdata,""99/99/9999"")"
        &Width     = "147"
        &Form      = "frame f-cab"}

    if p-tipo = 1
    then do:

        for each produ no-lock.

            if produ.catcod <> categoria.catcod
            then next.

            if p-estacao > 0 and
               produ.etccod <> p-estacao
            then next.
               
            if p-clase > 0 and
                not can-find (first tt-clase where 
                                    tt-clase.clacod = produ.clacod)
            then next. 
            
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.
            est = estoq.estatual.
            
            for each tt-saldo: delete tt-saldo. end.
            for each tt-movest: delete tt-movest. end.
            sal-atu = 0.
            sal-ant = 0.
            t-sai = 0.
            t-ent = 0.
            vdata2 = vdata.
            vdata1 = date(month(vdata2),01,year(vdata2)).
            vetbcod = estab.etbcod.
            vprocod = produ.procod.
    
            vdisp = no.
    
            if vetbcod = 981
            then run movest11-e.p.
            else run movest11.p.

            find first tt-saldo where
                       tt-saldo.ano-cto = 0  and
                       tt-saldo.mes-cto = 0  and
                       tt-saldo.etbcod = vetbcod and
                       tt-saldo.procod = vprocod
            no-lock no-error.
            if avail tt-saldo 
            then est = tt-saldo.sal-atu.
            else est = estoq.estatual.

            /*
            est = sal-atu.
            */
            /***********************
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
            *******************/
                
            if est = 0
            then next.
            
            create tt-produ.
            assign
                tt-produ.procod  = produ.procod
                tt-produ.estccod = produ.etccod
                tt-produ.qtdest  = est
                tt-produ.estcusto = estoq.estcusto
                tt-produ.estvenda = estoq.estvenda
                .
            /*
            display produ.procod column-label "Codigo"
                    produ.pronom FORMAT "x(35)"
                    est (TOTAL) column-label "Qtd." format "->>>>>9"
                    /*
                    estoq.estcusto column-label "Pc.Custo" format "->>>,>>9.99"
                    (estoq.estcusto * EST)(total)
                          column-label "Total Custo" format "->>>,>>9.99"
                    */
                                   
                    estoq.estvenda column-label "Pc.Venda" format "->>>,>>9.99"
                    
                    (estoq.estvenda * EST)(total)
                          column-label "Total Venda" format "->>>,>>9.99"
                                     
                                with frame f2 down width 200.
            
            */
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
            
            if p-estacao > 0 and
               produ.etccod <> p-estacao
            then next.
               
            if p-clase > 0 and
                not can-find (first tt-clase where 
                                    tt-clase.clacod = produ.clacod)
            then next. 
                
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.
            
            est = estoq.estatual.
            
            for each tt-saldo: delete tt-saldo. end.
            for each tt-movest: delete tt-movest. end.
            sal-atu = 0.
            sal-ant = 0.
            t-sai = 0.
            t-ent = 0.
            vdata2 = vdata.
            vdata1 = date(month(vdata2),01,year(vdata2)).
            vetbcod = estab.etbcod.
            vprocod = produ.procod.
    
            vdisp = no.
    
            if vetbcod = 981
            then run movest11-e.p.
            else run movest11.p.

            find first tt-saldo where
                       tt-saldo.ano-cto = 0  and
                       tt-saldo.mes-cto = 0  and
                       tt-saldo.etbcod = vetbcod and
                       tt-saldo.procod = vprocod
            no-lock no-error.
            if avail tt-saldo 
            then est = tt-saldo.sal-atu.
            else est = estoq.estatual.
            /*
            est = sal-atu.
            */
            
            /*******
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
            ***************/
            
            
            if est = 0
            then next.
            
            create tt-produ.
            assign
                tt-produ.procod  = produ.procod
                tt-produ.estccod = produ.etccod
                tt-produ.qtdest  = est
                tt-produ.estcusto = estoq.estcusto
                tt-produ.estvenda = estoq.estvenda
                .

            /*
            display produ.procod column-label "Codigo"
                    produ.pronom FORMAT "x(35)"
                    est (TOTAL) column-label "Qtd." format "->>>>>9"
                    /*
                    estoq.estcusto column-label "Pc.Custo" 
                            format "->>>,>>9.99"
                    (estoq.estcusto * EST)(total)
                            column-label "Total Custo" format "->>,>>>,>>9.99"
                      */      
                    estoq.estvenda column-label "Pc.Venda" format "->>>,>>9.99"
                    (estoq.estvenda * EST)(total)
                          column-label "Total Venda" format "->>>,>>9.99"
                          
                            
                            
                                    with frame f3 down width 200.
            */
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

    for each tt-produ:
        find first tt-estacao where tt-estacao.etccod = tt-produ.estccod
                    no-error.
        if not avail tt-estacao
        then do:
            create tt-estacao.
            tt-estacao.etccod = tt-produ.estccod.
        end.
    end.
    for each tt-estacao:
                            
        find estac where estac.etccod = tt-estacao.etccod
                        no-lock.
        put "Estacao : " estac.etcnom skip(1).  
            
    for each tt-produ /*break by tt-produ.estccod*/
            where tt-produ.estccod = tt-estacao.etccod:
        find produ where produ.procod = tt-produ.procod no-lock no-error.
        /*
        if first-of(tt-produ.estccod)
        then do:
            find estac where estac.etccod = tt-produ.estccod
                        no-lock.
            put "Estacao : " estac.etcnom skip.            
        end.
        */
        display produ.procod column-label "Codigo"
                produ.pronom FORMAT "x(35)"
                tt-produ.qtdest (TOTAL) column-label "Qtd." format "->>>>>9"
                tt-produ.estcusto column-label "Pc.Custo" 
                            format "->>>,>>9.99"
                (tt-produ.estcusto * tt-produ.qtdest)(total)
                            column-label "Total Custo" format "->>,>>>,>>9.99"
                            
                 tt-produ.estvenda column-label "Pc.Venda" format "->>>,>>9.99"
                 (tt-produ.estvenda * tt-produ.qtdest)(total)
                          column-label "Total Venda" format "->>>,>>9.99"
                                    with frame f3 down width 200.
        down with frame f3.
    end.
    end.

    output close.
    output stream stela close.

    if opsys = "UNIX"
    then do:        
        run visurel.p (input varquivo,"").
    end.
    else do:
        {mrod_l.i}.
    end.

    update lEtiqueta label "Geracao Etiquetas "
           with frame f-1 side-labels 1 col width 40
                row 15 col 10 title "GERA ETIQUETAS".
    if lEtiqueta = yes
    then do:
          
             run etq3cl1a.p (input table tt-etiqueta,
                             input "relinv").
    end. 
