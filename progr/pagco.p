/*----------------------------------------------------------------------------*/
/* /usr/admfin/pagex.p                               Titulo  - Cancelamento   */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 08/10/92 Oscar   Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var wetbcod     like titulo.etbcod.
def var wmodcod     like titulo.modcod.
def var wtitnat     like titulo.titnat.
def var wclifor     like titulo.clifor.
def var wtitnum     like titulo.titnum.
def var wtitpar     like titulo.titpar.
def var vtitvlpag   like titulo.titvlpag.
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:
    update wetbcod label "Estabelec." colon 12.
    find estab where estab.etbcod = wetbcod no-lock.
    display etbnom no-label format "x(10)".
    wmodcod = "CRE".
    wtitnat = no.
    display wmodcod " - " wtitnat.
    assign wclifor = 0
           wclifor = 0
           wtitnum = "".
    repeat:
        clear frame f8 all.
        clear frame f2 all.
        clear frame f3 all.
        clear frame f4 all.
        if wtitnat
            then do with column 1 side-labels 1 down width 48 row 4 frame f2:
            wclifor = 0.
            update wclifor colon 12.
            find forne where forne.forcod = wclifor NO-LOCK.
            display fornom format "x(32)" no-label at 14.
            end.
            else do with column 1 side-labels 1 down width 48 row 4 frame f3:
            wclifor = 0.
            update wclifor colon 12.
            find clien where clien.clicod = wclifor NO-LOCK.
            display clinom format "x(32)" no-label at 14.
            end.
        update wtitnum colon 15
               wtitpar colon 57
               with side-labels 1 down width 80 frame f4.
        find titulo where titulo.empcod = wempre.empcod and
                          titulo.etbcod = estab.etbcod and
                          titulo.modcod = wmodcod and
                          titulo.titnat = no and
                          titulo.clifor = wclifor and
                          titulo.titnum = wtitnum and
                          titulo.titpar = wtitpar NO-LOCK no-error.
        if not available titulo
            then do:
            message "Titulo nao cadastrado.".
            undo.
            end.
        form titdtemi format "99/99/99" label "Emiss./Vencim." colon 15
             "-"
             titdtven format "99/99/99" no-label
             titvlcob colon 15
             titvljur colon 15
             titdtdes colon 15
             titvldes colon 15
             with side-labels 1 down width 40 title " Cobranca " frame f5.
        find cobra of titulo NO-LOCK.
        display titdtemi
                titdtven
                titvlcob
                titvljur
                titdtdes
                titvldes with frame f5.
        display titobs with no-labels width 80 title " Observacoes " frame f7.
        form titdtpag  colon 15
             titvlpag colon 15 label "Valor Pago"
             titdesc   colon 15
             titjuro   colon 15
             ETBCOBRA
             with side-labels 1 down width 40 column 41
                  title " Pagamento " frame f8.
        display titdtpag
                titvlpag
                titdesc
                titjuro
                ETBCOBRA
                with frame f8.
    end.
end.
