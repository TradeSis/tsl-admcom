{admcab.i}
def var vetbcod like estab.etbcod.
def var vdti    like plani.pladat.
def var vdtf    like plani.pladat.
def var vdata   like plani.pladat.

def new shared temp-table tt-cup
    field etbcod like estab.etbcod
    field datmov like plani.pladat
    field cxacod like plani.cxacod
    field flag   as log format "Fechado/Aberto".

repeat:


    for each tt-cup.
        delete tt-cup.
    end.
        
        
    vetbcod = 0.
    vdti = today.
    vdtf = today.
    
    update vetbcod label "Filial " at 1
                    with frame f1 side-label width 80.
                    
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label with frame f1.
    end.

    update vdti label "Periodo" 
           vdtf no-label with frame f1.
           
    do vdata = vdti to vdtf:

        for each estab where if vetbcod <> 0
                             then estab.etbcod = vetbcod
                             else true no-lock:
                             
            find first plani where plani.etbcod = estab.etbcod and
                                   plani.movtdc = 05           and
                                   plani.pladat = vdata
                                        no-lock no-error.
            if avail plani
            then do: 
            
                find first mapcxa where mapcxa.etbcod = plani.etbcod and
                                        mapcxa.datmov = plani.pladat and
                                        mapcxa.de1    = dec(plani.cxacod)
                                            no-lock no-error.
                if not avail mapcxa
                then do:
                                            
                    find first tt-cup where tt-cup.etbcod = estab.etbcod and
                                            tt-cup.datmov = plani.pladat
                                                no-error.
                    if not avail tt-cup
                    then do:
                   
                        create tt-cup.
                        assign tt-cup.etbcod = estab.etbcod
                               tt-cup.datmov = plani.pladat
                               tt-cup.cxacod = plani.cxacod.
                        find deposito where deposito.etbcod = plani.etbcod and
                                            deposito.datmov = plani.pladat 
                                                   no-lock no-error.
                        if avail deposito
                        then tt-cup.flag = yes.
                        else tt-cup.flag = no.
                           
                    end.
                    
                end.
                                            
            
            end.
        end.                                
           
    end.       
    
    run tt-cup.p.
           
           
           
end.            
            
            
