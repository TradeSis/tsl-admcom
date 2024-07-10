{admcab.i}
def var vok as log.
def var vqtd as dec.

def var vrechie as recid.

def temp-table wfest
    field vetb like estab.etbcod
    field vtot31 as dec
    field vtot41 as dec.

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
            &Cond-Var  = "150"
            &Page-Line = "66"
            &Nom-Rel   = ""ESTCUSME""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """CONTROLE DE ESTOQUE """
            &Width     = "150"
            &Form      = "frame f-cabcab"}

    disp vmes
         vano with frame ffff side-labels centered.

    for each produ no-lock:

        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf no-lock.

            find first wfest where wfest.vetb = estab.etbcod no-error.
            if not avail wfest
            then do:
                create wfest.
                assign wfest.vetb = estab.etbcod
                       wfest.vtot31 = 0
                       wfest.vtot41 = 0.
            end.
            vrechie = ?.

            find hiest where hiest.etbcod = estab.etbcod and
                             hiest.procod = produ.procod and
                             hiest.hiemes = vmes         and
                             hiest.hieano = vano         no-lock no-error.

            if not avail hiest
            then do:
                /******** tirar 1998, colocar vano, proximo mes (3) ********/

                find last hiest where hiest.etbcod = estab.etbcod and
                                      hiest.procod = produ.procod and
                                      hiest.hieano = 1998
                                      no-lock no-error.

                if not avail hiest
                then do:

                    find last hiest where hiest.etbcod = estab.etbcod and
                                          hiest.procod = produ.procod and
                                          hiest.hieano = vano
                                          no-lock no-error.

                end.
                else vrechie = recid(hiest).

            end.
            else vrechie = recid(hiest).

            if vrechie = ?
            then next.

            find hiest where recid(hiest) = vrechie no-lock.
            if hiest.hiestf <= 0
            then next.

            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = hiest.procod no-lock no-error.
            if not avail estoq
            then next.
            if produ.catcod = 31
            then if hiest.hiestf >= 0
                 then vtot31 = vtot31 + (hiest.hiestf * estoq.estcusto).
            if produ.catcod = 41
            then if hiest.hiestf >= 0
                 then vtot41 = vtot41 + (hiest.hiestf * estoq.estcusto).

            output stream stela to terminal.
            disp stream stela
                 estab.etbcod
                 hiest.procod with frame fffpla centered color white/red.
            pause 0.
            output stream stela close.

        end.

    end.

    for each wfest by wfest.vetb:
        find estab where estab.etbcod = wfest.vetb no-lock.

        disp space(10) "Filial - " estab.etbcod column-label "Filial" space(10)
          vtot31(total) column-label "Moveis" format ">>,>>>,>>9.99" space(10)
          vtot41(total) column-label "Confeccoes" format ">>,>>>,>>9.99"
          (vtot31 + vtot41)(total)
            column-label "Tot.Est." format ">>,>>>,>>9.99"
             with frame f-imp width 200 down.
    end.
    output close.
end.
