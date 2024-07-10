FORM labotit.titnum     colon 15
    labotit.titpar     colon 15
    labotit.titdtemi   colon 15
    labotit.titdtven   colon 15
    labotit.titvlcob   colon 15
    with frame ftitulo
	overlay row 7 color
	white/cyan side-label width 39.
form labotit.titbanpag colon 15
    banco.bandesc no-label
    labotit.titagepag colon 15
    agenc.agedesc no-label
    labotit.titchepag colon 15
    with frame fbancpg centered
	 side-labels 1 down overlay
	 color white/cyan row 16
	 title " Banco Pago " width 80.
form wperjur         colon 16
    labotit.titvljur colon 16 skip(1)
    labotit.titdtdes colon 16
    wperdes         colon 16
    labotit.titvldes colon 16
    with frame fjurdes
	 overlay row 7 column 41 side-label
	 color white/cyan  width 40.
form
    labotit.titobs[1] at 1
    labotit.titobs[2] at 1
    with no-labels width 80 row 16
	 title " Observacoes " frame fobs
	 color white/cyan .

form
    labotit.titdtpag colon 13 label "Dt.Pagam"
    labotit.titvlpag  colon 13
    with frame fpag1 side-label
	 row 10 color white/cyan
	 overlay column 42 width 39 title " Pagamento " .
