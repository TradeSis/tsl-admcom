/*----------------------------------------------------------------------------*/
/* previli.p                                     Titulo Previsao - Listagem   */
/*                                                                            */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var vetbcod like estab.etbcod.
def var vforcod like titulo.clifor.
def var vmodcod like titulo.modcod.
DEF VAR TOTMES AS DEC FORMAT ">>>,>>>,>>9.99" EXTENT 99.
DEF VAR TOTdia AS DEC FORMAT ">>>,>>>,>>9.99".
def var vmes as i.
def var vdata like titulo.titdtven.
def var    wdti like titulo.titdtven label "Periodo".
def var    wdtf like titulo.titdtven.
def var varquivo as char format "x(20)".
def var    vtot like titulo.titvlcob
                                label "A Pagar"   format ">>>,>>>,>>>,>>9.99".

def temp-table wtit
    field wmes  as int
    field wdia  as int
    field wdata as date
    field wtot  as dec format ">>>,>>>,>>9.99".

wdti = today.
wdtf = wdti + 30.
repeat with frame f1:
    clear frame f1 all.
    for each wtit.
        delete wtit.
    end.
    update vmodcod with side-labels width 80 frame f1.

    update wdti validate(input wdti <> ?,
                        "Data deve ser Informada")
                         with frame f1.

    update wdtf validate(input wdtf > input wdti,
                         "Data Invalida")
                         with frame f1.

    {confir.i 1 "Listagem Previsao"}
    varquivo = "..\relat\res" + string(time).
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = ""PREVILI""
        &Nom-Sis   = """SISTEMA FINANCEIRO"""
        &Tit-Rel   = """PREVISAO FINANCEIRA  -  PERIODO : "" +
                            string(wdti,""99/99/9999"") + "" A "" +
                            string(wdtf,""99/99/9999"") "
        &Width     = "160"
        &Form      = "frame f-cabcab"}
    vtot  = 0.
    vmes  = month(wdtf) + 3.
    vdata = date(vmes,1,year(wdtf)) - 1.
    for each titulo where empcod = 19 and
                          titnat = yes and
                          titdtven >= input wdti        and
                          titdtven <= vdata             and
                          titsit   = "LIB"              and
                          titulo.modcod = vmodcod
                                     break by month(titulo.titdtven)
                                                 by titulo.titdtven:

        find first wtit where wtit.wmes = month(titulo.titdtven) and
                              wtit.wdia = day(titulo.titdtven) no-error.
        if not avail wtit
        then do:
            create wtit.
            assign wtit.wmes = month(titulo.titdtven)
                   wtit.wdia = day(titulo.titdtven).
                   wtit.wdata = titulo.titdtven.
        end.
        wtit.wtot = wtit.wtot + titulo.titvlcob.
    end.

    totdia = 0.
    for each wtit WHERE WTIT.wmes = MONTH(input wdti) by wtit.wdia:

        display wtit.wdata column-label "VENCIMENTO"
                wtit.wtot(total) column-label "A PAGAR"
                        with frame f-tit down width 140.
        if wdti <= wtit.wdata and
           wdtf >= wtit.wdata
        then TOTDIA = TOTdia + wtit.wtot.

    end.

    put skip " VENCIMENTO        A PAGAR              NCIMENTO   A PAGAR"
             " DUPLICATA " AT 85
    SKIP FILL ("-",137) FORMAT "X(137)" SKIP.



    for each wtit where wtit.wmes > month(input wdti) break by wtit.wdia
                                                            by wtit.wmes:

        TOTMES[WTIT.WMES] = TOTMES[WTIT.WMES] + WTIT.WTOT.

        put SPACE(7) wtit.wdata
            space(2) wtit.wtot.

        if last-of(wtit.wdia)
        then do:
            if wtit.wdia = 1
            then put "|______________________|" at 83 " " totdia skip.
            else
            put "|______________________|_______________________|" at 83
                skip.
        end.
    end.
    put skip
        "TOTAL............" totmes[month(wdti) + 1] space(17)
                            totmes[month(wdti) + 2].

    output close.
    {mrod.i}
end.
