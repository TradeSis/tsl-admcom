def var varq as char format "x(20)".
varq = "..\relat\sin" + string(time) + ".rel".

output to value(varq) page-size 65.
define shared buffer wempre for empre.
define variable w01 like contrato.vltotal.
define variable w02 like contrato.vltotal.
define variable w03 like contrato.vltotal.
define variable w001 like contrato.vltotal.
define variable w002 like contrato.vltotal.
define variable w003 like contrato.vltotal.
define variable w004 like contrato.vltotal.
form header
 wempre.emprazsoc "C R E D I A R I O" at 40 today at 71
 skip "Crediario - Posicao Sintetica" "Pag." at 71 page-number format ">>9"
 skip fill("-",78) format "x(78)" skip
 with frame fcab page-top no-box.
form header
 skip "Cliente" skip " Contrato" "Dt.Inic." space(4) "Valor total"
 space(5) "Pagamentos" space(2) "Saldo devedor" space(6) "Atrasados"
 with frame fdet page-top no-box.
view frame fcab.
view frame fdet.
for each clien use-index clien2:
 assign w001 = 0
	w002 = 0
	w003 = 0
	w004 = 0.
 for each contrato of clien where contrato.situacao < 9:
  if w001 = 0 or line-counter = page-size
   then put clinom " - " clicod skip.
  put space(4) contnum format "99999" space dtinicial space
      vltotal format ">>>,>>>,>>9.99".
  assign w01 = 0
	 w02 = 0
	 w03 = 0.
 for each titulo  where
    titulo.empcod = wempre.empcod and
    titulo.titnat = no and
    titulo.modcod = "CRE" and
    titulo.titnum = string(contrato.contnum):
   if titulo.titvlpag <> 0
    then assign w01 = w01 + titulo.titvlpag.
    else do:
    assign w02 = w02 + titulo.titvlcob.
    if titulo.titdtven > today
      then assign w03 = w03 + titulo.titvlcob.
    end.
  end.
  put space w01 format ">>>,>>>,>>9.99"
      space w02 format ">>>,>>>,>>9.99"
      space w03 format ">>>,>>>,>>9.99" skip.
  assign w001 = w001 + vltotal
	 w002 = w002 + w01
	 w003 = w003 + w02
	 w004 = w004 + w03.
 end.
 if w001 <> 0
  then put space(10) "Totais = " w001 space w002 space w003 space w004 skip
	       fill("-",78) format "x(78)" skip.
end.

output close.
dos silent value("type " + varq + " > prn").
