def input param ptipoOperacao as char.
def input param pvalorParcela as dec.
def input param pqtdParcelas as int.
def input param pvalorAcrescimo as dec.
def output param pcobcod as int.

            
pcobcod = 1.
            
    for each cobparam where 
            cobparam.tipoOperacao = ptipoOperacao and  
            cobparam.valMinParc   <= pvalorParcela and 
            cobparam.qtdMinParc   <= pqtdParcelas and  
            cobparam.valorMinimoAcrescimoTotal <= pvalorAcrescimo 
            no-lock by             
                cobparam.valorMinimoAcrescimoTotal desc.   
    
        find cobra of cobparam no-lock no-error. 
        if avail cobra
        then pcobcod = cobra.cobcod.
        leave. 
        
    end.    
                                                                                                         