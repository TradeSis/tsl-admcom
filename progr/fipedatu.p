def shared temp-table atu-pedid         like com.pedid.
def shared temp-table atu-liped         like com.liped.

def buffer bpedid                   for com.pedid.
def var vpednum                     like com.pedid.pednum.

/**
for each atu-liped.  
    find com.estoq where com.estoq.etbcod = atu-liped.etbcod
                           and com.estoq.procod = atu-liped.procod
                           no-lock no-error.
    if avail com.estoq 
    then do:  
        if com.estoq.estloc <> "" 
        then do:  
            if atu-liped.lipqtd > int(com.estoq.estloc) 
            then atu-liped.lipqtd = int(com.estoq.estloc).
        end.
    end.
end.
**/
def buffer cpedid for com.pedid.

for each atu-pedid :
    do transaction : 
        find first com.pedid where
                   com.pedid.pedtdc = atu-pedid.pedtdc and
                   com.pedid.pednum = atu-pedid.pednum and
                   com.pedid.etbcod = atu-pedid.etbcod 
                   no-error.
        if not avail com.pedid
        then create com.pedid.
        else do:
            find last cpedid where
                   cpedid.pedtdc = atu-pedid.pedtdc and
                   cpedid.pednum < 100000 and
                   cpedid.etbcod = atu-pedid.etbcod 
                   no-error.
            if avail cpedid
            then do:
                find com.pedid where
                     com.pedid.etbcod = atu-pedid.etbcod and
                     com.pedid.pedtdc = atu-pedid.pedtdc and
                     com.pedid.pednum = atu-pedid.pednum
                     no-error.
                if avail com.pedid
                then do:
                    for each com.liped where 
                             com.liped.etbcod = com.pedid.etbcod and
                             com.liped.pedtdc = com.pedid.pedtdc and
                             com.liped.pednum = com.pedid.pednum
                             :
                        com.liped.pednum = cpedid.pednum + 1.
                    end.             
                    com.pedid.pednum = cpedid.pednum + 1.     
                    atu-pedid.pednum = cpedid.pednum + 1.
                    create com.pedid.
                end.
            end.    
        end.
        ASSIGN
            com.pedid.pedtdc    = atu-pedid.pedtdc
            com.pedid.pednum    = atu-pedid.pednum
            com.pedid.regcod    = atu-pedid.regcod
            com.pedid.peddat    = atu-pedid.peddat
            com.pedid.comcod    = atu-pedid.comcod
            com.pedid.pedsit    = atu-pedid.pedsit
            com.pedid.fobcif    = atu-pedid.fobcif
            com.pedid.nfdes     = atu-pedid.nfdes
            com.pedid.ipides    = atu-pedid.ipides
            com.pedid.dupdes    = atu-pedid.dupdes
            com.pedid.cusefe    = atu-pedid.cusefe
            com.pedid.condes    = atu-pedid.condes
            com.pedid.condat    = atu-pedid.condat
            com.pedid.crecod    = atu-pedid.crecod
            com.pedid.peddti    = atu-pedid.peddti
            com.pedid.peddtf    = atu-pedid.peddtf
            com.pedid.acrfin    = atu-pedid.acrfin
            com.pedid.sitped    = atu-pedid.sitped
            com.pedid.vencod    = atu-pedid.vencod
            com.pedid.frecod    = atu-pedid.frecod.

        ASSIGN
            com.pedid.modcod    = atu-pedid.modcod
            com.pedid.etbcod    = atu-pedid.etbcod
            com.pedid.pedtot    = atu-pedid.pedtot
            com.pedid.clfcod    = atu-pedid.clfcod
            com.pedid.pedobs[1] = atu-pedid.pedobs[1]
            com.pedid.pedobs[2] = atu-pedid.pedobs[2]
            com.pedid.pedobs[3] = atu-pedid.pedobs[3]
            com.pedid.pedobs[4] = atu-pedid.pedobs[4]
            com.pedid.pedobs[5] = atu-pedid.pedobs[5].
        
        find first com.pedid where
                   com.pedid.pedtdc = atu-pedid.pedtdc and
                   com.pedid.pednum = atu-pedid.pednum and 
                   com.pedid.etbcod = atu-pedid.etbcod 
                   no-error.
        /*com.pedid.exportado = yes.
          */
        delete atu-pedid.
    end.
end.
for each atu-liped:        
    do transaction : 

        if true 
        then do:
            if atu-liped.lipsit = "Z" 
            then do :
                find first com.pedid where 
                           com.pedid.pedtdc = atu-liped.pedtdc and
                           com.pedid.sitped = "E" and
                           com.pedid.etbcod = atu-liped.etbcod and
                           com.pedid.pednum >= 100000
                         no-lock no-error.
                if not avail com.pedid
                then do :
                    find last bpedid where 
                              bpedid.pedtdc = 3 and
                              bpedid.etbcod = atu-liped.etbcod  and
                              bpedid.pednum >= 100000
                              no-error.
                    if avail bpedid
                    then vpednum = bpedid.pednum + 1.
                    else vpednum = 100000.
    
                    create com.pedid.
                    assign
                        com.pedid.etbcod = atu-liped.etbcod
                        com.pedid.pedtdc = atu-liped.pedtdc
                        com.pedid.peddat = today
                        com.pedid.pednum = vpednum
                        com.pedid.sitped = "E" 
                        com.pedid.pedsit = yes.
                end.
                else vpednum = com.pedid.pednum.
            end.
        end.
        
        find first com.liped where
                   com.liped.etbcod = atu-liped.etbcod and
                   com.liped.pedtdc = atu-liped.pedtdc and
                   com.liped.pednum = atu-liped.pednum and
                   com.liped.procod = atu-liped.procod and
                   com.liped.predt  = atu-liped.predt no-error.
        if not avail com.liped
        then create com.liped.
  
        ASSIGN
            com.liped.pedtdc    = atu-liped.pedtdc
            com.liped.pednum    = atu-liped.pednum
            com.liped.procod    = atu-liped.procod
            com.liped.lippreco  = atu-liped.lippreco
            com.liped.lipsit    = atu-liped.lipsit
            com.liped.predtf    = atu-liped.predtf
            com.liped.predt     = atu-liped.predt
            com.liped.lipcor    = atu-liped.lipcor
            com.liped.etbcod    = atu-liped.etbcod.

        if com.liped.lipsit = "Z" 
        then do :
            com.liped.lipqtd = com.liped.lipqtd + 
                                      atu-liped.lipqtd.
            com.liped.pednum = vpednum.
            com.liped.lipsit = "A".
        end.
        else com.liped.lipqtd = atu-liped.lipqtd.
        
        find first com.liped where
                   com.liped.etbcod = atu-liped.etbcod and
                   com.liped.pedtdc = atu-liped.pedtdc and
                   com.liped.pednum = atu-liped.pednum and
                   com.liped.procod = atu-liped.procod and
                   com.liped.predt  = atu-liped.predt no-error.
        /*com.liped.exportado = yes.
          */
        delete atu-liped.
    end.
end.
