{admcab.i}
def var vt as int.
def var vc as int.
def var vm as int.
def var varquivo as char format "x(20)".
def var x like plani.platot.
def var y like plani.platot.
def var w like plani.platot.
def var z like plani.platot.
def temp-table wmargem
    field data like plani.pladat
    field valor like plani.platot.

def temp-table w-demo
    field cod     as i
    field etbnom  like estab.etbnom
    field wtot    like plani.platot
    field wtotal  like plani.platot
    field wtotacr like plani.platot
    field wtotser like plani.platot.
def buffer bplani for plani.
def buffer bcontnf for contnf.
def var vtot like plani.platot.
def var wacr like plani.platot.
def var vetbcod like estab.etbcod.
def var vdt1 like plani.pladat.
def var vdt2 like plani.pladat.
def var vtotal like plani.platot.
def var vtotal1 like plani.platot.
def var vtotal2 like plani.platot.
def var valortot like plani.platot.
def var vvltotal like plani.platot.
def var vtotacr like plani.platot.
def var vtotser like plani.platot.
def var vvlcont like plani.platot.
def var wper like plani.platot.
def var vvldesc like plani.platot.
def var vvlacre like plani.platot.
def var vcatcod like produ.catcod.
repeat:
    for each wmargem:
        delete wmargem.
    end.
    for each w-demo:
        delete w-demo.
    end.
    update vetbcod with frame f1 side-label width 80.
    if vetbcod <> 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label with frame f1.
    end.
    else display "GERAL" @ estab.etbnom with frame f1.
    update vcatcod colon 16 with frame f1.
    find categoria where categoria.catcod = vcatcod no-lock no-error.
    if not avail categoria
    then do:
        message "Departamento nao cadastrado".
        undo, retry.
    end.
    display categoria.catnom no-label with frame f1.

    update vdt1 label "Periodo" colon 16
           vdt2 no-label with frame f1.
    for each estab where ( if vetbcod = 0
                           then true
                           else estab.etbcod = vetbcod ) no-lock.
    for each plani where plani.etbcod = estab.etbcod and
                         plani.movtdc = 5 and
                         plani.pladat >= vdt1 and
                         plani.pladat <= vdt2 no-lock break by plani.etbcod:

        vc = 0.
        vm = 0.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:

            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ
            then next.
            if produ.catcod = 31
            then vm = vm +  1.
            else vc = vc + 1.
        end.
        if vc >= vm
        then vt = 41.
        if vm >= vc
        then vt = 31.

        if vt <> vcatcod
        then next.

        vvltotal = 0.
        vvlcont = 0.
        wacr = 0.
        if plani.crecod > 1
        then do:
            find first contnf where contnf.etbcod = plani.etbcod and
                                    contnf.placod = plani.placod
                                        no-lock no-error.
            if avail contnf
            then do:
                for each bcontnf where bcontnf.etbcod  = contnf.etbcod and
                                       bcontnf.contnum = contnf.contnum
                                           no-lock:
                    find first bplani where bplani.etbcod = bcontnf.etbcod and
                                      bplani.placod = bcontnf.placod and
                                      bplani.pladat = plani.pladat   and
                                      bplani.movtdc = plani.movtdc
                                          no-lock no-error.
                    if not avail bplani
                    then next.
                    vvltotal = vvltotal + (bplani.platot - bplani.vlserv).
                end.
                find contrato where contrato.contnum = contnf.contnum
                                                 no-lock no-error.
                if avail contrato
                then do:
                    vvlcont = contrato.vltotal.
                    valortot = contrato.vltotal.
                    wacr = vvlcont  - vvltotal.
                    wper = plani.platot / vvltotal.
                    wacr = wacr * wper.

                end.
                else do:
                     wacr = plani.acfprod.
                     valortot = plani.platot.
                end.

                if wacr < 0 or wacr = ?
                then wacr = 0.

                assign vvldesc  = vvldesc  + plani.descprod
                       vvlacre  = vvlacre  + wacr.
            end.

            vtot = vtot + plani.platot.
            vtotal = vtotal + plani.platot -
                     plani.vlserv + wacr.
            vtotacr = vtotacr + wacr.
            vtotser = vtotser + plani.vlserv.
        end.
        else do:
            vtot = vtot + plani.platot.
            vtotal = vtotal + plani.platot - plani.vlserv.
            vtotser = vtotser + plani.vlserv.
        end.
    end.
    create w-demo.
    assign w-demo.cod     = 1
           w-demo.etbnom  = estab.etbnom
           w-demo.wtot    = vtot
           w-demo.wtotal  = vtotal
           w-demo.wtotacr = vtotacr
           w-demo.wtotser = vtotser.
           clear frame f2 no-pause.
    x = 0.
    y = 0.
    w = 0.
    z = 0.
    for each w-demo break by w-demo.cod:
        display w-demo.etbnom format "x(18)"
                wtot column-label "Total Liq." format ">,>>>,>>9.99"
                wtotal column-label "Total Venda"
                wtotacr column-label "Tot.Acre." format ">>>,>>9.99"
                wtotser column-label "Total Devolucao"
                                    with frame f2 down width 80.
        x = x + wtot.
        y = y + wtotal.
        w = w + wtotacr.
        z = z + wtotser.
        down with frame f2.
        /* pause 0. */
    end.


    create wmargem.
    assign wmargem.data = plani.pladat
           wmargem.valor = vtotal.
    vtotal = 0.
    vtotacr = 0.
    vvlacre = 0.
    vvldesc = 0.
    valortot = 0.
    wacr = 0.
    wper = 0.
    vvltotal = 0.
    vvlcont  = 0.
    valortot = 0.
    vtot = 0.
    vtotser = 0.

    end.
    display x label "Total Liquido"
            y label "Total Venda"
            w label "Total Acre."
            z label "Total Devolucao"
                        with frame f-tot side-label color white/red.

    varquivo = "..\encerra\demo" + STRING(month(vdt1),"99").

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""demoabe""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """DEMONSTRATIVO DE VENDAS POR FILIAL - PERIODO DE "" +
                                  string(vdt1,""99/99/9999"") + "" A "" +
                                  string(vdt2,""99/99/9999"") +
                                  ""  DEPARTAMENTO"" + string(vcatcod,""99"")"
        &Width     = "130"
        &Form      = "frame f-cabcab"}

        for each w-demo:
            display w-demo.etbnom format "x(20)"
                    wtot(total) column-label "Total Liq." format ">,>>>,>>9.99"
                    wtotal(total) column-label "Total Venda"
                    wtotacr(total) column-label "Total Acre."
                                                format ">>>,>>9.99"
                    wtotser(total) column-label "Total Devolucao"
                                            with frame f4 down width 200.
        end.
        output close.
        message "Deseja imprimir relatorio" update sresp.
        if sresp
        then dos silent value("type " + varquivo + " > prn").

end.
