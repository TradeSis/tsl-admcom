{admcab.i}
define variable w01 like contrato.vltotal.
define variable w02 like contrato.vltotal.
define variable w03 like contrato.vltotal.
define variable w001 like contrato.vltotal.
define variable w002 like contrato.vltotal.
define variable w003 like contrato.vltotal.
repeat:
 do with 1 column width 80 frame f1:
 prompt-for clien.clicod.
 find clien using clien.clicod.
 display clien.clinom.
 end.
 assign w001 = 0
	w002 = 0
	w003 = 0.
 for each contrato of clien:
  assign w01 = 0
	 w02 = 0
	 w03 = 0.
 for each titulo  where
    titulo.titnum = string(contrato.contnum) and
    titulo.empcod = wempre.empcod and
    titulo.titnat = no and
    titulo.modcod = "CRE"
    by titpar
    with width 80 down:
   if titulo.titpar = 0
   then display space(1) contnum label "Cont." dtinicial label "Dt.Inic.".
   display titulo.titpar label "Pc" titulo.titdtven label "Dt.Venc."
	   titulo.titvlcob format ">>>,>>>,>>9.99" label "Valor Parc."
	   titulo.titvlpag format ">>>,>>>,>>9.99" label "Valor Pago".
   w03 = 0.
   if titulo.titsit <> "PAG"
    then do:
    assign w02 = w02 + titulo.titvlcob
	   w03 = titulo.titvlcob.
    end.
    display w03 format ">>>,>>>,>>9.99" label "Saldo Deve.".
   w01 = w01 + titulo.titvlpag.
  end.
  assign w001 = w001 + vltotal
	 w002 = w002 + w01
	 w003 = w003 + w02.
  display space(11) "Total Parcial =" contrato.vltotal - contrato.vlentra
	  format ">>>,>>>,>>9.99" w01 w02
	  with width 80 1 down no-labels frame f3.
 end.
 display space(13)  "Total Geral =" w001 format ">>>,>>>,>>9.99"
	 w002 w003 with width 80 1 down no-labels frame f4.
 pause.
end.
