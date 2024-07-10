{admcab.i}
def var vok as l.
def var vcatcod  like produ.catcod.
def var vcatcod2 like produ.catcod.

def var i as int.
def var vdtini      like titulo.titdtemi    label "Data Inicial".
def var vdtfin      like titulo.titdtemi    label "Data Final".
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .
def var vjuro       like titulo.titjuro.
def var vdesc       like titulo.titdesc.

def temp-table wfresumo
    field etbcod    like estab.etbcod       column-label "Loja"
    field compra    like titulo.titvlcob    column-label "Tot.Compra"
                                                  format ">>>,>>>,>>9.99"
    field vista    like titulo.titvlcob    column-label "Tot. Vista"
                                                  format ">>>,>>>,>>9.99"
    field entrada   like titulo.titvlcob    column-label "Tot.Entrada"
                                                  format ">>>,>>>,>>9.99"
    field vlpago    like titulo.titvlpag    column-label "Valor Pago"
                                                  format ">>>,>>>,>>9.99"
    field vltotal   like titulo.titvlpag    column-label "Valor Total"
                                                  format ">>>,>>>,>>9.99"
    field qtdcont   as   int column-label "Qtd.Contratos"
    field juros     like titulo.titjuro     column-label "Juros".

repeat with 1 down side-label width 80 row 3:

    update vdtini colon 20
           vdtfin colon 20.
           i = 0.
    update vcatcod  label "Departamento"     colon 20
           with frame ff side-labels width 80 row 8 .
    find categoria where categoria.catcod = vcatcod no-lock no-error.
    display categoria.catnom no-label with frame  ff.
    if vcatcod = 41
    then vcatcod2 = 45.
    if vcatcod = 31
    then vcatcod2 = 35.
    for each wfresumo.
        delete wfresumo.
    end.
    do:
            for each contrato where contrato.dtinicial >= vdtini and
                                    contrato.dtinicial <= vdtfin no-lock.
                i = i  + 1.
                display contrato.dtinicial i
                        with frame f1 no-label 1 down
                            title " Contratos ". pause 0.
                for each contnf where contnf.etbcod  = contrato.etbcod and
                                      contnf.contnum = contrato.contnum
                                                            no-lock:
                    find plani where plani.etbcod = contnf.etbcod and
                                     plani.placod = contnf.placod
                                        no-lock no-error.
                    if not avail plani
                    then next.
                    vok = no.
                    for each movim where movim.etbcod = plani.etbcod and
                                         movim.placod = plani.placod and
                                         movim.movtdc = plani.movtdc no-lock:
                        find produ where produ.procod = movim.procod
                                                            no-lock no-error.
                        if not avail produ
                        then next.
                        if produ.catcod <> vcatcod and
                           produ.catcod <> vcatcod2
                        then do:
                            vok = no.
                            leave.
                        end.
                        else vok = yes.
                    end.
                end.
                if vok = no
                then next.
                find first wfresumo where wfresumo.etbcod = contrato.etbcod
                                                            no-error.
                if not avail wfresumo
                then create wfresumo.
                assign wfresumo.etbcod  = contrato.etbcod
                       wfresumo.entrada = wfresumo.entrada + contrato.vlentra
                       wfresumo.compra  = wfresumo.compra  + contrato.vltotal
                       wfresumo.qtdcont = wfresumo.qtdcont + 1.
            end.
            i = 0.

                for each titulo where titulo.empcod    = wempre.empcod  and
                                      titulo.titnat    = no             and
                                      titulo.modcod    = "CRE"          and
                                      titulo.titdtpag >= vdtini         and
                                      titulo.titdtpag <= vdtfin no-lock.
                    vok = no.
                    for each contnf where contnf.etbcod = titulo.etbcod and
                                          contnf.contnum = int(titulo.titnum)
                                                                    no-lock.
                        find first plani where plani.etbcod = contnf.etbcod and
                                               plani.placod = contnf.placod
                                                             no-lock no-error.
                        if not avail plani
                        then next.
                        else vok = yes.
                    end.
                    if vok = no
                    then next.
                    vok = no.
                    for each movim where movim.etbcod = plani.etbcod and
                                         movim.placod = plani.placod and
                                         movim.movtdc = plani.movtdc no-lock:
                        find produ where produ.procod = movim.procod
                                                        no-lock no-error.
                        if not avail produ
                        then next.
                        if produ.catcod <> vcatcod and
                           produ.catcod <> vcatcod2
                        then do:
                            vok = no.
                            leave.
                        end.
                        else vok = yes.
                    end.
                    if vok = no
                    then next.
                    if titulo.clifor = 1
                    then wfresumo.vista   = wfresumo.vista + titulo.titvlcob.

                    if titulo.titpar = 0
                    then
                        next.
                    i = i  + 1.
                    display titulo.titdtpag i titulo.etbcod
                            with frame f2 no-label 1 down
                                title " Parcelas ". pause 0.
                    find first wfresumo where wfresumo.etbcod = titulo.etbcobra
                                                                    no-error.
                    if not avail wfresumo
                    then create wfresumo.
                    assign
                        wfresumo.etbcod  = titulo.etbcobra.
                    if titulo.clifor > 1
                    then assign
                        wfresumo.vlpago  = wfresumo.vlpago + titulo.titvlcob
                        wfresumo.juros   = wfresumo.juros + titulo.titjuro.
                end.


    end.

    do:

        {mdadmcab.i
             &Saida     = "printer"
             &Page-Size = "64"
             &Cond-Var  = "120"
             &Page-Line = "66"
             &Nom-Rel   = """DREB032"""
             &Nom-Sis   = """SISTEMA CREDIARIO"""
             &Tit-Rel   = """RESUMO MENSAL DE CAIXA  -  PERIODO DE "" +
                            string(vdtini)  + "" A "" + string(vdtfin) +
                            ""   "" + categoria.catnom"
             &Width     = "120"
             &Form      = "frame f-cab"}

        for each wfresumo break by wfresumo.etbcod .
            wfresumo.vltotal = wfresumo.vlpago +
                               wfresumo.juros +
                               wfresumo.entrada +
                               wfresumo.vista.
            find estab where estab.etbcod = wfresumo.etbcod no-lock no-error.
            display wfresumo.etbcod     column-label "Etb."
            /*
                    estab.etbnom        column-label "Loja" when avail estab
            */
                    wfresumo.vlpago     column-label "Pagamentos"   (total)
                    wfresumo.juros                                  (TOTAL)
                    wfresumo.qtdcont                                (total)
                    wfresumo.compra     column-label "Contratos"    (total)
                    wfresumo.entrada    column-label "Entradas"     (total)
                    wfresumo.vista      column-label "V. Vista"     (total)
                    wfresumo.vltotal    column-label "TOTAL"        (total)
                    with frame flin
                         width 160 down no-box.
        end.
        output close.
    end.
end.
