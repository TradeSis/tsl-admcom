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

assign c_mail = "raquel.mathias@terra.com.br". /* 27 letras */

def var i_ct        as inte                 init 0.
def var c_texto     as char                 init "".
def var c_tx_pr     as char                 init "".
def var c_tx_se     as char                 init "".
def var c_tx_te     as char                 init "".
def var c_tx_qu     as char                 init "".
def var i_ct_tx     as inte                 init 0.

def var c_etapa     as char                 init "P".
def var l_exi_er    as logi                 init yes.

def temp-table tt-letras   no-undo
    field tipo   as char form "x(01)"
    field letra  as char form "x(01)"
    index let  letra.

for each tt-letras:
    delete tt-letras.
end.    

run pi-gravaletra.

do i_ct = 1 to length(c_mail):

   if substring(c_mail,i_ct,1) = chr(64)
   then l_exi_er = no.

   if c_etapa = "P"
   then do:
        if substring(c_mail,i_ct,1) <> chr(64)
        then assign c_tx_pr = c_tx_pr + substring(c_mail,i_ct,1).
        else assign c_etapa = "S".
   end.
   if c_etapa = "S"
   then do:
        if substring(c_mail,i_ct,1) <> chr(64)
        then assign c_texto = c_texto + substring(c_mail,i_ct,1).
   end.     
    
end.

assign i_ct_tx = length(c_texto).

if l_exi_er = yes
then do:
        message "O uso de arroba <@>, é obrigadorio em" skip
                "endereco de e-mail, favor verificar!"
                view-as alert-box.
       undo,retry.
end.

assign i_ct    = 0
       c_etapa = "S".

do i_ct = 1 to length(c_texto):

  if substring(c_texto,i_ct,1) <> chr(046)
  then assign c_tx_se = c_tx_se + substring(c_texto,i_ct,1).
  else leave.

end.

repeat:

  assign i_ct = i_ct + 1.
  
  if substring(c_texto,i_ct,1) <> chr(046)
  then assign c_tx_te = c_tx_te  + substring(c_texto,i_ct,1).
  else leave.

end.

repeat:

  assign i_ct = i_ct + 1.

  if substring(c_texto,i_ct,1) <> chr(046)
  then assign c_tx_qu = c_tx_qu  + substring(c_texto,i_ct,1).

  if substring(c_texto,i_ct,1) = chr(032)
  then leave.

end.

do i_ct = 1 to length(c_tx_pr):

  find first tt-letras where
             tt-letras.letra = substring(c_tx_pr,i_ct,1) and
             tt-letras.tipo  = "P" no-lock no-error.
  if not avail tt-letras
  then assign l_exi_er = yes.
  
  if l_exi_er = yes
  then do:
          message "Caracter invalido encontrado na digitacao" skip
                  "favor verificar.  < "
                  substring(c_tx_pr,i_ct,1) " > (PR) "
                  view-as alert-box.
          leave.        
  end.   
            

end.

assign i_ct = 0.

do i_ct = 1 to length(c_tx_se):

  find first tt-letras where
             tt-letras.letra = substring(c_tx_se,i_ct,1) and
             tt-letras.tipo  = "S" no-lock no-error.
  if not avail tt-letras
  then assign l_exi_er = yes.
  
  if l_exi_er = yes
  then do:
          message "Caracter invalido encontrado na digitacao" skip
                  "favor verificar.  < "
                  substring(c_tx_se,i_ct,1) " > (SE) "
                  view-as alert-box.
          leave.        
   end.         

end.

if c_tx_te <> "aero"     and
   c_tx_te <> "biz"      and
   c_tx_te <> "com"      and
   c_tx_te <> "coop"     and
   c_tx_te <> "info"     and
   c_tx_te <> "museum"   and
   c_tx_te <> "name"     and
   c_tx_te <> "net"      and
   c_tx_te <> "org"      and
   c_tx_te <> "pro"      and
   c_tx_te <> "gov"      and
   c_tx_te <> "edu"      and
   c_tx_te <> "mil"      and
   c_tx_te <> "int"
then assign l_exi_er = yes.
  
if l_exi_er = yes
then do:
        message "Terminador de dominio invalido" skip
                "favor verificar!"
                view-as alert-box.
        leave.        
end.         

message c_tx_qu skip
        l_exi_er view-as alert-box.  

if length(c_tx_qu) <  2       and
   length(c_tx_qu) >  2       and 
   c_tx_qu         <> "arpa"
then assign l_exi_er = yes.
  
if l_exi_er = yes
then do:
        message "Terminador de dominio invalido, para" skip
                "codigo de pais, favor verificar!"
                view-as alert-box.
        leave.        
end.         

        
                                    

message "Primeira " c_tx_pr  skip
        "Segunda  " c_tx_se  skip
        "Terceira " c_tx_te  skip
        "Quarta   " c_tx_qu  skip
        "Texto    " c_texto
        view-as alert-box.

message "SAIDA" skip
        l_exi_er view-as alert-box. 
        
procedure pi-gravaletra:

 def var i_num as inte form "9" init 0.
 
 repeat:
     create tt-letras.
     assign tt-letras.tipo  = "P"
            tt-letras.letra = string(i_num,"9").

     assign i_num = i_num + 1. 

     if i_num = 10 
     then leave.             
 end.
 
 assign i_num = 0.

 repeat:
     create tt-letras.
     assign tt-letras.tipo  = "S"
            tt-letras.letra = string(i_num,"9").

     assign i_num = i_num + 1. 

     if i_num = 10 
     then leave.             
 end.
      
 assign i_num = 0.      
 repeat:

     assign i_num = i_num + 1. 

     if i_num =  46  or
        i_num =  95  or
        i_num >= 65  and
        i_num <= 90  or
        i_num >= 97  and
        i_num <= 122 
     then do:
             create tt-letras.
             assign tt-letras.tipo  = "P"
                    tt-letras.letra = chr(i_num).
     end.               

     if i_num > 122
     then leave.
     
 end.   
    
 assign i_num = 0.      
 repeat:

     assign i_num = i_num + 1. 

     if i_num =  45  or
        i_num =  95  or
        i_num >= 65  and
        i_num <= 90  or
        i_num >= 97  and
        i_num <= 122 
     then do:
             create tt-letras.
             assign tt-letras.tipo  = "S"
                    tt-letras.letra = chr(i_num).
     end.               

     if i_num > 122
     then leave.
     
 end.        
         
end procedure.
