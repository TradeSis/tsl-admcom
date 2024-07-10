{admcab.i }
def var vmes as i.
def var vano as i.
def buffer estoq for estoq.
def var t-ven  like estoq.estvenda format "->>>,>>9.99".
DEF VAR t-val  like estoq.estvenda format "->>>,>>9.99".

def var t-venda  like estoq.estvenda format "->>>,>>9.99".
DEF VAR t-valest like estoq.estvenda format "->>,>>>,>>9.99".
def var v-giro   like estoq.estvenda format "->,>>9.99".
def var tot-v    like estoq.estvenda format "->>>,>>9.99".
DEF VAR est-ven  like estoq.estvenda format "->>>,>>9" .
DEF VAR venda    like estoq.estvenda format "->>>,>>9.99".
DEF VAR est-com  like estoq.estvenda format "->>>,>>9"   .
DEF VAR compra   like estoq.estvenda format "->>>,>>9.99".
DEF VAR est-atu  like estoq.estvenda format "->>>,>>9"   .
DEF VAR valest   like estoq.estvenda format "->>,>>>,>>9.99".
DEF VAR valcus   like estoq.estvenda format "->>>,>>9.99".

def var totcusto like estoq.estcusto.
def var totvenda like estoq.estcusto.
def buffer bestoq for estoq.
def var acre like plani.platot.
def var des like plani.platot.
def buffer bcurva for curva.
def buffer bmovim for movim.
def var totc like plani.platot.
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
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.
def var vclasup like clase.clasup.
repeat:
    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.

    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".
    update vclasup with frame f-dat side-label.
    if vclasup = 0
    then display "GERAL" @ clase.clanom with frame f-dat.
    else do:
        find clase where clase.clacod = vclasup no-lock.
        display clase.clanom no-label with frame f-dat.
    end.
    assign est-ven = 0
           venda   = 0
           est-com = 0
           compra = 0
           est-atu = 0
           valest  = 0
           valcus  = 0.


    {mdadmcab.i
        &Saida     = "i:\admcom\relat\cve3"
        &Page-Size = "64"
        &Cond-Var  = "135"
        &Page-Line = "66"
        &Nom-Rel   = ""RESCVE""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """RESUMO VENDA/COMPRA/ESTOQUE - DA FILIAL "" +
                            string(vetbi,"">>9"") + "" A "" +
                            string(vetbf,"">>9"") +
                      "" PERIODO DE "" +
                         string(vdti,""99/99/9999"") + "" A "" +
                         string(vdtf,""99/99/9999"") "
       &Width     = "135"
       &Form      = "frame f-cabcab"}

    tot-v = 0.
    if vclasup = 0
    then do:
    for each clase no-lock by clase.clasup
                           by clase.clacod:
        for each produ where produ.catcod = categoria.catcod and
                             produ.clacod = clase.clacod no-lock:
            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 5            and
                                 movim.movdat >= vdti        and
                                 movim.movdat <= vdtf        no-lock:

                totc = 0.
                des = 0.
                acre = 0.
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.pladat = movim.movdat and
                                       plani.movtdc = movim.movtdc
                                                        no-lock no-error.
                if avail plani and plani.crecod = 2
                then do:
                    for each contnf where contnf.placod = plani.placod and
                                          contnf.etbcod = plani.etbcod no-lock:
                        find contrato where contrato.contnum = contnf.contnum
                                                            no-lock no-error.
                        if avail contrato
                        then do:
                            if plani.platot > contrato.vltotal
                            then des = plani.platot / vltotal.
                            if plani.platot < vltotal
                            then acre = vltotal / plani.platot.
                        end.
                    end.
                end.
                if acre > 0
                then tot-v = tot-v + ((movim.movpc * movim.movqtm) * acre).
                if des > 0
                then tot-v = tot-v + ((movim.movpc * movim.movqtm) / des).
                if des = 0 and acre = 0
                then tot-v = tot-v + (movim.movpc * movim.movqtm).
            end.
        end.
    end.


    for each clase no-lock break by clase.clasup
                                 by clase.clacod:


        for each produ where produ.catcod = categoria.catcod and
                             produ.clacod = clase.clacod no-lock:

            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 5            and
                                 movim.movdat >= vdti        and
                                 movim.movdat <= vdtf        no-lock:

                totc = 0.
                des = 0.
                acre = 0.
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.pladat = movim.movdat and
                                       plani.movtdc = movim.movtdc
                                                        no-lock no-error.
                if avail plani and plani.crecod = 2
                then do:
                    for each contnf where contnf.placod = plani.placod and
                                          contnf.etbcod = plani.etbcod no-lock:
                        find contrato where contrato.contnum = contnf.contnum
                                                            no-lock no-error.
                        if avail contrato
                        then do:
                            if plani.platot > contrato.vltotal
                            then des = plani.platot / vltotal.
                            if plani.platot < vltotal
                            then acre = vltotal / plani.platot.
                        end.
                    end.
                end.

                if acre > 0
                then venda = venda + ((movim.movpc * movim.movqtm) * acre).
                if des > 0
                then venda = venda + ((movim.movpc * movim.movqtm) / des).
                if des = 0 and acre = 0
                then venda = venda + (movim.movpc * movim.movqtm).
                est-ven = est-ven + movim.movqtm.

            end.

            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 4  no-lock.
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat no-lock
                                            no-error.

                if avail plani
                then do:
                    if  plani.datexp >= vdti  and
                        plani.datexp <= vdtf
                    then assign
                            compra  = compra + (movim.movpc * movim.movqtm)
                            est-com = est-com + movim.movqtm.
                end.
            end.
            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 1  no-lock.
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat no-lock
                                            no-error.

                if avail plani
                then do:
                    if  plani.datexp >= vdti  and
                        plani.datexp <= vdtf
                    then assign
                            compra  = compra + (movim.movpc * movim.movqtm)
                            est-com = est-com + movim.movqtm.
                end.
            end.

            /**************************/


            for each estab no-lock:
                find bestoq where bestoq.etbcod = estab.etbcod and
                                  bestoq.procod = produ.procod no-lock no-error.
                if not avail bestoq
                then next.
                find hiest where hiest.etbcod = estab.etbcod and
                                 hiest.procod = produ.procod and
                                 hiest.hiemes = month(vdtf)  and
                                 hiest.hieano = year(vdtf) no-lock no-error.
                if not avail hiest
                then do:
                    if month(vdtf) = 1
                    then assign vano = year(vdtf) - 1
                                vmes = 12.
                    else assign vano = year(vdtf)
                                vmes = month(vdtf).
                    find last hiest where hiest.etbcod = estab.etbcod and
                                          hiest.procod = produ.procod and
                                          hiest.hiemes = vmes         and
                                          hiest.hieano = vano no-lock no-error.
                    if not avail hiest
                    then do:
                        find bestoq where bestoq.etbcod = estab.etbcod and
                                          bestoq.procod = produ.procod
                                                              no-lock no-error.
                        if avail bestoq
                        then do:
                            valest = valest +
                                     (bestoq.estatual * bestoq.estvenda).
                            valcus = valcus +
                                        (bestoq.estatual * bestoq.estcusto).
                            est-atu = est-atu + bestoq.estatual.
                        end.
                    end.
                    else do:
                        valest  = valest  + (hiest.hiestf * bestoq.estvenda).
                        valcus  = valcus  + (hiest.hiestf * bestoq.estcusto).
                        est-atu = est-atu + hiest.hiestf.
                    end.
                end.
                else do:
                    valest  = valest  + (hiest.hiestf * bestoq.estvenda).
                    valcus  = valcus  + (hiest.hiestf * bestoq.estcusto).
                    est-atu = est-atu + hiest.hiestf.
                end.
            end.

            output stream stela to terminal.
            disp stream stela produ.procod produ.clacod
                        with frame ffff centered color white/red 1 down.
            pause 0.
            output stream stela close.
        end.

        if line-counter = 6
     then put "    V E N D A S         C O M P R A S           E S T O Q U E S "
                AT 35 skip fill("-",135) format "x(135)".

        if est-ven = 0 and
           venda   = 0 and
           est-com = 0 and
           compra = 0   and
           est-atu = 0  and
           valest  = 0  and
           valcus  = 0
        then next.

        if line-counter = 6
   then put "      V E N D A S         C O M P R A S          E S T O Q U E S "
                AT 35 skip fill("-",135) format "x(135)".

        v-giro = (valest / venda).
        if v-giro = ?
        then v-giro = 0.
        display clase.clacod
                clase.clanom when avail clase
                est-ven(total by clase.clasup) column-label "FISICO"
                venda(total by clase.clasup)    column-label "FINANCEIRO"
                ((venda / tot-v) * 100)(total by clase.clasup)
                                       column-label "%/Par." format "->,>>9.99"
                est-com(total by clase.clasup) column-label "FISICO"
                compra(total by clase.clasup)  column-label "FINANCEIRO"
                est-atu(total by clase.clasup) column-label "FISICO"
                valest(total by clase.clasup)  column-label "FIN.VENDA"
                valcus(total by clase.clasup)  column-label "FIN.CUSTO"
                v-giro  column-label "GIRO"
                            with frame f-1 width 200 down no-box.

        t-venda = t-venda + venda.
        t-valest = t-valest + valest.

        t-ven = t-venda + venda.
        t-val = t-valest + valest.
        if last-of(clase.clasup)
        then do:
            put (t-valest / t-venda) to 129 " GIRO".
            t-valest = 0.
            t-venda  = 0.
        end.

            assign est-ven = 0
                   venda   = 0
                   est-com = 0
                   compra = 0
                   est-atu = 0
                   valest  = 0
                   valcus  = 0.

    end.
    put skip.
    put (t-val / t-ven) to 129 " GIRO TOTAL".
    end.
    else do:
    for each clase where clase.clasup = vclasup
                            no-lock by clase.clasup
                                    by clase.clacod:
        for each produ where produ.catcod = categoria.catcod and
                             produ.clacod = clase.clacod no-lock:
            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 5            and
                                 movim.movdat >= vdti        and
                                 movim.movdat <= vdtf        no-lock:

                totc = 0.
                des = 0.
                acre = 0.
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.pladat = movim.movdat and
                                       plani.movtdc = movim.movtdc
                                                        no-lock no-error.
                if avail plani and plani.crecod = 2
                then do:
                    for each contnf where contnf.placod = plani.placod and
                                          contnf.etbcod = plani.etbcod no-lock:
                        find contrato where contrato.contnum = contnf.contnum
                                                            no-lock no-error.
                        if avail contrato
                        then do:
                            if plani.platot > contrato.vltotal
                            then des = plani.platot / vltotal.
                            if plani.platot < vltotal
                            then acre = vltotal / plani.platot.
                        end.
                    end.
                end.
                if acre > 0
                then tot-v = tot-v + ((movim.movpc * movim.movqtm) * acre).
                if des > 0
                then tot-v = tot-v + ((movim.movpc * movim.movqtm) / des).
                if des = 0 and acre = 0
                then tot-v = tot-v + (movim.movpc * movim.movqtm).
            end.
        end.
    end.


    for each clase where clase.clasup = vclasup
                    no-lock break by clase.clasup
                                  by clase.clacod:


        for each produ where produ.catcod = categoria.catcod and
                             produ.clacod = clase.clacod no-lock:

            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 5            and
                                 movim.movdat >= vdti        and
                                 movim.movdat <= vdtf        no-lock:

                totc = 0.
                des = 0.
                acre = 0.
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat
                                                        no-lock no-error.
                if avail plani and plani.crecod = 2
                then do:
                    for each contnf where contnf.placod = plani.placod and
                                          contnf.etbcod = plani.etbcod no-lock:
                        find contrato where contrato.contnum = contnf.contnum
                                                            no-lock no-error.
                        if avail contrato
                        then do:
                            if plani.platot > contrato.vltotal
                            then des = plani.platot / vltotal.
                            if plani.platot < vltotal
                            then acre = vltotal / plani.platot.
                        end.
                    end.
                end.

                if acre > 0
                then venda = venda + ((movim.movpc * movim.movqtm) * acre).
                if des > 0
                then venda = venda + ((movim.movpc * movim.movqtm) / des).
                if des = 0 and acre = 0
                then venda = venda + (movim.movpc * movim.movqtm).
                est-ven = est-ven + movim.movqtm.

            end.

            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 4            and
                                 movim.movdat >= vdti        and
                                 movim.movdat <= vdtf        no-lock:
                compra  = compra + (movim.movpc * movim.movqtm).
                est-com = est-com + movim.movqtm.
            end.

            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 1            and
                                 movim.movdat >= vdti        and
                                 movim.movdat <= vdtf        no-lock:
                compra  = compra + (movim.movpc * movim.movqtm).
                est-com = est-com + movim.movqtm.
            end.
            /**************************/


            for each estab no-lock:
                find bestoq where bestoq.etbcod = estab.etbcod and
                                  bestoq.procod = produ.procod no-lock no-error.
                if not avail bestoq
                then next.
                find hiest where hiest.etbcod = estab.etbcod and
                                 hiest.procod = produ.procod and
                                 hiest.hiemes = month(vdtf)  and
                                 hiest.hieano = year(vdtf) no-lock no-error.
                if not avail hiest
                then do:
                    if month(vdtf) = 1
                    then assign vano = year(vdtf) - 1
                                vmes = 12.
                    else assign vano = year(vdtf)
                                vmes = month(vdtf).
                    find last hiest where hiest.etbcod = estab.etbcod and
                                          hiest.procod = produ.procod and
                                          hiest.hiemes = vmes         and
                                          hiest.hieano = vano no-lock no-error.
                    if not avail hiest
                    then do:
                        find bestoq where bestoq.etbcod = estab.etbcod and
                                          bestoq.procod = produ.procod
                                                              no-lock no-error.
                        if avail bestoq
                        then do:
                            valest = valest +
                                     (bestoq.estatual * bestoq.estvenda).
                            valcus = valcus +
                                        (bestoq.estatual * bestoq.estcusto).
                            est-atu = est-atu + bestoq.estatual.
                        end.
                    end.
                    else do:
                        valest  = valest  + (hiest.hiestf * bestoq.estvenda).
                        valcus  = valcus  + (hiest.hiestf * bestoq.estcusto).
                        est-atu = est-atu + hiest.hiestf.
                    end.
                end.
                else do:
                    valest  = valest  + (hiest.hiestf * bestoq.estvenda).
                    valcus  = valcus  + (hiest.hiestf * bestoq.estcusto).
                    est-atu = est-atu + hiest.hiestf.
                end.
            end.

            output stream stela to terminal.
            disp stream stela produ.procod produ.clacod
                        with frame fff3 centered color white/red 1 down.
            pause 0.
            output stream stela close.
        end.

        if line-counter = 6
     then put "    V E N D A S         C O M P R A S           E S T O Q U E S "
                AT 35 skip fill("-",135) format "x(135)".

        if est-ven = 0 and
           venda   = 0 and
           est-com = 0 and
           compra = 0   and
           est-atu = 0  and
           valest  = 0  and
           valcus  = 0
        then next.

        if line-counter = 6
   then put "      V E N D A S         C O M P R A S          E S T O Q U E S "
                AT 35 skip fill("-",135) format "x(135)".

        v-giro = (valest / venda).
        if v-giro = ?
        then v-giro = 0.
        display clase.clacod
                clase.clanom when avail clase
                est-ven(total by clase.clasup) column-label "FISICO"
                venda(total by clase.clasup)    column-label "FINANCEIRO"
                ((venda / tot-v) * 100)(total by clase.clasup)
                                       column-label "%/Par." format "->,>>9.99"
                est-com(total by clase.clasup) column-label "FISICO"
                compra(total by clase.clasup)  column-label "FINANCEIRO"
                est-atu(total by clase.clasup) column-label "FISICO"
                valest(total by clase.clasup)  column-label "FIN.VENDA"
                valcus(total by clase.clasup)  column-label "FIN.CUSTO"
                v-giro  column-label "GIRO"
                            with frame f-3 width 200 down no-box.

        t-venda = t-venda + venda.
        t-valest = t-valest + valest.

        t-ven = t-venda + venda.
        t-val = t-valest + valest.
        if last-of(clase.clasup)
        then do:
            put (t-valest / t-venda) to 129 " GIRO".
            t-valest = 0.
            t-venda  = 0.
        end.

            assign est-ven = 0
                   venda   = 0
                   est-com = 0
                   compra = 0
                   est-atu = 0
                   valest  = 0
                   valcus  = 0.

    end.
    put skip.
    put (t-val / t-ven) to 129 " GIRO TOTAL".
    end.
    output close.
    message "Deseja Imprimir Relatorio" update sresp.
    if sresp
    then dos silent value( " type i:\admcom\relat\cve3 > prn" ).
end.



