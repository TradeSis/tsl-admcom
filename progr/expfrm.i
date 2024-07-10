FORM titexporta.titnum     colon 15
    titexporta.titpar     colon 15
    titexporta.titdtemi   colon 15
    titexporta.titdtven   colon 15
    titexporta.titvlcob   colon 15
    titexporta.cobcod     colon 15
    with frame ftitexporta
	overlay row 7 color
	white/cyan side-label width 39.
form titexporta.titbanpag colon 15
    banco.bandesc no-label
    titexporta.titagepag colon 15
    agenc.agedesc no-label
    titexporta.titchepag colon 15
    with frame fbancpg centered
	 side-labels 1 down overlay
	 color white/cyan row 16
	 title " Banco Pago " width 80.
form titexporta.bancod   colon 15
    banco.bandesc           no-label
    titexporta.agecod   colon 15
    agenc.agedesc         no-label
    with frame fbanco centered
	 side-labels 1 down
	 color white/cyan row 16 .
form wperjur         colon 16
    titexporta.titvljur colon 16 skip(1)
    titexporta.titdtdes colon 16
    wperdes         colon 16
    titexporta.titvldes colon 16
    with frame fjurdes
	 overlay row 7 column 41 side-label
	 color white/cyan  width 40.
form
    titexporta.titobs[1] at 1
    titexporta.titobs[2] at 1
    with no-labels width 80 row 16
	 title " Observacoes " frame fobs
	 color white/cyan .

form
    titexporta.titdtpag colon 15 label "Dt.Pagam"
    titexporta.titvlpag  colon 15
    titexporta.cobcod    colon 15
    titexporta.titvljur  colon 15
    titexporta.titvldes  colon 15 column-label "Desconto"
    with frame fpag1 side-label
	 row 10 color white/cyan
	 overlay column 42 width 39 title " Pagamento " .
