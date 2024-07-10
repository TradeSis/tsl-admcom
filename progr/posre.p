{admcab.i}
define variable wdtrefer like diario.dtrefer.
repeat:
 assign wdtrefer = today - 1.
 update wdtrefer with 1 column width 80 frame f1.
 find diario where dtrefer = wdtrefer no-error.
 if not available diario
  then do:
  message "Dia ainda nao processado, consulta impossivel.".
  undo,retry.
  end.
 display vlvenda format ">>>,>>>,>>9.99"
	 vlentra format ">>>,>>>,>>9.99"
	 vlvenda - vlentra format ">>>,>>>,>>9.99" label "Valor Liquido"
	 vlvenc format ">>>,>>>,>>9.99"
	 with 1 column width 80 frame f2 title " Resultados ".
 display vlpago[1] format ">>>,>>>,>>9.99" label "Valor Pagamento"
	 vljuros[1] format ">>>,>>>,>>9.99" label "Valos Juros"
	 vldesc[1] format ">>>,>>>,>>9.99" label "Valor Descontos"
	 vldevol format ">>>,>>>,>>9.99" label "Valor Devolucoes"
	 with 1 column width 39 frame f3 title " Valores Loja ".
 display vlpago[2] format ">>>,>>>,>>9.99" label "Valor Pagamento"
	 vljuros[2] format ">>>,>>>,>>9.99" label "Valos Juros"
	 vldesc[2] format ">>>,>>>,>>9.99" label "Valor Descontos" skip(1)
	 with column 41 1 column width 40 frame f4 title " Valores Banco ".
end.
