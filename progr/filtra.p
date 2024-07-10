{admcab.i}
def var t-tra as dec.
def var t-rec as dec.
def var varquivo as char format "x(20)".
def var tottra as dec format "->>>,>>9.99".
def var totrec as dec format "->>>,>>9.99".
def var vetbcod like estab.etbcod.
def var vdti as date format "99/99/9999" initial today.
def var vdtf as date format "99/99/9999" initial today.
def var vdata as date format "99/99/9999".
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.

repeat:
    update vetbi label "Filial"
           vetbf label "Filial" with frame f1 side-label width 80.
    update vdti label "Data Inicial"
           vdtf label "Data Final"
                    with frame f1 side-label.

    varquivo = "i:\admcom\relat\tottra" + string(day(today)).

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""TOTTRA""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE  """
        &Tit-Rel   = """MOVIMENTACOES GERAL POR FILIAL - PERIODO DE "" +
                              string(vdti,""99/99/9999"") + "" A "" +
                              string(vdtf,""99/99/9999"") "
        &Width     = "130"
        &Form      = "frame f-cabcab"}
    t-tra = 0.
    t-rec = 0.
    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:
        tottra = 0.
        totrec = 0.
        do vdata = vdti to vdtf:
            for each plani where plani.etbcod = estab.etbcod and
                                 plani.movtdc = 6       and
                                 plani.pladat = vdata no-lock:

                tottra = tottra + plani.platot.
                t-tra  = t-tra + plani.platot.
            end.
            for each plani where plani.desti = estab.etbcod and
                                 plani.movtdc = 6       and
                                 plani.pladat = vdata no-lock:

                totrec = totrec + plani.platot.
                t-rec = t-rec + plani.platot.
            end.
        end.
        display estab.etbnom
                tottra column-label "Total Transferido"
                totrec column-label "Total Recebido"
                    with frame f2 down width 200.
        down with frame f2.
    end.
    put skip(2)
        t-tra to 43
        t-rec to 56.
    output close.
    message "Listar Relatorio" update sresp.
    if sresp
    then dos silent value("type " + varquivo + " > prn").
end.
