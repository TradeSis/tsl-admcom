/*** NAO E MAIS USADO ***/

{/admcom/progr/admcab-batch.i new}
setbcod = 999.
sfuncod = 101.

FUNCTION acha-pro returns character
    (input par-oque as char,
     input par-onde as char,
     input par-proc as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"|"). 
        if entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"="). 
            if vret = par-proc
            then leave. 
        end. 
    end.
    return vret. 
END FUNCTION.
 
def var p-ok as log.
def var v-peda as log.
def var p-sugerido as dec.
def var vmovqtm as dec.
def var qtd-conjunto as dec.
def var vpednum like pedid.pednum.

def buffer bpedid for pedid.

def temp-table tt-proped
    field etbcod like estab.etbcod
    field pladat like plani.pladat
    field placod like plani.placod
    field numero like plani.numero
    field procod like produ.procod
    field movqtm like movim.movqtm
    field sugere like p-sugerido.  

def var varqlog as char.
varqlog = "/admcom/logs/ped-aut-" + string(day(today),"99") +
            string(month(today),"99") + string(year(today),"9999").

for each estab where estab.etbnom begins "DREBES-FIL" no-lock:
    /*if estab.etbcod <> 59 and
       estab.etbcod <> 30
    then next.
    */
    setbcod = estab.etbcod.

    for each tt-proped: delete tt-proped. end.
    for each plani where plani.movtdc = 5 and
             plani.etbcod = estab.etbcod and
             plani.pladat = today  
             no-lock:
        for each movim where movim.etbcod = plani.etbco and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat
                             no-lock:
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ then next.
            if produ.procod = 10000 then next.
            if produ.catcod <> 31 then next.    
            if produ.pronom matches "*RECARGA*"  or
               produ.pronom matches "*FRETEIRO*" /*or
                   com.produ.pronom begins "*"  */
            then next.

            if movim.ocnum[9] = movim.placod
            then next.
                                            
            p-ok = no.
            p-sugerido = 0.
            vmovqtm = 0.
            qtd-conjunto = 0.
            run vercobertura-aut.p (input movim.procod,
                                    input movim.movqtm,
                                    output p-ok,
                                    output p-sugerido,
                                    output vmovqtm,
                                    output qtd-conjunto).
            if p-ok = no then next.
            
            v-peda = no.
            for each liped where liped.etbcod = movim.etbcod and
                                 liped.procod = movim.procod and
                                 liped.pedtdc = 3 and
                                 liped.predt  >= plani.pladat
                                 no-lock,
                first pedid of liped where 
                            pedid.modcod = "PEDA" and
                            pedid.peddat = plani.pladat no-lock:
                if movim.procod =
                        int(acha-pro(string(plani.placod),pedid.pedobs[5],
                                string(movim.procod)))
                then do:
                    v-peda = yes.
                    leave.
                end.
                else do:
                    create tt-proped.
                    assign
                        tt-proped.etbcod = plani.etbcod
                        tt-proped.pladat = plani.pladat
                        tt-proped.placod = plani.placod
                        tt-proped.numero = plani.numero
                        tt-proped.procod = movim.procod
                        tt-proped.movqtm = movim.movqtm
                        tt-proped.sugere = p-sugerido.
                end.
            end.
            if v-peda = no
            then do transaction:
                find last pedid where pedid.pedtdc = 3 and
                           pedid.sitped = "E" and
                           pedid.etbcod = movim.etbcod and
                           pedid.pednum >= 100000 and
                           pedid.peddat = today and
                           pedid.modcod = "PEDA"
                           no-error.
                if not avail pedid
                then do:
                     find last bpedid where bpedid.pedtdc = 3 and
                               bpedid.etbcod = movim.etbcod  and
                               bpedid.pednum >= 100000 no-error.
                     if avail bpedid
                     then vpednum = bpedid.pednum + 1.
                     else vpednum = 100000.
                     create pedid.
                     assign pedid.etbcod = movim.etbcod
                            pedid.pedtdc = 3
                            pedid.peddat = today
                            pedid.pednum = vpednum
                            pedid.sitped = "E"
                            pedid.modcod = "PEDA"
                            pedid.pedsit = yes.
                   
                end.
                find first liped where 
                           liped.etbcod = pedid.etbcod and
                           liped.pedtdc = pedid.pedtdc and
                           liped.pednum = pedid.pednum and
                           liped.procod = movim.procod no-error.
                if not avail liped
                then do:
                    create liped.
                    assign liped.pedtdc    = pedid.pedtdc
                           liped.pednum    = pedid.pednum
                           liped.procod    = movim.procod
                           liped.lippreco  = movim.movpc
                           liped.lipsit    = "Z"
                           liped.predtf    = pedid.peddat
                           liped.predt     = pedid.peddat
                           liped.etbcod    = pedid.etbcod
                           liped.protip    = string(movim.movhr).
                end.
                if qtd-conjunto > 0
                then liped.lipqtd = liped.lipqtd + p-sugerido.
                else liped.lipqtd = liped.lipqtd + movim.movqtm.
                                        
                pedid.pedobs[5] = pedid.pedobs[5] +
                     string(movim.placod) + "=" + string(movim.procod) + "|".
            end.
        end.
        output to value(varqlog) append.
        for each tt-proped:
            export tt-proped.
        end.
        output close.
        for each tt-proped:
            delete tt-proped.
        end.
    end.
end.
