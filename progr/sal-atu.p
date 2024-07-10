def var datasai  like plani.pladat.
def var vdt like plani.pladat.
def var vmovqtm like movim.movqtm.
def var vmes as int format "99".
def var vano as int format "9999".
def var t-sai   like plani.platot.
def var t-ent   like plani.platot.
def var vdata   like plani.pladat.
def var vtotdia like plani.platot.
def var vtot  like movim.movpc.
def var vtotg like movim.movpc.
def var vtotgeral like plani.platot.

def input  parameter vetbcod like estab.etbcod.
def input  parameter vprocod like produ.procod.
def input  parameter vdata1 like plani.pladat label "Data".
def input  parameter vdata2 like plani.pladat label "Data".
def output parameter sal-atu   like estoq.estatual.

def var vtotal like plani.platot.
def var vtoticm like plani.icms.
def var vtotmovim   like movim.movpc.
def var vmovtnom  like tipmov.movtnom.
def var vsalant   like estoq.estatual.
def var sal-ant   like estoq.estatual.

    sal-atu = 0.
    sal-ant = 0.
    
    find produ where produ.procod = vprocod no-lock.
    
    vdt = vdata1.
    
    find last hiest where hiest.etbcod = vetbcod      and
                          hiest.procod = produ.procod and
                          hiest.hiemes < month(vdata1) and
                          hiest.hieano = year(vdata1) no-lock no-error.
    if not avail hiest
    then do:
        
        find last hiest where hiest.etbcod = vetbcod      and
                              hiest.procod = produ.procod and
                              hiest.hieano = year(vdata1) - 1 no-lock no-error.
        if not avail hiest
        then do:
            find last hiest where hiest.etbcod = vetbcod      and
                                  hiest.procod = produ.procod and
                                  hiest.hieano = year(vdata1) - 2
                                        no-lock no-error.
            if not avail hiest
            then do:
                find last hiest where hiest.etbcod = vetbcod      and
                          hiest.procod = produ.procod             and
                          hiest.hiemes = month(vdata1)             and
                          hiest.hieano = year(vdata1) no-lock no-error.
                if not avail hiest
                then assign sal-ant = 0.
                else assign sal-ant = 0.
            end.
            else assign sal-ant = hiest.hiestf.
        end.
        else assign sal-ant = hiest.hiestf.
    end.
    else assign sal-ant = hiest.hiestf.

    sal-atu = sal-ant.
    
    do vdata = date(month(vdata1),1,year(vdata1)) to vdata2: 

        for each movim where movim.procod = produ.procod and
                             movim.desti  = vetbcod      and
                             movim.datexp = vdata no-lock:
                         
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.
            if avail plani
            then do:
                if plani.emite = 22 and plani.desti = 996
                then next.
            end.
            
            if movim.movtdc = 7  or 
               movim.movtdc = 8 
            then.
            else next.

            if month(movim.datexp) <> month(movim.movdat) and
               month(movim.movdat) = vmes
            then do:
                if movim.movtdc = 8  
                then assign sal-ant = sal-ant - movim.movqtm
                            sal-atu = sal-atu - movim.movqtm.

                if movim.movtdc = 7  
                then assign sal-ant = sal-ant + movim.movqtm
                            sal-atu = sal-atu + movim.movqtm.
            end.
        end. 
    end. 

    do vdata = date(month(vdata1),1,year(vdata1)) to vdata2: 
        for each movim where movim.procod = produ.procod and
                             movim.emite  = vetbcod      and
                             movim.datexp = vdata no-lock:

            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.
            if avail plani
            then do:
                if plani.emite = 22 and plani.desti = 996
                then next. 
            end.
            
            if movim.movtdc = 5  or
               movim.movtdc = 3  or
               movim.movtdc = 6  or
               movim.movtdc = 12 or
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 
            then. 
            else next.
            
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
            then sal-atu = sal-atu - movim.movqtm.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then sal-atu = sal-atu + movim.movqtm.

            if movim.movtdc = 6 or
               movim.movtdc = 3
            then do:
                if movim.etbcod = vetbcod
                then sal-atu = sal-atu - movim.movqtm.
            
                if movim.desti = vetbcod
                then sal-atu = sal-atu + movim.movqtm.
            end.

            vmovqtm = movim.movqtm.
            
            if movim.movtdc = 21
            then assign sal-atu  = sal-atu + vmovqtm.
        end.
        
        for each movim where movim.procod = produ.procod and
                             movim.desti  = vetbcod      and
                             movim.datexp = vdata no-lock:
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.
            if avail plani
            then do:
                if plani.emite = 22 and plani.desti = 996
                then next.
            end.
            
            if movim.movtdc = 5  or 
               movim.movtdc = 12 or 
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 or
               movim.movtdc = 07 or
               movim.movtdc = 08
            then next.
            
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
            then sal-atu = sal-atu - movim.movqtm.

            if movim.movtdc = 4  or
               movim.movtdc = 1  or
               movim.movtdc = 7  or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then sal-atu = sal-atu + movim.movqtm.

            if movim.movtdc = 6 or
               movim.movtdc = 3
            then do:
                if movim.etbcod = vetbcod
                then sal-atu = sal-atu - movim.movqtm.
            
                if movim.desti = vetbcod
                then sal-atu = sal-atu + movim.movqtm.
            end.
            
            if movim.movtdc = 21
            then assign sal-atu  = sal-atu + vmovqtm.
            
        end. 
        
        for each movim where movim.procod = produ.procod and
                             movim.desti  = vetbcod      and
                             movim.movdat = vdata no-lock:
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.
            if avail plani
            then do:
                if plani.emite = 22 and plani.desti = 996
                then next.
            end.
            
            if movim.movtdc = 7  or 
               movim.movtdc = 8 
            then.
            else next.
            
            if movim.movtdc = 8  
            then sal-atu = sal-atu - movim.movqtm.
            if movim.movtdc = 7  
            then sal-atu = sal-atu + movim.movqtm.
            
            if movim.movtdc = 21
            then assign sal-atu  = sal-atu + vmovqtm.
            
            if month(movim.movdat) <> month(movim.datexp)
            then do:
                if movim.movtdc = 7  
                then assign sal-atu = sal-atu - movim.movqtm.
            end.
        end. 
    end.
