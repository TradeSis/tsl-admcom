/********************************************************************
* Programa.....: p_val_mail.p
* Funcao.......: Validacao de e-mail digitado
* Data.........: 11/04/2007
* Autor........: Gerson Mathias
* observacoes..: Aceitar somente 
* (0-9,a-z,A-Z,.,_@0-9,a-z,A-Z,-,_).(aero,biz,com,coop,info,museum,
*  name,net,org,pro,gov,edu,mil.int).(terminadores de codigo de pais
*  arpa) {IP em dominios 0-255.0-255.0-255.0-255}
****************************************************************** */

def var c_mail      as char form "x(70)".
def var c_retorno   as char form "x(01)".
def var c_texto     as char.
def var c_txtmail   as char.
def var i_contador  as inte  init 0.
def var l_valida1   as logi  init no.
def var l_valida2   as logi  init no.
def var l_valida3   as logi  init no.
def var l_valida4   as logi  init no.
def var l_valida5   as logi  init no. 
def var i_tamanho   as inte extent 5.
def var l_confirma  as logi  init no.

/*
assign c_mail = "gerson.mathias@terra.com.br". /* 27 letras */

update c_mail no-label form "x(60)"
       with frame f-1 side-label 1 col 1 down width 80. 
*/

run pi-tamanho.

/* ------------------------------------------------------- */

run pi-primeiro.

if l_valida1 = yes then run pi-segundo.
                   else leave.

if l_valida2 = yes then run pi-terceiro.
                   else leave.

if l_valida3 = yes then run pi-quarto.
                   else leave.

if l_valida4 = no then do:

    message "E-mail " c_mail skip
            "nao considerado um mail valido!"
            "confirma utilizacao!"
            view-as alert-box buttons yes-no
                    title "E-MAIL NAO VALIDO"
                    update l_confirma.
                    
   if l_confirma = no
   then do:
           undo, retry.             
   end.                 
                    
end.

procedure pi-primeiro:

def var i_primeiro  as inte  init 0.

    do i_primeiro = 1 to length(c_mail):

     if substring(c_mail,i_primeiro,1) =  chr(046)  or
        substring(c_mail,i_primeiro,1) =  chr(064)  or                
        substring(c_mail,i_primeiro,1) =  chr(095)  or
        substring(c_mail,i_primeiro,1) >= chr(065)  and
        substring(c_mail,i_primeiro,1) <= chr(090)  or
        substring(c_mail,i_primeiro,1) >= chr(097)  and
        substring(c_mail,i_primeiro,1) <= chr(122)
     then do:   
       if i_primeiro < i_tamanho[1]
       then assign c_texto    = c_texto + substring(c_mail,i_primeiro,1)
                   i_contador = i_contador + 1.
       
       if i_primeiro = i_tamanho[1] + 1
       then do:
               assign c_txtmail = c_texto + "@"
                      l_valida1 = yes.
               leave.
       end.
     end.
     else do:
             message "Caracter invalido no e-mail!" skip
                     substring(c_mail,i_primeiro,1) + " - Primeira fase"
                     view-as alert-box.
             leave.
     end.

    end.

end procedure.

procedure pi-segundo:

def var i_segundo  as inte  init 0.

assign i_contador = i_contador + 1  
       c_texto    = ""
       i_segundo  = i_contador.

do i_segundo = i_contador to length(c_mail):

     if substring(c_mail,i_segundo,1) = chr(064)
     then next.
     
     if substring(c_mail,i_segundo,1) =  chr(046)  or
        substring(c_mail,i_segundo,1) =  chr(095)  or
        substring(c_mail,i_segundo,1) >= chr(065)  and
        substring(c_mail,i_segundo,1) <= chr(090)  or
        substring(c_mail,i_segundo,1) >= chr(097)  and
        substring(c_mail,i_segundo,1) <= chr(122)
     then do: 
       if substring(c_mail,i_segundo,1) <> chr(046)
       then assign c_texto    = c_texto + substring(c_mail,i_segundo,1)
                   i_contador = i_contador + 1.

       if i_segundo = i_tamanho[2] 
       then do:
               assign c_txtmail = c_txtmail + c_texto
                      l_valida2 = yes.
               leave.
       end.
     end.
     else do:
             message "Caracter invalido no e-mail!" skip
                     substring(c_mail,i_segundo,1) + " - Segunda fase"
                     view-as alert-box.
             leave.
     end.

    end.

end procedure.


procedure pi-terceiro:

def var i_terceiro  as inte  init 0.
def var l_confir  as logi  init yes.

assign i_contador = i_contador + 1
       c_texto    = "".

do i_terceiro = i_contador to length(c_mail):

     if substring(c_mail,i_terceiro,1) =  chr(046)  or
        substring(c_mail,i_terceiro,1) =  chr(095)  or
        substring(c_mail,i_terceiro,1) >= chr(065)  and
        substring(c_mail,i_terceiro,1) <= chr(090)  or
        substring(c_mail,i_terceiro,1) >= chr(097)  and
        substring(c_mail,i_terceiro,1) <= chr(122)
     then do: 
         if substring(c_mail,i_terceiro,1) <> chr(046)
         then assign c_texto    = c_texto + substring(c_mail,i_terceiro,1)
                     i_contador = i_contador + 1.
                     
         if i_terceiro = i_tamanho[3] 
         then do:
                 assign c_txtmail = c_texto
                        l_valida3 = yes.
                 leave.
         end.
                     
     end.
     else do:
             message "Caracter invalido no e-mail!" skip
                     substring(c_mail,i_terceiro,1) + " - Terceira fase"
                     view-as alert-box.
             leave.
     end.
       
end. /* Final DO */

if c_texto <> "aero"     and
   c_texto <> "biz"      and
   c_texto <> "com"      and
   c_texto <> "coop"     and
   c_texto <> "info"     and
   c_texto <> "museum"   and
   c_texto <> "name"     and
   c_texto <> "net"      and
   c_texto <> "org"      and
   c_texto <> "pro"      and
   c_texto <> "gov"      and
   c_texto <> "edu"      and
   c_texto <> "mil"      and
   c_texto <> "int"
   then do:
           message "Terminador de dominio invalido!" skip
                   c_texto + " - Terceira fase" skip
                   c_txtmail skip 
                   "confirma e-mail deseja seguir"
                   view-as alert-box buttons yes-no
                   title "ATENCAO" update l_confir.
           if l_confir = no
           then do:        
                   assign l_valida4 = no.
                   leave.
           end.                 
   end.

end procedure.

procedure pi-quarto:

def var i_quarto  as inte  init 0.
def var l_confir  as logi  init yes.

assign i_contador = i_contador + 1
       c_texto    = "".

do i_quarto = i_contador to length(c_mail):

     if substring(c_mail,i_quarto,1) =  chr(046)  or
        substring(c_mail,i_quarto,1) =  chr(095)  or
        substring(c_mail,i_quarto,1) >= chr(065)  and
        substring(c_mail,i_quarto,1) <= chr(090)  or
        substring(c_mail,i_quarto,1) >= chr(097)  and
        substring(c_mail,i_quarto,1) <= chr(122)
     then do: 
        if substring(c_mail,i_quarto,1) <> chr(046)
        then assign c_texto    = c_texto + substring(c_mail,i_quarto,1)
                    i_contador = i_contador + 1.

        if i_quarto = i_tamanho[4] 
        then do:
                 assign c_txtmail = c_texto
                        l_valida5 = yes.
                 leave.
        end.
     end.
     else do:
             message "Caracter invalido no e-mail!" skip
                     substring(c_mail,i_quarto,1) + " - Quarta fase"
                     view-as alert-box.
             leave.
     end.

end. /* DO */ 
       
  if c_texto <> "aero"     and
     c_texto <> "biz"      and
     c_texto <> "com"      and
     c_texto <> "coop"     and
     c_texto <> "info"     and
     c_texto <> "museum"   and
     c_texto <> "name"     and
     c_texto <> "net"      and
     c_texto <> "org"      and
     c_texto <> "pro"      and
     c_texto <> "gov"      and
     c_texto <> "edu"      and
     c_texto <> "mil"      and
     c_texto <> "int"
  then do:
          message "Terminador de dominio invalido!" skip
                  c_texto + " - Quarta fase" skip
                  c_txtmail skip 
                  "confirma e-mail deseja seguir"
                  view-as alert-box buttons yes-no
                          title "ATENCAO" update l_confir.
                  if l_confir = no
                  then do:        
                          assign l_valida4 = no.
                          leave.
                  end.                 
  end.   

end procedure.

procedure pi-tamanho:

  def var i_ct   as inte init 0.
  def var i_cont as inte init 1.
  
  do i_ct = 1 to length(c_mail):
  
        if substring(c_mail,i_ct,1) = chr(064) and
           i_cont                   = 1
        then do: 
                        assign i_tamanho[1] = i_ct.
                        assign i_cont = i_cont + 1.       
        end.

        if substring(c_mail,i_ct,1) = chr(046) and
           i_cont                   = 2
        then do:
                        assign i_tamanho[2] = i_ct.
                        assign i_cont = i_cont + 1. 
                        next.
        end.

        if substring(c_mail,i_ct,1) = chr(046) and
           i_cont                   = 3
        then do:
                        assign i_tamanho[3] = i_ct.
                        assign i_cont = i_cont + 1.       
                        next.
        end.

        if substring(c_mail,i_ct,1) = chr(046) and
           i_cont                   = 4
        then do:
                        assign i_tamanho[4] = i_ct.
                        assign i_cont = i_cont + 1.       
                        next.
        end.

        if substring(c_mail,i_ct,1) = chr(046) and
           i_cont                   = 5
        then do:
                        assign i_tamanho[5] = i_ct.
        end.

  end.

end procedure.
