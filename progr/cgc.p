/* cgc.p  -  Valida‡Æo do CGC                                                 */

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

def input  param par-cgc     like forne.forcgc.
def output param par-certo   as log.

par-certo = yes.

assign
    v-resto1  = int(int(substr(string(par-cgc),01,1)) * 5 +
                    int(substr(string(par-cgc),02,1)) * 4 +
                    int(substr(string(par-cgc),03,1)) * 3 +
                    int(substr(string(par-cgc),04,1)) * 2 +
                    int(substr(string(par-cgc),05,1)) * 9 +
                    int(substr(string(par-cgc),06,1)) * 8 +
                    int(substr(string(par-cgc),07,1)) * 7 +
                    int(substr(string(par-cgc),08,1)) * 6 +
                    int(substr(string(par-cgc),09,1)) * 5 +
                    int(substr(string(par-cgc),10,1)) * 4 +
                    int(substr(string(par-cgc),11,1)) * 3 +
                    int(substr(string(par-cgc),12,1)) * 2)
                    modulo 11
    v-resto2  = int(int(substr(string(par-cgc),01,1)) * 6 +
                    int(substr(string(par-cgc),02,1)) * 5 +
                    int(substr(string(par-cgc),03,1)) * 4 +
                    int(substr(string(par-cgc),04,1)) * 3 +
                    int(substr(string(par-cgc),05,1)) * 2 +
                    int(substr(string(par-cgc),06,1)) * 9 +
                    int(substr(string(par-cgc),07,1)) * 8 +
                    int(substr(string(par-cgc),08,1)) * 7 +
                    int(substr(string(par-cgc),09,1)) * 6 +
                    int(substr(string(par-cgc),10,1)) * 5 +
                    int(substr(string(par-cgc),11,1)) * 4 +
                    int(substr(string(par-cgc),12,1)) * 3 +
                    int(substr(string(par-cgc),13,1)) * 2)
                    modulo 11.
assign
    v-digito1 = (if v-resto1  = 0 or
                    v-resto1  = 1
                 then
                     0
                 else
                     11 - v-resto1)
    v-digito2 = (if v-resto2  = 0 or
                    v-resto2  = 1
                 then
                     0
                 else
                     11 - v-resto2).

if v-digito1 <> int(substr(string(par-cgc),13,1))
then
    par-certo = no.

if v-digito2 <> int(substr(string(par-cgc),14,1))
then
    par-certo = no.


if par-cgc = "0" or
    par-cgc = ?   or
    par-cgc = ""  or
    length(par-cgc) < 11 or
    substr(string(par-cgc),1,11) = "11111111111" or
    substr(string(par-cgc),1,11) = "22222222222" or
    substr(string(par-cgc),1,11) = "33333333333" or
    substr(string(par-cgc),1,11) = "44444444444" or
    substr(string(par-cgc),1,11) = "55555555555" or
    substr(string(par-cgc),1,11) = "66666666666" or
    substr(string(par-cgc),1,11) = "77777777777" or
    substr(string(par-cgc),1,11) = "88888888888" or
    substr(string(par-cgc),1,11) = "99999999999" or
    substr(string(par-cgc),1,11) = "00000000000" 
then par-certo = no.

