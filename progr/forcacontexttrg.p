def buffer bcontexttrg for contexttrg.
def buffer oldplani for plani.

for each plani where  
        plani.movtdc = 5 and
        plani.etbcod = 200 and 
        plani.dtinclu >= today - 90
    no-lock.

    find bcontextTRG where bcontextTRG.movtdc = plani.movtdc and
                          bcontextTRG.tabela = 'PLANI' and 
                          bcontextTRG.trecid = Recid(plani)
        no-lock no-error.
    if avail bcontextTRG
    then next.

    {/admcom/progr/contexttrg.i
         &tabela =   Plani
         &old    =   oldPlani }
    
end.    
                                      

