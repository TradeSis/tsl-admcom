{admcab.i}

def var totger like estoq.estatual.
def var totest like estoq.estatual.
def var totcus like estoq.estatual.
def var vok as log.
def var vqtd as dec.

def var wnp as i.
def var vvltotal as dec.
def var vvlcont  as dec.
def var wacr     as dec.
def var wper     as dec.
def var valortot as dec.
def var vval     as dec.
def var vval1    as dec.
def var vsal     as dec.
def var vlfinan  as dec.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vvlcusto    like plani.platot column-label "Vl.Custo".
def var vvlvenda    like plani.platot column-label "Vl.Venda".
def var vvlmarg     like plani.platot column-label "Margem".
def var vvlperc     as dec format ">>9.99 %" column-label "Perc".
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def var vacrepre    like plani.acfprod column-label "Acr.Previsto".
def var vcatcod     like produ.catcod.
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.
def var vmes like hiest.hiemes.
def var vano like hiest.hieano.
def stream stela.

repeat:

    update vetbi no-label
           "a"
           vetbf no-label
           with frame f-etb centered color blue/cyan row 10
                                    title " Filial ".
    update vmes
           vano
           with frame f-per centered color blue/cyan row 15.

        disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
        pause.

        {mdcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "150"
            &Page-Line = "66"
            &Nom-Rel   = """."""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """INVENTARIO DE ESTOQUE"""
            &Width     = "150"
            &Form      = "frame f-cab"}

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf  no-lock.

        disp vmes
             vano
             estab.etbcod
             estab.etbnom no-label
                with frame ffff side-labels centered.
    for each estoq where estoq.etbcod = estab.etbcod no-lock.

        totest = 0.
        if estoq.etbcod = 22 or
           estoq.etbcod = 990
        then next.
        find produ where produ.procod = estoq.procod no-lock no-error.
        if not avail produ
        then next.
        if estoq.estatual <= 0
        then next.
        if produ.clacod = 226
        then next.
        output stream stela to terminal.
        disp stream stela
             estoq.etbcod
             produ.procod
             estoq.estatual with frame fffpla centered color white/red.
        pause 0.
        output stream stela close.
        disp produ.procod
             produ.pronom
             estoq.estatual column-label "Quant."
             estoq.estcusto column-label "Custo Medio"
             (estoq.estatual * estoq.estcusto)  column-label "Sub-Total"
                    with frame f-imp width 200 down.
    end.
    find first autoriz where autoriz.etbcod = estab.etbcod no-lock no-error.
    if avail autoriz
    then do:
        put skip(1) "TOTAL......." at 67
             autoriz.valor3 format ">>,>>>,>>9.99".
        page.
    end.
    end.
    output close.
end.
