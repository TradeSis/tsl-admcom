/*----------------------------------------------------------------------------*/
/* previli.p                                     Titulo Previsao - Listagem   */
/*                                                                            */
/*----------------------------------------------------------------------------*/
{admcab.i}
DEF VAR TOTMES AS DEC FORMAT ">>>,>>>,>>9.99" EXTENT 99.
DEF VAR TOTdia AS DEC FORMAT ">>>,>>>,>>9.99".
def var vmes as i.
def var vdata like titulo.titdtven.
def var    wdti like titulo.titdtven label "Periodo".
def var    wdtf like titulo.titdtven.
def var    vtot like titulo.titvlcob
                                label "A Pagar"   format ">>>,>>>,>>>,>>9.99".

def temp-table wtit
    field wmes  as int
    field wdia  as int
    field wdata as date
    field wtot  as dec format ">>>,>>>,>>9.99".
form wdti          colon 18  " A"
     wdtf          colon 35  no-label with side-labels width 80 frame f1.
wdti = today.
wdtf = wdti + 30.
repeat with frame f1:
    totmes = 0.
    totdia = 0.
    vtot = 0.
    clear frame f1 all.
    for each wtit.
        delete wtit.
    end.
    update wdti validate(input wdti <> ?,
                        "Data deve ser Informada")
                         with frame f1.
    update wdtf with frame f1.
    vtot  = 0.
    vmes  = month(wdtf) + 3.
    vdata = date(vmes,1,year(wdtf)) - 1.
    for each titulo where empcod = 19 and
                          titnat = yes and
                          titdtven >= input wdti        and
                          titdtven <= vdata             and
                          titsit   = "LIB" break by month(titulo.titdtven)
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
                        with frame f-tit down width 40.
        if wdti <= wtit.wdata and
           wdtf >= wtit.wdata
        then TOTDIA = TOTdia + wtit.wtot.

    end.


    for each wtit where wtit.wmes > month(input wdti) break by wtit.wdia
                                                            by wtit.wmes:

        TOTMES[WTIT.WMES] = TOTMES[WTIT.WMES] + WTIT.WTOT.

        display SPACE(7) wtit.wdata column-label "VENCIMENTO"
                space(2) wtit.wtot  column-label "A PAGAR"
                    with frame f-tit2 width 40 down column 40 overlay.
    end.
    display skip
        "TOTAL............" totmes[month(wdti) + 1] space(17)
                            totmes[month(wdti) + 2]
                                with frame f-tot with row 20 no-box overlay.
end.
