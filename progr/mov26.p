{admcab.i}

def var tt1 as dec.
def var tt2 as dec.
def var tt3 as dec.
def var vetbnom like estab.etbnom.
def var v-ok as log.
def var tcus    like estoq.estcusto.
def var tven    like estoq.estvenda.
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var varquivo as char format "x(20)".
def buffer cmovim for movim.
def var vcat like produ.catcod initial 41.
def var vv as l.
def var lfin as log.
def var lcod as i.
def var vok as l.
def var vldev like plani.vlserv.
def var tot-ven  like plani.platot.
def var tot-mar  like plani.platot.
def var tot-acr  like plani.platot.
def buffer bmovim for movim.
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
def var vetbcod  like estab.etbcod.
def var vvlcusto    like plani.platot column-label "Vl.Custo".
def var vvlvenda    like plani.platot column-label "Vl.Venda".
def var vvlmarg     like plani.platot column-label "Margem".
def var vvlperc     as dec format ">>9.99 %" column-label "Perc".
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def var vacrepre    like plani.acfprod column-label "Acr.Previsto".
def var vcatcod     like produ.catcod.
def var vcatcod2    like produ.catcod.
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.

repeat:

    vcatcod2 = 0.

    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.

    if vcatcod = 31
    then vcatcod2 = 35.
    if vcatcod = 41
    then vcatcod2 = 45.

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

        if opsys = "UNIX"
        then varquivo = "/admcom/relat/geral" + string(time).
        else varquivo = "c:\temp\geral" + string(day(today)).

        {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""MOV26""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """MOVIMENTACOES GERAL POR FILIAL - "" +
                          string(vetbi,"">>9"") + "" A "" +
                          string(vetbf,"">>9"") + "" PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label.

    assign vvlcusto = 0
           vvlvenda = 0
           vvlmarg  = 0
           vvlperc  = 0
           vvldesc  = 0
           vvlacre  = 0
           vacrepre = 0
           vldev    = 0.
           vok = no.
           vv = yes.

    for each produ where produ.catcod = vcatcod or
                         produ.catcod = vcatcod2 no-lock .

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:
        tcus = 0.
        tven = 0.
        disp estab.etbcod
             estab.etbnom with frame f-etb1 side-label.
    for each movim where movim.etbcod = estab.etbcod and
                         movim.movtdc = 5            and
                         movim.procod = produ.procod and
                         movim.movdat >= vdti        and
                         movim.movdat <= vdtf
                            no-lock: /* break by movim.etbcod: */

        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               plani.movtdc = movim.movtdc and
                               plani.pladat = movim.movdat no-lock no-error.
        if avail plani and plani.modcod = "CAN" then next.

        output stream stela to terminal.
            disp stream stela
                 produ.procod
                 estab.etbcod
                 movim.movdat with frame fffpla centered color white/red.
            pause 0.
        output stream stela close.

        vvlcusto = 0.
        vvlvenda = 0.

        find estoq where estoq.etbcod = movim.etbcod and
                         estoq.procod = movim.procod no-lock no-error.
        if avail estoq
        then assign vvlcusto = vvlcusto + (movim.movqtm * estoq.estcusto)
                    vvlvenda = vvlvenda + (movim.movqtm * movim.movpc).

        vvlmarg = vvlvenda - vvlcusto.
        vvlperc = (vvlmarg * 100) / vvlvenda.
        if vvlperc = ?
        then vvlperc = 0.
        /***
        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               plani.movtdc = movim.movtdc and
                               plani.pladat = movim.movdat no-lock no-error.
        ***/
        
        disp movim.procod
             produ.pronom format "x(30)" when avail produ
             vvlcusto
             vvlvenda
             vvlmarg        format "->,>>>>>,>>9"
             vvlperc        when vvlperc >= 0 format "->>9.99%"
             plani.numero when avail plani column-label "NF.FISCAL"
             format ">>>>>>>9"
                                   with frame f-imp width 150 down no-box.

        tcus = tcus + (movim.movqtm * estoq.estcusto).
        tven = tven + (movim.movqtm * movim.movpc).
        tt1  = tt1  + vvlcusto.
        tt2  = tt2  + vvlvenda.
        tt3  = tt3  + vvlmarg.

        tot-ven = tot-ven + vvlvenda.
        tot-mar = tot-mar + vvlmarg.
        tot-acr = tot-acr  + vvlacre.
    end.
    end.
    put skip.
    put fill("-",93) format "x(93)" skip
        tt1 at 41
        tt2 at 54
        tt3 at 65
        (((tven - tcus) * 100) / tven) format "->>9.99%" at 76
        "TOTAL" at 95 skip
        fill("-",93) format "x(93)" skip(2).

    tcus = 0.
    tven = 0.
    tt1 = 0.
    tt2 = 0.
    tt3 = 0.


    end.
    output close.
    dos silent value("type " + varquivo + "  > prn").
    /*run visurel.p (input varquivo, input "").*/
end.
