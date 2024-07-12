{admcab.i}
def var varquivo as char.
def var vperc    like estoq.estvenda.
def var totcusto like estoq.estcusto.
def var totvenda like estoq.estcusto.
def buffer bestoq for estoq.
def var v-ac like plani.platot.
def var v-de like plani.platot.
def buffer bcurva for curva.
def buffer bmovim for movim.
def var i as i.
def var tot-c like plani.platot.
def var tot-v like plani.platot format "->>9.99".
def var tot-m like plani.platot.
def var vacum like plani.platot format "->>9.99".
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
def var vcatcod2    like produ.catcod.
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.

repeat:
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
           vetbf no-label with frame f-etb
           centered color blue/cyan row 12 title " Filial ".

    update vperc label "Perc" format ">>9.99%" with frame f-perc
           centered color blue/cyan row 16 side-label.

    for each curva:
        delete curva.
    end.

    totcusto = 0.
    totvenda = 0.
    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:
        message "0".
    for each plani where plani.movtdc = 5      and
                         plani.etbcod = estab.etbcod and
                         plani.pladat >= vdti  and
                         plani.pladat <= vdtf  no-lock:
        message "1".
        for each contnf where contnf.etbcod = plani.etbcod and
                              contnf.placod = plani.placod no-lock.
            find contrato where contrato.contnum = contnf.contnum
                            no-lock no-error.
            if avail contrato
            then do:
                if contrato.vltotal > plani.platot
                then v-ac = contrato.vltotal / plani.platot.
                if contrato.vltotal < plani.platot
                then v-de = plani.platot / contrato.vltotal.
            end.
        end.

        message "2".
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod no-lock
                             break by movim.procod:

            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ
            then next.

            if produ.catcod <> vcatcod and
               produ.catcod <> vcatcod2
            then next.

            output stream stela to terminal.
            disp stream stela produ.procod produ.fabcod
                        with frame ffff centered
                                       color white/red 1 down.
            pause 0.
            output stream stela close.

            find first curva where curva.cod = produ.procod no-error.
            if not avail curva
            then do:
                create curva.
                find last bcurva no-error.
                if not avail bcurva
                then curva.pos = 1000000.
                else curva.pos = bcurva.pos + 1.
                curva.cod = produ.procod.
            end.

            find estoq where estoq.etbcod = movim.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.

            curva.qtdven = curva.qtdven + movim.movqtm.
            if v-ac = 0 and v-de = 0
            then curva.valven = curva.valven + (movim.movqtm * movim.movpc).
            if v-ac > 0
            then curva.valven = curva.valven +
                                ((movim.movqtm * movim.movpc) * v-ac).
            if v-de > 0
            then curva.valven = curva.valven +
                                ((movim.movqtm * movim.movpc) / v-de).
            curva.valcus = curva.valcus + (movim.movqtm * estoq.estcusto).
            v-ac = 0.
            v-de = 0.

            if last-of(movim.procod)
            then do:

        message "3".
                for each estoq where estoq.procod = movim.procod and
                                     estoq.etbcod >= vetbi       and
                                     estoq.etbcod <= vetbf       no-lock:

                    curva.qtdest = curva.qtdest + estoq.estatual.
                    curva.estcus = curva.estcus +
                                   (estoq.estatual * estoq.estcusto).
                    curva.estven = curva.estven +
                                   (estoq.estatual * estoq.estvenda).
                end.
        message "4".
            end.
        end.
    end.
    end.
    i = 1.
    tot-v = 0.
    tot-c = 0.
        message "5".
    for each curva by curva.valven descending:
        curva.pos = i.
        tot-v = tot-v + curva.valven.
        tot-c = tot-c + (curva.valven - curva.valcus).
        i = i + 1.
    end.
        message "6".

    disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
    pause.

    varquivo = "c:\temp\curpro" + STRING(today).


    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "147"
            &Page-Line = "66"
            &Nom-Rel   = ""CURVAFAB""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """CURVA ABC FORNECEDORES EM GERAL - DA FILIAL "" +
                                  string(vetbi,"">>9"") + "" A "" +
                                  string(vetbf,"">>9"") +
                          "" PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "147"
            &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label.
    vacum = 0.
    for each curva by curva.pos:
        vacum = vacum + ((curva.valven / tot-v) * 100).
        if vacum >= vperc
        then leave.
        find produ where produ.procod = curva.cod no-lock no-error.
        curva.giro = (curva.estven / curva.valven).
        disp curva.pos format "9999" column-label "Pos."
             curva.cod format ">>>>>9" column-label "Codigo"
             produ.pronom when avail produ format "x(27)" column-label "Nome"
             curva.qtdven(total) format "->>>,>>9"    column-label "Qtd.Ven"
             curva.valcus(total) format "->>>,>>9" column-label "Val.Cus"
             curva.valven(total) format "->>>,>>9" column-label "Val.Ven"
             ((curva.valven / tot-v) * 100)(total)
                                 format "->>9.99"     column-label "%S/VEN"
             (((curva.valven - curva.valcus) / tot-c) * 100)(total)
                                 format "->>9.99"     column-label "%P/MAR"
             vacum               format "->>9.99"     column-label "% ACUM"
             curva.qtdest(total) format "->>>,>>9"    column-label "Qtd.Est"
             curva.estcus(total) format "->>>,>>9" column-label "Est.Cus"
             curva.estven(total) format "->>>,>>9" column-label "Est.Ven"
             curva.giro when curva.giro > 0
                                 format "->>9.99" column-label "Giro"
                     with frame f-imp width 200 down centered.
    end.
    put skip(2)
        "Total Custo" totcusto format "->>>,>>>,>>9.99" at 40 skip
        "Total Venda" totvenda format "->>>,>>>,>>9.99" at 40.

    output close.

    message "Deseja Imprimir o arquivo " varquivo + "?" update sresp.
    if sresp
    then dos silent value("type " + varquivo + " > prn").
end.