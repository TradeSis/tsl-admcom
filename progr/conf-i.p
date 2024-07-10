{admcab.i}
def var ac  as i.
def var tot as i.
def var de  as i.
def var vdata like plani.pladat.
def var est like estoq.estatual.

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

    {confir.i 1 "Posicao de Estoque"}
    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """LISCONF"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE - "" + estab.etbnom + ""  "" +
                                                   categoria.catnom "
        &Width     = "160"
        &Form      = "frame f-cab"}

    for each produ no-lock by pronom.

        if produ.catcod <> categoria.catcod
        then next.

        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-error.
        if not avail estoq
        then next.
        if estoq.estbaldat <> vdata
        then next.
        est = estoq.estatual.
        for each movim where movim.procod = produ.procod and
                             movim.movdat >= vdata + 1 no-lock:

        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod no-lock no-error.

        if not avail plani
        then next.
        find tipmov of movim no-lock.
        if plani.etbcod = estab.etbcod or
        plani.desti  = estab.etbcod
        then do:
            if movim.movtdc <> 6
            then do:
                if tipmov.movtdeb
                then est = est + movim.movqtm.
                else est = est - movim.movqtm.
            end.
            else do:
                if plani.etbcod = estab.etbcod
                then est = est + movim.movqtm.
                if plani.desti = estab.etbcod
                then est = est - movim.movqtm.
            end.
        end.
    end.
    ac = 0.
    de = 0.
    tot = 0.

    ac = estinvctm - est.
    de = est - estinvctm.


    if est = estinvctm
    then next.

    /**
    if ac > 0
    then assign tot = ac
                estoq.estmgluc = ac.
    else assign tot = de
                estoq.estmgoper = de.
    **/


    display produ.procod column-label "Codigo"
            produ.pronom FORMAT "x(35)"
            est (TOTAL) column-label "Qtd." format "->>>>9"
            estoq.estinvctm (total) column-label "Dig." format "->>>>9"
            ac when ac > 0 column-label "Acresc."
            de when de > 0 column-label "Decres."
            estoq.estcusto column-label "Pc.Custo" format ">,>>9.99"
            (estoq.estcusto * tot)(total)
                    column-label "Total Custo" format ">>,>>>,>>9.99"
                with frame f2 down width 200.
    end.
    output close.
end.
