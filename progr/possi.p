{admcab.i}
define variable w01 like contrato.vltotal.
define variable w02 like contrato.vltotal.
define variable w03 like contrato.vltotal.
define variable w001 like contrato.vltotal.
define variable w002 like contrato.vltotal.
define variable w003 like contrato.vltotal.
define variable w004 like contrato.vltotal.
define variable rsp as logical format "Sim/Nao" initial yes.
repeat:
 do with 1 column width 80 frame f1:
 prompt-for clien.clicod.
 find clien using clien.clicod.
 display clien.clinom.
 end.
 assign w001 = 0
	w002 = 0
	w003 = 0
	w004 = 0.
 for each contrato of clien
     with width 80 7 down frame f2 no-box:
  display space(1) contnum dtinicial label "Dt.Inic."
	  vltotal format ">>>,>>>,>>9.99".
  assign w01 = 0
	 w02 = 0
	 w03 = 0.
 for each titulo  where
    titulo.empcod = wempre.empcod and
    titulo.titnat = no and
    titulo.modcod = "CRE" and
    titulo.titnum = string(contrato.contnum) :
   if titulo.titsit = "PAG"
    then assign w01 = w01 + titulo.titvlpag.
    else if titulo.titdtven >= today
	  then assign w02 = w02 + titulo.titvlcob.
	  else assign w03 = w03 + titulo.titvlcob.
  end.
  display w01 format ">>>,>>>,>>9.99" label "Pagamentos"
	  w02 + w03 format ">>>,>>>,>>9.99" label "Saldo Devedor"
	  w03 format ">>>,>>>,>>9.99" label "Atrasados".
  if w03 > 0
   then color display messages w03.
  assign w001 = w001 + vltotal
	 w002 = w002 + w01
	 w003 = w003 + w02 + w03
	 w004 = w004 + w03.
 end.
 do with 1 down width 80 frame f4 no-labels:
  display "Totais =" space(10) w001 w002 w003 w004.
 end.
end.
