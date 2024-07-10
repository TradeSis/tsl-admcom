/* Projeto Melhorias Mix - Luciano    */
{/admcom/progr/admcab-batch.i new}

def var vseta as char.
vseta = SESSION:PARAMETER.
if vseta = "OK"
then.
else quit.                     

message "Programa desativado pela TI em 14/08/2014." .
do on error undo.        
    quit.
end.



def var sresp as log.
def var vestatual like estoq.estatual.
def var reserva like estoq.estatual.
def buffer bliped for liped.
def buffer bfestoq for estoq.
def temp-table tt-liped like liped.
def temp-table tt-estab like estab.
def var par-pedtdc like liped.pedtdc init 7.
def var setbcod-ant like setbcod.
setbcod-ant = setbcod.
for each estab no-lock:
    setbcod = estab.etbcod.
    for each pedid where pedid.etbcod = estab.etbcod and
                         pedid.pedtdc = par-pedtdc and
                         pedid.sitped = "A" and
                         pedid.peddat <= today
                         no-lock:
        for each bliped where bliped.pedtdc = pedid.pedtdc and
                             bliped.etbcod = pedid.etbcod and
                             bliped.pednum = pedid.pednum and
                             bliped.lipsit = "A"
                             .
            if bliped.predtf = ?
            then do transaction:
                delete bliped.
                next.
            end.
            find produ where produ.procod = bliped.procod no-lock no-error.
            if not avail produ then next.
            {tbcntgen6.i today}            
            if avail tbcntgen
            then do transaction:
                delete bliped.
                next.
            end.
            sresp = no.
            run tem-mix.p(input produ.procod,
                        output sresp).
            if sresp = no
            then do transaction:
                delete bliped.       
                next.
            end.
            if produ.clacod = 136 and
                   (estab.etbcod <> 7 or
                    estab.etbcod <> 8 or
                    estab.etbcod <> 15 or
                    estab.etbcod <> 33 or
                    estab.etbcod <> 39 or
                    estab.etbcod <> 72 or
                    estab.etbcod <> 41 or 
                    estab.etbcod <> 49 or
                    estab.etbcod <> 51 or
                    estab.etbcod <> 79 or
                    estab.etbcod <> 80 or
                    estab.etbcod <> 2 or
                    estab.etbcod <> 14 or
                    estab.etbcod <> 31 or
                    estab.etbcod <> 38 or
                    estab.etbcod <> 37)
            then do transaction:
                delete bliped.
                next.
            end.
 
            find bfestoq where bfestoq.etbcod = 900
                           and bfestoq.procod = produ.procod
                                no-lock no-error.

            find estoq where estoq.etbcod = 993 and
                     estoq.procod = produ.procod
                     no-lock.
                     
            vestatual = 0.
            run estoque-reserva.
            vestatual = estoq.estatual - reserva.
            
            if avail bfestoq
            then vestatual = vestatual + bfestoq.estatual.
            
            if  vestatual = 0
            then do transaction:
                delete bliped.
            end.
            else
            if bliped.lipqtd = ? and 
               bliped.predtf < today
            then do:   
                find first tt-estab where
                           tt-estab.etbcod = bliped.etbcod no-error.
                if not avail tt-estab
                then do:
                    create tt-estab.
                    tt-estab.etbcod = bliped.etbcod.
                end.            
                create tt-liped.
                buffer-copy bliped to tt-liped.
            end.
        end.        
    end.                     
end.
setbcod = setbcod-ant.
def buffer bpedid for pedid.
def buffer cpedid for pedid.
def buffer bestab for estab.
def buffer cliped for liped.
def var vpednum like pedid.pednum.
find first tt-liped where tt-liped.etbcod > 0 no-error.
if avail tt-liped
then do :
    for each tt-estab where tt-estab.etbcod > 0:
        find last bpedid where
                              bpedid.pedtdc = 3 and
                              bpedid.etbcod = tt-estab.etbcod  and
                              bpedid.pednum < 100000
                              no-error.
        if avail bpedid
        then vpednum = bpedid.pednum + 1.
        else vpednum = 1.
        find bestab where bestab.etbcod = tt-estab.etbcod no-lock.
        do transaction:
            create cpedid.
            assign
                        cpedid.etbcod = bestab.etbcod
                        cpedid.pedtdc = 3
                        cpedid.peddat = today
                        cpedid.pednum = vpednum
                        cpedid.sitped = "E"
                        cpedid.pedsit = yes
                        cpedid.regcod = bestab.regcod
                        cpedid.modcod = "PEDR".
        end.
        for each tt-liped where tt-liped.etbcod = bestab.etbcod :
            do transaction:
                create cliped.
    
                ASSIGN
                            cliped.pedtdc    = cpedid.pedtdc
                            cliped.pednum    = cpedid.pednum
                            cliped.procod    = tt-liped.procod
                            cliped.lippreco  = 0
                            cliped.lipsit    = "B"
                            cliped.predtf    = ?
                            cliped.predt     = cpedid.peddat
                            cliped.etbcod    = cpedid.etbcod
                            cliped.lipqtd    = 1
                            cliped.protip    = string(time) 
                            cliped.prehr     = time
                            .
                find first tbcntgen where
                                   tbcntgen.tipcon = 5 and
                                   tbcntgen.etbcod = 0 and
                                   tbcntgen.numfim = string(produ.procod)
                                   no-lock no-error.
                if avail tbcntgen and tbcntgen.valor > 0
                then cliped.lipqtd = tbcntgen.quantidade.
 
            end.
            find bliped where bliped.etbcod = tt-liped.etbcod and
                            bliped.pednum = tt-liped.pednum and
                            bliped.pedtdc = tt-liped.pedtdc and
                            bliped.procod = tt-liped.procod
                            no-error.
            if avail bliped
            then do transaction:
                delete bliped.                  
            end.
            delete tt-liped.
        end.
        delete tt-estab.
    end.
end.
                 
quit.

procedure estoque-reserva:
    def var vdata as date.
    if estoq.etbcod = 993
        or estoq.etbcod = 900
    then do:
        reserva = 0. 
        do vdata = today - 10 to today.
            for each liped where liped.pedtdc = 3
                             and liped.predt  = vdata
                             and liped.procod = produ.procod no-lock:
                                         
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.

                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.
                
                reserva = reserva + liped.lipqtd.
            
            end.
        end.
    end.
end procedure.
