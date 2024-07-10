def var v-ori as char.
def var v-des as char.
def var ii as int.
def var v-sub as log.

def var vetbcod         like mapcxa.etbcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var varq as char.
def var sparam as char.

sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").


repeat:

    if opsys = "unix" and sparam <> "AniTA"
    then do:
        
        input from /admcom/audit/param_mr.
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
                         
        for each mapcxa where mapcxa.Etbcod = estab.etbcod
                  and mapcxa.datmov >= vdti  
                  and mapcxa.datmov <= vdtf no-lock:
            
            find first mapctb where mapctb.Etbcod = mapcxa.etbcod
                        and mapctb.cxacod = mapcxa.cxacod
                        and mapctb.datmov = mapcxa.datmov
                                exclusive-lock no-error.

            if not avail mapctb
            then do on error undo, retry:

                create mapctb.

                buffer-copy mapcxa to mapctb.

            end.
        end.
    end. 
    leave.
end.    
         