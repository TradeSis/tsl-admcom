disable triggers for load of finloja.titulo.
disable triggers for load of fin.titulo.
disable triggers for load of finloja.contrato.
disable triggers  for load of finloja.contnf.
disable triggers for load of comloja.plani.
disable triggers for load of comloja.movim.
def input parameter p-etbcod  like fin.contrato.etbcod.
def input parameter p-contnum like fin.contrato.contnum.
def input parameter vnovo like fin.contrato.clicod.
def output parameter tit-log as char.

def buffer contrato for finloja.contrato.
def buffer contnf   for finloja.contnf.
def buffer titulo   for finloja.titulo.
def buffer plani    for comloja.plani.
def buffer movim    for comloja.movim.
 
find contrato where
        contrato.contnum = p-contnum no-error.
if not avail contrato
then do:
     find fin.contrato where fin.contrato.contnum = p-contnum
                       no-lock no-error.
     if avail fin.contrato
     then do transaction:
          create contrato.
          buffer-copy fin.contrato to contrato.
          
          if not can-find(contnf where 
                     contnf.etbcod  = contrato.etbcod and
                     contnf.contnum = contrato.contnum) 
          then for each fin.contnf where fin.contnf.etbcod  = contrato.etbcod
                                     and fin.contnf.contnum = contrato.contnum
                                     no-lock:
                  
                   if not can-find(contnf where 
                             contnf.etbcod  = fin.contnf.etbcod and
                             contnf.placod  = fin.contnf.placod and
                             contnf.contnum = fin.contnf.contnum) 
                   then do:
                        create contnf.
                        buffer-copy fin.contnf to contnf. 
                   end.
              end.
        end.             
 end.

if not avail contrato
then do:
     tit-log = "Contrato " + string(p-contnum) + 
              " nao encontrado na filial".

end.
else do:
    for each contnf where 
             contnf.etbcod  = contrato.etbcod and
             contnf.contnum = contrato.contnum:
        find first plani where 
                   plani.etbcod = contnf.etbcod and
                   plani.placod = contnf.placod no-error.
        if avail plani
        then do:
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat:
                do transaction:
                    movim.desti = vnovo.
                end. 
                
            end.
            do transaction:
                plani.desti = vnovo.
            end.
        end.
    end.                           
    
    for each titulo where titulo.titnum = string(p-contnum) and
                          titulo.etbcod = p-etbcod and
                          titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.clifor = contrato.clicod and
                          titulo.modcod = "CRE".
        do transaction:
            titulo.clifor = vnovo.
            titulo.exportado = yes.
        end.
    end.
    do transaction:
        contrato.clicod = vnovo.
    end.
    tit-log = "Contrato " + string(contrato.contnum) + 
                        " alterado na filial".
end.