{admcab.i}
define variable wini as date label "Data Limite".
do with 1 column width 80 frame f1 title " Parametro para Emissao ":
 update wini.
end.
define variable wcnt as integer format "9".
define variable wflag as logical.
define variable w1 like clien.clinom.
define variable w2 like clien.autoriza extent 0.
define variable w3 like clien.endereco extent 0.
define variable w4 like numero extent 0.
define variable w5 like compl extent 0.
define variable w8 like clien.ufecod extent 0.
define variable w6 like bairro extent 0.
define variable w7 like cidade extent 0.
define variable w9 like cep extent 0.
output to printer page-size 0.
for each clien:
 wflag = no.
 for each contrato of clien where situacao > 0 and situacao < 9,
     each titulo where
    titulo.titnum = string(contrato.contnum) and
    titulo.empcod = wempre.empcod and
    titulo.titnat = no and
    titulo.modcod = "CRE" and
	titdtven < wini:
  wflag = yes.
  leave.
 end.
 if wflag
  then do:
  if wcnt = 0
   then do:
   assign w1 = clinom
	  w3 = endereco[1]
	  w4 = numero[1]
	  w5 = compl[1]
	  w6 = bairro[1]
	  w7 = cidade[1]
	  w8 = ufecod[1]
	  w9 = cep[1].
   if contrato.autoriza <> 0
    then assign w2 = clien.autoriza[contrato.autoriza].
    else assign w2 = " ".
   assign wcnt = 1.
   end.
   else do:
   put w1 format "x(34)" clinom format "x(34)" at 38 skip.
   if w2 <> " "
    then put "A/C " w2.
   if contrato.autoriza <> 0
    then put "A/C " at 38 clien.autoriza[contrato.autoriza].
   if w2 = " " and contrato.autoriza = 0
    then put skip(1).
    else put skip.
   put w3 + "," + string(w4) format "x(34)"
       endereco[1] + "," + string(numero[1]) format "x(34)" at 38 skip
       w5 compl[1] at 38 skip
       w6 bairro[1] at 38 skip
       w7 space w8 space w9 format ">>>>>"
       cidade[1] at 38 space ufecod[1] space cep[1] format ">>>>>"
       skip(3).
   assign wcnt = 0.
   end.
  end.
end.
if wcnt = 1
   then do:
   put w1 format "x(34)" skip.
   if w2 <> " "
    then put "A/C " w2.
   if w2 = " "
    then put skip(1).
    else put skip.
   put w3 + "," + string(w4) format "x(34)" skip
       w5 skip
       w6 skip
       w7 space w8 space w9 format ">>>>>"
       skip(4).
   end.
output close.
output close.
