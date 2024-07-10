{admcab.i}

def var vetbcod  like estab.etbcod.
def var vcatcod  like categoria.catcod.
def var vpro like produ.procod.
def var vq like estoq.estatual. 
def var vc as char format "x(20)".
def var vpend   as int format "->>>9".
def var vqtd like estoq.estinvctm format "->,>>9.99".
def var vimp as l.
def stream stela.
def var varquivo as char.
def var vest like estoq.estatual.
def var vant like estoq.estatual.
def var vmes as int.
def var vano as int.
def var vprocod like produ.procod.
def var vquan   like estoq.estatual.
def var vpath as char format "x(30)".

def var v-etccod      like estac.etccod.

def temp-table wcol
    field wcol as char format "x(2)".
def var vcol as char format "x(2)".

def var vlei            as char format "x(26)".
def var vetb            as i    format ">>9".
def var vcod            as i    format "9999999".
def var vcod2           as i    format "999999".
def var ac  as i.
def var tot as i.
def var de  as i.
def var vdata like plani.pladat.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var est like estoq.estatual.

repeat:
    for each wcol:
        delete wcol.
    end.

    update vetbcod colon 20 label "Filial"
                with frame f1 side-label centered width 80.
                
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.

    update vcatcod colon 20 label "Departamento" with frame f1.
    
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f1.
    v-etccod = 0. 
    do: 
        update v-etccod colon 20 with frame f1 side-label. 
        if v-etccod > 0 
        then do: 
            find estac where estac.etccod = v-etccod no-lock. 
            disp estac.etcnom no-label with frame f1. 
        end. 
    end.
    
    update vdata label "Data da Coleta" colon 20 with frame f1.
    
    repeat:
        update vcol label "Coletor" with frame f3 side-label centered.
        find first wcol where wcol.wcol = vcol no-error.
        if not avail wcol
        then do:
            create wcol.
            assign wcol.wcol = vcol.
        end.
    end.

    {confir.i 1 "Importacao dos Coletores"}

    for each wcol:
       vpath = "m:\coletor\col" + string(wcol.wcol,"x(02)") + "\coleta99.txt".
       input from value(vpath).
       repeat:
            vqtd = 0.
            import vlei.
            assign vetb = int(substring(string(vlei),4,2))
                   vcod = int(substring(string(vlei),14,7))
                   vcod2 = int(substring(string(vlei),14,6))
                   vqtd = int(substring(string(vlei),21,6)).

            if vetb <> estab.etbcod or vcod = 0 or vcod = ? or
               vcod = 1 or vcod = 2 or vcod = 3 or vcod = 4 or vcod = 5
            then next.
            find produ where produ.procod = vcod no-lock no-error.
            if not avail produ
            then do:
                find produ where produ.procod = vcod2 no-lock no-error.
                if not avail produ
                then next.
            end.
            
            if produ.catcod = vcatcod
            then.
            else next.
            
            if v-etccod > 0 and 
               produ.etccod <> v-etccod 
            then next.
                        
            
            
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.
            
        
            
            find coletor where coletor.etbcod = estab.etbcod and
                               coletor.procod = produ.procod and
                               coletor.coldat = vdata no-error.
            if not avail coletor
            then do transaction:
                create coletor.
                assign coletor.etbcod   = estab.etbcod
                       coletor.procod   = produ.procod
                       coletor.coldat   = vdata
                       coletor.pronom   = produ.pronom
                       coletor.catcod   = vcatcod  
                       coletor.estatual = estoq.estatual
                       coletor.estcusto = estoq.estcusto
                       coletor.estvenda = estoq.estvenda.
            end.
            
            do transaction:
                coletor.colqtd = coletor.colqtd + vqtd.
            end.
            
        end.
        
        input close.
        
    end.

    message "Deseja Processar" update sresp.
    if sresp = no
    then next.
    
    output stream stela to terminal.
    
    for each produ where produ.catcod = categoria.catcod no-lock:
    
        if v-etccod > 0 and 
           produ.etccod <> v-etccod 
        then next.
        
        display stream stela produ.procod with 1 down. pause 0.
    
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-error.

        if not avail estoq
        then next.

        vest = estoq.estatual.
        
        for each movim where movim.procod = produ.procod and
                             movim.emite  = estab.etbcod and
                             movim.datexp > vdata no-lock:

            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat use-index plani
                                                     no-lock no-error.

            if not avail plani
            then next.
            
            if plani.etbcod <> estab.etbcod and
               plani.desti  <> estab.etbcod
            then next.

            if plani.emite = 22 and
               plani.serie = "m1"
            then next.

            if plani.movtdc = 5 and
               plani.emite  <> estab.etbcod
            then next.

            find tipmov of movim no-lock.
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
               then do:
                   if movim.datexp >= vdata
                   then vest = vest + movim.movqtm.
               end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then do:
                if movim.datexp >= vdata
                then vest = vest - movim.movqtm.
            end.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest + movim.movqtm.
                end.
                if plani.desti = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest - movim.movqtm.
                end.
            end.
        end.
        
        for each movim where movim.procod = produ.procod and
                             movim.desti  = estab.etbcod and
                             movim.datexp > vdata no-lock:


            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat
                                                     no-lock no-error.

            if not avail plani
            then next.
            
            if avail plani
            then do:
                if plani.emite = 22 and desti = 996
                then next.
                
            end.
            
            if movim.movtdc = 5  or 
               movim.movtdc = 12 or 
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 
            then next.
            

            
            
            if plani.etbcod <> estab.etbcod and
               plani.desti  <> estab.etbcod
            then next.

            if plani.emite = 22 and
               plani.serie = "m1"
            then next.

            if plani.movtdc = 5 and
               plani.emite  <> estab.etbcod
            then next.
            find tipmov of movim no-lock.
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  
               then do:
                   if movim.datexp >= vdata
                   then vest = vest + movim.movqtm.
               end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 
            then do:
                if movim.datexp >= vdata
                then vest = vest - movim.movqtm.
            end.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest + movim.movqtm.
                end.
                if plani.desti = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest - movim.movqtm.
                end.
            end.
        end.

        
        find coletor where coletor.etbcod = estab.etbcod and
                           coletor.procod = produ.procod and
                           coletor.coldat = vdata no-error.
        if not avail coletor
        then do transaction:
            create coletor.
            assign coletor.etbcod   = estab.etbcod
                   coletor.coldat   = vdata
                   coletor.procod   = produ.procod
                   coletor.catcod   = vcatcod
                   coletor.colqtd   = 0
                   coletor.pronom   = produ.pronom
                   coletor.estcusto = estoq.estcusto
                   coletor.estvenda = estoq.estvenda
                   coletor.estatual = vest.
        end.
        
        do transaction:
            if vest > coletor.colqtd
            then coletor.coldec = vest - coletor.colqtd.

            if vest < coletor.colqtd
            then coletor.colacr = coletor.colqtd - vest.
            
            coletor.estatual = vest.

        end.
        

    end.
    output stream stela close.
end.
