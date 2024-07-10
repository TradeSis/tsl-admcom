{admcab.i}
DEF VAR vdia as date format "99/99/9999" initial today.
def var vimp as log format "80/132" label "Tipo de Impressao".
def var vok as log.
def var vpreco like estoq.estvenda.
def var i as i.
def var vdata like plani.pladat.
def var vqtd  as int format "->>9".
def var vclacod like produ.clacod.
def var vetb  as char format "x(50)".
DEF VAR VDPT AS I FORMAT "99" LABEL "Departamento".
DEF VAR VQTDTOT AS INT FORMAT "->>>9" label "TOT.".
def var vcont   as int initial 0.
def var vtip    as char format "XX".
def var vcol as i format ">".
def buffer bestoq for estoq.

repeat:
    vcont = 0.
    prompt-for categoria.catcod colon 20
                with frame f1 side-label centered color white/red row 7.
    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label with frame f1.
    
    update skip vimp colon 20 with frame f1.
    update skip vdia label "Nao movimentado desde" with frame f1.

    {confir.i 1 "Livro de Preco"}

    def var varquivo as char .
    varquivo = "/admcom/relat/produto-nao-mov." + string(time).
    
    if vimp = no
    then do:
    {mdadm080.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """PRECOLI4"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE NA "" +
                    ""FILIAL "" + string(estab.etbcod)"
        &Width     = "160"
        &Form      = "frame f-cab"}
    end.
    else do:
    {mdadm132.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """PRECOLI4"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE NA "" +
                    ""FILIAL "" + string(estab.etbcod)"
        &Width     = "160"
        &Form      = "frame f-cab2"}
    end.
    for each produ where produ.catcod = categoria.catcod
                                 no-lock break by pronom.

        find first movim where movim.movdat > vdia and
                               movim.procod = produ.procod and
                               (movim.movtdc = 4 or
                               movim.movtdc = 5) no-lock no-error.
        if avail movim
        then next.

        vqtd = 0.
        i = 0.
        vetb = "".
        for each estoq where estoq.procod = produ.procod no-lock:
            vqtd = vqtd + estoq.estatual.
            if estoq.estatual <> 0
            then do:
                vetb = trim(vetb) + " " + string(estoq.etbcod).
            end.
        end.
        if vqtd = 0
        then next.
        find first estoq where estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.

        display produ.procod format ">>>>>>>>9"
                produ.pronom format "x(45)" 
                estoq.estvenda column-label "Preco!Venda"
                estoq.estproper column-label "Preco!Promocao" format ">>,>>9.99"
                            when estoq.estproper <> 0
                vqtd  column-label "Quant!Estoque" format "->,>>9.99" space(3)
                vetb  column-label "Filiais"    
                    with frame f-down down width 210.

    end.
    output close.
    run visurel.p(varquivo,"").
end.
