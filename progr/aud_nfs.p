{admcab.i} 
def var vobs like plani.notobs.
def var itvaloroutroicm like plani.platot.

def var ipi_base  like plani.platot.
def var ipi_capa  like plani.platot.
def var ipi_item  like plani.platot.
def var base_icms like plani.platot.
def var vdatexp like plani.datexp.
def var vcod as char format "x(18)".
def var vemite like plani.emite.
def var vdesti like plani.desti.
def var vopccod as char.
def var vali    as int.
def var varq    as char. 
def var val_contabil like plani.platot.
def var visenta like plani.platot.
def var voutras like plani.platot.
def buffer bmovim for movim.

def input parameter vetbcod like estab.etbcod.
def input parameter vop  like opcom.opccod.
def input parameter vdti like plani.pladat.
def input parameter vdtf like plani.pladat.
def input parameter arq_tot as log.

def shared temp-table tt-fiscal
    field etbcod  like estab.etbcod
    field opfcod  as char
    field alicota as dec format ">>9.99"
    field totsai  like plani.platot 
    field base    like plani.platot 
    field icms    like plani.icms 
    field ipi     like plani.ipi 
    field valcon  like plani.platot
    field outras  like plani.outras
    field isentas like plani.isenta.
 



def shared temp-table tt-plani
    field rec as recid
    field numero like plani.numero
    field serie  as char
    field vemi   like plani.emite
    field vdata  like plani.pladat 
    field tot_pla like plani.platot
    field val_con like plani.platot
    field bas_icm like plani.platot
    field val_icm like plani.platot
    field tipo   as char
    field opf    like opcom.opccod.
 
 
 
    for each tipmov where tipmov.movtnota = yes and
                          tipmov.movtdeb  = yes no-lock:

        if tipmov.movtdc = 5
        then next.
        for each estab where if vetbcod = 0
                             then true 
                             else estab.etbcod = vetbcod no-lock:
            for each plani where plani.etbcod = estab.etbcod  and
                                 plani.movtdc = tipmov.movtdc and
                                 plani.datexp >= vdti         and
                                 plani.datexp <= vdtf no-lock:
               
                
                ipi_base = 0.
                ipi_item = 0.
                ipi_capa = 0.
                
                if plani.platot = 0
                then next.
                                
                if plani.serie = "U" 
                then. 
                else next.
          
                if plani.emite = 995 and
                   plani.desti = 998 
                then next.
                if plani.emite = 998 and
                   plani.desti = 995
                then next.   
                
                vdatexp = plani.datexp.
                if plani.movtdc = 13 and
                   plani.datexp >= 01/01/2005 and
                   plani.datexp <= 05/31/2005
                then vdatexp = date(07,
                                    day(plani.datexp),
                                    year(plani.datexp)).
        

             
             
                vemite = plani.emite.  
                if vemite = 998  
                then vemite = 995.
            
                vdesti = plani.desti.  
                if vdesti = 998  
                then vdesti = 995.
               
               
                assign visenta      = 0 
                       voutras      = 0.

               


             
                if plani.movtdc = 6 or
                   plani.movtdc = 9 or
                   plani.movtdc = 22
                then do:   
                    if plani.protot = 0 
                    then next. 
                    vopccod = "5152". 
                    vcod = "E" + string(vdesti,"9999999") + "          ". 
                end.    
                else do: 
                    find forne where forne.forcod = vdesti no-lock no-error.
                    if not avail forne 
                    then next.

                    vcod = "F" + string(forne.forcod,"9999999") + 
                            "          ". 
                
                    if forne.ufecod = "RS"
                    then find first opcom where 
                                    opcom.movtdc = plani.movtdc no-lock.
                    else find last opcom where 
                                   opcom.movtdc = plani.movtdc no-lock.
                
                    vopccod = string(opcom.opccod). 
                
                end.


                if plani.bicms > 0
                then vali = int((plani.icms * 100) / plani.bicms).
                else vali = 0. 
             
                base_icms = 0.
                find first bmovim where bmovim.etbcod = plani.etbcod and
                                        bmovim.placod = plani.placod and
                                        bmovim.movtdc = plani.movtdc and
                                        bmovim.movdat = plani.pladat 
                                                no-lock no-error.
                if avail bmovim 
                then do: 
                    
                    for each movim where movim.etbcod = plani.etbcod and
                                         movim.placod = plani.placod and
                                         movim.movtdc = plani.movtdc and
                                         movim.movdat = plani.pladat no-lock:
                             
                
                        if movim.movpc = 0 or
                           movim.movqtm = 0
                        then next.   
                        itvaloroutroicm =  movim.movpc * movim.movqtm.

                    
                        base_icms = 0.  
                                            
                        
                        val_contabil = movim.movpc * movim.movqtm.
 
                        if vopccod = "6901" 
                        then assign visenta = val_contabil  
                                              - (movim.movpc * movim.movqtm) 
                                              - plani.ipi.
                                    voutras = val_contabil 
                                              - (movim.movpc * movim.movqtm) 
                                              - plani.ipi - visenta.

                        if vopccod = "5202" or 
                           vopccod = "6202"
                        then assign base_icms = movim.movpc * movim.movqtm
                                    itvaloroutroicm = 0 
                                    val_contabil = val_contabil + 
                                                ((movim.movpc * movim.movqtm) * 
                                                (movim.movalipi / 100))
                                    ipi_capa = plani.ipi
                                    ipi_item =  ((movim.movpc * movim.movqtm) * 
                                                (movim.movalipi / 100))
                                    ipi_base = if movim.movalipi <> 0
                                               then (movim.movpc *   
                                                     movim.movqtm)
                                               else 0.
                        else assign ipi_capa = 0
                                    ipi_item = 0
                                    ipi_base = 0.
                                    
                        vobs[1] = plani.notobs[1].
                        vobs[2] = plani.notobs[2].
                        
                        if vobs[1] = "" and
                           ipi_capa > 0
                        then vobs[1] = "VALOR IPI: " + 
                                       string(ipi_capa,">>,>>9.99").
                              
                        if arq_tot
                        then do:
                        find first tt-fiscal where 
                                   tt-fiscal.etbcod  = vemite and
                                   tt-fiscal.opfcod  = vopccod and
                                   tt-fiscal.alicota = movim.movalicms
                                            no-error.
                        if not avail tt-fiscal 
                        then do:
                
                            create tt-fiscal.
                            assign tt-fiscal.etbcod  = vemite
                                   tt-fiscal.opfcod  = vopccod
                                   tt-fiscal.alicota = movim.movalicms.
                               
                        end.

                          
                        assign tt-fiscal.totsai  = tt-fiscal.totsai + 
                                                   (movim.movpc * movim.movqtm)
                               tt-fiscal.base    = tt-fiscal.base  + base_icms
                               tt-fiscal.icms    = tt-fiscal.icms  + 
                                           ( ((movim.movpc * movim.movqtm) * 
                                             (movim.movalicms / 100)) ) 
                               tt-fiscal.ipi     = tt-fiscal.ipi  + ipi_item
                               tt-fiscal.valcon  = tt-fiscal.valcon + 
                                                   val_contabil
                               tt-fiscal.outras  = tt-fiscal.outras + 
                                                   itvaloroutroicm 
                               tt-fiscal.isentas = tt-fiscal.isenta + visenta.
                              
                        end.
                        else do:
                        if vop = vopccod  
                        then do:  
                            find first tt-plani where 
                                       tt-plani.rec  = recid(plani) and
                                       tt-plani.tipo = "E" no-error.
                            if not avail tt-plani  
                            then do:  
                                create tt-plani. 
                                assign tt-plani.rec     = recid(plani)
                                       tt-plani.numero  = plani.numero 
                                       tt-plani.tipo    = "E"
                                       tt-plani.opf     = vopccod
                                       tt-plani.serie   = "01" 
                                       tt-plani.vemi    = vemite
                                       tt-plani.vdata   = vdatexp
                                       tt-plani.tot_pla = plani.platot 
                                       tt-plani.val_icm = plani.icms.
                            end.   
                            tt-plani.bas_icm = tt-plani.bas_icm + base_icms.
                            tt-plani.val_con = tt-plani.val_con + val_contabil.
                    
                        end.
                        end.
                    end.
                end.
                else do:
                
                    base_icms = 0.
                    itvaloroutroicm = plani.platot.
                    

                    val_contabil = plani.platot.
                    visenta = 0.

                    voutras = val_contabil.
 
  
                    if vopccod = "6901"  
                    then assign visenta = val_contabil  
                                          - (plani.platot) 
                                          - plani.ipi.
                                voutras = val_contabil 
                                          - (plani.platot) 
                                          - plani.ipi - visenta.
                    
                    if vopccod = "5202" or
                       vopccod = "6202"
                    then assign base_icms = plani.platot 
                                itvaloroutroicm = 0
                                val_contabil = val_contabil + plani.ipi.
                  
                    vobs[1] = plani.notobs[1]. 
                    vobs[2] = plani.notobs[2].
                        
                    if vobs[1] = "" and 
                       plani.ipi > 0
                    then vobs[1] = "VALOR IPI: " + 
                                   string(plani.ipi,">>,>>9.99").
                                   
                    if arq_tot
                    then do:  
                    find first tt-fiscal where 
                               tt-fiscal.etbcod  = vemite and
                               tt-fiscal.opfcod  = vopccod and
                               tt-fiscal.alicota = 0 no-error.
                    if not avail tt-fiscal 
                    then do:
                    
                        create tt-fiscal.
                        assign tt-fiscal.etbcod  = vemite
                               tt-fiscal.opfcod  = vopccod
                               tt-fiscal.alicota = 0.
                               
                    end.

                          
                    assign tt-fiscal.totsai  = tt-fiscal.totsai + plani.platot
                           tt-fiscal.base    = tt-fiscal.base  + base_icms
                           tt-fiscal.icms    = tt-fiscal.icms  + 
                                          (plani.platot * (plani.alicms / 100)) 
                           tt-fiscal.ipi     = tt-fiscal.ipi   + 0
                           tt-fiscal.valcon  = tt-fiscal.valcon + val_contabil
                           tt-fiscal.outras  = tt-fiscal.outras + voutras
                           tt-fiscal.isentas = tt-fiscal.isenta + visenta.
                    end.
                    else do:
                    
                    if vop = vopccod   
                    then do:   
                        find first tt-plani where 
                                   tt-plani.rec  = recid(plani) and
                                   tt-plani.tipo = "E" no-error.
                        if not avail tt-plani   
                        then do:   
                            create tt-plani. 
                            assign tt-plani.rec     = recid(plani)
                                   tt-plani.numero  = plani.numero 
                                   tt-plani.tipo    = "E"
                                   tt-plani.opf     = vopccod
                                   tt-plani.serie   = "01" 
                                   tt-plani.vemi    = vemite
                                   tt-plani.vdata   = vdatexp
                                   tt-plani.tot_pla = plani.platot 
                                   tt-plani.val_con = val_contabil 
                                   tt-plani.val_icm = plani.icms
                                   tt-plani.bas_icm = base_icms.
                        end.
                    end.           
                    end.
                end.
            end.                                 
        end.
    end.
