{admcab.i}
def var vdtini  as date.
def var vdtfin  as date.

def var vtotetb     like titulo.titvlpag.
def var wtotal      like titulo.titvlpag.

def temp-table wft
    field etbcod    like titulo.etbcod
    field dtpag     like titulo.titdtpag
    field vtotal    like titulo.titvlcob column-label "Total"
                                          FORMAT "->>>,>>>,>>>,>>>,>>9.99".

REPEAT:
    form with frame ftot.
    prompt-for estab.etbcod colon 20
               with frame f1 .
    find estab using estab.etbcod no-error.
    if not avail estab
    then do:
        if estab.etbcod entered
        then do:
            message "Estabelecimento Invalido".
            undo.
        end.
    end.
    display estab.etbnom no-label when avail estab
            with frame f1.
    update vdtini   colon 20 label "Data Inicial"
           vdtfin   colon 20 label "Data Final"
           with frame f1
                row 4 width 80 side-label.
    for each wft.
        delete wft.
    end.

    message "Processando...".

    if estab.etbcod not entered
    THEN
        for each titulo USE-INDEX TITDTPAG
                where titulo.empcod = wempre.empcod and
                              titulo.titnat = no            and
                              titulo.modcod = "CRE"         and
                              titulo.titdtpag >= vdtini     and
                              titulo.titdtpag <= vdtfin     and
                              titulo.titvlpag < 0
                              no-lock:
            display etbcod
                    clifor
                    titnum
                    titpar
                    titvlpag format "->>>,>>>,>>>,>>9.99".
        end.
    ELSE
        for each titulo USE-INDEX TITDTPAG
                where titulo.empcod = wempre.empcod and
                              titulo.titnat = no            and
                              titulo.modcod = "CRE"         and
                              titulo.titdtpag >= vdtini     and
                              titulo.titdtpag <= vdtfin     and
                                titulo.etbcod = estab.etbcod and
                                titulo.titvlpag < 0
                              no-lock:
            display etbcod
                    clifor
                    titnum
                    titpar
                    titvlpag format "->>>,>>>,>>>,>>9.99".
        end.
end.
