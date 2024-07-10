def input parameter vetbcod like estab.etbcod.

pause 0 before-hide.

message "Deletando...".
for each finloja.tabjur:
    delete finloja.tabjur.
end.

message "Copiando...".
for each fin.tabjur where fin.tabjur.etbcod = vetbcod no-lock:
    message finloja.tabjur.nrdias.         
    find finloja.tabjur where finloja.tabjur.nrdias = fin.tabjur.nrdias
         no-error.
    if not avail finloja.tabjur
    then do.
        create finloja.tabjur.
        assign
            finloja.tabjur.nrdias = fin.tabjur.nrdias.
    end.
    assign
        finloja.tabjur.fator  = fin.tabjur.fator.
end.        
hide message no-pause.
message "Concluido" view-as alert-box.

