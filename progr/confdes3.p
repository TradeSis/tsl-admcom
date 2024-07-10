 def input parameter vrowid as row.
 
 def shared temp-table tt-diverg
    field empcod like fin.titluc.empcod
    field titnat like fin.titluc.titnat
    field modcod like fin.titluc.modcod
    field etbcod like fin.titluc.etbcod
    field clifor like fin.titluc.clifor
    field titnum like fin.titluc.titnum
    field titpar like fin.titluc.titpar
    field titsit like fin.titluc.titsit
    field titdtpag like fin.titluc.titdtpag 
    field titvlcob like fin.titluc.titvlcob    
    field obs    as char format "x(40)"
    index etbcod is primary
           etbcod
           titnum     
    index titnum is unique
           empcod
           titnat
           modcod
           etbcod
           CliFor
           titnum
           titpar.
   
   
   find tt-diverg where rowid(tt-diverg) = vrowid no-lock no-error.
   if not avail tt-diverg 
   then return.
   
   if tt-diverg.obs = "Nao encontrado na LP"
   then do:
        find fin.titluc where 
                             fin.titluc.empcod = tt-diverg.empcod and
                             fin.titluc.titnat = tt-diverg.titnat and
                             fin.titluc.modcod = tt-diverg.modcod and
                             fin.titluc.etbcod = tt-diverg.etbcod and
                             fin.titluc.clifor = tt-diverg.clifor and
                             fin.titluc.titnum = tt-diverg.titnum and
                             fin.titluc.titpar = tt-diverg.titpar
                             no-lock no-error.
            if avail fin.titluc
            then do:
                run paga-titluc.p (recid(fin.titluc)). 
            
               end.
    end.
    if tt-diverg.obs = "Nao encontrou titulo na Matriz" 
    then do:
         find finloja.titluc 
                       where finloja.titluc.empcod = tt-diverg.empcod and
                             finloja.titluc.titnat = tt-diverg.titnat and
                             finloja.titluc.modcod = tt-diverg.modcod and
                             finloja.titluc.etbcod = tt-diverg.etbcod and
                             finloja.titluc.clifor = tt-diverg.clifor and
                             finloja.titluc.titnum = tt-diverg.titnum and
                             finloja.titluc.titpar = tt-diverg.titpar
                             no-lock no-error.
            if avail finloja.titluc
            and finloja.titsit ="pag"
            then do:
                 create fin.titluc.
                 buffer-copy finloja.titluc to fin.titluc.
                 run paga-titluc.p (recid(fin.titluc)). 
           end.        
      end.
      
end procedure.
