{admcab.i}
def var vclacod like clase.clacod.
def var vclasup like clase.clasup.
def buffer bclase for clase.
def var fila as char.


def new shared temp-table tt-produ
    field fabcod like fabri.fabcod
    field procod like produ.procod
    field pronom like produ.pronom
    field estemp like estoq.estatual
    field estatual like estoq.estatual
    field estvenda like estoq.estvenda
    field clacod   like clase.clacod
        index ind-1 pronom.
    
    
def var totest     like estoq.estatual.
def var vfabcod    like fabri.fabcod.
def var vcatcod     like categoria.catcod.
def var varquivo    as char format "X(20)". 


repeat:

    for each tt-produ:
        delete tt-produ.
    end.
        
    update vcatcod label "Departamento" colon 15 with frame f-for.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-for.


    
    update vfabcod label "Fornecedor" colon 15
                            with frame f-for centered side-label
                                                    color white/red row 4.
    if vfabcod = 0
    then display "GERAL" @ fabri.fabnom with frame f-for.
    else do:
        find fabri where fabri.fabcod = vfabcod no-lock.
        disp fabri.fabnom no-label with frame f-for.
    end.
    
    update vclacod label "Classe" colon 15 with frame f-for.
    if vclacod = 0
    then display "GERAL" @ clase.clanom with frame f-for.
    else do:
        find clase where clase.clacod = vclacod no-lock.
        display clase.clanom no-label with frame f-for.
    end.
 


    for each clase where (if vclacod = 0
                          then true
                          else clase.clacod = vclacod) no-lock,
        each produ where produ.catcod = vcatcod and
                         produ.clacod = clase.clacod no-lock:
         
        if vfabcod = 0
        then.
        else if vfabcod <> produ.fabcod
             then next.
        
        totest = 0.
        for each estoq where estoq.procod = produ.procod no-lock:
            totest = totest + estoq.estatual.
        end.
        if totest <= 0
        then next.
    
        find estoq where estoq.etbcod = setbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq 
        then next.

        find first tt-produ where tt-produ.procod = produ.procod no-error.
        if not avail tt-produ
        then do: 
            create tt-produ.
            assign tt-produ.fabcod   = vfabcod
                   tt-produ.procod   = produ.procod
                   tt-produ.clacod   = vclacod
                   tt-produ.pronom   = produ.pronom
                   tt-produ.estemp   = totest
                   tt-produ.estatual = estoq.estatual
                   tt-produ.estvenda = estoq.estvenda.
        end.    
    end.
    
    run tt-produ.p.

end.
        
   


