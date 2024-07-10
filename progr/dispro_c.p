{admcab.i}
def var vprocod like produ.procod.
def var vetbcod like estab.etbcod.
def var vqtd    as int.
def var vetb    like estab.etbcod.
def var vpednum like pedid.pednum.
repeat:
    
    update vetbcod label "Filial " 
                with frame f1 side-label width 80. 
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    
    vpednum = 0.  
    find last pedid use-index ped 
                where pedid.etbcod = estab.etbcod and  
                      pedid.pedtdc = 5  no-lock no-error.
        
    if not avail pedid  
    then vpednum = 1.  
    else vpednum = pedid.pednum + 1.
                                        
                        
    for each dispro where dispro.etbcod = estab.etbcod and 
                          dispro.pednum = vpednum      and
                          dispro.disqtd > 0 no-lock:
        find produ where produ.procod = dispro.procod no-lock.
        display dispro.pednum
                produ.procod
                produ.pronom format "x(30)"
                dispro.disqtd column-label "Qtd.Distr." format ">>>>>9"
                dispro.datexp format "99/99/9999" column-label "Inclusao"
                    with frame f-lista down centered.

    end.
end.
        
            
        
