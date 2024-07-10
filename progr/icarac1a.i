/* ****************************************************
*  Programa......: icarac1a.i
*  Funcao........: Bloqueia caracater especial
*  Data..........: 31/07/2006
*  Autor.........: Gerson Mathias
**************************************************** */

def var cText1     as char form "x(70)"  init "".
def var cCara1     as char form "x(01)"  init "".
def var iCont1     as inte               init 0.
def var lErro1     as logi               init no.

assign cText1 = {1}.

do iCont1 = 1 to length(cText1):
  
   if substring(cText1,iCont1,1) >= chr(001) and
      substring(cText1,iCont1,1) <= chr(031) or
      substring(cText1,iCont1,1) >= chr(033) and
      substring(cText1,iCont1,1) <= chr(064) or
      substring(cText1,iCont1,1) >= chr(091) and
      substring(cText1,iCont1,1) <= chr(096) or
      substring(cText1,iCont1,1) >= chr(123) 
   then do:
   
           message substring(cText1,iCont1,1)  skip
                   string(iCont1)  view-as alert-box. 
           assign lErro1 = yes
                  cCara1 = substring(cText1,iCont1,1).
           leave.       
   end.        
                  
end.

if lErro1 = yes 
then do:
        message "CARACTER INVALIDO NO CAMPO NOME" skip
                "( " + cCara1 + " ) " view-as alert-box.
        undo, retry.
end.        
