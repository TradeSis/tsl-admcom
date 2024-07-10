{admcab.i}
def var vdatini as date label "Data Inicial" format "99/99/9999" initial today.
def var vdatfin as date label "Data Final" format "99/99/9999" initial today.
repeat:

    update vdatini
           vdatfin with frame fdat centered color white/red side-labels.

    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = """CONFPRE"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONFERENCIA DE PRECO"""
        &Width     = "80"
        &Form      = "frame f-cab"}

    for each produ where produ.datexp >= vdatini and
                         produ.datexp <= vdatfin:
        find fabri of produ no-lock.
        find estoq where estoq.etbcod = setbcod and
                         estoq.procod = produ.procod no-lock.
        if estoq.estdtven >= vdatini and
           estoq.estdtven <= vdatfin
        then disp produ.procod
                  produ.pronom format "x(30)"
                  fabri.fabnom format "x(15)"
                  estoq.estcusto column-label "Custo" format ">>>,>>9.99"
                  estoq.estvenda column-label "Venda" format ">>>,>>9.99".
    end.

    output close.

end.
