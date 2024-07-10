{admcab.i }

setbcod = 900.

if setbcod <> 995 and
   setbcod <> 900
then return.
   
def var vprocod like produ.procod.
def var vetbcod like estab.etbcod.
def var vqtd    as int.
def var vetb    like estab.etbcod.
def var vpednum like pedid.pednum.

repeat:
    
    update vprocod label "Produto"
            with frame f1 side-label width 80.
            
    find produ where produ.procod = vprocod no-lock no-error.
    if not avail produ
    then do:
        display "Produto nao cadastrado".
        pause.
        undo, retry.
    end.
    if produ.catcod <> 91
      then do:
          message "Distribuicao de Moda deve ser realizado Pedido Comercial".
        undo.
        end.


	display produ.pronom no-label with frame f1.
    
    vetbcod = vetb + 1.

    update vetbcod label "Filial " with frame f1. 
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    
    update vqtd    label "Qtd    " at 1
             validate(vqtd > 0, "Quantidade Invalida") 
                with frame f1. 
    vetb = estab.etbcod.    
    message "Confirma Distribuicao" update sresp.
    if sresp
    then do: 
        vpednum = 0. 
        find last pedid use-index ped
                 where pedid.etbcod = estab.etbcod and  
                       pedid.pedtdc = 5  no-lock no-error.
        
        if not avail pedid 
        then vpednum = 1. 
        else vpednum = pedid.pednum + 1.
                        
        find dispro where dispro.etbcod = estab.etbcod and 
                          dispro.pednum = vpednum      and 
                          dispro.dtenvwms = ?          and 
                          dispro.dtretwms = ?          and
                          dispro.procod = produ.procod no-error.
        if true /*not avail dispro */
        then do transaction: 
        
            create dispro. 
            assign dispro.etbcod = estab.etbcod 
                   dispro.pednum = vpednum 
                   dispro.disdat = today 
                   dispro.procod = produ.procod
                   dispro.disqtd = vqtd
                   dispro.situacao = "WMS" 
                   dispro.dtenvwms = ? 
                   dispro.dtretwms = ?
                   dispro.datexp = today.
                                   
        end.
        else do transaction:
            dispro.disqtd = dispro.disqtd + vqtd.
            dispro.situacao = "WMS". 
            dispro.dtenvwms = ?. 
            dispro.dtretwms = ?.
        end.    
        if setbcod = 995
        then run alcis_dstrh.p (produ.procod).   
        else if setbcod = 900
            then run alcis_dstrh-900.p (produ.procod). 
    end.
end.
        
