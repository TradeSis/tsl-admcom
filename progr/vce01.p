{admcab.i }
def buffer bcurva for curva.
def buffer bclase for clase.
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
    /*
    update vetbi no-label
           "a"
           vetbf no-label with frame f-etb centered color blue/cyan row 12
                                    title " Filial ".
    */

        disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
        pause.

    for each curva:
        disp "DELETANDO ...." curva.cod no-label with frame fffff centered.
        pause 0.
        delete curva.
    end.
    /*
        {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""VCE01""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """RESUMO VENDA/COMPRA/ESTOQUE GERAL - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label.
    */
    for each bclase where bclase.claord = (if categoria.catcod = 31
                                           then yes
                                           else no) and
                          bclase.clasup = 0 break by bclase.clacod:
        disp bclase.clacod
             bclase.clanom with frame f1 down. pause 0.

        for each clase where clase.claord = (if categoria.catcod = 31
                                               then yes
                                               else no) and
                             clase.clasup = bclase.clacod break by clase.clacod:

            disp clase.clacod
                 clase.clanom with frame f1 down. pause 0.

            for each produ where produ.clacod = clase.clacod:

            disp produ.procod with 1 down. pause 0.

                for each movim where movim.procod = produ.procod and
                                     movim.movtdc = 5 and
                                     movim.movdat >= vdti and
                                     movim.movdat <= vdtf:

                    find first curva where curva.cod = clase.clacod no-error.
                    if not avail curva
                    then do:
                        find last bcurva no-error.
                        create curva.
                        assign curva.cod = clase.clacod.
                        if avail bcurva
                        then curva.pos = bcurva.pos + 1.
                        else curva.pos = 1.
                    end.
                    curva.qtdven = curva.qtdven + movim.movqtm.
                    curva.valven = curva.valven + (movim.movqtm * movim.movpc).

                end.

                for each movim where movim.procod = produ.procod and
                                     movim.movtdc = 4 and
                                     movim.movdat >= vdti and
                                     movim.movdat <= vdtf:

                    find first curva where curva.cod = clase.clacod no-error.
                    if not avail curva
                    then do:
                        find last bcurva no-error.
                        create curva.
                        assign curva.cod = clase.clacod.
                        if avail bcurva
                        then curva.pos = bcurva.pos + 1.
                        else curva.pos = 1.
                    end.
                    curva.estcus = curva.estcus + movim.movqtm.
                    curva.valcus = curva.valcus + (movim.movqtm * movim.movpc).

                end.

                for each estoq where estoq.procod = produ.procod:

                    find first curva where curva.cod = clase.clacod no-error.
                    if not avail curva
                    then do:
                        find last bcurva no-error.
                        create curva.
                        assign curva.cod = clase.clacod.
                        if avail bcurva
                        then curva.pos = bcurva.pos + 1.
                        else curva.pos = 1.
                    end.
                    curva.qtdest = curva.qtdest + estoq.estatual.
                    curva.estven = curva.estven +
                                   (estoq.estatual * estoq.estcusto).

                end.
                disp curva with 1 column. pause 0.
            end.

        end.




    end.
end.

/*
    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock.
        assign vvlcusto = 0
               vvlvenda = 0
               vvlmarg  = 0
               vvlperc  = 0
               vvldesc  = 0
               vvlacre  = 0
               vacrepre = 0.
        for each plani where plani.movtdc = 5 and
                             plani.etbcod = estab.etbcod and
                             plani.pladat >= vdti and
                             plani.pladat <= vdtf:

            find first bmovim where bmovim.etbcod = plani.etbcod and
                                    bmovim.placod = plani.placod no-lock
                                    no-error.
                                    if not avail bmovim then next.
            find produ where produ.procod = bmovim.procod no-lock no-error.
            if not avail produ
            then next.
            if produ.catcod <> vcatcod
            then next.

            output stream stela to terminal.
            disp stream stela
                 plani.etbcod
                 plani.pladat with frame fffpla centered color white/red.
            pause 0.
            output stream stela close.

            /************* Calculo do acrescimo *****************/

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
                                          bplani.placod = bcontnf.placod
                                          no-lock no-error.
                        if not avail bplani
                        then next.
                        vvltotal = vvltotal + (bplani.platot - bplani.vlserv).
                    end.
                    find contrato where contrato.contnum = contnf.contnum
                                                    no-lock no-error.
                    if avail contrato
                    then do:

                        find finan where finan.fincod = contrato.crecod
                                                        no-lock no-error.
                        if avail finan
                        then do:

                            vvlcont = contrato.vltotal.
                            valortot = contrato.vltotal.
                        end.

                        wacr = vvlcont  - vvltotal.  /*plani.platot.*/

                        wper = plani.platot / vvltotal.

                        wacr = wacr * wper.

                    end.
                    else do:
                        wacr = plani.acfprod.
                        valortot = plani.platot.
                    end.

                    if wacr < 0
                    then wacr = 0.

                    assign vvldesc  = vvldesc  + plani.descprod
                           vvlacre  = vvlacre  + wacr.

            /****************************    ********************/

            /**********************  Inicio do acrescimo previsto *******/

                    if avail finan
                    then do:
                        wnp = finan.finnpc + if finan.finent = yes
                                             then 1
                                             else 0.
                        vval = 0.
                        vval1 = 0.
                        vsal = 0.

                        vval = (plani.platot * finan.finfat).

                        if finan.fincod < 50 or finan.fincod >= 100
                        then do:
                            vsal = vval - int(vval).
                            if vsal > 0
                            then vval = vval + (0.50 - vsal).
                            if vsal < 0 and vsal <> -0.50
                            then vval = ((vval - int(vval)) * -1) + vval.
                            vlfinan = vval * wnp.
                        end.
                        else do:
                            vval1 = vval.
                            if vval1 > vval
                            then vval1 = vval1 - 0.10.
                            vlfinan = vvltotal.
                        end.

                        assign vacrepre = vacrepre + (vlfinan - plani.platot).

                    end.
                end.
            end.
            /********************* ********************/

            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod no-lock:
                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ
                then next.
                if produ.catcod = vcatcod
                then do:
                    find estoq where estoq.etbcod = movim.etbcod and
                                     estoq.procod = movim.procod
                                                            no-lock no-error.
                    if avail estoq
                    then vvlcusto = vvlcusto + (movim.movqtm * estoq.estcusto).

                    assign vvlvenda = vvlvenda + (movim.movqtm * movim.movpc).
                end.
            end.

            /* message vacrepre vvlacre vvldesc vlfinan plani.platot. */
        end.
        vvlmarg = vvlvenda - vvlcusto.
        vvlperc = (vvlmarg * 100) / vvlvenda.
        if vvlperc = ?
        then vvlperc = 0.
        disp "Filial - " estab.etbcod column-label "Filial" space(5)
             vvlcusto(total)
             vvlvenda(total)
             vvlmarg(total)
             vvlperc
             vvldesc(total)
             vvlacre(total)
             vacrepre(total)
             (vvlvenda - vvldesc + vvlacre)(total) label "Vl.Liq."
             ((vvlacre / vvlvenda) * 100) label "M %" format ">>9.99"
             with frame f-imp width 150 down.
    end.
    output close.
end.
*/
