{admcab.i}
def var vdt like titulo.titdtven.
def var vdti like titulo.titdtven.
def var vdtf like titulo.titdtven.
def var ventra like titulo.titvlcob.
def var vtotal like titulo.titvlcob.
def var vetbcod like estab.etbcod.
def temp-table wtit
    field wetb like estab.etbcod
    field wmes as int format "99"
    field wano as int format "9999"
    field wcar like titulo.titvlcob
    field wsal like titulo.titvlcob.

repeat:


    for each wtit.
        delete wtit.
    end.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final"
                with frame f1 side-label width 80.

    update vetbcod colon 16 with frame f1.
    if vetbcod = 0
    then do:
        disp "TODAS FILIAIS" @ estab.etbnom with frame f1.
        do vdt = vdti to vdtf:
            for each estab no-lock:
                for each contrato where contrato.etbcod    = estab.etbcod and
                                        contrato.dtinicial = vdt no-lock:

                    vtotal = vtotal + contrato.vltotal.
                    ventra = ventra + contrato.vlentra.

                    for each titulo where titulo.empcod   = 19    and
                                          titulo.titnat   = no    and
                                          titulo.modcod   = "CRE" and
                                          titulo.etbcod   = contrato.etbcod and
                                          titulo.clifor   = contrato.clicod and
                                          titulo.titnum   =
                                                        string(contrato.contnum)
                                                              no-lock:
                        find first wtit where
                                        wtit.wmes = month(titulo.titdtven) and
                                        wtit.wano = year(titulo.titdtven)  and
                                        wtit.wetb = estab.etbcod no-error.
                        if not avail wtit
                        then do:
                            create wtit.
                            assign wtit.wetb = estab.etbcod
                                   wtit.wmes = month(titulo.titdtven)
                                   wtit.wano = year(titulo.titdtven).
                        end.
                        if titulo.titsit = "lib"
                        then wtit.wsal = wtit.wsal + titulo.titvlcob.

                        wtit.wcar = wtit.wcar + titulo.titvlcob.
                        display wtit.wetb column-label "ETB"
                                wtit.wano column-label "ANO"
                                wtit.wmes column-label "MES"
                                wtit.wcar column-label "CARTEIRA"
                                wtit.wsal column-label "SALDO"
                                                with 1 down. pause 0.
                    end.
                end.
            end.
        end.
    end.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        disp estab.etbnom no-label with frame f1.
        do vdt = vdti to vdtf:
            for each contrato where contrato.etbcod    = estab.etbcod and
                                    contrato.dtinicial = vdt no-lock:

                vtotal = vtotal + contrato.vltotal.
                ventra = ventra + contrato.vlentra.

                for each titulo where titulo.empcod   = 19    and
                                      titulo.titnat   = no    and
                                      titulo.modcod   = "CRE" and
                                      titulo.etbcod   = contrato.etbcod and
                                      titulo.clifor   = contrato.clicod and
                                      titulo.titnum   = string(contrato.contnum)
                                                no-lock:
                    find first wtit where wtit.wmes = month(titulo.titdtven) and
                                          wtit.wano = year(titulo.titdtven)  and
                                          wtit.wetb = estab.etbcod no-error.
                    if not avail wtit
                    then do:
                        create wtit.
                        assign wtit.wetb = estab.etbcod
                               wtit.wmes = month(titulo.titdtven)
                               wtit.wano = year(titulo.titdtven).
                    end.
                    if titulo.titsit = "lib"
                    then wtit.wsal = wtit.wsal + titulo.titvlcob.

                    wtit.wcar = wtit.wcar + titulo.titvlcob.
                    display wtit.wetb column-label "ETB"
                            wtit.wano column-label "ANO"
                            wtit.wmes column-label "MES"
                            wtit.wcar column-label "CARTEIRA"
                            wtit.wsal column-label "SALDO"
                                            with 1 down. pause 0.
                end.
            end.
        end.
    end.
    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""CRE04""
        &Nom-Sis   = """SISTEMA DE CREDIARIO"""
        &Tit-Rel   = """MOVIMENTO DA CARTEIRA FILIAL "" + string(vetbcod) +
                      ""   - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
        &Width     = "130"
        &Form      = "frame f-cabcab"}
    put "VALOR TOTAL CONTRATOS: " vtotal skip
        "VALOR TOTAL ENTRADAS : " ventra.
    for each wtit by wtit.wetb
                  by wtit.wano
                  by wtit.wmes:
        disp wtit.wano          column-label "ANO"
             wtit.wmes          column-label "MES"
             wtit.wcar(total)   column-label "CARTEIRA"
             wtit.wsal(total)   column-label "SALDO"
             ((wtit.wsal / wtit.wcar) * 100) column-label "Perc"
                                format "->>9.99 %"
                with frame f3 down width 200.
    end.
    output close.

end.
