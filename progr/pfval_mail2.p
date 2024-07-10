/********************************************************************
* Programa.....: p_val_mail.p
* Funcao.......: Validacao de e-mail digitado
* Data.........: 11/04/2007
* Autor........: Gerson Mathias
* observacoes..: Aceitar somente 
* (0-9,a-z,A-Z,.,_@0-9,a-z,A-Z,-,_).(aero,biz,com,coop,info,museum,
*  name,net,org,pro,gov,edu,mil.int).(terminadores de codigo de pais
*  arpa) {IP em dominios 0-255.0-255.0-255.0-255}
* Alteração    : em 11/05/2009 adaptar para Function
*                include p_val_mail.p por Antonio
****************************************************************** */

def input  parameter p_mail  as char.
def output parameter p_retorno as logical.


def var z           as int.
def var v-dom-par   as char.
def var v-ok-dom    as logical.
def var v-n-separa  as int. 
def var c_retorno   as char form "x(01)".
def var c_texto     as char.
def var c_txtmail   as char.
def var i_ct        as inte  init 0.
def var i_contador  as inte  init 0.
def var l_valida1   as logi  init no.
def var l_valida2   as logi  init no.
def var l_valida3   as logi  init no.
def var l_valida4   as logi  init no.
def var l_valida5   as logi  init no. 
def var i_tamanho   as inte extent 5.
def var l_confirma  as logi  init no.


/*
assign p_mail = "gerson.mathias@terra.com.br". /* 27 letras */

update p_mail no-label form "x(60)"
       with frame f-1 side-label 1 col 1 down width 80. 
*/

def var i_primeiro  as inte  init 0.
def var i_segundo   as inte  init 0.
def var i_terceiro  as inte  init 0.
def var l_confir    as logi  init yes.
def var i_quarto    as inte  init 0.
def var v-dominios  as char  initial 
"com^inf^jus^mil^org^psi^radio^rec^srv^tmp^tur^tv^etc^adm^adv^arq^ato^bio^bmd
^cim^cng^cnt^ecn^eng^eti^fnd^fot^fst^ggf^jor^lel^mat^med^mus^not^ntr^odo^ppg
^pro^psc^qsl^slg^taxi^teo^trd^vet^zlg^blog^flog^nom^vlog^wiki^gov^lebes".

/* antonio - Validação de @, . e Dominios  */

assign p_retorno = yes.
if p_mail = "" then do:
 
    assign p_retorno = no.
    return.

end.

if num-entries(p_mail,"@") <= 1
then do:

    assign p_retorno = no.
    return.

end.


if (not p_mail matches("*.*"))
then do:
    assign p_retorno = no.
    return.
end.    
if (not p_mail matches("*@*")) 
    or substring(p_mail,1,1) = "@" 
    or substring(p_mail,length(p_mail),1) = "@"  
then do:
    assign p_retorno = no.
    return.
end.

assign v-n-separa = num-entries(v-dominios,"^")
       v-ok-dom   = no
       v-dom-par   = p_mail.
       if p_mail matches ("*" + "." + "*") 
       then do:
       
            assign
                v-dom-par = entry(2,p_mail,"@")  /* antes sem esta linha */.
                
            if num-entries(v-dom-par,".") > 1
            then assign     
                v-dom-par = entry(2,v-dom-par,".").  /* entry(2,p_mail,"."). */
                
       end.
       
do z = 1 to v-n-separa:
    if (not v-dom-par matches ("*" + entry(z,v-dominios,"^") + "*"))
    then next.
    v-ok-dom = yes.
    leave.
end.

if v-ok-dom = no
then do:
    assign p_retorno = no.
    return.
end.

/**/

do i_ct = 1 to length(p_mail):
    if substring(p_mail,i_ct,1) <> "a" and
       substring(p_mail,i_ct,1) <> "b" and
       substring(p_mail,i_ct,1) <> "c" and
       substring(p_mail,i_ct,1) <> "d" and
       substring(p_mail,i_ct,1) <> "e" and
       substring(p_mail,i_ct,1) <> "f" and
       substring(p_mail,i_ct,1) <> "g" and
       substring(p_mail,i_ct,1) <> "h" and
       substring(p_mail,i_ct,1) <> "i" and
       substring(p_mail,i_ct,1) <> "j" and
       substring(p_mail,i_ct,1) <> "k" and
       substring(p_mail,i_ct,1) <> "l" and
       substring(p_mail,i_ct,1) <> "m" and
       substring(p_mail,i_ct,1) <> "n" and
       substring(p_mail,i_ct,1) <> "o" and
       substring(p_mail,i_ct,1) <> "p" and
       substring(p_mail,i_ct,1) <> "q" and
       substring(p_mail,i_ct,1) <> "r" and
       substring(p_mail,i_ct,1) <> "s" and
       substring(p_mail,i_ct,1) <> "t" and
       substring(p_mail,i_ct,1) <> "u" and
       substring(p_mail,i_ct,1) <> "v" and
       substring(p_mail,i_ct,1) <> "w" and
       substring(p_mail,i_ct,1) <> "x" and
       substring(p_mail,i_ct,1) <> "y" and
       substring(p_mail,i_ct,1) <> "z" and
       substring(p_mail,i_ct,1) <> "." and
       substring(p_mail,i_ct,1) <> "_" and
       substring(p_mail,i_ct,1) <> "-" and
       substring(p_mail,i_ct,1) <> "@" and
       substring(p_mail,i_ct,1) <> "0" and
       substring(p_mail,i_ct,1) <> "1" and
       substring(p_mail,i_ct,1) <> "2" and
       substring(p_mail,i_ct,1) <> "3" and
       substring(p_mail,i_ct,1) <> "4" and
       substring(p_mail,i_ct,1) <> "5" and
       substring(p_mail,i_ct,1) <> "6" and
       substring(p_mail,i_ct,1) <> "7" and
       substring(p_mail,i_ct,1) <> "8" and
       substring(p_mail,i_ct,1) <> "9" 
    then do:
          assign p_retorno = no.
    end.
end.       
