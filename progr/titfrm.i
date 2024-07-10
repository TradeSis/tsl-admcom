FORM titulo.titnum     colon 15
    titulo.titpar     colon 15
    titulo.titdtemi   colon 15
    titulo.titdtven   colon 15
    titulo.titvlcob   colon 15
    titulo.cobcod     colon 15
    with frame ftitulo
	overlay row 7 color
	white/cyan side-label width 39.
form titulo.titbanpag colon 15
    banco.bandesc no-label
    titulo.titagepag colon 15
    agenc.agedesc no-label
    titulo.titchepag colon 15
    with frame fbancpg centered
	 side-labels 1 down overlay
	 color white/cyan row 16
	 title " Banco Pago " width 80.
form titulo.bancod   colon 15
    banco.bandesc           no-label
    titulo.agecod   colon 15
    agenc.agedesc         no-label
    with frame fbanco centered
	 side-labels 1 down
	 color white/cyan row 16 .
form wperjur         colon 16
    titulo.titvljur colon 16 skip(1)
    titulo.titdtdes colon 16
    wperdes         colon 16
    titulo.titvldes colon 16
    with frame fjurdes
	 overlay row 7 column 41 side-label
	 color white/cyan  width 40.
form
    titulo.titobs[1] at 1
    titulo.titobs[2] at 1
    with no-labels width 80 row 16
	 title " Observacoes " frame fobs
	 color white/cyan .

form
    titulo.titdtpag colon 15 label "Dt.Pagam"
    titulo.titvlpag  colon 15
    titulo.cobcod    colon 15
    titulo.titvljur  colon 15
    titulo.titvldes  colon 15 column-label "Desconto"
    with frame fpag1 side-label
	 row 10 color white/cyan
	 overlay column 42 width 39 title " Pagamento " .
