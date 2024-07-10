/* Este programa deleta um celular que foi lanáado com erro no sistema
de habilitaá‰es. Deleta na matriz e na filial. */

{admcab.i}

def var vetbcod like ger.estab.etbcod.
def var vcelular like adm.habil.celular format "x(14)".
def var ip   as char format "x(15)".

repeat:    
    
    if connected ("admloja")
    then disconnect admloja.
    
 update vetbcod label "Filial" with frame f1 side-label width 80.
   find estab where estab.etbcod = vetbcod no-lock no-error.
   if not avail estab
    then do:
            message "Filial n∆o Cadastrada.".
    undo, retry.
 end.
 
 update vcelular label "Celular"     with frame f1.
 update ip       label "IP - Filial" with frame f1.
 
 message "Conectando...". hide message no-pause.
 connect adm -H value(ip) -S sadm -N tcp -ld admloja.
    
    if not connected ("admloja")
    then do:
        message "Banco nao conectado".
        undo, retry.    
    end.
    
   run dhabil1.p(input vetbcod,
            input vcelular).
     
     
   if connected ("admloja")
   then disconnect admloja.
end.
 
  