/*----------------------------------------------------------------------------*/
/* finan/previf.p                               Titulo Previsao - Consulta   */
/*----------------------------------------------------------------------------*/
{admcab.i }

    def var recatu1         as recid.
    def var recatu2         as recid.
    def var esqpos1         as int.
    def var esqpos2         as int.
    def var esqregua        as log.
    def var reccont         as int.
    def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
    def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def var vvlatu      like titulo.titvlcob.
def var vtitnat like titulo.titnat.
def var    wperdes as dec format ">9.99 %" label "Perc. Desc.".
def var    wperjur as dec format ">9.99 %" label "Perc. Juros".
def var    wdti like titulo.titdtven label "Periodo".
def var    wdtf like titulo.titdtven.
def var    vlrsl  like titulo.titvlcob
                                 label "Saldo Dia"   format "->>,>>>,>>9.99".
def var    totpg  like titulo.titvlcob
                                 label "A Pagar"     format ">>>,>>>,>>9.99".
def var    totrc  like titulo.titvlcob
                                 label "A Receber"   format ">>>,>>>,>>9.99".
def var    totger like titulo.titvlcob
                                 label "Saldo Geral" format "->>,>>>,>>9.99".

def var    totgerfin like titulo.titvlcob
                                 label "TOTAL GERAL" format "->>,>>>,>>9.99".
def var    totti as integer format ">>>9".
def var    totgerti as integer format ">>>9".
def var wdtesp as log.
def var wdtaux as date.
def var wdtesp2 as log.
def var wdtaux2 as date.
def var vsldger like titulo.titvlcob.
def var    totgerpg
        like titulo.titvlcob label "A Pagar"   format ">>>,>>>,>>9.99".
def var    totgerrc
        like titulo.titvlcob label "A Receber"   format ">>>,>>>,>>9.99".
def var vsldini like titulo.titvlcob.
def var vsldti    as integer format ">>>9" label "Tit".
def var vsldpg like titulo.titvlcob label "A Pagar"   format ">>>,>>>,>>9.99".
def var vsldrc like titulo.titvlcob label "A Receber" format ">>>,>>>,>>9.99".
def var vtitdd1 as int.
def var vtitdd2 as int.
def buffer wtitulo for titulo.
def temp-table wftit
    field titdtven like titulo.titdtven
    field titdd     as integer format ">>9" label "Tit"
    field titdd1    as integer format ">>9" label "Tit"
    field titdd2    as integer format ">>9" label "Tit"
    field titnat like titulo.titnat
    field vlrpg like titulo.titvlcob label "A Pagar"   format ">>,>>>,>>9.99"
    field vlrrc like titulo.titvlcob label "A Receber" format ">>,>>>,>>9.99"
    field totsl like titulo.titvlcob label "Saldo" format "->,>>>,>>9.99"
    field sldger like titulo.titvlcob
                                 label "Saldo Geral" format "->>,>>>,>>9.99"
    field sldti    as integer format ">>>9" label "Tit"
    field sldpg like titulo.titvlcob label "A Pagar"   format ">>>,>>>,>>9.99"
    field sldrc like titulo.titvlcob label "A Receber" format ">>>,>>>,>>9.99".



def var wchave as cha format " 999999  xxxxxxxx  999 "
                      label  "CLI/FOR  Num.Tit.  Par.".

form titulo.etbcod colon 17
        validate(true,"")
     estab.etbnom  no-label
     vtitnat
     wdti          colon 17
        help "Informe a Data Inicial para a Consulta"
     " A"
     wdtf          colon 35  no-label
        help "Informe a Data Final para a Consulta"
    vsldini  colon 60 format "-zz,zzz,zz9.99"
    /* totgerfin colon 60 format "-zz,zzz,zz9.99" */
                   with side-labels width 80 frame f1
                   row 4 color black/cyan.

form wftit.titdtven column-label "Dt.Vecto" format "99/99/99"
              with frame fdat  row  9 column 01 5 down color black/cyan .
/*form wftit.titdd
        with frame ftit  row  9 column 11 5 down color black/cyan .*/

form wftit.titdd2 wftit.vlrrc
    with frame frec  row  9 column 11 5 down color black/cyan .

form wftit.titdd1 wftit.vlrpg
        with frame fpag  row  9 column 30 5 down color black/cyan .
form vlrsl    with frame fsal  row  9 column 49 5 down color black/cyan .
form wftit.sldger
    with frame fger  row  9 column 65 5 down color black/cyan .
form          with frame ftdat row 19 column 01 down no-label color black/cyan .
form totti    with frame fttit row 19 column 11 down no-label color black/cyan .
form totpg    with frame ftpag row 19 column 33 down no-label color black/cyan .
form totrc    with frame ftrec row 19 column 17 down no-label color black/cyan .
form totsl    with frame ftsal row 19 column 49 down no-label color black/cyan .
form totger to 30
    with frame ftger row 19 column 49 down no-label color black/cyan .

wdti = today.
wdtf = wdti + 30.
repeat:
    clear frame f1    all.
    hide frame fdat  no-pause.
    /*hide frame ftit  no-pause.*/
    hide frame fpag  no-pause.
    hide frame frec  no-pause.
    hide frame frec  no-pause.
    hide frame fsal  no-pause.
    hide frame fger  no-pause.
    hide frame ftdat no-pause.
    hide frame fttit no-pause.
    hide frame ftpag no-pause.
    hide frame ftrec no-pause.
    hide frame ftsal no-pause.
    hide frame ftger no-pause.
    clear frame fdat  all.
    /*clear frame ftit  all.*/
    clear frame fpag  all.
    clear frame frec  all.
    clear frame frec  all.
    clear frame fsal  all.
    clear frame fger  all.
    clear frame ftdat all.
    clear frame fttit all.
    clear frame ftpag all.
    clear frame ftrec all.
    clear frame ftsal all.
    clear frame ftger all.
    display "" @ titulo.etbcod with frame f1.
    prompt-for titulo.etbcod with frame f1.
    if input titulo.etbcod <> ""
       then do:
               find estab where
                             estab.etbcod  = input titulo.etbcod
                             no-lock no-error.
               display etbnom with frame f1.
       end.
       else disp "TODOS" @ etbnom with frame f1.
    update vtitnat with frame f1.
    update wdti validate(input wdti <> ?,
                        "Data deve ser Informada")
                         with frame f1.

    update wdtf validate(input wdtf > input wdti,
                         "Data Invalida")
                         with frame f1.
    update vsldini label "Saldo Inicial"
            with frame f1.
    for each wftit.
        delete wftit.
    end.
    totgerfin = vsldini.
    for each titulo where titulo.empcod = wempre.empcod and
                          titulo.titnat = vtitnat and
                          titdtven >= wdti        and
                          titdtven <= wdtf        and
                          titsit   = "LIB"        and
                        ( if input titulo.etbcod = 0
                             then true
                             else titulo.etbcod = input titulo.etbcod )
                          no-lock break by titulo.titdtven:
        /*
        {titvlatu.i vvlatu}
        */
        totgerfin = totgerfin + if titnat = yes
                                then - vvlatu
                                else + vvlatu.
        totgerti  = totgerti  + 1.
        totgerpg  = totgerpg  + if titulo.titnat = yes
                                then vvlatu
                                else 0.
        totgerrc  = totgerrc  + if titulo.titnat = no
                                then vvlatu
                                else 0.
        find first wftit where wftit.titdtven = titulo.titdtven no-error.
        if not avail wftit
        then create wftit.
        assign
            wftit.titdtven = titulo.titdtven.
            if titulo.titnat = yes
            then wftit.titdd1   = wftit.titdd1 + 1.
            else wftit.titdd2   = wftit.titdd2 + 1.
        assign
            wftit.titdd    = wftit.titdd + 1
            wftit.vlrrc    = wftit.vlrrc + if titulo.titnat = no
                                           then vvlatu
                                           else 0
            wftit.vlrpg    = wftit.vlrpg + if titulo.titnat = yes
                                           then vvlatu
                                           else 0
            wftit.totsl    = wftit.totsl  + if titnat = yes
                                            then - vvlatu
                                            else + vvlatu.
    end.
    vsldger = vsldini.
    vsldti = 0.
    vsldpg = 0.
    vsldrc = 0.
    vtitdd1 = 0.
    vtitdd2 = 0.
    for each wftit break by wftit.titdtven.
        vtitdd1 = wftit.titdd1 + 1.
        vtitdd2 = wftit.titdd2 + 1.
        vsldger = vsldger + wftit.totsl.
        vsldti  = vsldti  + wftit.titdd.
        vsldpg  = vsldpg  + wftit.vlrpg.
        vsldrc  = vsldrc  + wftit.vlrrc.
        wftit.sldger = vsldger.
        wftit.sldti  = vsldti .
        wftit.sldpg  = vsldpg .
        wftit.sldrc  = vsldrc .
    end.
    display "SUBTOTAL"
            "TOTAL" at 01 with frame ftdat.
    disp totgerfin to 30 with frame ftger.
    if totgerfin < 0
    then color display red/cyan  totgerfin  with frame ftger.
    else color display blue/cyan totgerfin with frame ftger.

    disp skip totgerti  with frame fttit.
    color display blue/cyan totgerti with frame fttit.

    disp skip totgerpg with frame ftpag.
    color display blue/cyan totgerpg with frame ftpag.

    disp skip totgerrc with frame ftrec.
    color display blue/cyan totgerrc with frame ftrec.

    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    /*disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.*/
    if recatu1 = ?
    then
        find first wftit where
            true no-error.
    else
        find wftit where recid(wftit) = recatu1.
    if not available wftit
    then leave.
    clear frame fdat all no-pause.
    /*clear frame ftit all no-pause.*/
    clear frame fpag all no-pause.
    clear frame frec all no-pause.
    clear frame fsal all no-pause.
    clear frame fger all no-pause.
    vlrsl  = wftit.vlrrc - wftit.vlrpg.
    display wftit.titdtven with frame fdat.
    /*display wftit.titdd                    with frame ftit.*/
    display wftit.titdd1 wftit.vlrpg    when vlrpg <> 0 with frame fpag.
    display wftit.titdd2 wftit.vlrrc    when vlrrc <> 0 with frame frec.
    display vlrsl    when vlrsl <> 0 with frame fsal.
    if vlrsl < 0
    then color display red/cyan  vlrsl with frame fsal.
    else color display blue/cyan vlrsl with frame fsal.
        display wftit.sldger   when wftit.sldger <> 0 with frame fger.
        if wftit.sldger < 0
        then color display red/cyan  wftit.sldger with frame fger.
        else color display blue/cyan wftit.sldger with frame fger.
    totti  = wftit.sldti.
    display totti with frame fttit.
    totpg  = wftit.sldpg.
    display totpg  with frame ftpag.
    totrc = wftit.sldrc.
    display totrc with frame ftrec.
    totger = wftit.sldger.
    display totger with frame ftger.
    if totger < 0
    then color display red/cyan  totger with frame ftger.
    else color display blue/cyan totger with frame ftger.


    recatu1 = recid(wftit).
    /*
    color display message
        esqcom1[esqpos1]
            with frame f-com1.*/
    repeat:
        find next wftit where
                true.
        if not available wftit
        then leave.
        if frame-line(fdat) = frame-down(fdat)
        then leave.
        down with frame fdat.
        /*down with frame ftit.*/
        down with frame fpag.
        down with frame frec.
        down with frame fsal.
        down with frame fger.
        vlrsl  = wftit.vlrrc - wftit.vlrpg.
        display wftit.titdtven with frame fdat.
        /*display wftit.titdd                    with frame ftit.*/
        display wftit.titdd1 wftit.vlrpg    when vlrpg <> 0 with frame fpag.
        display wftit.titdd2 wftit.vlrrc    when vlrrc <> 0 with frame frec.
        display vlrsl    when vlrsl <> 0 with frame fsal.
        if vlrsl < 0
        then color display red/cyan  vlrsl with frame fsal.
        else color display blue/cyan vlrsl with frame fsal.
        display wftit.sldger   when wftit.sldger <> 0 with frame fger.
        if wftit.sldger < 0
        then color display red/cyan  wftit.sldger with frame fger.
        else color display blue/cyan wftit.sldger with frame fger.
    end.
    up frame-line(fdat) - 1 with frame fdat.
    /*up frame-line(ftit) - 1 with frame ftit.*/
    up frame-line(fpag) - 1 with frame fpag.
    up frame-line(frec) - 1 with frame frec.
    up frame-line(fsal) - 1 with frame fsal.
    up frame-line(fger) - 1 with frame fger.

    repeat with frame fdat:

        find wftit where recid(wftit) = recatu1.

        choose field wftit.titdtven color white/black
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next wftit where
                true no-error.
            if not avail wftit
            then next.
            color display black/cyan
                wftit.titdtven.
            if frame-line(fdat) = frame-down(fdat)
            then do:
                scroll with frame fdat.
                /*scroll with frame ftit.*/
                scroll with frame fpag.
                scroll with frame frec.
                scroll with frame fsal.
                scroll with frame fger.
            end.
            else do:
                down with frame fdat.
                /*down with frame ftit.*/
                down with frame fpag.
                down with frame frec.
                down with frame fsal.
                down with frame fger.
            end.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev wftit where
                true no-error.
            if not avail wftit
            then next.
            color display black/cyan
                wftit.titdtven.
            if frame-line(fdat) = 1
            then do:
                scroll down with frame fdat.
                /*scroll down with frame ftit.*/
                scroll down with frame fpag.
                scroll down with frame frec.
                scroll down with frame fsal.
                scroll down with frame fger.
            end.
            else do:
                up with frame fdat.
                /*up with frame ftit.*/
                up with frame fpag.
                up with frame frec.
                up with frame fsal.
                up with frame fger.
            end.
        end.
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(fdat):
                find next wftit
                    no-error.
                if not avail wftit
                then leave.
                recatu1 = recid(wftit).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(fdat):
                find prev wftit no-error.
                if not avail wftit
                then leave.
                recatu1 = recid(wftit).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame  fdat no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.


          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end.
          view frame fdat.
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame fdat.
        vlrsl  = wftit.vlrrc - wftit.vlrpg.
        display wftit.titdtven with frame fdat.
        /*display wftit.titdd                    with frame ftit.*/
        display wftit.titdd1 wftit.vlrpg    when vlrpg <> 0 with frame fpag.
        display wftit.titdd2 wftit.vlrrc    when vlrrc <> 0 with frame frec.
        display vlrsl    when vlrsl <> 0 with frame fsal.
        if vlrsl < 0
        then color display red/cyan  vlrsl with frame fsal.
        else color display blue/cyan vlrsl with frame fsal.
        display wftit.sldger   when wftit.sldger <> 0 with frame fger.
        if wftit.sldger < 0
        then color display red/cyan  wftit.sldger with frame fger.
        else color display blue/cyan wftit.sldger with frame fger.
    totti  = wftit.sldti.
    display totti with frame fttit.
    totpg  = wftit.sldpg.
    display totpg  with frame ftpag.
    totrc = wftit.sldrc.
    display totrc with frame ftrec.
        totger = wftit.sldger.
        display totger with frame ftger.
        if totger < 0
        then color display red/cyan  totger with frame ftger.
        else color display blue/cyan totger with frame ftger.
        /*if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        */
        recatu1 = recid(wftit).
   end.
end.
end.
