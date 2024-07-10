{admcab.i}
def var t01 like plani.platot.
def var t02 like plani.platot.
def var t03 like plani.platot.
def var t04 like plani.platot.
def var t05 like plani.platot.
def var t06 like plani.platot.
def var t07 like plani.platot.
def var t08 like plani.platot.
def var t09 like plani.platot.
def var t10 like plani.platot.
def var zz    as i.
def var z     as i.
def var fab   like produ.fabcod extent 1000.
def var est-v like movim.movpc  extent 1000.
def var est-c like movim.movqtm extent 1000.
def var qua-v like movim.movpc  extent 1000.
def var qua-e like movim.movqtm extent 1000.
def var val-v like movim.movpc  extent 1000.
def var val-c like movim.movpc  extent 1000.
def var vok   as log.
def var vvalcus like movim.movpc.
def var vvalven like movim.movpc.
def var vqtdven like movim.movpc.
def var vqtd like movim.movqtm.
def var vestc like movim.movqtm.
def var vestv like movim.movqtm.
def var varquivo as char format "x(20)".
def var vcusto   like estoq.estcusto.
def var vestven  like estoq.estvenda.
def var totcusto like estoq.estcusto.
def var totvenda like estoq.estvenda.
def buffer bestoq for estoq.
def var v-ac like plani.platot.
def var v-de like plani.platot.
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
           vetbf no-label with frame f-etb centered color blue/cyan row 12
                                    title " Filial ".
    totcusto = 0.
    totvenda = 0.
    tot-v = 0.
    tot-c = 0.
    i = 0.
    t01 = 0.
    t02 = 0.
    t03 = 0.
    t04 = 0.
    t05 = 0.
    t06 = 0.
    t07 = 0.
    t08 = 0.
    t09 = 0.
    t10 = 0.
    for each produ where produ.catcod = vcatcod or
                         produ.catcod = vcatcod2 no-lock break by produ.fabcod:
        output stream stela to terminal.
        disp stream stela produ.procod produ.fabcod tot-v format ">>,>>>,>>9.99"
                    with frame ffff centered
                                       color white/red 1 down.
        pause 0.
        output stream stela close.
        find first bmovim where bmovim.procod = produ.procod and
                                bmovim.movtdc = 5            and
                                bmovim.movdat >= vdti        and
                                bmovim.movdat <= vdtf no-lock no-error.
        if not avail bmovim
        then next.

        vestven = 0.
        vcusto  = 0.
        for each estab no-lock:
            find bestoq where bestoq.etbcod = estab.etbcod and
                              bestoq.procod = produ.procod no-lock no-error.
            if avail bestoq
            then do:
                assign totcusto = totcusto +
                                   (bestoq.estcusto * bestoq.estatual)
                       totvenda = totvenda +
                                  (bestoq.estvenda * bestoq.estatual).
                if bestoq.estatual > 0
                then assign
                    vestven = vestven + (bestoq.estatual * bestoq.estvenda)
                    vcusto  = vcusto  + (bestoq.estatual * bestoq.estcusto).
                if bestoq.estatual > 0
                then vqtd = vqtd + bestoq.estatual.
            end.
        end.

        assign vestv = vestv + vestven
               vestc = vestc + vcusto.
        for each movim where movim.procod = produ.procod and
                             movim.movtdc = 5 and
                             movim.movdat >= vdti and
                             movim.movdat <= vdtf no-lock:
            v-de = 0.
            v-ac = 0.
            if movim.etbcod >= vetbi and
               movim.etbcod <= vetbf
            then do:
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat
                                            no-lock no-error.
                if avail plani and plani.crecod = 2
                then do:
                for each contnf where contnf.etbcod = plani.etbcod and
                                      contnf.placod = plani.placod no-lock.
                    find contrato where contrato.contnum = contnf.contnum
                                no-lock no-error.
                    if avail contrato
                    then do:
                        if contrato.vltotal > (plani.platot - plani.vlserv)
                        then v-ac = contrato.vltotal /
                                              (plani.platot - plani.vlserv).
                        if contrato.vltotal < (plani.platot - plani.vlserv)
                        then v-de = (plani.platot - plani.vlserv)
                                              / contrato.vltotal.
                    end.
                end.

                if plani.platot < 1
                then assign v-de = 0
                            v-ac = 0.
                end.
                find estoq where estoq.etbcod = movim.etbcod and
                                 estoq.procod = produ.procod no-lock no-error.
                if not avail estoq
                then next.


                vqtdven = vqtdven + movim.movqtm.
                if v-ac = 0 and v-de = 0
                then vvalven = vvalven + (movim.movqtm * movim.movpc).
                if v-ac > 0
                then vvalven = vvalven + ((movim.movqtm * movim.movpc) * v-ac).
                if v-de > 0
                then vvalven = vvalven +
                                    ((movim.movqtm * movim.movpc) / v-de).
                vvalcus = vvalcus + (movim.movqtm * estoq.estcusto).
                v-ac = 0.
                v-de = 0.
            end.
        end.

        if last-of(produ.fabcod)
        then do:
            i = 0.
            zz = 1000.
            do i = 1 to 1000:
                vok = no.
                if vvalven > val-v[i]
                then do:
                    do z = 1000 to i by -1:
                        zz = zz - 1.
                        if zz <> 0
                        then assign fab[z]   = fab[zz]
                                    est-v[z] = est-v[zz]
                                    est-c[z] = est-c[zz]
                                    qua-v[z] = qua-v[zz]
                                    qua-e[z] = qua-e[zz]
                                    val-v[z] = val-v[zz]
                                    val-c[z] = val-c[zz].
                    end.
                    assign fab[i]   = produ.fabcod
                           est-v[i] = vestv
                           est-c[i] = vestc
                           qua-v[i] = vqtdven
                           qua-e[i] = vqtd
                           val-v[i] = vvalven
                           val-c[i] = vvalcus
                           vok      = yes
                           vestv  =  0
                           vestc  =  0
                           vqtdven = 0
                           vqtd    = 0
                           vvalven = 0
                           vvalcus = 0.
                end.
                if val-v[i] = 0 and fab[i] = 0
                then do:
                    assign fab[i]   = produ.fabcod
                           est-v[i] = vestv
                           est-c[i] = vestc
                           qua-v[i] = vqtdven
                           qua-e[i] = vqtd
                           val-v[i] = vvalven
                           val-c[i] = vvalcus
                           vok      = yes
                           vestv  =  0
                           vestc  =  0
                           vqtdven = 0
                           vqtd    = 0
                           vvalven = 0
                           vvalcus = 0.


                end.
                if vok
                then leave.

            end.

            tot-v = tot-v + vvalven.
            tot-c = tot-c + (vvalven - vvalcus).

            assign vestv  =  0
                   vestc  =  0
                   vqtdven = 0
                   vqtd    = 0
                   vvalven = 0
                   vvalcus = 0.
        end.
    end.

    disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
    pause.

    varquivo = "c:\temp\abc" + STRING(day(today)) +
                string(categoria.catcod,"99").

    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""abc01""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """curfab ABC FORNECEDORES EM GERAL - DA FILIAL "" +
                                  string(vetbi,"">>9"") + "" A "" +
                                  string(vetbf,"">>9"") +
                          "" PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "160"
            &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label.
    vacum = 0.

    i     = 0.
    do i = 1 to 1000:
        if val-c[i] = 0
        then next.
        find fabri where fabri.fabcod = fab[i] no-lock no-error.
        if not avail fabri
        then next.
        vacum = vacum + ((val-v[i] / tot-v) * 100).

        disp i format "9999" column-label "Pos."
             fabri.fabcod format ">>>>>9" column-label "Codigo"
             fabri.fabnom when avail fabri format "x(27)" column-label "Nome"
             qua-v[i] format "->>>,>>9"    column-label "Qtd.Ven"
             val-c[i] format "->>>,>>9" column-label "Val.Cus"
             val-v[i] format "->>>,>>9" column-label "Val.Ven"
             ((val-v[i] / tot-v) * 100)
                                 format "->>9.99" column-label "%S/VEN"
             vacum               format "->>9.99" column-label "% ACUM"
             (val-v[i] - val-c[i])(total) format "->>>,>>9"
                                                      column-label "LUCRO"
             (((val-v[i] - val-c[i]) / tot-c) * 100)(total)
                                 format "->>9.99"     column-label "%P/MAR"
             qua-e[i] format "->>>,>>9"    column-label "Qtd.Est"
             est-c[i] format "->,>>>,>>9" column-label "Est.Cus"
             est-v[i] format "->>>,>>9" column-label "Est.Ven"
             (est-v[i] / val-v[i])
                                 format "->,>>9.99" column-label "Giro"
                     with frame f-imp width 200 down.
        assign t01 = t01 + qua-v[i]
               t02 = t02 + val-c[i]
               t03 = t03 + val-v[i]
               t04 = t04 + ((val-v[i] / tot-v) * 100)
               t05 = t05 + (val-v[i] - val-c[i])
               t06 = t06 + (((val-v[i] - val-c[i]) / tot-c) * 100)
               t07 = t07 + qua-e[i]
               t08 = t08 + est-c[i]
               t09 = t09 + est-v[i]
               t10 = t10 + (est-v[i] / val-v[i]).
        down with frame f-imp.
    end.
    put skip fill("-",137) format "x(137)" skip
        t01 FORMAT "->>>,>>9" at 41
        t02 FORMAT "->>>,>>9" at 50
        t03 FORMAT "->>>,>>9" at 59
        t04 FORMAT "->>9.99"  at 68
        t05 FORMAT "->>>,>>9" at 84
        t06 FORMAT "->>9.99"  at 93
        t07 FORMAT "->>>,>>9" at 101 space(1)
        t08 FORMAT ">>>>,>>9"  at 112 space(1)
        t09 FORMAT "->>>,>>9"
        /* t10 FORMAT "->,>>9.99" */
        "            TOTAL".
    output close.
    dos silent value("type " + varquivo + " > prn").
end.
