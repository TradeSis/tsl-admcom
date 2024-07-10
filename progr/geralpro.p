{admcab.i}
def var varquivo as char.
def buffer cplani for plani.
def var totpla like plani.platot.
def var totac like plani.platot.
def var tot-c like plani.platot.
def var tot-v like plani.platot.
def var tot-m like plani.platot.
def var ac like plani.platot.

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
def var vlacre     like plani.acfprod column-label "Acrescimo".
def var vacrepre    like plani.acfprod column-label "Acr.Previsto".
def var vcatcod     like produ.catcod.
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.

repeat:
    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.

    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".

    update vetbi no-label
           "a"
           vetbf no-label with frame f-etb centered color blue/cyan row 12
                                    title " Filial ".
        disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
        pause.

        varquivo = "..\relat\geralpro" + string(time).


        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "150"
            &Page-Line = "66"
            &Nom-Rel   = ""GERALPRO""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """VENDAS - VL.CUSTO,VENDA, MARGEM - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "150"
            &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label.

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock.

        tot-c = 0.
        tot-v = 0.
        tot-m = 0.
        totac = 0.
        disp "Filial - " estab.etbcod no-label estab.etbnom no-label skip(1)
             with frame f-impx width 130 down.

        for each produ where produ.catcod = categoria.catcod
                             no-lock by produ.procod:

            output stream stela to terminal.
            disp stream stela produ.procod with frame ffff centered
                                           color white/red 1 down.
            pause 0.
            output stream stela close.

            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.

            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 5 and
                                 movim.movdat >= vdti and
                                 movim.movdat <= vdtf and
                                 movim.etbcod = estab.etbcod no-lock:
                ac = 0.
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod
                                            no-lock no-error.
                if avail plani
                then do:
                    find first contnf where contnf.etbcod = movim.etbcod and
                                            contnf.placod = movim.placod
                                                    no-lock no-error.
                    if avail contnf
                    then do:
                        find contrato where contrato.contnum = contnf.contnum
                                            no-lock no-error.
                        if avail contrato
                        then do:
                            totpla = 0.
                            for each bcontnf where
                                            bcontnf.etbcod = contnf.etbcod and
                                            bcontnf.contnum = contrato.contnum
                                                no-lock:
                                for each cplani where
                                            cplani.etbcod = bcontnf.etbcod and
                                            cplani.placod = bcontnf.placod
                                                                        no-lock:
                                    totpla = totpla + cplani.platot -
                                             cplani.descprod - cplani.vlserv.
                                end.
                            end.
                            if contrato.vltotal > totpla
                            then ac = contrato.vltotal / totpla.
                        end.
                    end.
                end.

                vlacre = 0.
                if ac > 0
                then vlacre = ((movim.movpc * movim.movqtm) * ac)
                                - (movim.movpc * movim.movqtm).
                else vlacre = 0.

                assign vvlcusto = 0
                       vvlvenda = 0
                       vvlmarg  = 0
                       vvlperc  = 0
                       vvldesc  = 0
                       vvlacre  = 0
                       vacrepre = 0
                       totpla   = 0.
                totac = totac + vlacre.
                vvlcusto = vvlcusto + (movim.movqtm * estoq.estcusto).
                vvlvenda = vvlvenda + (movim.movqtm * movim.movpc).

                vvlmarg = vvlvenda - vvlcusto.
                vvlperc = (vvlmarg * 100) / vvlvenda.
                if vvlperc = ?
                then vvlperc = 0.

                tot-c = tot-c + vvlcusto.
                tot-v = tot-v + vvlvenda.
                tot-m = tot-m + vvlmarg.

                disp space(15)
                     produ.procod
                     produ.pronom format "X(35)"
                     day(movim.movdat) format "99" label "Dia"
                     vvlcusto
                     vvlvenda
                     vvlmarg format "->,>>>,>>9.99"
                     vvlperc when vvlperc > 0
                     vlacre column-label "Acresc." format "->,>>>,>>9"
                     with frame f-imp width 200 down.
            end.
        end.
    end.
    display space(45) "Total............"
            tot-c no-label
            tot-v no-label space(2)
            tot-m  format "->>>,>>>,>99.99" no-label space(10) 
            totac  format "->>>,>>>,>99.99"
                    no-label with frame f-tot side-label width 200.
    output close.
    
    {mrod.i}
    
end.
