{admcab.i}
def var vpos as i.
def var vqtd as i.
def var vano as i.
def var vmes as i.
def var varquivo as char format "x(20)".
def var i as i.
def var vdt    as date format "99/99/9999".
def var vetb   like estab.etbcod.
def var vcatcod     like produ.catcod.

def var vdti as date.
def var vdtf as date.
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.

def stream stela.
def buffer bprodu for produ.

def var vqtdmov as int.

def temp-table tt-mov
    field procod like produ.procod
    field movqtm like movim.movqtm
    field valmov like movim.movpc
    index i1 procod
    index i2 movqtm descending
    .
    
def temp-table tt-fil
    field etbcod like estab.etbcod
    index i1 etbcod.

repeat:
    for each tt-mov: delete tt-mov. end.
    for each tt-fil: delete tt-fil. end.

    update vetbi at 12 label "Filial"
           vetbf label "Ate"
           vdti at 11 label "Periodo"
           vdtf label "Ate"
           with frame f1 1 down side-label width 80.

    if vetbi > vetbf or
       vetbi = 0
    then next.
    if vdti > vdtf or
       vdti = ? or
       vdtf = ?
    then do:
        bell.
        message color red/with
            "Periodo invalido." view-as alert-box.
        next.
    end.
            
    find estab where estab.etbcod = vetbi no-lock no-error.
    if not avail estab
    then do:
        bell.
        message color red/with
        "Filial " vetbi " não cadastrada." view-as alert-box.
        next.
    end.
    find estab where estab.etbcod = vetbf no-lock no-error.
    if not avail estab
    then do:
        bell.
        message color red/with
        "Filial " vetbf " não cadastrada." view-as alert-box.
        next.
    end.

    update vcatcod at 6 label "Departamento"
                with frame f1.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f1.

    update vqtdmov at 1 label "Quantidade minima" with frame f1.
    
    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:
        create tt-fil.
        tt-fil.etbcod = estab.etbcod.
    end.    
                                
                                
    for each produ where produ.catcod = vcatcod no-lock:
        disp produ.procod format ">>>>>>>>9" with frame f-pro 1 down row 10
            centered color message no-box.
        pause 0.    
        for each tt-fil use-index i1:
            disp tt-fil.etbcod with frame f-pro.
            pause 0.
            for each movim where movim.procod = produ.procod and
                                 movim.etbcod = tt-fil.etbcod and
                                 movim.movdat >= vdti and
                                 movim.movdat <= vdtf
                                 no-lock:
                find first tt-mov where tt-mov.procod = movim.procod no-error.
                if not avail tt-mov
                then create tt-mov.
                assign
                    tt-mov.procod = movim.procod 
                    tt-mov.movqtm = tt-mov.movqtm + movim.movqtm
                    tt-mov.valmov = tt-mov.valmov +
                        (movim.movpc * movim.movqtm)
                    .
            end.
        end.
    end.

    if vqtdmov > 0
    then do:
        for each tt-mov:
            if tt-mov.movqtm < vqtdmov
            then delete tt-mov.
        end.    
    end.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/rel-cve." + string(time).
    else varquivo = "l:~\relat~\rel-cve." + string(time).

    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "120"
            &Page-Line = "66"
            &Nom-Rel   = ""rel-ote""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """PRODUTOS MAIS MOVIMENTADOS """
            &Width     = "120"
            &Form      = "frame f-cabcab"}

    disp with frame f1.
    
    for each tt-mov use-index i2.
        find produ where produ.procod = tt-mov.procod no-lock no-error.
        if not avail produ then next.
        disp produ.procod
             produ.pronom
             tt-mov.movqtm(total)
             tt-mov.valmov(total)
             with frame f-disp down width 120.
    end.
    
    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.

end.
