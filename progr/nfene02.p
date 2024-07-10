{admcab.i}
def input  parameter vetbcod like estab.etbcod.
def input  parameter vtot    like plani.platot.
def input  parameter vdtf    like plani.pladat.
def output parameter vrec    as recid.
def output parameter vnum    like plani.numero.
def var vnumero              like plani.numero.
def var vplacod              like plani.placod.
def buffer bplani for plani.

vnumero = 0.
do transaction:
   
    
    find last bplani where bplani.etbcod = vetbcod and
                           bplani.placod <= 500000 
                                exclusive-lock no-error.
    if not avail bplani
    then vplacod = 1.
    else vplacod = bplani.placod + 1.
    
    find last plani use-index numero 
                where plani.etbcod = vetbcod and
                      plani.emite  = vetbcod and
                      plani.serie  = "U"          and
                      plani.movtdc <> 4           and
                      plani.movtdc <> 5 no-lock no-error. 
    if not avail plani 
    then vnumero = 1. 
    else vnumero = plani.numero + 1.
        
    if vetbcod = 998 or 
       vetbcod = 995
    then do: 
        vnumero = 0. 
        for each estab where estab.etbcod = 998 or
                             estab.etbcod = 995 no-lock.
                                 
            find last plani use-index numero 
                    where plani.etbcod = estab.etbcod and
                          plani.emite  = estab.etbcod and
                          plani.serie  = "U"          and
                          plani.movtdc <> 4           and
                          plani.movtdc <> 5 exclusive-lock no-error. 
                      
            if not avail plani 
            then vnumero = 1. 
            else do: 
                if vnumero < plani.numero 
                then vnumero = plani.numero.
            end.    
        end.
        if vnumero = 1 
        then. 
        else vnumero = vnumero + 1.
    end.   
    
    
    create plani.
    assign plani.etbcod = vetbcod
           plani.placod = vplacod
           plani.movtdc = 11
           plani.serie  = "U"
           plani.numero = vnumero
           plani.emite  = vetbcod 
           plani.desti  = vetbcod
           plani.pladat = today
           plani.datexp = vdtf
           plani.dtinclu = today
           plani.modcod  = "DUP"
           plani.horincl = time
           plani.hiccod  = 1949
           plani.icms    = (0.50 * (0.30 * vtot))
           plani.notobs[1] = ""
           plani.notobs[3] = string(vtot).



    vrec = recid(plani).
    vnum = plani.numero.
    
end.

                           
                

    
     