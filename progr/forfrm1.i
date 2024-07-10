FORM banfin.titulo.clifor    colon 15 label "Fornec."
    banfin.titulo.titnum     colon 15
    banfin.titulo.titpar     colon 15
    banfin.titulo.titdtemi   colon 15
    banfin.titulo.titdtven   colon 15
    banfin.titulo.titvlcob   colon 15
    banfin.titulo.cobcod     colon 15
    with frame ftitulo
        overlay row 7 color
        white/cyan side-label width 39.

FORM vtitnum     colon 15
     vtitpar     colon 15
     vtitdtemi   colon 15
     vtitdtven   colon 15
     vtitvlcob   colon 15
     vcobcod     colon 15
     fin.cobra.cobnom no-label format "x(15)"
     banfin.titulo.modcod colon 15
     fin.modal.modnom no-label format "x(15)"
     banfin.titulo.evecod colon 15
     fin.event.evenom no-label format "x(15)"
     with frame ftit overlay row 7 color white/cyan side-label width 39.

FORM vtitnum     colon 15
     vtitpar     colon 15
     vtitdtemi   colon 15
     vtotal      colon 15
     vcobcod     colon 15
     fin.cobra.cobnom no-label format "x(15)"
     vevecod colon 15
     fin.event.evenom no-label format "x(15)"
     with frame ftit2 overlay row 7 color white/cyan side-label width 39.

form banfin.titulo.titbanpag colon 15
    banco.bandesc no-label
    banfin.titulo.titagepag colon 15
    agenc.agedesc no-label
    banfin.titulo.titchepag colon 15
    with frame fbancpg centered
         side-labels 1 down overlay
         color white/cyan row 16
         title " Banco Pago " width 80.

form banfin.titulo.bancod   colon 15
    banco.bandesc           no-label
    banfin.titulo.agecod   colon 15
    agenc.agedesc         no-label
    with frame fbanco centered
         side-labels 1 down
         color white/cyan row 16 .

form vbancod   colon 15
    banco.bandesc           no-label
    vagecod   colon 15
    agenc.agedesc         no-label
    with frame fbanco2 centered
         side-labels 1 down
         color white/cyan row 16 .
form wperjur         colon 16
    banfin.titulo.titvljur colon 16 skip(1)
    banfin.titulo.titdtdes colon 16
    wperdes         colon 16
    banfin.titulo.titvldes colon 16
    with frame fjurdes
         overlay row 7 column 41 side-label
         color white/cyan  width 40.

form wperjur         colon 16
    vtitvljur colon 16 skip(1)
    vtitdtdes colon 16
    wperdes         colon 16
    vtitvldes colon 16 with frame fjurdes2
         overlay row 7 column 41 side-label
         color white/cyan  width 40.

form
    vtitobs[1] at 1
    vtitobs[2] at 1
    with no-labels width 80 row 16
         title " Observacoes " frame fobs2
         color white/cyan .

form
    banfin.titulo.titobs[1] at 1
    banfin.titulo.titobs[2] at 1
    with no-labels width 80 row 16
         title " Observacoes " frame fobs
         color white/cyan .

form
    banfin.titulo.titdtpag colon 15 label "Dt.Pagam"
    banfin.titulo.titvlpag  colon 15
    banfin.titulo.cobcod    colon 15
    banfin.titulo.titvljur  colon 15 column-label "Juros"
    banfin.titulo.titvldes  colon 15 column-label "Desconto"
    with frame fpag1 side-label
         row 10 color white/cyan
         overlay column 42 width 39 title " Pagamento " .
