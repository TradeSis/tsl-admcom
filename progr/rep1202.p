{admcab.i}

def var varquivo as char.
def var vdata  as date format "99/99/9999".
def var totsal like contrato.vltotal.
def var totger like contrato.vltotal.
def var totcon like contrato.vltotal.
def buffer btitulo for titulo.
def stream stela.

repeat:
    update vdata label "Data" with frame f11 side-label width 80.

    varquivo = "/admcom/relat/rep1202_" + string(mtime).
    {mdcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "120"
        &Page-Line = "66"
        &Nom-Rel   = """REP1202"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """RESUMO DE REPARCELAMENTO  -  ATE "" + string(vdata)"
        &Width     = "120"
        &Form      = "frame f-cab"}
    totger = 0.

    for each contrato use-index est no-lock
                                          break by contrato.etbcod
                                                by contrato.clicod.

        find clien where clien.clicod = contrato.clicod no-lock no-error.
        if not avail clien
        then next.

        if contrato.banco = 99 and
           contrato.dtinicial <= vdata
        then do:
            find first titulo where titulo.empcod = 19 and
                                    titulo.titnat = no and
                                    titulo.modcod = "CRE" and
                                    titulo.etbcod = contrato.etbcod and
                                    titulo.clifor = contrato.clicod and
                                    titulo.titnum = string(contrato.contnum) and
                                    titulo.tpcontrato = "L" /*titpar = 51*/
                              no-lock no-error.
            if avail titulo
            then do:
                for each btitulo where btitulo.empcod = 19
                                  and  btitulo.titnat = no
                                  and  btitulo.modcod = "CRE"
                                  and  btitulo.etbcod = contrato.etbcod
                                  and  btitulo.clifor = contrato.clicod
                                  and  btitulo.titnum = string(contrato.contnum)
                                      no-lock:
                    totcon = totcon + btitulo.titvlcob.
                    totger = totger + btitulo.titvlcob.
                    if btitulo.titsit = "LIB"
                    then totsal = totsal + btitulo.titvlcob.
                end.
            end.

            output stream stela to terminal.
            disp stream stela contrato.etbcod
                              contrato.clicod
                              totger column-label "TOTAL"
                              i with frame f3 1 down centered row 8. pause 0.
            output stream stela to close.
        end.

        if last-of(contrato.clicod) and totcon > 0
        then do:
            display contrato.etbcod column-label "FL." format ">>9"
                    contrato.clicod
                    clien.clinom
                    totcon(total by contrato.etbcod) column-label "Vl.Total"
                    totsal(total by contrato.etbcod) column-label "Saldo"
                    with frame f2 down width 200.
            totcon = 0.
            totsal = 0.
        end.
    end.
    put skip.
    display totger label "TOTAL GERAL.................... "
                        with frame f4 side-label.
    output close.

    run visurel.p (input varquivo, input "").
end.

