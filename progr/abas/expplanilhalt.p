def var veminom as char format "x(35)".
def var vcp     as char init ";".
def var varquivo as char format "x(50)".

varquivo = "/admcom/tmp/expabasneogrid/leadtimecalc1.csv".

update varquivo label "Arquivo" with side-labels.

output to value(varquivo).
    put unformatted
        "Codigo_produto"  vcp
        "Nome_produto"        vcp
        "Codigo_Estab"  vcp
        "Nome_Estab"       vcp
        "Codigo_Forne"   vcp
        "Nome_Forne"        vcp
        "LeadTime_Calculado"
        
        skip.

for each abasresoper no-lock.

    find estab of abasresoper no-lock.
    find produ of abasresoper no-lock.
    
    veminom = "".
    if abasresoper.etbcod >= 500
    then do:
        find forne where forne.forcod = abasresoper.emite no-lock.
        veminom = forne.fornom.
    end.
    else do:
        next.
            /*
        find estab where estab.etbcod = abasresoper.emite no-lock.
        veminom = estab.etbnom.
        */
    end.
    put unformatted
        abasresoper.procod  vcp
        replace(produ.pronom,";"," ")        vcp
        abasresoper.etbcod  vcp
        replace(estab.etbnom,";"," ")        vcp
        abasresoper.emite   vcp
        replace(veminom,";"," ")             vcp
        trim(replace(string(abasresoper.leadtime,">>>>>9.99"),".",","))
        
        skip.
end.        
output close. 

