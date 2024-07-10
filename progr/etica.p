{admcab.i}
define variable wmes as i format "99" label "Mes Aniversario".
do with 1 column width 80 frame f1 title " Parametro para Emissao ":
 update wmes.
end.
define variable wcnt as integer format "9".
define variable wflag as logical.
define variable w1 like clien.clinom.
define variable w2 like clien.autoriza extent 0.
define variable w3 like clien.endereco extent 0.
define variable w4 like clien.numero extent 0.
define variable w5 like clien.compl extent 0.
define variable w8 like clien.ufecod extent 0.
define variable w6 like clien.bairro extent 0.
define variable w7 like clien.cidade extent 0.
define variable w9 like cep extent 0.
output to xisp page-size 0.
for each clien where month(dtnasc) = wmes:
  if wcnt = 0
   then do:
   assign w1 = clinom
	  w2 = " "
	  w3 = endereco[1]
	  w4 = numero[1]
	  w5 = compl[1]
	  w6 = bairro[1]
	  w7 = cidade[1]
	  w8 = ufecod[1]
	  w9 = cep[1].
   assign wcnt = 1.
   end.
   else do:
   put w1 format "x(34)" clinom format "x(34)" at 38 skip.
   if w2 <> " "
    then put "A/C " w2.
   if w2 = " "
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
