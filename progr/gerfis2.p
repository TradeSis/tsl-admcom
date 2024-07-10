{admcab.i}

def var vemite  like plani.emite.
def var vdesti  like plani.desti.
def var vtot like plani.platot.
def var vmovtdc like tipmov.movtdc.
def var d-dtini     as   date init today.
def var i-nota      like plani.numero.
def var i-seq       as   int format ">>>9".
def var vcgc    as char format "xx.xxx.xxx/xxxx-xx".
def var vemp    as int.
def var vdata   as date.

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
def stream sarq.

repeat:
    vetbcod = 0.
    update vetbcod colon 16 with frame f1.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1 side-label width 80.
    message "Confirma Geracao ? " update sresp.
    if sresp = no
    then undo, retry.
    
    do vdt = vdti to vdtf:
        display vdt with 1 down. pause 0.
        for each plani where plani.movtdc = 4             and
                             plani.etbcod = estab.etbcod  and
                             plani.dtinclu = vdt          and
                             plani.notsit  = no no-lock:
            if plani.emite = 5027
            then next.
        
            find forne where forne.forcod = plani.emite no-lock no-error.
            if not avail forne
            then next.
        
            
            vemite = plani.emite.
            if plani.emite = 98
            then vemite = 995.
            
            
            
            find fiscal2 where fiscal2.emite  = vemite and
                              fiscal2.desti  = plani.desti and
                              fiscal2.movtdc = plani.movtdc and
                              fiscal2.numero = plani.numero and
                              fiscal2.serie  = plani.serie no-error.
            if not avail fiscal2
            then do transaction:
                create fiscal2.
                assign  fiscal2.emite  = vemite
                        fiscal2.desti  = plani.desti
                        fiscal2.movtdc = plani.movtdc
                        fiscal2.numero = plani.numero
                        fiscal2.serie  = plani.serie
                        fiscal2.outras = plani.outras
                        fiscal2.plaemi = plani.pladat
                        fiscal2.plarec = plani.dtinclu
                        fiscal2.platot = plani.platot 
                        fiscal2.bicms  = plani.bicms     
                        fiscal2.icms   = plani.icms   
                        fiscal2.ipi    = plani.ipi
                        fiscal2.opfcod = plani.hiccod. 
                
                
                if forne.ufecod = "RS"
                then assign fiscal2.alicms = 17
                            fiscal2.opfcod = 1102.
                else assign fiscal2.alicms = 12
                            fiscal2.opfcod = 2102.
                
                
                
                
            end.
        end.
        
        for each plani where plani.movtdc = 15            and
                             plani.etbcod = estab.etbcod  and
                             plani.pladat = vdt          no-lock:
        
            find forne where forne.forcod = plani.emite no-lock no-error.
            if not avail forne
            then next.

            
            
            vdesti = plani.desti.
            if plani.desti = 98
            then vdesti    = 995.
            
            
            
            
            find fiscal2 where fiscal2.emite  = plani.emite  and
                              fiscal2.desti  = vdesti       and
                              fiscal2.movtdc = 4            and
                              fiscal2.numero = plani.numero and
                              fiscal2.serie  = plani.serie no-error.
            if not avail fiscal2
            then do transaction:
                create  fiscal2.
                assign  fiscal2.emite  = plani.emite
                        fiscal2.desti  = vdesti
                        fiscal2.movtdc = 4
                        fiscal2.numero = plani.numero
                        fiscal2.serie  = plani.serie
                        fiscal2.outras = plani.platot
                        fiscal2.plaemi = plani.pladat
                        fiscal2.plarec = plani.dtinclu
                        fiscal2.platot = plani.platot. 
                        
                        /*
                        fiscal2.bicms  = plani.bicms     
                        fiscal2.icms   = plani.icms   
                        fiscal2.ipi    = plani.ipi. 
                        */

                if forne.ufecod = "RS"
                then fiscal2.opfcod  = 1949.
                else fiscal2.opfcod  = 2949.
                find first movim where movim.placod = plani.placod and
                                       movim.etbcod = plani.etbcod 
                                                no-lock no-error.
                if movim.movalicms <> 0 
                then do:
                    if forne.ufecod = "RS"
                    then fiscal2.alicms = 17.
                    else fiscal2.alicms = 12.
                end.
                
            end.
        end.
        
        
        
        if vetbcod = 996
        then do:
            for each lancxa use-index ind-3 
                        where lancxa.cxacod = 13  and
                              lancxa.datlan = vdt and
                              lancxa.lantip = "C" and
                              lancxa.lancod = 100 
                        no-lock :
                vtot = 0.
                for each titulo where titulo.empcod = 19
                                  and titulo.titnat = yes
                                  and titulo.modcod = "DUP"
                                  and titulo.clifor = lancxa.forcod
                                  and titulo.titnum = lancxa.titnum
                                  and titulo.etbcod = lancxa.etbcod
                                no-lock : 
                    vtot = vtot + titulo.titvlcob.
                    vdata = titulo.titdtemi.
                end.
                
                
                find fiscal2 where fiscal2.emite  = lancxa.forcod  and
                                   fiscal2.desti  = 996             and
                                   fiscal2.movtdc = 4              and
                                   fiscal2.numero = lancxa.numlan  and
                                   fiscal2.serie  = "U" no-error.
                if not avail fiscal2
                then do transaction:
                    create  fiscal2.
                    assign  fiscal2.emite  = lancxa.forcod
                            fiscal2.desti  = 996
                            fiscal2.movtdc = 4
                            fiscal2.numero = lancxa.numlan
                            fiscal2.serie  = "U"
                            fiscal2.outras = 0
                            fiscal2.plaemi = vdata
                            fiscal2.plarec = vdata
                            fiscal2.platot = vtot
                            fiscal2.bicms  = vtot     
                            fiscal2.icms   = vtot * 0.17   
                            fiscal2.opfcod = 1102
                            fiscal2.alicms = 17.
                end.
                vtot = 0.
            end.   
            
            vtot = 0.
            for each lancxa use-index ind-3 
                        where lancxa.cxacod = 13  and
                              lancxa.datlan = vdt and
                              lancxa.lantip = "C" and
                              lancxa.forcod = 102044 
                                no-lock break by lancxa.forcod:

                vtot = vtot + lancxa.vallan.
                
                if last-of(lancxa.forcod)
                then do:
                
                    find fiscal2 where fiscal2.emite  = lancxa.forcod  and
                                      fiscal2.desti  = 996             and
                                      fiscal2.movtdc = 4              and
                                      fiscal2.numero = lancxa.numlan  and
                                      fiscal2.serie  = "U" no-error.
                    if not avail fiscal2
                    then do transaction:
                        create  fiscal2.
                        assign  fiscal2.emite  = lancxa.forcod
                                fiscal2.desti  = 996
                                fiscal2.movtdc = 4
                                fiscal2.numero = lancxa.numlan
                                fiscal2.serie  = "U"
                                fiscal2.outras = 0
                                fiscal2.plaemi = vdt
                                fiscal2.plarec = vdt
                                fiscal2.platot = vtot
                                fiscal2.bicms  = vtot     
                                fiscal2.icms   = vtot * 0.25   
                                fiscal2.opfcod = 1102
                                fiscal2.alicms = 25.
                    end.
                    vtot = 0.
                end.
            end.                                      
            
            vtot = 0.
            for each lancxa use-index ind-3 
                        where lancxa.cxacod = 13  and
                              lancxa.datlan = vdt and
                              lancxa.lantip = "C" and
                              lancxa.forcod = 101998 
                                no-lock break by lancxa.forcod:

                vtot = vtot + lancxa.vallan.
                
                if last-of(lancxa.forcod)
                then do:
                
                    find fiscal2 where fiscal2.emite  = lancxa.forcod  and
                                      fiscal2.desti  = 996             and
                                      fiscal2.movtdc = 4              and
                                      fiscal2.numero = lancxa.numlan  and
                                      fiscal2.serie  = "U" no-error.
                    if not avail fiscal2
                    then do transaction:
                        create  fiscal2.
                        assign  fiscal2.emite  = lancxa.forcod
                                fiscal2.desti  = 996
                                fiscal2.movtdc = 4
                                fiscal2.numero = lancxa.numlan
                                fiscal2.serie  = "U"
                                fiscal2.outras = 0
                                fiscal2.plaemi = vdt
                                fiscal2.plarec = vdt
                                fiscal2.platot = vtot
                                fiscal2.bicms  = vtot     
                                fiscal2.icms   = vtot * 0.25   
                                fiscal2.opfcod = 1102
                                fiscal2.alicms = 25.
                    end.
                    vtot = 0.
                end.
            end.                                      
            

            
            
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
                
                    find fiscal2 where fiscal2.emite  = lancxa.forcod  and
                                      fiscal2.desti  = 996             and
                                      fiscal2.movtdc = 4              and
                                      fiscal2.numero = lancxa.numlan  and
                                      fiscal2.serie  = "U" no-error.
                    if not avail fiscal2
                    then do transaction:
                        create  fiscal2.
                        assign  fiscal2.emite  = lancxa.forcod
                                fiscal2.desti  = 996
                                fiscal2.movtdc = 4
                                fiscal2.numero = lancxa.numlan
                                fiscal2.serie  = "U"
                                fiscal2.outras = 0
                                fiscal2.plaemi = vdt
                                fiscal2.plarec = vdt
                                fiscal2.platot = vtot
                                fiscal2.bicms  = vtot     
                                fiscal2.icms   = vtot * 0.25   
                                fiscal2.opfcod = 1102
                                fiscal2.alicms = 25.
                    end.
                    vtot = 0.
                end.
            end.                                      
            
            vtot = 0.
            for each lancxa use-index ind-3 
                        where lancxa.cxacod = 13  and
                              lancxa.datlan = vdt and
                              lancxa.lantip = "C" and
                              lancxa.forcod = 533 
                                no-lock break by lancxa.forcod:

                vtot = vtot + lancxa.vallan.
                
                if last-of(lancxa.forcod)
                then do:
                
                    find fiscal2 where fiscal2.emite  = lancxa.forcod  and
                                      fiscal2.desti  = 996             and
                                      fiscal2.movtdc = 4              and
                                      fiscal2.numero = lancxa.numlan  and
                                      fiscal2.serie  = "U" no-error.
                    if not avail fiscal2
                    then do transaction:
                        create  fiscal2.
                        assign  fiscal2.emite  = lancxa.forcod
                                fiscal2.desti  = 996
                                fiscal2.movtdc = 4
                                fiscal2.numero = lancxa.numlan
                                fiscal2.serie  = "U"
                                fiscal2.outras = 0
                                fiscal2.plaemi = vdt
                                fiscal2.plarec = vdt
                                fiscal2.platot = vtot
                                fiscal2.bicms  = vtot     
                                fiscal2.icms   = vtot * 0.25   
                                fiscal2.opfcod = 1102
                                fiscal2.alicms = 25.
                    end.
                    vtot = 0.
                end.
            end.                                      
        end.
 

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
            if vdesti = 98
            then vdesti = 995.
            if vdesti = 999
            then vdesti = 996.
            
            find fiscal2 where fiscal2.emite  = titulo.cxacod       and
                              fiscal2.desti  = vdesti              and
                              fiscal2.movtdc = 4                   and
                              fiscal2.numero = int(titulo.titnum)  and
                              fiscal2.serie  = "U" no-error.
            if not avail fiscal2
            then do transaction:
                create  fiscal2.
                assign  fiscal2.emite  = titulo.clifor
                        fiscal2.desti  = vdesti
                        fiscal2.movtdc = 4
                        fiscal2.numero = int(titulo.titnum)
                        fiscal2.serie  = "U"
                        fiscal2.outras = 0
                        fiscal2.plaemi = vdt
                        fiscal2.plarec = vdt
                        fiscal2.platot = titulo.titvlcob
                        fiscal2.bicms  = titulo.titvlcob     
                        fiscal2.icms   = titulo.titvlcob * 0.12   
                        fiscal2.opfcod = 1353
                        fiscal2.alicms = 12.
            end.
        end.
    end.
end.
