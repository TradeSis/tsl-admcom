output to printer page-size 63.
define shared buffer wempre for empre.
define variable w01 like contrato.vltotal.
define variable w001 like contrato.vltotal.
form header
 wempre.emprazsoc "C R E D I A R I O" at 40 today at 73
 skip "Crediario - Atrasados" "Pag." at 73 page-number format ">>9"
 skip fill("-",80) format "x(80)" skip
 with frame fcab page-top no-box.
form header
 skip "Cliente" space (41) "Cont. Pc Dt.Venc.    Valor Parc."
 with frame fdet page-top no-box.
view frame fcab.
view frame fdet.
assign w01 = 0.
for each clien use-index clien2 where situacao = yes:
 assign w001 = 0.
 for each contrato of clien where situacao > 0 and situacao < 9,
 each titulo  where
    titulo.empcod = wempre.empcod and
    titulo.titnat = no and
    titulo.modcod = "CRE" and
    titulo.titnum = string(contrato.contnum) and
     titulo.titdtven < today and titulo.titsit <> "LIB"
     break by clien.clicod:
  if first(clien.clicod)
   then put clien.clinom "-" clien.clicod " ".
   else put space(48).
  put contrato.contnum " "
      titulo.titpar " "
      titulo.titdtven " "
      titulo.titvlcob skip.
  assign w001 = w001 + titulo.titvlcob.
 end.
 if w001 > 0
 then put space(50) "Total Cliente = " w001 format ">>>,>>>,>>9.99"
	  skip fill("-",80) format "x(80)" skip.
 w01 = w01 + w001.
end.
put skip(2) space(52) "Total Geral = " w01 format ">>>,>>>,>>9.99".
