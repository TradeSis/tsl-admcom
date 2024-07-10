{admcab.i}
def var vcatcod like categoria.catcod.
def var wmark as dec.
def var wperven as dec.
def var i as i.
def var vdti as date label "Data Inicial de Venda" format "99/99/9999".
def var vdtf as date label "Data Final de Venda"   format "99/99/9999".
def var vcli like clase.clacod label "Classe Inicial".
def var vclf like clase.clacod label "Classe Final".
def var westtotal  like plani.platot.
def var wventotal  like plani.platot.
def var vetbcod like estab.etbcod.
def var westtotqtd as i label "Estoque".
def var westqtd as i.
def var wventotqtd as i label "Qtd.Ven.".
def var westtotalqtd like estoq.estatual.
def var wventotalqtd as i.
def var wvenqtd as i.
def var vmes as int format ">9".
def var vano as int format ">>>9".
def temp-table whiest
    field clacod like clase.clacod
    field clanom like clase.clanom
    field estvalor  like plani.platot column-label "Vl.Custo"
    field estqtd    as i label "Estoque"
    field venvalor  like plani.platot column-label "Vl.Custo"
    field venqtd    as i label "Qtd.Ven."
    field venvenda  like plani.platot
    field estcusto    like estoq.estcusto
    field estvenda  like estoq.estvenda.
do:
    vetbcod = 0.
    vano = 1997.
    
    update vcatcod label "Departamento" colon 25
                with frame f1.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f1.

  update vetbcod colon 25 skip
           vcli    colon 25
           vclf    colon 60
           vdti    colon 25
           vdtf    colon 60 with frame f1 side-label width 80.
  pause 0 before-hide.

    for each produ where produ.catcod = categoria.catcod and
                         produ.clacod >= vcli and
                         produ.clacod <= vclf no-lock :
        display produ.clacod produ.procod with 1 down centered. pause 0.
        westqtd = 0.
        if vetbcod > 0
        then do:
            find estoq where estoq.etbcod = vetbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.
            if estoq.estatual <> ?
            then westqtd = westqtd + estoq.estatual.
        end.
        else do:
            for each estoq where estoq.procod = produ.procod:
                if estoq.estatual <> ?
                then westqtd = westqtd + estoq.estatual.
            end.
        end.

        wvenqtd = 0.
        if vetbcod > 0
        then do:
            for each movim where movim.etbcod = vetbcod and
                                 movim.movtdc = 5 and
                                 movim.procod = produ.procod and
                                 movim.movdat >= vdti and
                                 movim.movdat <= vdtf:
                wvenqtd = wvenqtd + movim.movqtm.
            end.
            for each movim where movim.etbcod = vetbcod and
                                 movim.movtdc = 12 and
                                 movim.procod = produ.procod and
                                 movim.movdat >= vdti and
                                 movim.movdat <= vdtf:
                wvenqtd = wvenqtd - movim.movqtm.
            end.
        end.
        else do:
            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 5 and
                                 movim.movdat >= vdti and
                                 movim.movdat <= vdtf:
                wvenqtd = wvenqtd + movim.movqtm.
            end.
            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 12 and
                                 movim.movdat >= vdti and
                                 movim.movdat <= vdtf:
                wvenqtd = wvenqtd - movim.movqtm.
            end.
        end.

        find first estoq where estoq.procod  = produ.procod no-lock no-error.
        if not avail estoq
        then next.
        if estoq.estcusto = ?
        then next.

        find first whiest where whiest.clacod = produ.clacod no-error.
        if not avail whiest
        then do:
            create whiest.
            assign whiest.clacod = produ.clacod.
            find clase where clase.clacod = whiest.clacod.
            assign whiest.clanom = clase.clanom.
        end.
        /*
        do i = 1 to 2:
            find estoq where estoq.procod = produ.procod and
                             estoq.etbcod = i no-lock no-error.
            if not avail estoq
            then next.
            whiest.estcusto   = whiest.estcusto   + estoq.estcusto.
            whiest.estvenda = whiest.estvenda + estoq.estvenda.
        end.
        */

        whiest.estcusto = estoq.estcusto.
        whiest.estvenda = estoq.estvenda.

        whiest.estvalor = whiest.estvalor + (westqtd * estoq.estcusto).
        westtotal = westtotal + (westqtd * estoq.estcusto).
        whiest.estqtd = whiest.estqtd + westqtd.
        westtotalqtd = westtotalqtd + westqtd.

        whiest.venvalor = whiest.venvalor + (wvenqtd * estoq.estcusto).
        whiest.venvenda = whiest.venvenda + (wvenqtd * estoq.estvenda).
        wventotal = wventotal + (wvenqtd * estoq.estcusto).
        whiest.venqtd = whiest.venqtd + wvenqtd.
        wventotalqtd = wventotalqtd + wvenqtd.
    end.
    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "150"
        &Page-Line = "66"
        &Nom-Rel   = ""ESTVEN""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &Tit-Rel   = """RELATORIO DE ESTOQUE/VENDIDO POR CLASSE NA LOJA "" +
                     string(vetbcod) + "" - "" + string(vdti) + "" A "" +
                                                 string(vdtf)"
        &Width     = "150"
        &Form      = "frame f-cabcab"}

    for each whiest where whiest.venqtd > 0 or
                          whiest.estqtd > 0
                           break by whiest.clacod:

        wmark = whiest.venvenda / whiest.venvalor.

        if wmark = ?
        then wmark = 0.

        if wmark <= 0
        then wmark = whiest.estvenda / whiest.estcusto.

        wperven = (whiest.venqtd / whiest.estqtd) * 100.

        find clase where clase.clacod = whiest.clacod.

        display clase.clacod
                clase.clanom format "x(20)"
                whiest.estqtd format "->>,>>9"
                   (total )
                   space(2)
                ((whiest.estqtd / westtotalqtd) * 100)
                   (total )
                         format "->>9.99 %"
                        column-label "Perc."
                   space(2)
                whiest.estvalor format ">>,>>>,>>9"
                   (total )
                   space(2)
                ((whiest.estvalor / westtotal) * 100)
                   (total )
                         format "->>9.99 %"
                        column-label "Perc."
                   space(2)
                whiest.venqtd when whiest.venqtd > 0 format "->>,>>9"
                   (total )
                   space(2)
                ((whiest.venqtd / wventotalqtd) * 100) when whiest.venqtd > 0
                format "->>9.99 %"
                   (total )
                        column-label "Perc."
                   space(2)
                whiest.venvalor when whiest.venqtd > 0 format ">>>,>>>,>>9"
                   (total)
                   space(2)
                ((whiest.venvalor / wventotal) * 100) when whiest.venqtd > 0
                format "->>9.99 %"
                   (total )
                        column-label "Perc."
                   space(2)
                (((whiest.venvenda - whiest.venvalor) / whiest.venvenda) * 100)
                when whiest.venqtd > 0
                format "->>9.99"
                        column-label "L.B."
                   space(2)
                ((whiest.venvalor / whiest.venvenda) * 100)
                when whiest.venqtd > 0
                format "->>9.99" column-label "CMV"
                   space(2)
                (whiest.estqtd / (whiest.venqtd / (vdtf - vdti)))
                when whiest.venqtd > 0
                format ">>>9" column-label "COB."
                   space(2)
                whiest.venvenda when whiest.venqtd > 0 and whiest.estqtd > 0
                   (total )
                   column-label "Vl.Venda" format ">>,>>>,>>9"
                    with frame f-tot no-box width 200 down.
    end.
    output close.
END.
