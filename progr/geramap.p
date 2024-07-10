/* {admcab.i} */

def var v-ori as char.
def var v-des as char.
def var ii as int.
def var v-sub as log.

def var vetbcod         like mapcxa.etbcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var varq as char.

/**** comentado em 10/01/2014 por Claudir
repeat:

    if opsys = "unix"
    then do:
        
        input from /admcom/audit/param_mp.
        repeat:
            import varq.
            vetbcod = int(substring(varq,1,3)).
            vdti    = date(int(substring(varq,6,2)),
                           int(substring(varq,4,2)),
                           int(substring(varq,8,4))).
            vdtf    = date(int(substring(varq,14,2)),
                           int(substring(varq,12,2)),
                           int(substring(varq,16,4))).
                       
        end.
        input close.
    
        if vetbcod = 999
        then return.
    
    end.
    else do:
    
        update vetbcod label "Filial" with frame f1.
        if vetbcod = 0
        then display "GERAL" @ estab.etbnom with frame f1.
        else do:
            find estab where estab.etbcod = vetbcod no-lock.
            display estab.etbnom no-label with frame f1.
        end.
    
        update vdti label "Data Inicial" colon 13
               vdtf label "Data Final" with frame f1 side-label width 80.
    end.
    
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:
                         
        /***
        if today = 08/26/11
        then do:
            for each mapctb where mapctb.etbcod = estab.etbcod and 
                              mapctb.datmov >= 08/16/11        and 
                              mapctb.datmov <= vdtf :
                delete mapctb.
            end.
        end.
        else do:
            for each mapctb where mapctb.etbcod = estab.etbcod and 
                              mapctb.datmov >= today - 1       and 
                              mapctb.datmov <= vdtf :
                delete mapctb.
            end.
        end.
        ***/
        for each mapcxa where mapcxa.etbcod = estab.etbcod and 
                              mapcxa.datmov >= vdti        and 
                              mapcxa.datmov <= vdtf no-lock:
               
            v-des = "". 
            v-sub = yes. 
            do ii = 1 to 20 /***29450 15***/:
                if substring(mapcxa.ch1,ii,1) = " " 
                then v-des = v-des + " ". 
                else if substring(mapcxa.ch1,ii,1) = "0" and v-sub
                     then. 
                     else assign v-sub = no
                                 v-des = v-des + substring(mapcxa.ch1,ii,1).
            end.
            
            find mapctb where mapctb.etbcod = mapcxa.etbcod and
                              mapctb.cxacod = mapcxa.cxacod and
                              mapctb.datmov = mapcxa.datmov and
                              mapctb.nrored = mapcxa.nrored 
                              no-error.
            if not avail mapctb 
            then do transaction:
                              
                create mapctb. 
                buffer-copy mapcxa to mapctb.
                
                assign mapctb.ch1 = v-des.
                
            end.
            else do:
                /**
                if mapctb.ch2 = ""
                then do transaction:
                                  
                    assign mapctb.datatu = mapcxa.datatu 
                           mapctb.datred = mapcxa.datred 
                           mapctb.nrofab = mapcxa.nrofab 
                           mapctb.nroseq = mapcxa.nroseq 
                           mapctb.nrocan = mapcxa.nrocan 
                           mapctb.gtotal = mapcxa.gtotal 
                           mapctb.valliq = mapcxa.valliq 
                           mapctb.valbru = mapcxa.valbru 
                           mapctb.vlsan  = mapcxa.vlsan 
                           mapctb.vlsub  = mapcxa.vlsub 
                           mapctb.vlsup  = mapcxa.vlsup 
                           mapctb.vlise  = mapcxa.vlise 
                           mapctb.vlacr  = mapcxa.vlacr 
                           mapctb.vldes  = mapcxa.vldes 
                           mapctb.vlcan  = mapcxa.vlcan 
                           mapctb.cooini = mapcxa.cooini.

                    assign mapctb.coofin = mapcxa.coofin 
                           mapctb.t01    = mapcxa.t01 
                           mapctb.t02    = mapcxa.t02 
                           mapctb.t03    = mapcxa.t03 
                           mapctb.t04    = mapcxa.t04 
                           mapctb.t05    = mapcxa.t05 
                           mapctb.t06    = mapcxa.t06 
                           mapctb.t07    = mapcxa.t07 
                           mapctb.t08    = mapcxa.t08 
                           mapctb.t09    = mapcxa.t09 
                           mapctb.t10    = mapcxa.t10 
                        /*   mapctb.t11    = mapcxa.t11 
                           mapctb.t12    = mapcxa.t12 */
                           mapctb.t13    = mapcxa.t13 
                           mapctb.t14    = mapcxa.t14 
                           mapctb.t15    = mapcxa.t15 
                           mapctb.t16    = mapcxa.t16 
                           mapctb.dt1    = mapcxa.dt1 
                           mapctb.dt2    = mapcxa.dt2 
                           mapctb.dt3    = mapcxa.dt3.

                    assign mapctb.ch1    = mapcxa.ch1 
                           mapctb.ch2    = mapcxa.ch2 
                           mapctb.ch3    = mapcxa.ch3 
                           mapctb.de1    = mapcxa.de1 
                           mapctb.de2    = mapcxa.de2 
                           mapctb.de3    = mapcxa.de3.
                
                    assign mapctb.ch1 = v-des.

                end.
                **/
            end.
            if mapctb.vlcan > 100000
            then do transaction:
                mapctb.vlcan = 0.
            end.    
            
        end.
    end.
    
    if opsys = "unix"
    then return.
    
end.    
******/
         