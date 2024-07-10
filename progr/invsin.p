{admcab.i }
def var totest like estoq.estatual.
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

        {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "80"
            &Page-Line = "66"
            &Nom-Rel   = ""ESTCUSME""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """CONTROLE DE ESTOQUE """
            &Width     = "80"
            &Form      = "frame f-cabcab"}

    disp vmes
         vano with frame ffff side-labels centered.

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock.
        totest = 0.
        if estab.etbcod = 22 or estab.etbcod = 990
        then next.
        for each hiest where hiest.etbcod = estab.etbcod and
                             hiest.hiemes = vmes         and
                             hiest.hieano = vano no-lock:

            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = hiest.procod no-lock no-error.
            if not avail estoq
            then next.
            find produ where produ.procod = hiest.procod no-lock no-error.
            if not avail produ
            then next.
            if produ.catcod = 41 and
               hiest.etbcod = 15 and
               hiest.hiemes = 12
            then next.
            output stream stela to terminal.
            disp stream stela
                 estab.etbcod
                 hiest.procod with frame fffpla centered color white/red.
            pause 0.
            output stream stela close.
            totest = totest + (hiest.hiestf * estoq.estcusto).
        end.
        totest = totest + (totest * 0.598593697).
        if estab.etbcod = 16
        then totest = 162489.00 .
        disp
          space(10) "Filial - " estab.etbcod column-label "Filial" space(10)
          (totest)(total)
                column-label "Estoque" format ">>,>>>,>>9.99" space(10)
             with frame f-imp width 80 down.

    end.

    output close.
end.
