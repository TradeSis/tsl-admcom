{admcab.i}.
def var v-ac as dec.
def var v-de as dec.
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

    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".

    update vetbi no-label
           "a"
           vetbf no-label with frame f-etb centered color blue/cyan row 12
                                    title " Filial ".

    message "Confirma geracao do resumo" update sresp.
    if not sresp
    then leave.

    vcatcod2 = 0.
    find categoria where categoria.catcod = 31 no-lock.
    disp categoria.catnom no-label with frame f-dep.

    if vcatcod = 31
    then vcatcod2 = 35.
    if vcatcod = 41
    then vcatcod2 = 45.


    varquivo = "..\encerra\res" + "31" + string(day(today)).
        {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""ENC01""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """MOVIMENTACOES GERAL POR FILIAL - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label.

    /*******************************************************************
    * Para cada Estabelecimento escolhido, segue o processamento ...   *
    *******************************************************************/

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock.
        assign vvlcusto = 0
               vvlvenda = 0
               vvlmarg  = 0
               vvlperc  = 0
               vvldesc  = 0
               vvlacre  = 0
               vacrepre = 0
               vldev    = 0.

        /***************************************************************
        * Le todas as planilhas de venda do periodo solicitado         *
        ***************************************************************/

        for each plani where plani.movtdc = 5 and
                             plani.etbcod = estab.etbcod and
                             plani.pladat >= vdti and
                             plani.pladat <= vdtf no-lock:

            /***********************************************************
            * Veirifica se os produtos desta planilha, pertencem ao    *
            * departamento escolhido.                                  *
            ***********************************************************/

            vok = no.
            vv = yes.
            for each bmovim where bmovim.etbcod = plani.etbcod and
                                  bmovim.placod = plani.placod and
                                  bmovim.movtdc = plani.movtdc and
                                  bmovim.movdat = plani.pladat no-lock:

                find produ where produ.procod = bmovim.procod no-lock no-error.
                if  avail produ
                then vcat = produ.catcod.
                if vcat = vcatcod  or
                   vcat = vcatcod2
                then do:
                    vok = yes.
                    leave.
                end.
                if vcat <> vcatcod  and
                   vcat <> vcatcod2
                then vv = no.
            end.
            if vok = no
            then next.
            if vv = no
            then next.

            /***********************************************************
            * Exibicao do andamento do processo na TELA                *
            ***********************************************************/

            output stream stela to terminal.
            disp stream stela
                 plani.etbcod
                 plani.pladat with frame fffpla centered color white/red.
            pause 0.
            output stream stela close.

            /***********************************************************
            * Calculo do Acrescimo e Desconto                          *
            ***********************************************************/

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
                        find bplani where bplani.etbcod = bcontnf.etbcod and
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
            end.

            /***********************************************************
            * Calculo do Valor de Custo e Venda                        *
            ***********************************************************/

            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = 5 no-lock:

                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ
                then next.

                if produ.catcod = vcatcod  or
                   produ.catcod = vcatcod2
                then do:
                    find estoq where estoq.etbcod = movim.etbcod and
                                     estoq.procod = movim.procod
                                                            no-lock no-error.
                    if avail estoq
                    then assign vvlcusto = vvlcusto +
                                         (movim.movqtm * estoq.estcusto).


                    /* **************************

                    ******* Calculo ANTIGO de acrescimo e desconto ********

                    if avail plani and plani.crecod = 2
                    then do:
                        for each contnf where contnf.etbcod = plani.etbcod and
                                              contnf.placod = plani.placod
                                                                    no-lock.
                            find contrato where contrato.contnum =
                                                            contnf.contnum
                                                            no-lock no-error.
                            if avail contrato
                            then do:
                                if contrato.vltotal >
                                            (plani.platot - plani.vlserv)
                                then v-ac = contrato.vltotal /
                                            (plani.platot - plani.vlserv).
                                if contrato.vltotal <
                                            (plani.platot - plani.vlserv)
                                then v-de = (plani.platot - plani.vlserv)
                                                          / contrato.vltotal.
                            end.
                        end.

                        if plani.platot < 1
                        then assign v-de = 0
                                    v-ac = 0.
                    end.

                    if v-ac = 0 and v-de = 0
                    then vvlvenda = vvlvenda +
                                        (movim.movqtm * movim.movpc).
                    if v-ac > 0
                    then vvlvenda = vvlvenda +
                                        ((movim.movqtm * movim.movpc) * v-ac).
                    if v-de > 0
                    then vvlvenda = vvlvenda +
                                        ((movim.movqtm * movim.movpc) / v-de).

                    v-ac = 0.
                    v-de = 0.

                    ****************************************************** */

                    vvlvenda = vvlvenda + (movim.movqtm * movim.movpc).

                end.
            end.

        end.

        vvlmarg = vvlvenda - vvlcusto.
        vvlperc = (vvlmarg * 100) / vvlvenda.
        if vvlperc = ?
        then vvlperc = 0.

        /***************************************************************
        * Display das informacoes colhidas para um arquivo             *
        ***************************************************************/

        disp "Filial - " estab.etbcod column-label "Filial" space(5)
             vvlcusto(total)
             vvlvenda(total)
             vvlmarg(total) format "->,>>>,>>9"
             vvlperc        when vvlperc >= 0 format "->>9.99%"
             vvldesc(total)
             vvlacre(total)
             vacrepre(total) format "->,>>>,>>9"
             (vvlvenda - vvldesc + vvlacre)(total)
                                    format "->,>>>,>>9.99" label "Vl.Liq."
             ((vvlacre / vvlvenda) * 100) label "M %" format ">>9.99"
             with frame f-imp width 150 down.
        tot-ven = tot-ven + vvlvenda.
        tot-mar = tot-mar + vvlmarg.
        tot-acr = tot-acr  + vvlacre.
    end.

    display ((tot-mar / tot-ven) * 100) no-label format "->>9.99 %" at 61
            ((tot-acr / tot-ven) * 100) no-label format "->>9.99 %" at 119
              with frame f-tot width 150 no-label no-box.
    assign tot-ven = 0.
           tot-mar = 0.
           tot-acr = 0.
    output close.


    vcatcod2 = 0.
    find categoria where categoria.catcod = 41 no-lock.
    disp categoria.catnom no-label with frame f-dep41.

    if vcatcod = 31
    then vcatcod2 = 35.
    if vcatcod = 41
    then vcatcod2 = 45.

    varquivo = "c:\temp\res" + "41" + string(day(today)).

        {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""ENC01""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """MOVIMENTACOES GERAL POR FILIAL - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label.

    /*******************************************************************
    * Para cada Estabelecimento escolhido, segue o processamento ...   *
    *******************************************************************/

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock.
        assign vvlcusto = 0
               vvlvenda = 0
               vvlmarg  = 0
               vvlperc  = 0
               vvldesc  = 0
               vvlacre  = 0
               vacrepre = 0
               vldev    = 0.

        /***************************************************************
        * Le todas as planilhas de venda do periodo solicitado         *
        ***************************************************************/

        for each plani where plani.movtdc = 5 and
                             plani.etbcod = estab.etbcod and
                             plani.pladat >= vdti and
                             plani.pladat <= vdtf no-lock:

            /***********************************************************
            * Veirifica se os produtos desta planilha, pertencem ao    *
            * departamento escolhido.                                  *
            ***********************************************************/

            vok = no.
            vv = yes.
            for each bmovim where bmovim.etbcod = plani.etbcod and
                                  bmovim.placod = plani.placod and
                                  bmovim.movtdc = plani.movtdc and
                                  bmovim.movdat = plani.pladat no-lock:

                find produ where produ.procod = bmovim.procod no-lock no-error.
                if  avail produ
                then vcat = produ.catcod.
                if vcat = vcatcod  or
                   vcat = vcatcod2
                then do:
                    vok = yes.
                    leave.
                end.
                if vcat <> vcatcod  and
                   vcat <> vcatcod2
                then vv = no.
            end.
            if vok = no
            then next.
            if vv = no
            then next.

            /***********************************************************
            * Exibicao do andamento do processo na TELA                *
            ***********************************************************/

            output stream stela to terminal.
            disp stream stela
                 plani.etbcod
                 plani.pladat with frame fpla41 centered color white/red.
            pause 0.
            output stream stela close.

            /***********************************************************
            * Calculo do Acrescimo e Desconto                          *
            ***********************************************************/

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
                        find bplani where bplani.etbcod = bcontnf.etbcod and
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
            end.

            /***********************************************************
            * Calculo do Valor de Custo e Venda                        *
            ***********************************************************/

            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = 5 no-lock:

                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ
                then next.

                if produ.catcod = vcatcod  or
                   produ.catcod = vcatcod2
                then do:
                    find estoq where estoq.etbcod = movim.etbcod and
                                     estoq.procod = movim.procod
                                                            no-lock no-error.
                    if avail estoq
                    then assign vvlcusto = vvlcusto +
                                         (movim.movqtm * estoq.estcusto).


                    /* **************************

                    ******* Calculo ANTIGO de acrescimo e desconto ********

                    if avail plani and plani.crecod = 2
                    then do:
                        for each contnf where contnf.etbcod = plani.etbcod and
                                              contnf.placod = plani.placod
                                                                    no-lock.
                            find contrato where contrato.contnum =
                                                            contnf.contnum
                                                            no-lock no-error.
                            if avail contrato
                            then do:
                                if contrato.vltotal >
                                            (plani.platot - plani.vlserv)
                                then v-ac = contrato.vltotal /
                                            (plani.platot - plani.vlserv).
                                if contrato.vltotal <
                                            (plani.platot - plani.vlserv)
                                then v-de = (plani.platot - plani.vlserv)
                                                          / contrato.vltotal.
                            end.
                        end.

                        if plani.platot < 1
                        then assign v-de = 0
                                    v-ac = 0.
                    end.

                    if v-ac = 0 and v-de = 0
                    then vvlvenda = vvlvenda +
                                        (movim.movqtm * movim.movpc).
                    if v-ac > 0
                    then vvlvenda = vvlvenda +
                                        ((movim.movqtm * movim.movpc) * v-ac).
                    if v-de > 0
                    then vvlvenda = vvlvenda +
                                        ((movim.movqtm * movim.movpc) / v-de).

                    v-ac = 0.
                    v-de = 0.

                    ****************************************************** */

                    vvlvenda = vvlvenda + (movim.movqtm * movim.movpc).

                end.
            end.

        end.

        vvlmarg = vvlvenda - vvlcusto.
        vvlperc = (vvlmarg * 100) / vvlvenda.
        if vvlperc = ?
        then vvlperc = 0.

        /***************************************************************
        * Display das informacoes colhidas para um arquivo             *
        ***************************************************************/

        disp "Filial - " estab.etbcod column-label "Filial" space(5)
             vvlcusto(total)
             vvlvenda(total)
             vvlmarg(total) format "->,>>>,>>9"
             vvlperc        when vvlperc >= 0 format "->>9.99%"
             vvldesc(total)
             vvlacre(total)
             vacrepre(total) format "->,>>>,>>9"
             (vvlvenda - vvldesc + vvlacre)(total)
                                    format "->,>>>,>>9.99" label "Vl.Liq."
             ((vvlacre / vvlvenda) * 100) label "M %" format ">>9.99"
             with frame f-imp41 width 150 down.
        tot-ven = tot-ven + vvlvenda.
        tot-mar = tot-mar + vvlmarg.
        tot-acr = tot-acr  + vvlacre.
    end.

    display ((tot-mar / tot-ven) * 100) no-label format "->>9.99 %" at 61
            ((tot-acr / tot-ven) * 100) no-label format "->>9.99 %" at 119
              with frame f-tot width 150 no-label no-box.
    assign tot-ven = 0.
           tot-mar = 0.
           tot-acr = 0.
    output close.






    /* dos silent value("type " + varquivo + "  > prn"). */

end.
