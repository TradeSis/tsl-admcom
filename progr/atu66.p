/****
for each gerloja.estab:
    display "deletando..." gerloja.estab.etbcod with 1 down. pause 0.
    
    do transaction:
        delete gerloja.estab.
    end.

end.

for each ger.estab no-lock.

    display "Importando..." ger.estab.etbcod with 1 down. pause 0.
        
    create gerloja.estab.
    {tt-estab.i gerloja.estab ger.estab}.
        
end.
***********/
            
for each ger.estab no-lock.

    display "Atualizando..." ger.estab.etbcod with 1 down. pause 0.
    
    find first gerloja.estab where gerloja.estab.etbcod = ger.estab.etbcod.
                       
    if not avail gerloja.estab
    then create gerloja.estab.
    
    {tt-estab.i gerloja.estab ger.estab}.
            
end.
            


        