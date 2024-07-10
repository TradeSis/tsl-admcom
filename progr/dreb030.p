{admcab.i}
def var vdata       like titulo.titdtemi.
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .
def var vjuro       like titulo.titjuro.
def var vdesc       like titulo.titdesc.

def new shared temp-table wfresumo
    field etbcod    like estab.etbcod       column-label "Loja"
    field data      like titulo.titdtpag    column-label "Data"
    field compra    like titulo.titvlcob    column-label "Tot.Compra"
                                                  format ">>>,>>9.99"
    field entrada   like titulo.titvlcob    column-label "Tot.Entrada"
                                                  format ">>>,>>9.99"
    field vlpago    like titulo.titvlpag    column-label "Valor Pago"
                                                  format ">>>,>>9.99"
    field titjuro   like titulo.titjuro     column-label "Juros"
                                                  format ">>>,>>9.99"
    field titdesc   like titulo.titdesc     column-label "Decontos"
                                                  format ">>>,>>9.99".

repeat with 1 down side-label width 80 row 3:

    update vdata colon 20.
    /*
    if vdata entered
    then do:
    */
    for each wfresumo.
        delete wfresumo.
    end.
    do:
        for each contrato where contrato.datexp    = vdata no-lock.
            if contrato.banco <> 99
            then next.
            find first wfresumo where wfresumo.etbcod  = contrato.etbcod
                                  and wfresumo.data    = contrato.dtinicial
                                                        no-error.
            if not avail wfresumo
            then create wfresumo.
            assign wfresumo.etbcod  = contrato.etbcod
                   wfresumo.data    = contrato.dtinicial
                   wfresumo.entrada = wfresumo.entrada + contrato.vlentra
                   wfresumo.compra  = wfresumo.compra  + contrato.vltotal.
        end.

        for each estab no-lock.
            for each titulo where titulo.etbcod = estab.etbcod  and
                                  titulo.cxacod = 99            and
                                  titulo.cxmdat = vdata         and
                                  titulo.titpar > 0             :
                if titulo.clifor = 1
                then
                    next .
                vjuro = if titulo.titjuro = titulo.titdesc
                        then 0
                        else titulo.titjuro.
                vdesc = if titulo.titjuro = titulo.titdesc
                        then 0
                        else titulo.titdesc.
                find first wfresumo where wfresumo.etbcod = titulo.etbcobra and
                                          wfresumo.data   = titulo.titdtpag
                                                                    no-error.
                if not avail wfresumo
                then create wfresumo.
                assign wfresumo.etbcod  = titulo.etbcobra
                       wfresumo.data    = titulo.titdtpag
                       wfresumo.vlpago  = wfresumo.vlpago + (titulo.titvlpag -
                                                             titulo.titjuro  +
                                                             titulo.titdesc)
                       wfresumo.titjuro = wfresumo.titjuro + vjuro
                       wfresumo.titdesc = wfresumo.titdesc + vdesc.
            end.
        end.
    end.
    /*
    end.
    */
    message "Deseja na Tela ou Relatorio" update sresp format "Tela/Relatorio".

    if sresp
    then do:
        run dreb030t.p.
    end.
    else do:

        {mdadmcab.i
             &Saida     = "printer"
             &Page-Size = "64"
             &Cond-Var  = "120"
             &Page-Line = "66"
             &Nom-Rel   = """DREB030"""
             &Nom-Sis   = """SISTEMA CREDIARIO"""
             &Tit-Rel   = """RESUMO DE DIGITACAO PAGAMENTOS E CONTRATOS DIA "" +
                            string(vdata) "
             &Width     = "120"
             &Form      = "frame f-cab"}

        for each wfresumo break by wfresumo.etbcod
                                by wfresumo.data.
            find estab where estab.etbcod = wfresumo.etbcod no-lock .
            if first-of(wfresumo.etbcod)
            then
                display wfresumo.etbcod     column-label "Etb."
                        estab.etbnom        column-label "Loja" when avail estab
                        with frame flin.
            display wfresumo.data
                    space(2)
                    wfresumo.compra     when wfresumo.compra > 0
                                        column-label "Tot.Compra"   (total)
                    wfresumo.entrada    when wfresumo.entrada > 0
                                        column-label "Tot.Entrada"  (total)
                    space(2)
                    "|"    no-label
                    space(2)
                    wfresumo.vlpago     when wfresumo.vlpago > 0
                                        column-label "Valor Pago"   (total)
                    wfresumo.titjuro    when wfresumo.titjuro > 0
                                        column-label "Juros"        (total)
                    wfresumo.titdesc    when wfresumo.titdesc > 0
                                        column-label "Descontos"    (total)
                    with frame flin
                         width 160 down no-box.
        end.
        output close.
    end.
end.
