def var vexp as log.
def stream contrato. output stream contrato to /dados/dump/contrato.d.
def stream titulo .  output stream titulo to /dados/dump/titulo.d.

def var vtotal as int.
def var vexportado as int.
def var vnaoexportado as int.
pause 0 before-hide.     

form with frame f.
for each contrato
 no-lock with frame f.

    vtotal = vtotal + 1.
    
 /*   disp vtotal with 1 col. */
    
    vexp = no.
    
    if contrato.dtinicial >= 01/01/2002
    then vexp = yes.
    
    
    disp /* contrato.contnum */ contrato.dtinicial format "99/99/9999".
    if not vexp
    then do:
        for each titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = "CRE"and
                          titulo.etbcod = contrato.etbcod and
                          titulo.clifor = contrato.clicod and
                          titulo.titnum = string(contrato.contnum) no-lock.
        if titulo.titsit = "LIB"
        then vexp = yes.
        /*
        disp titulo.titnum titulo.titpar titsit vexp .
        */
        end.
    end.
    
    if vexp = no
    then do:
        vnaoexportado = vnaoexportado + 1.
      /*  disp vnaoexportado. */
        next.
    end.
    

    export stream contrato contrato.
    
    for each titulo where titulo.empcod = 19 and
                               titulo.titnat = no and
                               titulo.modcod = "CRE"and
                               titulo.etbcod = contrato.etbcod and
                               titulo.clifor = contrato.clicod and
                               titulo.titnum = string(contrato.contnum) 
                               no-lock.
            export stream titulo titulo.

    end.
    vexportado = vexportado + 1.
    disp vexportado.
  end.


output stream contrato close.
output stream titulo close.
