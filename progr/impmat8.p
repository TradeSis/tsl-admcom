def temp-table mat-titulo like titulo.

input from titulo.mat.8.
repeat.
    create mat-titulo.
    import mat-titulo.

    
            find first fin.titulo where 
                       fin.titulo.empcod = mat-titulo.empcod
                   and fin.titulo.titnat = mat-titulo.titnat 
                   and fin.titulo.modcod = mat-titulo.modcod 
                   and fin.titulo.etbcod = mat-titulo.etbcod 
                   and fin.titulo.clifor = mat-titulo.clifor 
                   and fin.titulo.titnum = mat-titulo.titnum 
                   and fin.titulo.titpar = mat-titulo.titpar
                       no-error.
            if not avail fin.titulo
            then create fin.titulo.

            if fin.titulo.titsit <> "PAG" 
            then do :
                {tt-titulo.i fin.titulo mat-titulo}.
            end.    
        
            assign 
                fin.titulo.exportado       = yes.
                
            find first fin.titulo where 
                       fin.titulo.empcod = mat-titulo.empcod
                   and fin.titulo.titnat = mat-titulo.titnat 
                   and fin.titulo.modcod = mat-titulo.modcod 
                   and fin.titulo.etbcod = mat-titulo.etbcod 
                   and fin.titulo.clifor = mat-titulo.clifor 
                   and fin.titulo.titnum = mat-titulo.titnum 
                   and fin.titulo.titpar = mat-titulo.titpar
                       no-error.
            if avail fin.titulo
            then do  :
                if fin.titulo.titsit = mat-titulo.titsit and
                   fin.titulo.titvlcob = mat-titulo.titvlcob and 
                   fin.titulo.titdtpag = mat-titulo.titdtpag 
                then mat-titulo.exportado = yes.
            end.      
        end.    
    
    delete mat-titulo.
    
end.

input close.