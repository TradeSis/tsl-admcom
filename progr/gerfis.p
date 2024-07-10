/* {admcab.i} */

def var varq    as char.
def var vemite  like plani.emite.
def var vdesti  like plani.desti.
def var vtot like plani.platot.
def var vmovtdc like tipmov.movtdc.
def var d-dtini     as   date init today.
def var i-nota      like plani.numero.
def var i-seq       as   int format ">>>9".
def var vcgc as char format "xx.xxx.xxx/xxxx-xx".
def var vemp as int.

def var outras-icms as dec format "->>>,>>9.99".
def var vetbcod like estab.etbcod.
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

def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
 
repeat:

    if opsys = "unix" and sparam <> "AniTA"
    then do:

        input from /admcom/audit/param_04.
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
    do vdt = vdti to vdtf:
        
        for each plani where plani.movtdc = 4             and
                             plani.etbcod = estab.etbcod  and
                             plani.dtinclu = vdt          and
                             plani.notsit  = no no-lock:
            if plani.numero = 0
            then next.
            if plani.emite = 5027
            then next.
        
            find forne where forne.forcod = plani.emite no-lock no-error.
            if not avail forne
            then next.
        
            
            vemite = plani.emite.
            
            /*
            if plani.emite = 998
            then vemite = 993 /*95*/.
            */
            
            find fiscal where fiscal.emite  = vemite and
                              fiscal.desti  = plani.desti and
                              fiscal.movtdc = plani.movtdc and
                              fiscal.numero = plani.numero and
                              fiscal.serie  = plani.serie no-error.
            if not avail fiscal
            then do transaction:
                create fiscal.
                assign  fiscal.emite  = vemite
                        fiscal.desti  = plani.desti
                        fiscal.movtdc = plani.movtdc
                        fiscal.numero = plani.numero
                        fiscal.serie  = plani.serie
                        fiscal.outras = plani.outras
                        fiscal.plaemi = plani.pladat
                        fiscal.plarec = plani.dtinclu
                        fiscal.platot = plani.platot 
                        fiscal.bicms  = plani.bicms     
                        fiscal.icms   = plani.icms   
                        fiscal.ipi    = plani.ipi
                        fiscal.opfcod = int(plani.opccod).
                
                if forne.ufecod = "RS" 
                then fiscal.alicms = 17.
                else fiscal.alicms = 12.
                
            end.
        end.
        
        for each plani where plani.movtdc = 28            and
                             plani.etbcod = estab.etbcod  and
                             plani.dtinclu = vdt          and
                             plani.notsit  = no no-lock:
            if plani.numero = 0
            then next.
            if plani.emite = 5027
            then next.
        
            find forne where forne.forcod = plani.emite no-lock no-error.
            if not avail forne
            then next.
        
            
            vemite = plani.emite.
            /*
            if plani.emite = 998
            then vemite = 993 /*95*/.
            */
            
            
            find fiscal where fiscal.emite  = vemite and
                              fiscal.desti  = plani.desti and
                              fiscal.movtdc = plani.movtdc and
                              fiscal.numero = plani.numero and
                              fiscal.serie  = plani.serie no-error.
            if not avail fiscal
            then do transaction:
                create fiscal.
                assign  fiscal.emite  = vemite
                        fiscal.desti  = plani.desti
                        fiscal.movtdc = plani.movtdc
                        fiscal.numero = plani.numero
                        fiscal.serie  = plani.serie
                        fiscal.outras = plani.outras
                        fiscal.plaemi = plani.pladat
                        fiscal.plarec = plani.dtinclu
                        fiscal.platot = plani.platot 
                        fiscal.bicms  = plani.bicms     
                        fiscal.icms   = plani.icms   
                        fiscal.ipi    = plani.ipi
                        fiscal.opfcod = int(plani.opccod).
                
                if forne.ufecod = "RS" 
                then fiscal.alicms = 17.
                else fiscal.alicms = 12.
                
            end.
        end.
 
        for each plani where plani.movtdc = 23            and
                             plani.etbcod = estab.etbcod  and
                             plani.dtinclu = vdt          and
                             plani.notsit  = no no-lock:
            if plani.numero = 0
            then next.
            if plani.emite = 5027
            then next.
        
            find forne where forne.forcod = plani.emite no-lock no-error.
            if not avail forne
            then next.
        
            
            vemite = plani.emite.
            /*
            if plani.emite = 998
            then vemite = 993 /*95*/.
            */
            
            
            find fiscal where fiscal.emite  = vemite and
                              fiscal.desti  = plani.desti and
                              fiscal.movtdc = 4           and
                              fiscal.numero = plani.numero and
                              fiscal.serie  = plani.serie no-error.
            if not avail fiscal
            then do transaction:
                create fiscal.
                assign  fiscal.emite  = vemite
                        fiscal.desti  = plani.desti
                        fiscal.movtdc = 4
                        fiscal.numero = plani.numero
                        fiscal.serie  = plani.serie.
            end.
            do transaction:
            assign
                fiscal.outras = plani.outras
                fiscal.plaemi = plani.pladat
                fiscal.plarec = plani.dtinclu
                fiscal.platot = plani.platot 
                fiscal.bicms  = plani.bicms     
                fiscal.icms   = plani.icms   
                fiscal.ipi    = plani.ipi
                fiscal.opfcod = int(plani.opccod).
                
                if fiscal.outras = 0 and
                   fiscal.platot > fiscal.bicms
                then fiscal.outras = fiscal.platot - fiscal.bicms.
                   
                if forne.ufecod = "RS" 
                then fiscal.alicms = 17.
                else fiscal.alicms = 12.
            end.
                
        end.
        

        for each tipmov no-lock:
            if tipmov.movtdc = 27 or
               tipmov.movtdc = 32 or
               tipmov.movtdc = 34 or
               tipmov.movtdc = 35 or
               tipmov.movtdc = 37 or
               tipmov.movtdc = 38 or
               tipmov.movtdc = 39
            then.
            else  next.   
        
        for each plani where plani.movtdc = tipmov.movtdc and
                             plani.etbcod = estab.etbcod  and
                             plani.dtinclu = vdt          no-lock:
            if plani.numero = 0
            then next.
            find forne where forne.forcod = plani.emite no-lock no-error.
            if not avail forne and plani.movtdc <> 27
            then next.

            
            
            vdesti = plani.desti.
            /*
            if plani.desti = 998
            then vdesti    = 993 /*95*/.
            */
            
            
            
            find fiscal where fiscal.emite  = plani.emite   and
                              fiscal.desti  = vdesti        and
                              fiscal.movtdc = plani.movtdc  and
                              fiscal.numero = plani.numero  and
                              fiscal.serie  = plani.serie no-error.
            if not avail fiscal
            then do transaction:
                create  fiscal.
                assign  fiscal.emite  = plani.emite
                        fiscal.desti  = vdesti
                        fiscal.movtdc = plani.movtdc
                        fiscal.numero = plani.numero
                        fiscal.serie  = plani.serie
                        fiscal.outras = plani.platot
                        fiscal.plaemi = plani.pladat
                        fiscal.plarec = plani.dtinclu
                        fiscal.platot = plani.platot 
                        fiscal.opfcod = plani.opccod.
                        

            end.
            
        end.
        end.
        /************** /
        for each plani where plani.movtdc = 15            and
                             plani.etbcod = estab.etbcod  and
                             plani.pladat = vdt          no-lock:
            if plani.numero = 0
            then next.
            find forne where forne.forcod = plani.emite no-lock no-error.
            if not avail forne
            then next.

            
            vdesti = plani.desti.
            
            /*
            if plani.desti = 998
            then vdesti    = 993 /*95*/.
            */
            
            
            
            find fiscal where fiscal.emite  = plani.emite  and
                              fiscal.desti  = vdesti       and
                              fiscal.movtdc = 4            and
                              fiscal.numero = plani.numero and
                              fiscal.serie  = plani.serie no-error.
            if not avail fiscal
            then do transaction:
                create  fiscal.
                assign  fiscal.emite  = plani.emite
                        fiscal.desti  = vdesti
                        fiscal.movtdc = 4
                        fiscal.numero = plani.numero
                        fiscal.serie  = plani.serie
                        fiscal.outras = plani.platot
                        fiscal.plaemi = plani.pladat
                        fiscal.plarec = plani.dtinclu
                        fiscal.platot = plani.platot 
                        fiscal.opfcod = plani.opccod.
                        

                if forne.ufecod = "RS"
                then fiscal.opfcod  = 1915.
                else fiscal.opfcod  = 2915.
            end.
        end.
        *************/
        
        /*
        if estab.etbcod = 996
        then do:
            
                        
            
            vtot = 0.
            for each lancxa use-index ind-3 
                        where lancxa.cxacod = 13  and
                              lancxa.datlan = vdt and
                              lancxa.lantip = "C" and
                              lancxa.forcod = 100071 
                                no-lock break by lancxa.forcod:

                vtot = vtot + lancxa.vallan.
                
                if last-of(lancxa.forcod)
                then do:
                
                    find fiscal where fiscal.emite  = lancxa.forcod  and
                                      fiscal.desti  = 996             and
                                      fiscal.movtdc = 4              and
                                      fiscal.numero = int(lancxa.titnum)  and
                                      fiscal.serie  = "U" no-error.
                    if not avail fiscal
                    then do transaction:
                        create  fiscal.
                        assign  fiscal.emite  = lancxa.forcod
                                fiscal.desti  = 996
                                fiscal.movtdc = 4
                                fiscal.numero = int(lancxa.titnum)
                                fiscal.serie  = "U"
                                fiscal.outras = vtot
                                fiscal.plaemi = vdt
                                fiscal.plarec = vdt
                                fiscal.platot = vtot
                                fiscal.bicms  = 0
                                fiscal.icms   = 0 
                                fiscal.opfcod = 1253 
                                fiscal.alicms = 0.
                    end.
                    vtot = 0.
                end.
            end.                                      
        end.
        */
        
        

        for each frete where frete.forcod <> 0 no-lock,
            each titulo where titulo.empcod = 19            and
                              titulo.titnat = yes           and
                              titulo.modcod = "NEC"         and
                              titulo.titdtpag = vdt         and
                              titulo.etbcod = estab.etbcod  and
                              titulo.clifor = frete.forcod no-lock.

        
            find forne where forne.forcod = titulo.clifor no-lock no-error.
            if not avail forne
            then next.
            if forne.ufecod = "RS"
            then next.

            vdesti = titulo.etbcod.
            /*
            if vdesti = 998
            then vdesti = 993 /*95*/.
            if vdesti = 999
            then vdesti = 996.
            */
            
            find fiscal where fiscal.emite  = titulo.cxacod       and
                              fiscal.desti  = vdesti              and
                              fiscal.movtdc = 4                   and
                              fiscal.numero = int(titulo.titnum)  and
                              fiscal.serie  = "U" no-error.
            if not avail fiscal
            then do transaction:
                create  fiscal.
                assign  fiscal.emite  = titulo.clifor
                        fiscal.desti  = vdesti
                        fiscal.movtdc = 4
                        fiscal.numero = int(titulo.titnum)
                        fiscal.serie  = "U"
                        fiscal.outras = 0
                        fiscal.plaemi = vdt
                        fiscal.plarec = vdt
                        fiscal.platot = titulo.titvlcob
                        fiscal.bicms  = titulo.titvlcob     
                        fiscal.icms   = titulo.titvlcob * 0.12   
                        fiscal.opfcod = 2353
                        fiscal.alicms = 12.
            end.
        end.
        
        for each tipmov no-lock:
            if 
               tipmov.movtdc = 10 or
               tipmov.movtdc = 11 or
               tipmov.movtdc = 47 or
               tipmov.movtdc = 51 or
               tipmov.movtdc = 53 or
               tipmov.movtdc = 57 or
               tipmov.movtdc = 60 or
               tipmov.movtdc = 61 or
               tipmov.movtdc = 62 or
               tipmov.movtdc = 65             
            then.
            else  next.   
        
            for each plani where plani.movtdc = tipmov.movtdc
                             and plani.etbcod = estab.etbcod
                             and plani.pladat = vdt 
                                        no-lock:
                if plani.numero = 0
                then next.
            
                find fiscal where fiscal.emite  = plani.emite   and
                                  fiscal.desti  = plani.desti   and
                                  fiscal.movtdc = plani.movtdc  and
                                  fiscal.numero = plani.numero  and
                                  fiscal.serie  = plani.serie no-error.
                if not avail fiscal
                then do transaction:
                
                    create  fiscal.
                    assign  fiscal.emite  = plani.emite
                            fiscal.desti  = plani.desti
                            fiscal.movtdc = plani.movtdc
                            fiscal.numero = plani.numero
                            fiscal.serie  = plani.serie
                            fiscal.outras = plani.platot
                            fiscal.plaemi = plani.pladat
                            fiscal.plarec = plani.dtinclu
                            fiscal.platot = plani.platot 
                            fiscal.opfcod = plani.opccod.
                        
                end.
                
            end.
            
        end.
        
    end.
    end.
    
    if opsys = "unix"
    then return.
    

end.
