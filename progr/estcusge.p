{admcab.i}
def var vtot35 as dec.
def var vtot31 as dec.
def var vtot41 as dec.
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

repeat:

    update vetbi no-label
           "a"
           vetbf no-label with frame f-etb centered color blue/cyan row 12
                                    title " Filial ".
        disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
        pause.

        {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""ESTCUSGE""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """CONTROLE DE ESTOQUE """
            &Width     = "160"
            &Form      = "frame f-cabcab"}

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock.

        assign vvlcusto = 0
               vvlvenda = 0
               vvlmarg  = 0
               vvlperc  = 0
               vvldesc  = 0
               vvlacre  = 0
               vacrepre = 0.
        vtot35 = 0.
        vtot31 = 0.
        vtot41 = 0.
        for each estoq where estoq.etbcod = estab.etbcod and
                             estoq.estatual > 0 no-lock:

            find produ where produ.procod = estoq.procod no-lock no-error.
            if not avail produ then next.
            /*
            if produ.catcod <> 31 and
               produ.catcod <> 41
            then next.
            */
            output stream stela to terminal.
            disp stream stela
                 estab.etbcod
                 produ.procod with frame fffpla centered color white/red.
            pause 0.
            output stream stela close.
            
            if estoq.estcusto = ? or
               estoq.estcusto = 0
            then do:
                find last movim use-index datsai
                          where movim.procod = produ.procod and
                                movim.movtdc = 4 no-lock no-error.

                if avail movim
                then do:
                    if produ.catcod = 31
                    then vtot31 = vtot31 + (estoq.estatual * movim.movpc).
                    if produ.catcod = 41
                    then vtot41 = vtot41 + (estoq.estatual * movim.movpc).
                    if produ.catcod <> 31 and
                       produ.catcod <> 41
                    then vtot35 = vtot35 + (estoq.estatual * movim.movpc).

                end.
            end.
            else do:
                if produ.catcod = 31
                then vtot31 = vtot31 + (estoq.estatual * estoq.estcusto).
                if produ.catcod = 41
                then vtot41 = vtot41 + (estoq.estatual * estoq.estcusto).

                if produ.catcod <> 31 and
                   produ.catcod <> 41
                then vtot35 = vtot35 + (estoq.estatual * estoq.estcusto).



            end. 

        end.

        disp space(10) "Filial - " estab.etbcod column-label "Filial" space(10)
          vtot31(total) column-label "Moveis" format ">>,>>>,>>9.99" space(10)
          vtot41(total) column-label "Confeccoes" 
                            format ">>,>>>,>>9.99" space(10)
          vtot35(total) column-label "Outros" format ">>,>>>,>>9.99"


          (vtot31 + vtot41 + vtot35)(total) column-label "Total"  
             format ">>,>>>,>>9.99"   with frame f-imp width 200 down.
    end.
    output close.
end.
