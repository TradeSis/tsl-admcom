/* {admcab.i} */

def var vlancod like tablan.lancod.
def var vemite like plani.emite.
def var varq as char.    
def var ii as int.
def var vetb like estab.etbcod extent 3.
def var d-dtini     as   date init today.
def var i-nota      like plani.numero.
def var i-seq       as   int format ">>>9".
def var vcgc as char format "xx.xxx.xxx/xxxx-xx".
def var vemp as int.

def var outras-icms as dec format "->>>,>>9.99".
def var vetbcod  like estab.etbcod.
def var nu as int.
def var vvlcont as dec format ">>>>>.99".
def var vlannum as int.
def var i       as int.
def var wni     as int.
def var ni      as int.
def var nf      as int.
def var vdt     as date format "99/99/9999".
def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.

def var vtotalmov as dec.
def var vtotbicms as dec.
def var vtotalicm as dec decimals 6 format ">>,>>9.999".
def var vicms as dec decimals 6.
def var vicm as dec.

def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
     
repeat:

    vlancod = 0.
    vetbcod = 0.
    
    if opsys = "unix" and sparam <> "AniTA"
    then do:
        
        input from /admcom/audit/param_12.
        repeat:
            import varq.
            vetbcod = int(substring(varq,1,3)).
            vdti    = date(int(substring(varq,5,2)),
                           int(substring(varq,3,2)),
                           int(substring(varq,7,4))).
            vdtf    = date(int(substring(varq,13,2)),
                           int(substring(varq,11,2)),
                           int(substring(varq,15,4))).
                       
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
    
    
    do vdt = vdti to vdtf:
        
        for each estab where if vetbcod = 0
                             then true
                             else estab.etbcod = vetbcod no-lock,
            each plani where plani.movtdc = 12            and
                             plani.etbcod = estab.etbcod  and
                            (plani.serie  = "1" or plani.serie  = "55") and
                             plani.pladat = vdt /*and
                             plani.numero = 14009*/:

            assign
                vtotalmov = 0 vtotalicm = 0 vicms = 0.
            
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod 
                                 :
                assign
                    vtotalmov = vtotalmov + (movim.movpc * movim.movqtm)
                    vtotbicms = vtotbicms + ((movim.movpc * movim.movqtm) 
                                            - movim.movdes)
                    vtotalicm = vtotalicm + 
                        (((movim.movpc * movim.movqtm) - movim.movdes) 
                        * (movim.movalicms / 100))
                    vicms = ((movim.movpc * movim.movqtm) - movim.movdes) 
                        * (movim.movalicms / 100).
 
                /*disp vicms movim.movicms. pause.
                */
                
                /*
                if vicms <> movim.movicms
                then movim.movicms = vicms.
                */
                
            end.
            
            vicm = dec(substr(string(vtotalicm,">>>>>>>>9.999"),1,12)).
            
            /******
            if plani.platot <> vtotalmov
            then do transaction:
                assign
                    plani.protot = vtotalmov
                    plani.platot = vtotalmov
                    plani.bicms  = vtotalmov
                    plani.icms   = vtotalicm.   
            end.
            if vicm <> plani.icms
            then do transaction:
                plani.icms = vicm.
            end.
            *******/
            
            find fiscal where fiscal.emite  = estab.etbcod  and
                              fiscal.desti  = estab.etbcod  and
                              fiscal.movtdc = plani.movtdc  and
                              fiscal.numero = plani.numero  and
                              fiscal.serie  = plani.serie no-error.
            if not avail fiscal
            then do transaction:
                create fiscal.
                assign  fiscal.emite  = estab.etbcod
                        fiscal.desti  = estab.etbcod
                        fiscal.movtdc = plani.movtdc
                        fiscal.numero = plani.numero
                        fiscal.serie  = plani.serie
                        fiscal.outras = plani.outras
                        fiscal.plaemi = plani.pladat
                        fiscal.plarec = plani.pladat
                        fiscal.platot = plani.platot 
                        fiscal.bicms  = plani.bicms     
                        fiscal.icms   = plani.icms   
                        fiscal.ipi    = plani.ipi
                        fiscal.opfcod = 1202
                        fiscal.alicms = 17.
            end.
            else do transaction:
                assign  
                        fiscal.outras = plani.outras
                        fiscal.plaemi = plani.pladat
                        fiscal.plarec = plani.pladat
                        fiscal.platot = plani.platot 
                        fiscal.bicms  = plani.bicms     
                        fiscal.icms   = plani.icms   
                        fiscal.ipi    = plani.ipi
                        fiscal.opfcod = 1202
                        fiscal.alicms = 17.

            end.
        end.
        
        for each estab where if vetbcod = 0
                             then true
                             else estab.etbcod = vetbcod no-lock,
            each lancxa use-index ind-3 where lancxa.cxacod = 13  and
                                              lancxa.datlan = vdt and
                                              lancxa.lantip = "C" and
                                              lancxa.etbcod = estab.etbcod and
                                              lancxa.forcod = 100071 no-lock:
            
            vemite = lancxa.etbcod.
            
            if vemite = 999
            then vemite = 996.
            if vemite = 998
            then vemite = 900 /*95*/.

            find fiscal where fiscal.emite  = lancxa.forcod  and
                              fiscal.desti  = vemite         and
                              fiscal.movtdc = 12             and
                              fiscal.numero = int(lancxa.titnum)  and
                              fiscal.serie  = "01" no-error.
                              
            if not avail fiscal
            then do transaction: 
                create  fiscal.
                assign  fiscal.emite  = lancxa.forcod
                        fiscal.desti  = vemite
                        fiscal.movtdc = 12
                        fiscal.numero = int(lancxa.titnum)
                        fiscal.serie  = "01"
                        fiscal.outras = lancxa.vallan
                        fiscal.plaemi = lancxa.datlan
                        fiscal.plarec = lancxa.datlan
                        fiscal.platot = lancxa.vallan
                        fiscal.bicms  = 0
                        fiscal.icms   = 0
                        fiscal.opfcod = 1253
                        fiscal.alicms = 0.
            end. 
        end.
    end.
    if opsys = "unix"
    then return.

end.
