{admcab.i}
def var v-de as dec.
def var v-ac as de.
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
def var pro   like produ.procod extent 1000.
def var val-v like plani.platot extent 1000.
def var val-c like plani.platot extent 1000.
def var val-q like plani.platot extent 1000.
def var est-v like plani.platot extent 1000.
def var est-c like plani.platot extent 1000.
def var est-q like plani.platot extent 1000.
def var vok as log.

def var vvalven like plani.platot.
def var vvalcus like plani.platot.
def var vqtdven like plani.platot.
def var vestven like plani.platot.
def var vestcus like plani.platot.
def var vqtdest like plani.platot.
def var varquivo as char format "x(20)".
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
def var vfabcod     like produ.fabcod.

def stream stela.
def buffer bestoq for estoq.
def buffer bcontnf for contnf.
def buffer bplani for plani.
def buffer bestab for estab.
repeat:
    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.
    if vcatcod = 31
    then vcatcod2 = 35.
    if vcatcod = 41
    then vcatcod2 = 45.

    update vfabcod label "Fornecedor"
                with frame f-depf centered side-label color blue/cyan row 8.
    find fabri where fabri.fabcod = vfabcod no-lock.
    disp fabri.fabnom no-label with frame f-depf.

    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 12
                                    title " Periodo ".

    update vetbi no-label
           "a"
           vetbf no-label with frame f-etb centered color blue/cyan row 16
                                    title " Filial ".
    tot-v = 0.
    tot-c = 0.

    for each produ where produ.fabcod = fabri.fabcod no-lock:

        assign vvalven = 0
               vvalcus = 0
               vqtdven = 0
               vestven = 0
               vestcus = 0
               vqtdest = 0.
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
        /*
        find first bmovim where bmovim.procod = produ.procod and
                                bmovim.movtdc = 5 and
                                bmovim.movdat >= vdti and
                                bmovim.movdat <= vdtf no-lock no-error.
        if not avail bmovim
        then next.
        */
        output stream stela to terminal.
        disp stream stela produ.procod with frame ffff centered
                                       color white/red 1 down.
        pause 0.
        output stream stela close.

        for each bestab no-lock:
            find bestoq where bestoq.procod  = produ.procod and
                              bestoq.etbcod  = bestab.etbcod no-lock no-error.
            if avail bestoq
            then assign
                    vqtdest = vqtdest + bestoq.estatual
                    vestcus = vestcus + (bestoq.estatual * bestoq.estcusto)
                    vestven = vestven + (bestoq.estatual * bestoq.estvenda).
        end.

        for each movim where movim.procod = produ.procod and
                             movim.movtdc = 5 and
                             movim.movdat >= vdti and
                             movim.movdat <= vdtf no-lock:
            if movim.etbcod >= vetbi and
               movim.etbcod <= vetbf
            then do:

                v-de = 0.
                v-ac = 0.
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat
                                                no-lock no-error.
                if avail plani and plani.crecod = 2
                then do:
                    for each contnf where contnf.etbcod = plani.etbcod and
                                          contnf.placod = plani.placod
                                                                  no-lock.
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

                find estoq where estoq.etbcod = estab.etbcod and
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
        i = 0.
        zz = 1000.
        do i = 1 to 1000:
            vok = no.
            if vvalven > val-v[i]
            then do:
                do z = 1000 to i by -1:
                    zz = zz - 1.
                    if zz <> 0
                    then assign pro[z]   = pro[zz]
                                val-v[z] = val-v[zz]
                                val-c[z] = val-c[zz]
                                val-q[z] = val-q[zz]
                                est-v[z] = est-v[zz]
                                est-c[z] = est-c[zz]
                                est-q[z] = est-q[zz].
                end.
                assign pro[i]   = produ.procod
                       val-v[i] = vvalven
                       val-c[i] = vvalcus
                       val-q[i] = vqtdven
                       est-v[i] = vestven
                       est-c[i] = vestcus
                       est-q[i] = vqtdest
                       vok      = yes.
            end.
            if val-v[i] = 0 and pro[i] = 0
            then do:
                assign pro[i]   = produ.procod
                       val-v[i] = vvalven
                       val-c[i] = vvalcus
                       val-q[i] = vqtdven
                       est-v[i] = vestven
                       est-c[i] = vestcus
                       est-q[i] = vqtdest
                       vok      = yes.
            end.

            tot-v = tot-v + vvalven.
            tot-c = tot-c + (vvalven - vvalcus).
            if vok
            then leave.
        end.
    end.


    disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
    pause.

    varquivo = "c:\temp\abc02" + STRING(day(today)).

    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "150"
            &Page-Line = "66"
            &Nom-Rel   = ""ABC02""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """CURVA ABC PRODUTOS POR FORNECEDOR - DA FILIAL "" +
                                  string(vetbi,"">>9"") + "" A "" +
                                  string(vetbf,"">>9"") +
                          "" PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "150"
            &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label.
    disp fabri.fabcod label "Fornecedor"
         fabri.fabnom no-label with frame f-dep22 side-label.
    vacum = 0.
    i = 0.
    do i = 1 to 1000:
        if est-c[i] = 0
        then leave.
        vacum = vacum + ((val-v[i] / tot-v) * 100).
        find produ where produ.procod = pro[i] no-lock no-error.
        disp i format "9999" column-label "Pos."
             produ.procod format ">>>>>9" column-label "Codigo"
             produ.pronom when avail produ format "x(35)" column-label "Nome"
             val-q[i]     format "->>>,>>9"    column-label "Qtd.Ven"
             val-c[i]     format "->>>,>>9.99" column-label "Val.Cus"
             val-v[i]     format "->>>,>>9.99" column-label "Val.Ven"
             ((val-v[i] / tot-v) * 100)
                                 format "->>9.99"     column-label "%S/VEN"
             vacum               format "->>9.99"     column-label "% ACUM"
             (val-v[i] - val-c[i])     format "->>>,>>9.99"
                                                      column-label "LUCRO"
             (((val-v[i] - val-c[i]) / tot-c) * 100)
                                 format "->>9.99"     column-label "%P/MAR"
             est-q[i] format "->>>,>>9"    column-label "Qtd.Est"
             est-c[i] format "->>>,>>9.99" column-label "Est.Cus"
             est-v[i] format "->>>,>>9.99" column-label "Est.Ven"
             (est-v[i] / val-v[i]) format "->>9.99" column-label "Giro"
                     with frame f-imp width 200 down.
        down with frame f-imp.

        assign t01 = t01 + val-q[i]
               t02 = t02 + val-c[i]
               t03 = t03 + val-v[i]
               t04 = t04 + ((val-v[i] / tot-v) * 100)
               t05 = t05 + (val-v[i] - val-c[i])
               t06 = t06 + (((val-v[i] - val-c[i]) / tot-c) * 100)
               t07 = t07 + est-q[i]
               t08 = t08 + est-c[i]
               t09 = t09 + est-v[i]
               t10 = t10 + (est-v[i] / val-v[i]).

    end.
    put skip fill("-",156) format "x(156)" skip
        "TOTAIS........................"
        t01 FORMAT "->>>,>>9" at 49
        t02 FORMAT "->>>,>>9" at 61
        t03 FORMAT "->>>,>>9" at 73
        t04 FORMAT "->>9.99"  at 82
        t05 FORMAT "->>>,>>9" at 101
        t06 FORMAT "->>9.99"  at 110
        t07 FORMAT "->>>,>>9" at 118 space(1)
        t08 FORMAT ">>>>,>>9" at 130 space(1)
        t09 FORMAT "->>>,>>9" at 142
         skip fill("-",156) format "x(156)".
    output close.
    dos silent value("type " + varquivo + " > prn").
end.
