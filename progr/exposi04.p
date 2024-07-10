{admcab.i}

def var vetbcod like estab.etbcod.
def var vcodexpositor like expositor.codexpositor.
def var vclacod like clase.clacod.

form vetbcod label "Filial   "
     estab.etbnom no-label
     vcodexpositor at 1 label "Expositor"
     expositor.descricao no-label
     vclacod at 1 label "Classe   "
     clase.clanom no-label
     with frame f1 width 80 1 down side-label.
     

do on error undo with frame f1.
    vetbcod = 0.
    update vetbcod .
    if vetbcod > 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock.
        disp estab.etbnom.
    end.    
    vcodexpositor = 0.
    update vcodexpositor.
    if vcodexpositor  > 0
    then do:
        find expositor where expositor.codexpositor = vcodexpositor no-lock.
        disp expositor.descricao.
    end.    
    vclacod = 0.
    update vclacod.
    if vclacod > 0
    then do:
        find clase where clase.clacod = vclacod no-lock.
        disp clase.clanom.
    end.
end.

def var vestatual like estoq.estatual.
def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.

procedure cal-est:
    vestatual = 0.
    for each produ where produ.clacod = clase.clacod no-lock:
        find estoq where estoq.etbcod = exploja.etbcod and
                         estoq.procod = produ.procod
                         no-lock no-error.
        if avail estoq
        then vestatual = vestatual + estoq.estatual.
    end.
    for each bclase where bclase.clasup = clase.clacod no-lock.
        for each produ where produ.clacod = bclase.clacod no-lock:
            find estoq where estoq.etbcod = exploja.etbcod and
                         estoq.procod = produ.procod
                         no-lock no-error.
            if avail estoq
            then vestatual = vestatual + estoq.estatual.
        end.
        for each cclase where cclase.clasup = bclase.clacod no-lock.
            for each produ where produ.clacod = cclase.clacod no-lock:
                find estoq where estoq.etbcod = exploja.etbcod and
                         estoq.procod = produ.procod
                         no-lock no-error.
                if avail estoq
                then vestatual = vestatual + estoq.estatual.
            end.
            for each dclase where dclase.clasup = cclase.clacod no-lock.
                for each produ where produ.clacod = dclase.clacod no-lock:
                    find estoq where estoq.etbcod = exploja.etbcod and
                         estoq.procod = produ.procod
                         no-lock no-error.
                    if avail estoq
                    then vestatual = vestatual + estoq.estatual.
                end.
                for each eclase where eclase.clasup = dclase.clacod no-lock.
                    for each produ where produ.clacod = eclase.clacod no-lock:
                        find estoq where estoq.etbcod = exploja.etbcod and
                             estoq.procod = produ.procod
                             no-lock no-error.
                        if avail estoq
                        then vestatual = vestatual + estoq.estatual.
                    end.
                end.
            end.            
        end.
    end.
        
end procedure.

def temp-table tt-exploja
    field etbcod like estab.etbcod
    field expcod like expositor.codexpositor
    field clacod like clase.clacod
    field qtdexp as int
    field qtdpec as int
    field qtdest as int
    index i1 etbcod.

for each expositor where (if vcodexpositor > 0
               then expositor.codexpositor = vcodexpositor
               else true) no-lock,
    each expcapacidade where
         expcapacidade.codexpositor = expositor.codexpositor and
         ( if vclacod > 0
            then expcapacidade.clacod = vclacod else true) no-lock,
    each exploja where exploja.codexpositor = expcapacidade.codexpositor and
                       exploja.clacod = expcapacidade.clacod and
                       (if vetbcod > 0
                        then exploja.etbcod = vetbcod else true)
                        no-lock:
    find clase where clase.clacod = exploja.clacod no-lock. 
    vestatual = 0.
    run cal-est.

 
    create tt-exploja.
    assign    
        tt-exploja.etbcod = exploja.etbcod
        tt-exploja.expcod = exploja.codexpositor
        tt-exploja.clacod = exploja.clacod
            tt-exploja.qtdexp = exploja.qtdexpositor
            tt-exploja.qtdpec = expcapacidade.quantidade * exploja.qtdexpositor
            tt-exploja.qtdest = tt-exploja.qtdest + vestatual.
end.                           
for each tt-exploja where tt-exploja.qtdexp = 0:
    delete tt-exploja.
end. 
                      
    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/expositor" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\ expositor" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""exposi02"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """CAPACIDADE DE EXPOSITORES POR CLASSE""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}
    disp with frame f1.
    for each tt-exploja no-lock break by tt-exploja.etbcod
                                    by tt-exploja.expcod
                                    by tt-exploja.clacod:
        if first-of (tt-exploja.etbcod)
        then do:
            find estab where estab.etbcod = tt-exploja.etbcod 
                no-lock no-error.
            disp tt-exploja.etbcod column-label "Fil"
                 estab.etbnom no-label when avail estab
                    format "x(20)"
                 with frame f-disp down.
        end.
        if first-of (tt-exploja.expcod)
        then do:
            find expositor where expositor.codexpositor = tt-exploja.expcod
                            no-lock no-error.
            disp tt-exploja.expcod column-label "Expositor"
                 expositor.descricao no-label when avail expositor
                    format "x(30)"
                 with frame f-disp.
        end.
        find clase where clase.clacod = tt-exploja.clacod no-lock no-error.
        disp tt-exploja.clacod  column-label "Classe"
             clase.clanom no-label when avail clase format "x(20)"
             tt-exploja.qtdexp column-label "qtd.Expositor"
             tt-exploja.qtdpec column-label "Qtd.Itens"
             tt-exploja.qtdest column-label "Estoque"
             with frame f-disp down width 150.
        down with frame f-disp.     
    end.
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
