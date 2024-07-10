{admcab.i}
def var vdt  like plani.pladat.
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

                find first wfresumo where wfresumo.etbcod = contrato.etbcod
                                                            no-error.
                if not avail wfresumo
                then create wfresumo.
                assign wfresumo.etbcod  = contrato.etbcod
                       wfresumo.entrada = wfresumo.entrada + contrato.vlentra
                       wfresumo.compra  = wfresumo.compra  + contrato.vltotal
                       wfresumo.qtdcont = wfresumo.qtdcont + 1.
            end.
            do vdt = vdtini to vdtfin:
                for each plani where plani.datexp = vdt no-lock.
                    if plani.movtdc <> 5
                    then next.
                    if plani.desti = 1
                    then do:
                        find first wfresumo where wfresumo.etbcod = plani.etbcod
                                                                    no-error.
                        if avail wfresumo
                        then wfresumo.vista = wfresumo.vista +
                                              (plani.platot - plani.vlserv).
                    end.
                end.
            end.
            i = 0.

                for each titulo where titulo.empcod    = wempre.empcod  and
                                      titulo.titnat    = no             and
                                      titulo.modcod    = "CRE"          and
                                      titulo.titdtpag >= vdtini         and
                                      titulo.titdtpag <= vdtfin no-lock.
                    /*
                    if titulo.clifor = 1
                    then wfresumo.vista   = wfresumo.vista + titulo.titvlcob.
                    */
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
             &Nom-Rel   = """DREB031"""
             &Nom-Sis   = """SISTEMA CREDIARIO"""
             &Tit-Rel   = """RESUMO MENSAL DE CAIXA  -  PERIODO DE "" +
                            string(vdtini)  + "" A "" + string(vdtfin) "
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
