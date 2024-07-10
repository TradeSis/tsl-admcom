{admcab.i}

def var varquivo as char format "x(15)".
def stream stela.
def var vsit as char format "x(15)".
def var vdti like plani.pladat.
def var fila as char.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vesc as log format "Emitente/Destinatario".
def var vetb like estab.etbcod.
def var vprocod like produ.procod.
def var vops as log format "Suprimento/Ativo" initial yes.


def new shared temp-table tt-plani
    field etbcod like plani.etbcod
    field pladat like plani.pladat  
    field procod like produ.procod
    field pronom like produ.pronom
    field movqtm like movim.movqtm
    field movpc  like movim.movpc
    field platot like plani.platot
    field datexp like plani.datexp format "99/99/9999" 
    field emite  like plani.emite 
    field desti  like plani.desti
    field numero like plani.numero format ">>>>>>9"
    field notant like plani.numero format ">>>>>>9"
    field serie  like plani.serie  
    field placod like plani.placod
    field confi  as char format "x(15)".

 
    
if opsys = "unix"
   then do:
   find first impress where impress.codimp = setbcod no-lock no-error.
   if avail impress
      then assign fila = string(impress.dfimp). 
   end.                    
     else assign fila = "". 

repeat:

    for each tt-plani:
        delete tt-plani.
    end.
    
    vetb = 0.
    update vetbcod label "Filial" with frame f1 side-label.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        disp estab.etbnom no-label with frame f1 width 80.
    end.
    
    update vdti label "Data Inicial" colon 13
           vdtf label "Data Final"
           /* vesc label "Consulta"  */
           /* vetb label "Estabelecimento" */
           with frame f1.
    vprocod = 0.
    update vprocod label "Produto" at 1
                with frame f1.
                
    if vprocod = 0
    then display "GERAL" @ produ.pronom with frame f1. 
    else do:
        find produ where produ.procod = vprocod no-lock.
        display produ.pronom no-label with frame f1.
    end. 
    update vops label "Filtro" with frame f1.
    
            
    if vesc
    then do:
        for each estab where if vetbcod = 0
                             then true
                             else estab.etbcod = vetbcod no-lock:
            for each plani where plani.movtdc = 9 and
                                 plani.etbcod = estab.etbcod and
                                 plani.serie  = "u"   and 
                                 plani.pladat >= vdti and
                                 plani.pladat <= vdtf no-lock:
      
                if vetb <> 0
                then if vetb <> plani.desti
                     then next.
            
        
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.placod = plani.placod no-lock:
                                     

                    if vprocod = 0
                    then.
                    else if movim.procod <> vprocod
                         then next.
                         
                    find produ where produ.procod = movim.procod no-lock.
                    if vops 
                    then if substring(produ.prouncom,1,1) = "S"
                         then.
                         else next.
                    if vops = no
                    then if substring(produ.prouncom,1,1) = "A"
                         then.
                         else next.
                         
                         
                    

                    create tt-plani.
                    assign tt-plani.etbcod = plani.etbcod
                           tt-plani.procod = movim.procod 
                           tt-plani.pronom = produ.pronom
                           tt-plani.platot = (movim.movpc * movim.movqtm)
                           tt-plani.movqtm = movim.movqtm
                           tt-plani.movpc  = movim.movpc
                           tt-plani.pladat = plani.pladat  
                           tt-plani.datexp = plani.datexp
                           tt-plani.emite  = plani.emite 
                           tt-plani.desti  = plani.desti
                           tt-plani.numero = plani.numero 
                           tt-plani.notant = plani.nottran
                           tt-plani.serie  = plani.serie  
                           tt-plani.placod = plani.placod
                           tt-plani.confi  = vsit.

                    find estoq where estoq.etbcod = 996 and
                                     estoq.procod = produ.procod no-lock no-error.
                    if avail estoq
                    then assign tt-plani.platot = (estoq.estcusto * movim.movqtm)
                                tt-plani.movpc  = estoq.estcusto.

                end.            

            end.
        end.    
    end.
    else do:
    
        for each estab where if vetbcod = 0
                             then true
                             else estab.etbcod = vetbcod no-lock:
    
            for each plani where plani.movtdc = 9 and
                                 plani.desti  = estab.etbcod and
                                 plani.serie  = "U" and
                                 plani.pladat >= vdti and
                                 plani.pladat <= vdtf no-lock:
      
                if vetb <> 0
                then if vetb <> plani.emite
                     then next.
                
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.placod = plani.placod no-lock:

                    if vprocod = 0
                    then.
                    else if movim.procod <> vprocod
                         then next.
     
                    find produ where produ.procod = movim.procod no-lock.
                    
                    if vops 
                    then if substring(produ.prouncom,1,1) = "S"
                         then.
                         else next.
                    if vops = no
                    then if substring(produ.prouncom,1,1) = "A"
                         then.
                         else next.

                    create tt-plani.
                    assign tt-plani.etbcod = plani.etbcod
                           tt-plani.procod = movim.procod
                           tt-plani.pronom = produ.pronom
                           tt-plani.platot = (movim.movpc * movim.movqtm)
                           tt-plani.movqtm = movim.movqtm
                           tt-plani.movpc  = movim.movpc
                           tt-plani.pladat = plani.pladat  
                           tt-plani.datexp = plani.datexp
                           tt-plani.emite  = plani.emite 
                           tt-plani.desti  = plani.desti
                           tt-plani.numero = plani.numero 
                           tt-plani.notant = plani.nottran
                           tt-plani.serie  = plani.serie  
                           tt-plani.placod = plani.placod
                           tt-plani.confi  = vsit.
                    find estoq where estoq.etbcod = 996 and
                                     estoq.procod = produ.procod no-lock no-error.
                    if avail estoq
                    then assign tt-plani.platot = (estoq.estcusto * movim.movqtm)
                                tt-plani.movpc  = estoq.estcusto.
                                     
                           
                end.            
                 
            end.
        
        end.
        
    end.


    run confir_3.p (input vetbcod,
                    input vdti,
                    input vdtf).


end.

 