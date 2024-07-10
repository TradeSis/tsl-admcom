define input parameter wcontnum like contrato.contnum.
define variable wcnt as logical initial yes.
define variable w01 like dtvenc.
define variable w02 like contrato.clicod.
define variable w03 like clien.clinom.
define variable w04 like contrato.contnum.
define variable w05 like parcela.
define variable w06 as character format "x(30)".
define variable w07 as integer format ">>>>9".
define variable w08 as character format "x(6)".
define variable w09 as character format "!!".
define variable w10 as character format "x(20)".
define variable w11 as character format "x(25)".
define variable w12 like vlparc.
define variable w13 as character format "x(30)".


output to printer.
find contrato where contnum = wcontnum.
find clien of contrato.


if contrato.indimp = yes
 then do:
 assign w01 = contrato.dtinicial
	w02 = contrato.clicod
	w03 = clinom
	w04 = contrato.contnum
	w05 = 0
	w06 = endereco[1]
	w07 = numero[1]
	w08 = compl[1]
	w09 = ufecod[1]
	w10 = bairro[1]
	w11 = cidade[1]
	w12 = contrato.vlentra
	wcnt = no.
	contrato.indimp = no.
 if contrato.autoriza <> 0
  then assign w13 = clien.autoriza[contrato.autoriza].
 end.
for each parcela of contrato where indimp = yes:
 if wcnt
  then do:
  assign w01 = dtvenc
	 w02 = contrato.clicod
	 w03 = clinom
	 w04 = contrato.contnum
	 w05 = parcela
	 w06 = endereco[1]
	 w07 = numero[1]
	 w08 = compl[1]
	 w09 = ufecod[1]
	 w10 = bairro[1]
	 w11 = cidade[1]
	 w12 = vlparc.

  if contrato.autoriza <> 0
   then assign w13 = clien.autoriza[contrato.autoriza].
  assign wcnt = no.
  end.
  else do:
  put w01 at 56 dtvenc at 124 skip(3)
      today at 5 w04 at 19 "-" w05
      today at 72 contrato.contnum at 87 "-" parcela skip(1)
      w12 at 53 vlparc at 121 skip(1)
      "Juros por dia de atraso : TAXA BANCARIA" at 4
      "Juros por dia de atraso : TAXA BANCARIA" at 72 skip(3).
  if w13 <> fill(" ",30)
   then put "A\C " at 4 w13.
  if contrato.autoriza <> 0
   then put "A\C " at 72 clien.autoriza[contrato.autoriza] skip.
   else put skip.
  put "Cliente:" at 7 w02
      "Cliente:" at 75 contrato.clicod skip(1)
      w03 at 7 clinom at 75 skip
      w06 at 7 "," w07 "/" w08 "-" w09
      endereco[1] at 75 "," numero[1] "/" compl[1] "-" ufecod[1] skip
      w10 at 11 space(1) w11 bairro[1] at 79 space(1) cidade[1]
      skip(6).
  assign wcnt = yes.
  end.
  assign parcela.indimp = no.
end.
if not wcnt
 then do:
  put w01 at 56 skip(3)
      today at 5 w04 at 19 "-" w05 skip(1)
      w12 at 53 skip(1)
      "Juros por dia de atraso : TAXA BANCARIA" at 4 skip(3).
  if w13 <> fill(" ",30)
   then put "A\C " at 4 w13 skip.
   else put skip.
  put "Cliente:" at 7 w02 skip(1)
      w03 at 7 skip
      w06 at 7 "," w07 "/" w08 "-" w09 skip
      w10 at 11 space(1) w11 skip(6).
 end.
output close.
