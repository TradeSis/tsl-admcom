{admcab.i}
def var vtotcomp    like titulo.titvlcob.
def var vtotpag     like titulo.titvlcob.
def var vtotjur     like titulo.titvlcob.
def var vtotdes     like titulo.titvlcob.
def var ventrada    like titulo.titvlcob.
def var vdtini      like titulo.titdtemi label "Data Inicial".
def var vdtfin      like titulo.titdtemi label "Data Final  ".
def var sresumo     as   log format "Sim/Nao" initial yes.
def var wpar        as int format ">>9" .

def temp-table wlinha
    field data as date
    field totcomp like titulo.titvlcob format "->,>>>,>>>,>>9.99"
    field entrada like titulo.titvlcob format "->,>>>,>>>,>>9.99"
    field totpag  like titulo.titvlcob format "->,>>>,>>>,>>9.99"
    field totjur  like titulo.titvlcob format "->,>>>,>>>,>>9.99"
    field totdes  like titulo.titvlcob format "->,>>>,>>>,>>9.99".

repeat with 1 down side-label width 80 row 3:
    prompt-for estab.etbcod colon 20.
    find estab using etbcod .
    display estab.etbnom no-label.
    update vdtini colon 20
           vdtfin colon 50.

    message "Imprimir ?" update sresumo.
    if sresumo
    then do:
        output to printer page-size 64.
        form header
            wempre.emprazsoc
                    space(6) "RESCTPG"   at 60
                    "Pag.: " at 71 page-number format ">>9" skip
                    "RESUMO DE CONTRATOS E PAGAMENTOS "   at 1
                    today format "99/99/9999" at 60
                    string(time,"hh:mm:ss") at 73
                    skip fill("-",80) format "x(80)" skip
                    with frame fcab no-label page-top no-box width 137.
        view frame fcab.

        for each contrato where contrato.etbcod = estab.etbcod and
                                contrato.dtinicial >= vdtini and
                                contrato.dtinicial <= vdtfin .

            find first wlinha where wlinha.data = contrato.dtinicial no-error.
            if not avail wlinha then do:
                create wlinha.
                assign wlinha.data = contrato.dtinicial
                       wlinha.totcomp = wlinha.totcomp + contrato.vltotal
                       wlinha.entrada = wlinha.entrada + contrato.vlentra.
            end.
            else do:
                assign wlinha.totcomp = wlinha.totcomp + contrato.vltotal
                       wlinha.entrada = wlinha.entrada + contrato.vlentra.
            end.

        end .

        for each titulo use-index titdtpag where
                 titulo.empcod = wempre.empcod and
                 titulo.titnat = no and
                 titulo.modcod = "CRE" and
                 titulo.titdtpag >= vdtini and
                 titulo.titdtpag <= vdtfin and
                 titulo.etbcod = estab.etbcod.

            find first wlinha where wlinha.data = titulo.titdtpag no-error.
            if not avail wlinha then do:
                create wlinha.
                wlinha.data = titulo.titdtpag.
                wlinha.totpag = wlinha.totpag + titulo.titvlcob.
            wlinha.totjur = wlinha.totjur + (titulo.titvlpag - titulo.titvlcob).
            wlinha.totdes = wlinha.totdes + (titulo.titvlcob - titulo.titvlpag).
            end.
            else do:
                wlinha.totpag = wlinha.totpag + titulo.titvlcob.
            wlinha.totjur = wlinha.totjur + (titulo.titvlpag - titulo.titvlcob).
            wlinha.totdes = wlinha.totdes + (titulo.titvlcob - titulo.titvlpag).
            end.

        end.

        for each wlinha by wlinha.data:
            disp wlinha.data     column-label "Data"
                 wlinha.totcomp  column-label "Vl.Contrato " (TOTAL)
                 wlinha.entrada  column-label "Vl.Entradas " (TOTAL)
                 wlinha.totpag   column-label "Vl.Parcelas " (TOTAL)
                 wlinha.totjur   column-label "Vl.Juros    " (TOTAL)
                 wlinha.totdes   column-label "Vl.Descontos" (TOTAL)
                 with frame f1.
        end.

        output close.
    end.
    else undo,retry.

end.
