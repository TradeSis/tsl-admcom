def var sresp as log format "Sim/Nao".
def input parameter vetbcod like estab.etbcod.
def input parameter vdata   like plani.pladat.
def input parameter n-env   as int.


find finloja.depban where finloja.depban.etbcod = vetbcod and
                          finloja.depban.datexp = vdata   and
                          finloja.depban.dephora = n-env no-error.
if avail finloja.depban
then do:
                          
                              
    disp finloja.depban.
                              
    message "Excluir Deposito" update sresp.
    
    if sresp
    then do:
        
        delete finloja.depban.
        
        find fin.depban where fin.depban.etbcod = vetbcod and
                              fin.depban.datexp = vdata   and
                              fin.depban.dephora = n-env no-error.
        if avail fin.depban
        then do:
            delete fin.depban.
        end.
        
    end.    
    
end.    
else do:
    message "Este deposito nao existe na loja, excluir na matriz" 
            update sresp.
    if sresp
    then do:
        
        find fin.depban where fin.depban.etbcod = vetbcod and
                              fin.depban.datexp = vdata   and
                              fin.depban.dephora = n-env no-error.
        if avail fin.depban
        then do:
            delete fin.depban.
        end.
    end.
    
end.    
        
        
         

                       
