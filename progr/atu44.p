def input parameter vetbcod like estab.etbcod.

def input parameter resp_dat as log.
def input parameter vdti    like com.plani.pladat.
def input parameter vdtf    like com.plani.pladat.

def input parameter resp_pro as log.
def input parameter vprocod-1 like com.produ.procod format ">>>>>>>>>".
def input parameter vprocod-2 like com.produ.procod format ">>>>>>>>>".


if resp_dat
then do:
    for each com.produ where com.produ.datexp >= vdti and
                             com.produ.datexp <= vdtf no-lock.
                             
        display "Atualizando Produtos...."
                com.produ.procod format ">>>>>>>>9" no-label
                    with frame f1 1 down centered.
        pause 0.         
        
        find comloja.produ where comloja.produ.procod = com.produ.procod 
                                                                    no-error.
        if not avail comloja.produ
        then create comloja.produ.

        {produlj.i comloja.produ com.produ}.
    
        find com.estoq where com.estoq.etbcod = vetbcod and
                             com.estoq.procod = com.produ.procod 
                                        no-lock no-error.
        if not avail com.estoq
        then next.
                                         
                                   
        find comloja.estoq where comloja.estoq.etbcod = com.estoq.etbcod and
                                 comloja.estoq.procod = com.estoq.procod 
                                        no-error.

        if not avail comloja.estoq 
        then create comloja.estoq. 
    
        {estoq.i comloja.estoq com.estoq}. 
        
    end.
    
    for each com.estoq where com.estoq.etbcod = vetbcod
                         and com.estoq.datexp >= vdti and
                             com.estoq.datexp <= vdtf no-lock.

        find com.produ where 
             com.produ.procod = com.estoq.procod no-lock no-error.
        if not avail com.produ
        then next.

        display "Atualizando Produtos...."
                com.produ.procod format ">>>>>>>>9" no-label
                    with frame f1-b 1 down centered.
        pause 0.         
        
        find comloja.produ where 
             comloja.produ.procod = com.produ.procod no-error.

        if not avail comloja.produ
        then create comloja.produ.

        {produlj.i comloja.produ com.produ}.
    
        find comloja.estoq where comloja.estoq.etbcod = com.estoq.etbcod and
                                 comloja.estoq.procod = com.estoq.procod 
                                        no-error.

        if not avail comloja.estoq 
        then create comloja.estoq. 
    
        {estoq.i comloja.estoq com.estoq}. 
        
    end.
 


end.
else do:
    for each com.produ where if (vprocod-1 <> 0 and
                                 vprocod-2 <> 0)
                             then (com.produ.procod >= vprocod-1 and
                                   com.produ.procod <= vprocod-2)
                             else true no-lock.
                             
        display "Atualizando Produtos...."
                com.produ.procod format ">>>>>>>>9" no-label
                    with frame f2 1 down centered.
        pause 0.         
                               
    
        
        find comloja.produ where comloja.produ.procod = com.produ.procod 
                                                                    no-error.
        if not avail comloja.produ
        then create comloja.produ.

        {produlj.i comloja.produ com.produ}.
    
        find com.estoq where com.estoq.etbcod = vetbcod and
                             com.estoq.procod = com.produ.procod 
                                    no-lock no-error.
        if not avail com.estoq
        then next.
                                    
                                   
        find comloja.estoq where comloja.estoq.etbcod = com.estoq.etbcod and
                                 comloja.estoq.procod = com.estoq.procod 
                                        no-error.

        if not avail comloja.estoq 
        then create comloja.estoq. 
    
        {estoq.i comloja.estoq com.estoq}. 
        
    end.
    


end.
    
    



         

                       
