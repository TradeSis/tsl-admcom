
output to titulo.mat.8.

for each estab where estab.etbcod = 8 no-lock : 
    
    for each finmatriz.titulo where 
             finmatriz.titulo.exportado = no and 
             finmatriz.titulo.etbcod = estab.etbcod
             use-index exportado. 
    
        if finmatriz.titulo.etbcobra = estab.etbcod 
        then next.        
         
        if finmatriz.titulo.titnat = yes
        then next.

        
        export titulo.
        
        titulo.exportado = yes.
        
    end. 

end.

output close.



