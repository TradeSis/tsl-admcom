{admcab.i new}
def buffer btabmix for tabmix.
sresp = no.
message "Confirma recalculo geral do MIX ?" update sresp.
if not sresp then return.
for each produ where catcod = 31 no-lock:
    for each tabmix where
                    tabmix.tipomix = "M" and
                    tabmix.etbcod > 0
                    no-lock by etbcod:
        if tabmix.descmix <> "MIX - " + string(tabmix.etbcod,"999")
        then next.
         
        find first btabmix where
                   btabmix.tipomix = "P" and
                   btabmix.codmix = tabmix.codmix and
                   btabmix.etbcod = 0 and
                   btabmix.promix = produ.procod
                   no-lock no-error.
        if avail btabmix
        then do:          
            find first produaux where produaux.procod = produ.procod and
                        produaux.nome_campo = "MIX" and 
                        produaux.valor_campo begins string(tabmix.etbcod,"999")
                        no-lock no-error.
            if not avail produaux
            then do:
                run expmix01.p(input btabmix.codmix, produ.procod).
            end.
        end.
        else do:
            find first produaux where produaux.procod = produ.procod and
                produaux.nome_campo = "MIX" and
                produaux.valor_campo begins string(tabmix.etbcod,"999")
                 no-error.
            if avail produaux and
                entry(2,produaux.valor_campo,",") = "Sim"
            then  produaux.valor_campo = string(tabmix.etbcod,"999") + ",Nao". 
        end.
    end.
end.                        
