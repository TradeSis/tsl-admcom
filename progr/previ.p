/*----------------------------------------------------------------------------*/
/* /usr/admctp/previ.p                           Titulo Previsao - Consulta   */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 03/12/92 Oscar   Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i }
def var    wperdes as dec format ">9.99 %" label "Perc. Desc.".
def var    wperjur as dec format ">9.99 %" label "Perc. Juros".
def var    wdti like titulo.titdtven label "Periodo".
def var    wdtf like titulo.titdtven.
def var vlrpg like titulo.titvlcob label "A Pagar" format ">>>,>>>,>>>,>>9.99".
def var vlrrc like titulo.titvlcob
                                  label "A Receber" format ">>>,>>>,>>>,>>9.99".
def var vlrsl like titulo.titvlcob label "Saldo" format "->>,>>>,>>>,>>9.99".
def var totpg like titulo.titvlcob label "A Pagar" format ">>>,>>>,>>>,>>9.99".
def var totrc like titulo.titvlcob
                                label "A Receber" format ">>>,>>>,>>>,>>9.99".
def var totsl like titulo.titvlcob label "Saldo" format "->>,>>>,>>>,>>9.99".
def var    totti as integer format ">>>>>9".
def var    titdd as integer format ">>>>>9" label "Nr.Tit".
def buffer wtitulo for titulo.
def var wchave as cha format " 999999  xxxxxxxx  999 "
                      label  "CLI/FOR  Num.Tit.  Par.".

form titulo.etbcod colon 18
     estab.etbnom  no-label colon 30
     wdti          colon 18  " A"
     wdtf          colon 35  no-label
                   with side-labels width 80 frame f1.

form titulo.titdtven     with frame fdat  row  8 column 01 7 down.
form titdd        with frame ftit  row  8 column 13 7 down.
form vlrpg        with frame fpag  row  8 column 21 7 down.
form vlrrc        with frame frec  row  8 column 41 7 down.
form vlrsl        with frame fsal  row  8 column 61 7 down.
form "T O T A L " with frame ftdat row 19 column 01 down no-label.

form totti        with frame fttit row 19 column 13 down no-label.
form totpg        with frame ftpag row 19 column 21 down no-label.
form totrc        with frame ftrec row 19 column 41 down no-label.
form totsl        with frame ftsal row 19 column 61 down no-label.

wdti = today.
wdtf = wdti + 30.
repeat:
    clear frame f1    all.
    clear frame fdat  all.
    clear frame ftit  all.
    clear frame fpag  all.
    clear frame frec  all.
    clear frame frec  all.
    clear frame fsal  all.
    clear frame ftdat all.
    clear frame fttit all.
    clear frame ftpag all.
    clear frame ftrec all.
    clear frame ftsal all.
    display "" @ titulo.etbcod with frame f1.
    prompt-for titulo.etbcod with frame f1.
    if input titulo.etbcod <> ""
       then do:
               find estab where estab.etbcod = input titulo.etbcod no-error.
               display etbnom with frame f1.
       end.
       else disp "TODOS" @ etbnom with frame f1.
    update wdti validate(input wdti <> ?,
                        "Data deve ser Informada")
                         with frame f1.

    update wdtf validate(input wdtf > input wdti,
                         "Data Invalida")
                         with frame f1.

    for each titulo where titulo.empcod = wempre.empcod and
                          titdtven >= input wdti        and
                          titdtven <= input wdtf        and
                          titsit   = "LIB" and
                        ( if not avail estab
                             then true
                             else titulo.etbcod = input titulo.etbcod )
                          break by titdtven:

        titdd = titdd + 1.

        if titnat
           then do:
                   vlrpg = vlrpg + titvlcob.
           end.
           else do:
                   vlrrc = vlrrc + titvlcob.
           end.

        if last-of(titdtven)
           then do:
                   vlrsl = vlrrc - vlrpg.
                   pause 0.
                   display titdtven                 with frame fdat.
                   display titdd                    with frame ftit.
                   display vlrpg    when vlrpg <> 0 with frame fpag.
                   display vlrrc    when vlrrc <> 0 with frame frec.
                   display vlrsl    when vlrsl <> 0 with frame fsal.
                   totpg = totpg + vlrpg.
                   totrc = totrc + vlrrc.
                   totsl = totrc - totpg.
                   totti = totti + titdd.
                   pause 0.
                   view frame ftdat.
                   display totti with frame fttit.
                   display totpg with frame ftpag.
                   display totrc with frame ftrec.
                   display totsl with frame ftsal.
                   if frame-line (fdat) = frame-down (fdat)
                      then pause.
                   vlrpg = 0.
                   vlrrc = 0.
                   titdd = 0.
                   down with frame fdat.
                   down with frame ftit.
                   down with frame fpag.
                   down with frame frec.
                   down with frame fsal.
           end.
    end.
    totpg = 0.
    totrc = 0.
    totsl = 0.
    totti = 0.
    pause.
end.
