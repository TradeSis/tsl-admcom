{admcab.i}
def var vv as char format "x(01)".
def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var vativo  as log.
def var vprocod like produ.procod.


def temp-table tt-caixa
    field etbcod like estab.etbcod
    field cxacod like serial.cxacod
    field tot    like plani.platot.


def var ven07 as dec.
def var ven12 as dec.
def var ven17  as dec.
def var vensub as dec.
def var totven as dec.
def var bas12  as dec.
def var bas17  as dec.
def var icm17  as dec. 


def var i as i.


def var vok as l.
def var xx as i.
def var vred as int.
def var valcon as dec.
def var valicm as dec.
def var varquivo as char format "x(20)".
def var vlinha as char format "x(25)".
def  var vcont as int.
def var vcxacod like caixa.cxacod.
def var vdia    as int format "99".
def var vmes    as int format "99".

def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vdata as date format "99/99/9999".

def var vetbcod like estab.etbcod.


def new shared temp-table tt-map
    field t-datmov like mapctb.datmov
    field t-sit    as char format "x(15)"
    field t-etbcod like estab.etbcod
    field t-equipa as int format "99"
    field t-cxacod as int format "99"
    field t-cxa    as char format "x(15)"
        index ind-1 t-etbcod
                    t-cxacod.
         

repeat:

            
    for each tt-map:
        delete tt-map.
    end.        
    
    vdti = today.
    vdtf = today.
    
    vetbcod = 0.
    update vetbcod label "Filial" with frame f1 side-label width 80.
    if vetbcod = 0
    then display "TODAS" @ estab.etbnom with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Filial nao cadastrada".
            pause.
            undo, retry.
        end.
        display estab.etbnom no-label with frame f1.
            
    end.
 
    update vdti label "Periodo" 
           vdtf no-label with frame f1.
     
    for each tt-caixa:
        delete tt-caixa.
    end.
    
      
    do vdata = vdti to vdtf:

        for each tabecf where if vetbcod <> 0
                              then tabecf.etbcod = vetbcod
                              else true no-lock,
            each estab where estab.etbcod = tabecf.etbcod no-lock:
                             
            find first plani where plani.etbcod = estab.etbcod and
                                   plani.movtdc = 05           and
                                   plani.pladat = vdata        and
                                   plani.cxacod = tabecf.de1
                                        no-lock no-error.
            if avail plani
            then do: 
            
                find first mapctb where mapctb.etbcod = plani.etbcod and
                                        mapctb.datmov = plani.pladat and
                                        mapctb.de1    = dec(plani.cxacod)
                                            no-lock no-error.
                if not avail mapctb
                then do:
                    find first tt-map where tt-map.t-etbcod = estab.etbcod and
                                            tt-map.t-equipa = tabecf.equipa
                                                no-error.
                    if not avail tt-map
                    then do:
                   
                     
                        create tt-map.
                        assign tt-map.t-etbcod = estab.etbcod
                               tt-map.t-equipa = tabecf.equipa
                               tt-map.t-cxacod   = plani.cxacod 
                               tt-map.t-sit    = "Problema".
                               
                        find deposito where deposito.etbcod = estab.etbcod and
                                            deposito.datmov = vdata 
                                                        no-lock no-error.
                        if avail deposito
                        then tt-map.t-cxa  = "Fechado".
                        else tt-map.t-cxa  = "Aberto".
                    end.
                end.
                else do:
                    find first tt-map where tt-map.t-etbcod = estab.etbcod and
                                            tt-map.t-equipa = tabecf.equipa
                                                no-error.
                    if not avail tt-map
                    then do:
                        create tt-map.
                        assign tt-map.t-etbcod = estab.etbcod
                               tt-map.t-equipa = tabecf.equipa
                               tt-map.t-cxacod = plani.cxacod
                               tt-map.t-sit    = "OK".
                               
                        find deposito where deposito.etbcod = estab.etbcod and
                                            deposito.datmov = vdata 
                                                        no-lock no-error.
                        if avail deposito
                        then tt-map.t-cxa  = "Fechado".
                        else tt-map.t-cxa  = "Aberto".
                    end.
                end.
            end.
        end.                                
           
    end.       

    run tt-map.p (input vdti,
                  input vdtf).
       
end.    
