{admcab.i}
def var vdata like plani.pladat.
def var sal-atu like estoq.estatual format "->,>>9.99".
def var vforcod like produ.fabcod.
repeat:

    prompt-for estab.etbcod
                with frame f1 side-label centered color white/red row 7.
    find estab using estab.etbcod no-lock.
    disp estab.etbnom no-label with frame f1.

    prompt-for categoria.catcod colon 16 with frame f1.
    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label with frame f1.
    update vforcod colon 16 with frame f1.
    if vforcod <> 0
    then do:
        find forne where forne.forcod = vforcod no-lock.
        display forne.fornom no-label with frame f1.
    end.
    else display "GERAL" @ forne.fornom with frame f1.

    update vdata label "Data" colon 16 with frame f1.



    {confir.i 1 "Posicao de Estoque"}
    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = """POSESTL0"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE NEGATIVO - ""
                      + estab.etbnom + ""  "" +
                                                   categoria.catnom "
        &Width     = "80"
        &Form      = "frame f-cab"}
    if vforcod = 0
    then do:

        for each produ no-lock by pronom.

            if produ.catcod <> categoria.catcod
            then next.

            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.

            sal-atu = estoq.estatual.

            for each movim where movim.procod = produ.procod and
                                 movim.movdat >= vdata no-lock:

                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat
                                                no-lock no-error.

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

                find tipmov of movim no-lock.
                if movim.movtdc = 5 or
                   movim.movtdc = 13 or
                   movim.movtdc = 14 or
                   movim.movtdc = 16 or
                   movim.movtdc = 8  or
                   movim.movtdc = 18
                   then if movim.movdat > vdata
                        then sal-atu = sal-atu + movim.movqtm.

                if movim.movtdc = 4 or
                   movim.movtdc = 1 or
                   movim.movtdc = 7 or
                   movim.movtdc = 12 or
                   movim.movtdc = 15 or
                   movim.movtdc = 17
                then if movim.movdat > vdata
                     then sal-atu = sal-atu - movim.movqtm.

                if movim.movtdc = 6
                then do:
                    if plani.etbcod = estab.etbcod
                    then if movim.movdat > vdata
                         then sal-atu = sal-atu + movim.movqtm.
                    if plani.desti = estab.etbcod
                    then if movim.movdat > vdata
                         then sal-atu = sal-atu - movim.movqtm.
                end.
            end.

            if sal-atu >= 0
            then next.

            display produ.procod column-label "Codigo"
                    produ.pronom FORMAT "x(35)"
                    sal-atu (TOTAL) column-label "Qtd." format "->>>>9"
                    estoq.estcusto column-label "Pc.Custo" format ">,>>9.99"
                    (estoq.estatual * estoq.estcusto) (TOTAL)
                                                        column-label "Total"
                                                       format "->,>>>,>>9.99"
                                with frame f2 down width 80.
        end.
    end.
    else do:
        for each produ where produ.catcod = categoria.catcod and
                             produ.fabcod = vforcod no-lock.

            if produ.catcod <> categoria.catcod
            then next.

            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.

            sal-atu = estoq.estatual.

            for each movim where movim.procod = produ.procod and
                                 movim.movdat >= vdata no-lock:

                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat
                                                no-lock no-error.

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

                find tipmov of movim no-lock.
                if movim.movtdc = 5 or
                   movim.movtdc = 13 or
                   movim.movtdc = 14 or
                   movim.movtdc = 16 or
                   movim.movtdc = 8  or
                   movim.movtdc = 18
                   then if movim.movdat > vdata
                        then sal-atu = sal-atu + movim.movqtm.

                if movim.movtdc = 4 or
                   movim.movtdc = 1 or
                   movim.movtdc = 7 or
                   movim.movtdc = 12 or
                   movim.movtdc = 15 or
                   movim.movtdc = 17
                then if movim.movdat > vdata
                     then sal-atu = sal-atu - movim.movqtm.

                if movim.movtdc = 6
                then do:
                    if plani.etbcod = estab.etbcod
                    then if movim.movdat > vdata
                         then sal-atu = sal-atu + movim.movqtm.
                    if plani.desti = estab.etbcod
                    then if movim.movdat > vdata
                         then sal-atu = sal-atu - movim.movqtm.
                end.
            end.

            if sal-atu >= 0
            then next.


            display produ.procod column-label "Codigo"
                    produ.pronom FORMAT "x(35)"
                    sal-atu (TOTAL) column-label "Qtd." format "->>>>9"
                    estoq.estcusto column-label "Pc.Custo" format ">,>>9.99"
                    (estoq.estatual * estoq.estcusto) (TOTAL)
                                                        column-label "Total"
                                                       format "->,>>>,>>9.99"
                                with frame ff2 down width 80.
        end.

    end.
    output close.
end.
