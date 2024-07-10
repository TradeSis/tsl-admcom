/* cpf.p  -  Valida‡Æo do CPF                                                 */

/*******************************************************************************
*         Vari veis necess rias no programa                                    *
*                                                                              *
*   def var v-certo         as log.                                            *
*   def var v-resto1        as int.                                            *
*   def var v-resto2        as int.                                            *
*   def var v-digito1       as int.                                            *
*   def var v-digito2       as int.                                            *
*                                                                              *
*******************************************************************************/

def var v-certo         as log.
def var v-resto1        as int.
def var v-resto2        as int.
def var v-digito1       as int.
def var v-digito2       as int.

def input  param par-cpf     like clien.ciccgc.
def output param par-certo   as log.

par-certo = yes.

/*** 26/08/08 ***/
def var vct  as int.
def var vcpf as char.
do vct = 1 to length(par-cpf).
    if substr(par-cpf, vct, 1) >= "0" and
       substr(par-cpf, vct, 1) <= "9"
    then vcpf = vcpf + substr(par-cpf, vct, 1).
end.    
par-cpf = vcpf.
/*** ***/

v-digito1 = (if ((int(substr(string(par-cpf,"99999999999"),01,1)) * 10 +
                  int(substr(string(par-cpf,"99999999999"),02,1)) *  9 +
                  int(substr(string(par-cpf,"99999999999"),03,1)) *  8 +
                  int(substr(string(par-cpf,"99999999999"),04,1)) *  7 +
                  int(substr(string(par-cpf,"99999999999"),05,1)) *  6 +
                  int(substr(string(par-cpf,"99999999999"),06,1)) *  5 +
                  int(substr(string(par-cpf,"99999999999"),07,1)) *  4 +
                  int(substr(string(par-cpf,"99999999999"),08,1)) *  3 +
                  int(substr(string(par-cpf,"99999999999"),09,1)) *  2)
                  modulo 11 = 0) or
                ((int(substr(string(par-cpf,"99999999999"),01,1)) * 10 +
                  int(substr(string(par-cpf,"99999999999"),02,1)) *  9 +
                  int(substr(string(par-cpf,"99999999999"),03,1)) *  8 +
                  int(substr(string(par-cpf,"99999999999"),04,1)) *  7 +
                  int(substr(string(par-cpf,"99999999999"),05,1)) *  6 +
                  int(substr(string(par-cpf,"99999999999"),06,1)) *  5 +
                  int(substr(string(par-cpf,"99999999999"),07,1)) *  4 +
                  int(substr(string(par-cpf,"99999999999"),08,1)) *  3 +
                  int(substr(string(par-cpf,"99999999999"),09,1)) *  2)
                  modulo 11 = 1)
              then  0
              else (11 -
                   (int(substr(string(par-cpf,"99999999999"),01,1)) * 10 +
                    int(substr(string(par-cpf,"99999999999"),02,1)) *  9 +
                    int(substr(string(par-cpf,"99999999999"),03,1)) *  8 +
                    int(substr(string(par-cpf,"99999999999"),04,1)) *  7 +
                    int(substr(string(par-cpf,"99999999999"),05,1)) *  6 +
                    int(substr(string(par-cpf,"99999999999"),06,1)) *  5 +
                    int(substr(string(par-cpf,"99999999999"),07,1)) *  4 +
                    int(substr(string(par-cpf,"99999999999"),08,1)) *  3 +
                    int(substr(string(par-cpf,"99999999999"),09,1)) *  2)
                    modulo 11)).

if v-digito1 <> int(substr(string(par-cpf,"99999999999"),10,1))
then
    par-certo = no.

v-digito2 = (if ((int(substr(string(par-cpf,"99999999999"),01,1)) * 11 +
                  int(substr(string(par-cpf,"99999999999"),02,1)) * 10 +
                  int(substr(string(par-cpf,"99999999999"),03,1)) *  9 +
                  int(substr(string(par-cpf,"99999999999"),04,1)) *  8 +
                  int(substr(string(par-cpf,"99999999999"),05,1)) *  7 +
                  int(substr(string(par-cpf,"99999999999"),06,1)) *  6 +
                  int(substr(string(par-cpf,"99999999999"),07,1)) *  5 +
                  int(substr(string(par-cpf,"99999999999"),08,1)) *  4 +
                  int(substr(string(par-cpf,"99999999999"),09,1)) *  3 +
                  int(substr(string(par-cpf,"99999999999"),10,1)) *  2)
                  modulo 11 = 0) or
                ((int(substr(string(par-cpf,"99999999999"),01,1)) * 11 +
                  int(substr(string(par-cpf,"99999999999"),02,1)) * 10 +
                  int(substr(string(par-cpf,"99999999999"),03,1)) *  9 +
                  int(substr(string(par-cpf,"99999999999"),04,1)) *  8 +
                  int(substr(string(par-cpf,"99999999999"),05,1)) *  7 +
                  int(substr(string(par-cpf,"99999999999"),06,1)) *  6 +
                  int(substr(string(par-cpf,"99999999999"),07,1)) *  5 +
                  int(substr(string(par-cpf,"99999999999"),08,1)) *  4 +
                  int(substr(string(par-cpf,"99999999999"),09,1)) *  3 +
                  int(substr(string(par-cpf,"99999999999"),10,1)) *  2)
                  modulo 11 = 1)
                  then  0
                  else (11 -
                 (int(substr(string(par-cpf,"99999999999"),01,1)) * 11 +
                  int(substr(string(par-cpf,"99999999999"),02,1)) * 10 +
                  int(substr(string(par-cpf,"99999999999"),03,1)) *  9 +
                  int(substr(string(par-cpf,"99999999999"),04,1)) *  8 +
                  int(substr(string(par-cpf,"99999999999"),05,1)) *  7 +
                  int(substr(string(par-cpf,"99999999999"),06,1)) *  6 +
                  int(substr(string(par-cpf,"99999999999"),07,1)) *  5 +
                  int(substr(string(par-cpf,"99999999999"),08,1)) *  4 +
                  int(substr(string(par-cpf,"99999999999"),09,1)) *  3 +
                  int(substr(string(par-cpf,"99999999999"),10,1)) *  2)
                  modulo 11)).

if v-digito2 <> int(substr(string(par-cpf,"99999999999"),11,1))
then
    par-certo = no.

if par-cpf = "0" or
    par-cpf = ?   or
    par-cpf = ""  or
    length(par-cpf) < 11 or
    substr(string(par-cpf),1,11) = "11111111111" or
    substr(string(par-cpf),1,11) = "22222222222" or
    substr(string(par-cpf),1,11) = "33333333333" or
    substr(string(par-cpf),1,11) = "44444444444" or
    substr(string(par-cpf),1,11) = "55555555555" or
    substr(string(par-cpf),1,11) = "66666666666" or
    substr(string(par-cpf),1,11) = "77777777777" or
    substr(string(par-cpf),1,11) = "88888888888" or
    substr(string(par-cpf),1,11) = "99999999999" or
    substr(string(par-cpf),1,11) = "00000000000" 
then par-certo = no.
