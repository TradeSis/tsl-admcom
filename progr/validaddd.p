/*
** Valida DDD
** Cristiano Hickel - 18/09/2006
** 
** Utilizado para validar cadastros de telefone
** Programas cliout9.p (matriz), clioutb4.p (filial)
*/

def input  parameter v-uf       like clien.ufecod[1]. /* UF */
def input  parameter v-telefone like clien.fax.      /* Numero telefone */
def input  parameter v-tipo as int.        /* 1- Convencional, 2- Celular */
def output parameter v-ok   as log.        /* Retorna resultado da validacao */

def var i as int.

assign v-ok = yes.

/* Valida DDD informado */
case v-uf:
  when "RS" then do:
    if substring(v-telefone,1,2) <> "51" and
       substring(v-telefone,1,2) <> "53" and
       substring(v-telefone,1,2) <> "54" and
       substring(v-telefone,1,2) <> "55"
    then assign v-ok = no.
    else assign v-ok = yes.
  end.
  when "SC" then do:
    if substring(v-telefone,1,2) <> "47" and
       substring(v-telefone,1,2) <> "48" and
       substring(v-telefone,1,2) <> "49"
    then assign v-ok = no.
    else assign v-ok = yes.
  end.
  when "PR" then do:
    if substring(v-telefone,1,2) <> "41" and
       substring(v-telefone,1,2) <> "42" and
       substring(v-telefone,1,2) <> "43" and
       substring(v-telefone,1,2) <> "44" and
       substring(v-telefone,1,2) <> "45" and
       substring(v-telefone,1,2) <> "46"
    then assign v-ok = no.
    else assign v-ok = yes.
  end.
  when "SP" then do:
    if substring(v-telefone,1,2) <> "11" and
       substring(v-telefone,1,2) <> "12" and
       substring(v-telefone,1,2) <> "13" and
       substring(v-telefone,1,2) <> "14" and
       substring(v-telefone,1,2) <> "15" and
       substring(v-telefone,1,2) <> "16" and
       substring(v-telefone,1,2) <> "17" and
       substring(v-telefone,1,2) <> "18" and
       substring(v-telefone,1,2) <> "19"
    then assign v-ok = no.
    else assign v-ok = yes.
  end.
  when "RJ" then do:
    if substring(v-telefone,1,2) <> "21" and
       substring(v-telefone,1,2) <> "22" and
       substring(v-telefone,1,2) <> "24"
    then assign v-ok = no.
    else assign v-ok = yes.
  end.
  otherwise assign v-ok = no.
end case.

if not v-ok then return.

/* Valida Telefone convencional, nco deve permitir celular neste campo */
if v-tipo = 1
then do:
    if substring(v-telefone,3,1) = "9" or
       substring(v-telefone,3,1) = "8"
    then assign v-ok = no.
    /* Considerando que nco existem mais numeros de 7 digitos */
    if length(v-telefone) <> 10
    then assign v-ok = no.
end.
else do:
    /* Valida Telefone celular, nco deve permitir convencional neste campo */
    if substring(v-telefone,3,2) <> "99" and
       substring(v-telefone,3,2) <> "98"
    then assign v-ok = no.
    if length(v-telefone) <> 11
    then assign v-ok = no.    
end.

/* Impede caracteres nao numericos */
do i = 1 to length(v-telefone):
    if substring(v-telefone,i,1) < chr(48) or
       substring(v-telefone,i,1) > chr(57)
    then do:
        assign v-ok = no. 
        return. 
    end.
end.

/* Claro: 91, 92, 93
** TIM: 81, 82, 83
** VIVO: 96, 97, 98, 99
** BR TELECOM: 84, 85
*/

