def var varq as char format "x(20)".
varq = "..\relat\ana" + string(time) + ".rel".

output to value(varq) page-size 65.
define shared buffer wempre for empre.
define variable w01 like contrato.vltotal.
define variable w02 like contrato.vltotal.
define variable w03 like contrato.vltotal.
define variable w04 like contrato.vltotal.
define variable w001 like contrato.vltotal.
define variable w002 like contrato.vltotal.
define variable w003 like contrato.vltotal.
form header
 wempre.emprazsoc "C R E D I A R I O" at 40 today at 71
 skip "Crediario - Posicao Analitica" "Pag." at 71 page-number format ">>9"
 skip fill("-",78) format "x(78)" skip
 with frame fcab page-top no-box.
form header
 skip "Cliente" skip " Cont." "Dt.Inic." space(1) "Pc" "Dt.Venc."
 space(4) "Valor Parc." space(5) "Valor Pago" space(4) "Saldo Deve."
 "Local"
 with frame fdet page-top no-box.
view frame fcab.
view frame fdet.
for each clien where situacao = yes:
 form header
  skip clien.clinom " - " clien.clicod
  with frame fcli page-top no-box.
 view frame fcli.
 assign w001 = 0
	w002 = 0
	w003 = 0.
 for each contrato of clien where situacao > 0 and situacao < 9:
  assign w01 = 0
	 w02 = 0
	 w03 = 0.
 for each titulo  where
    titulo.empcod = wempre.empcod and
    titulo.titnat = no and
    titulo.modcod = "CRE" and
    titulo.titnum = string(contrato.contnum):
   if (w001 = 0 and w01 = 0) and line-counter <> 1 and line-counter < page-size
    then put clinom " - " clicod skip.
   if titpar = 1
    then put space contnum format "99999" space dtinicial.
    else put space(15).
   put space titpar space titulo.titdtven space titvlcob format ">>>,>>>,>>9.99"
       space titvlpag format ">>>,>>>,>>9.99".
   assign w04 = 0.
   if titulo.titvlpag = 0
    then do:
    assign w03 = w03 + titvlcob.
	   w04 = titvlcob.
    end.
   put space w04 format ">>>,>>>,>>9.99" space  skip.
   assign w01 = w01 + titvlcob
	  w02 = w02 + titvlpag.
  end.
  assign w001 = w001 + w01
	 w002 = w002 + w02
	 w003 = w003 + w03.
  put space(11) "Total Contrato = " w01 format ">>>,>>>,>>9.99" space w02
      space w03 skip.
 end.
 if w001 > 0
  then put space(12) "Total Cliente = " w001 format ">>>,>>>,>>9.99"
	   space w002 space w003 skip fill("-",78) format "x(78)" skip.
end.
output close.
dos silent value("type " + varq + " > prn").
