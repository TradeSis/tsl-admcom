{admcab.i} 

def var frete_item like movim.movpc.
def var valicm  as dec.
def var tip-doc as char.
def var ie_subst_trib as char.
def var per_desc like plani.platot.
def var valor_item like plani.platot.
def var protot_capa like plani.platot.
def var desc_capa like plani.platot.
def var nome_produto as char format "x(45)".  
def var v-ser as char.
def var v-mod as char.
def var v-tipo as char format "x(01)". 
def var vnumero like fiscal.numero.
def var totpla like plani.platot.
def buffer bmovim for movim.
def var vemi like plani.emite.
def var vdesti like plani.etbcod.
def var data_rec like plani.pladat. 
def var recpla as recid.
def var varq as char.
def var tot_pro like plani.platot.
def var base_subs  like plani.platot.
def var valor_subs like plani.platot.
def var vcodfis as char format "x(10)".
def var vsittri as char format "x(03)".
def var base_icms like plani.platot.
def var base_ipi  like plani.platot.
def var vdes      like plani.platot. 
def var vipi      like plani.platot.
def var vicms     like plani.platot.
def var visenta   like plani.isenta.
def var voutras   like plani.platot.
def var val_contabil like plani.platot.
def var vopccod as char.
def var vali    as int.
def var vcod as char format "x(18)".
def var ali_icms like movim.movalipi.
def var ali_ipi  like movim.movalicms.
def var vobs     like plani.notobs.


def input parameter vetbcod like estab.etbcod.
def input parameter vop  like opcom.opccod.
def input parameter vdti like plani.pladat.
def input parameter vdtf like plani.pladat.
def input parameter arq_tot as log.

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
 
                                                         
                                                         
    for each tipmov where tipmov.movtdc = 4 or
                          tipmov.movtdc = 12 no-lock:
                          
        
        for each estab where if vetbcod = 0
                             then true 
                             else estab.etbcod = vetbcod no-lock:
         
            for each fiscal where fiscal.movtdc = tipmov.movtdc and
                                  fiscal.desti  = estab.etbcod  and
                                  fiscal.plarec >= vdti         and
                                  fiscal.plarec <= vdtf no-lock:

                v-mod = "01".
                v-ser = "01".
                vcod = "".
                recpla = ?.
                v-tipo = "T".
                
                if fiscal.platot = 0 
                then next.

                if tipmov.movtdc = 4 
                then do:  
                    find plani where plani.etbcod = estab.etbcod 
                                 and plani.emite  = fiscal.emite   
                                 and plani.movtdc = tipmov.movtdc  
                                 and plani.serie  = fiscal.serie   
                                 and plani.numero = fiscal.numero 
                                            no-lock no-error.
                    if not avail plani  
                    then do:
                
                        find plani where plani.etbcod = estab.etbcod 
                                     and plani.emite  = fiscal.emite 
                                     and plani.movtdc = 15 
                                     and plani.serie  = fiscal.serie 
                                     and plani.numero = fiscal.numero 
                                             no-lock no-error.
                        if avail plani
                        then recpla = recid(plani).
                    end.
                    else recpla = recid(plani).
                end.     
                else do:
                    find first plani where plani.etbcod = estab.etbcod 
                                and plani.emite  = fiscal.emite 
                                and plani.movtdc = 12 
                                and plani.serie  = fiscal.serie 
                                and plani.nottran = fiscal.numero 
                                            no-lock no-error.
                    if not avail plani
                    then do:

                        find first plani where plani.etbcod = estab.etbcod 
                                           and plani.emite  = fiscal.emite 
                                           and plani.movtdc = 12 
                                           and plani.serie  = fiscal.serie 
                                           and plani.numero = fiscal.numero 
                                            no-lock no-error.
                        if avail plani
                        then assign vcod = "E" + 
                                           string(fiscal.emite,"9999999") + 
                                           "          "
                                    recpla = recid(plani)
                                    v-tipo = "P".

                    end.
                    else do:
                
                        assign vcod = "E" + string(fiscal.emite,"9999999") + 
                                      "          "              
                                      recpla = recid(plani)
                                      v-tipo = "P".

                    
                    end.
                end. 

                if (estab.etbcod > 900 or {conv_igual.i estab.etbcod}
                   or  estab.etbcod = 22) and
                    fiscal.movtdc = 4
                then do:
                    find forne where forne.forcod = fiscal.emite 
                                no-lock no-error.  
                    if not avail forne  
                    then next.
                    vcod = "F" + string(forne.forcod,"9999999") + "          ". 
                    find first frete where frete.forcod = forne.forcod
                            no-lock no-error.
                    if avail frete 
                    then assign
                         vcod = "T" + string(forne.forcod,"9999999") +
                                "          "
                         v-ser = "U"
                         v-mod = "08".          
                    
                end.
                else assign vcod = "E" + string(fiscal.emite,"9999999") + 
                                    "          "
                                    v-tipo = "P".  
                                                   
                if fiscal.opfcod = 1102 or
                   fiscal.opfcod = 2102
                then do:
                    find forne where forne.forcod = fiscal.emite 
                            no-lock no-error.  
                    if not avail forne  
                    then next.
                    vcod = "F" + string(forne.forcod,"9999999") + "          ".
                    v-tipo = "T".  
                   
                end.
                   
                if fiscal.opfcod = 1915 or
                   fiscal.opfcod = 2915 or
                   fiscal.opfcod = 2910 or
                   fiscal.opfcod = 1253
                then do: 
                
                    find forne where forne.forcod = fiscal.emite 
                                no-lock no-error.  
                    if not avail forne  
                    then next.
                    vcod = "F" + string(forne.forcod,"9999999") +
                            "          ".               
                    find first frete where frete.forcod = forne.forcod
                            no-lock no-error.
                    if avail frete 
                    then assign
                         vcod = "T" + string(forne.forcod,"9999999") + 
                                "          "
                         v-ser = "U"
                         v-mod = "08".          
                end.

                if fiscal.opfcod = 1353 or
                   fiscal.opfcod = 2353
                then assign v-mod = "08" 
                            v-ser = "U".


                vopccod = string(fiscal.opfcod). 
                

                if fiscal.bicms > 0 
                then vali = int((fiscal.icms * 100) / fiscal.bicms). 
                else vali = 0.
                
                if recpla <> ?
                then find plani where recid(plani) = recpla no-lock no-error. 
                    
                if fiscal.desti = fiscal.emite
                then v-tipo = "P".
                else v-tipo = "T".
                
                    
                if avail plani
                then do:
                
                    v-ser = plani.serie.
                    if v-ser = "U"
                    then v-ser = "01".
                     


                    ie_subst_trib = "".
                    if plani.icmssubst > 0
                    then do:
                        find forne where forne.forcod = plani.emite 
                                    no-lock no-error.
                        if avail forne
                        then ie_subst_trib = forne.foriesub.
                    
                    end.

                    
                    
                    if plani.movtdc = 12
                    then data_rec = plani.pladat.
                    else data_rec = plani.datexp.
               
                    find first bmovim where 
                               bmovim.etbcod = plani.etbcod and
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
                   
                        frete_item = 0.
                        if movim.movdev > 0
                        then frete_item = movim.movdev.
                        
                        
                        if movim.movpc = 0 or
                           movim.movqtm = 0
                        then next. 
 
                        tot_pro = movim.movqtm * movim.movpc.
                        vcodfis = "".
                        vsittri = "".
                    
                        find produ where produ.procod = movim.procod 
                                            no-lock no-error.
                                        
                        if not avail produ
                        then next.
                        
                    
                        if produ.codfis > 0
                        then vcodfis = substring(string(produ.codfis),1,4) + 
                                       "." +   
                                       substring(string(produ.codfis),5,2) +  
                                       "." +  
                                       substring(string(produ.codfis),7,2).
                        if produ.codori > 0
                        then vsittri = string(produ.codori) + 
                                       string(produ.codtri).
                        
                        base_subs  = 0.
                        valor_subs = 0.
                    
                    
                        if (vsittri = "170" or
                            vsittri = "270") and
                           fiscal.movtdc <> 12 
                        then do:
                        
                            base_subs  = tot_pro + 
                                         ((tot_pro - (tot_pro * 0.0519)) 
                                         * 0.578259).
                                    
                            valor_subs = (tot_pro + ((tot_pro - 
                                         (tot_pro * 0.0519)) * 0.578259))
                                          * 0.0965156.


                        end.   
                    
                        base_ipi = 0.
                    
                        if plani.ipi > 0
                        then base_ipi = ((movim.movpc + frete_item) 
                                         * movim.movqtm).
                            
                        if plani.protot > 0
                        then

                        base_icms = (fiscal.bicms / plani.protot) * 
                                    (movim.movpc * movim.movqtm).
     
                        if fiscal.platot > 0
                        then vdes = (plani.descprod / fiscal.platot) * 
                                    (movim.movpc * movim.movqtm).
                  
                        vipi  = base_ipi  * (movim.movalipi / 100).
                        vicms = base_icms * (movim.movalicms / 100). 
                    
                        
                       
                        val_contabil = ((movim.movpc + frete_item) 
                                        * movim.movqtm) + vipi.
 

                        visenta = val_contabil - base_icms - vipi.
                        if visenta < 0
                        then visenta = 0.

                        voutras = val_contabil - base_icms - vipi - visenta.
                        
                                                       
                        if fiscal.opfcod = 1915 or
                           fiscal.opfcod = 2915 
                        then assign voutras = val_contabil
                                    visenta = 0.

                        
                        if voutras < 0
                        then voutras = 0.
                        
                        valor_item = movim.movpc.

                        protot_capa = plani.protot.
                        desc_capa   = plani.descprod.
                        
                        per_desc   = plani.descprod / plani.protot.
                        
                        if vopccod = "1949" or 
                           vopccod = "2949"
                        then do:   
                            
                            if plani.bicms > 0
                            then assign base_icms = val_contabil
                                        voutras   = 0.
                            else assign base_icms = 0
                                        voutras   = val_contabil.    
                        end.
                        
                        
                        valicm = ((valor_item * movim.movqtm) * 
                                     (movim.movalicms / 100)).
                        
                        
                        
                        if vopccod = "1102" or
                           vopccod = "2102" or
                           vopccod = "1202" or 
                           vopccod = "1910" or
                           vopccod = "2910" 

                           /*
                           vopccod = "1949" or
                           vopccod = "2949" or
                           vopccod = "2102" or 
                           vopccod = "2124" or
                           vopccod = "2353" */
                        then do: 
                            
                            visenta = 0.
                            run trata_cfop.p (input vopccod, 
                                              input movim.procod,
                                              input ((movim.movpc + 
                                                      frete_item)
                                                     * movim.movqtm),
                                              input movim.movalicms,   
                                              input movim.movicms,   
                                              input movim.movsubst,
                                              output base_icms,  
                                              output visenta,  
                                              output voutras,  
                                              output vsittri,
                                              output valicm).
                           
                            find clafis where clafis.codfis = produ.codfis
                                        no-lock no-error.
                            if avail clafis
                            then vsittri = string(clafis.sittri).
                                        
                            
                        end.   



                        vobs[1] = plani.notobs[1].
                        vobs[2] = plani.notobs[2].
                        
                        if vobs[1] = "" and
                           fiscal.ipi > 0
                        then vobs[1] = "VALOR IPI: " + 
                                       string(fiscal.ipi,">>,>>9.99").


                        
                        if arq_tot
                        then do:  
                        find first tt-fiscal where 
                                   tt-fiscal.etbcod  = estab.etbcod and
                                   tt-fiscal.opfcod  = vopccod and
                                   tt-fiscal.alicota = movim.movalicms
                                            no-error.
                        if not avail tt-fiscal
                        then do:
                
                            create tt-fiscal.
                            assign tt-fiscal.etbcod  = estab.etbcod
                                   tt-fiscal.opfcod  = vopccod
                                   tt-fiscal.alicota = movim.movalicms.
                           
                        end.

                        if base_icms = ?
                        then base_icms = 0.
                        if valicm = ?
                        then valicm = 0.
                        if visenta = ?
                        then visenta = 0.

                        assign tt-fiscal.totsai  = tt-fiscal.totsai + 
                                                   (movim.movpc * movim.movqtm)
                               tt-fiscal.base    = tt-fiscal.base  + 
                                                   base_icms
                               tt-fiscal.icms    = tt-fiscal.icms  + valicm
                               tt-fiscal.ipi     = tt-fiscal.ipi   + vipi
                               tt-fiscal.valcon  = tt-fiscal.valcon + 
                                                   val_contabil
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
                                       tt-plani.serie   = v-ser 
                                       tt-plani.vemi    = fiscal.emite
                                       tt-plani.vdata   = fiscal.plarec
                                       tt-plani.tot_pla = fiscal.platot
                                       tt-plani.bas_icm = protot_capa 
                                       tt-plani.val_icm = fiscal.icms.
                            end.  
                            assign tt-plani.val_con = val_contabil.               
                        end.
                        end. 
                        end.
                    end.
                    else do:
                       
                        if fiscal.emite = 101998 or
                           fiscal.emite = 102044 or 
                           fiscal.emite = 533    or 
                           fiscal.emite = 100071 or 
                           fiscal.emite = 103114
                        then vcod = "F" + "0100725" + "          ".  
 
 
                        tot_pro = fiscal.platot.
                        vcodfis = "".
                        vsittri = "".
                    
                    
                        base_subs  = 0.
                        valor_subs = 0.
                        
                        vipi  = fiscal.ipi.

                        base_icms = ((fiscal.bicms / fiscal.platot) * 
                                     (fiscal.platot)) - vipi.

                        base_ipi = base_icms.
 
                        vdes = 0.
                  
                    
                        vicms = base_icms * (fiscal.alicms / 100). 
                    
                    
                    
                        val_contabil = (fiscal.platot) + vipi.
 
                        visenta = val_contabil - (fiscal.platot) 
                                  - vipi.
                       
                        if visenta < 0
                        then visenta.
                        
                        voutras = val_contabil - fiscal.platot 
                                  - vipi - visenta.
                       
                        if voutras < 0
                        then voutras = 0.
                        
                                    
                        if fiscal.opfcod = 1915 or
                           fiscal.opfcod = 2915 
                        then voutras = val_contabil.
                        
                                   
                        if vopccod = "1949" or
                           vopccod = "2949" 
                        then do:   
                
                            if plani.bicms > 0
                            then assign base_icms = val_contabil
                                        voutras   = 0.
                            else assign base_icms = 0
                                        voutras   = val_contabil.    
                       
                        end.

                        vnumero = fiscal.numero.
                        if vnumero >= 1000000
                        then vnumero = int(substring(string(vnumero),2,6)).
                        
                        vobs[1] = fiscal.plaobs[1].
                        vobs[2] = fiscal.plaobs[2].
                        
                        if vobs[1] = "" and
                           fiscal.ipi > 0
                        then vobs[1] = "VALOR IPI: " + 
                                       string(fiscal.ipi,">>,>>9.99").

                        if arq_tot
                        then do:  
                        find first tt-fiscal where 
                                   tt-fiscal.etbcod  = estab.etbcod and
                                   tt-fiscal.opfcod  = vopccod and
                                   tt-fiscal.alicota = fiscal.alicms
                                            no-error.
                        if not avail tt-fiscal
                        then do:
                
                            create tt-fiscal.
                            assign tt-fiscal.etbcod  = estab.etbcod
                                   tt-fiscal.opfcod  = vopccod
                                   tt-fiscal.alicota = fiscal.alicms.
                           
                        end.

                          
                        assign tt-fiscal.totsai  = tt-fiscal.totsai + 
                                                   fiscal.platot
                               tt-fiscal.base    = tt-fiscal.base  + 
                                                   base_icms
                               tt-fiscal.icms    = tt-fiscal.icms  + vicms
                               tt-fiscal.ipi     = tt-fiscal.ipi   + vipi
                               tt-fiscal.valcon  = tt-fiscal.valcon + 
                                                   val_contabil
                               tt-fiscal.outras  = tt-fiscal.outras + voutras
                               tt-fiscal.isentas = tt-fiscal.isenta + visenta.
                 
                        end.
                        else do: 
                        if vop = vopccod  
                        then do:  
                            find first tt-plani where 
                                       tt-plani.rec  = recid(fiscal) and
                                       tt-plani.tipo = "E" no-error.
                            if not avail tt-plani  
                            then do:  
                                create tt-plani. 
                                assign tt-plani.rec     = recid(fiscal)
                                       tt-plani.numero  = vnumero 
                                       tt-plani.tipo    = "E"
                                       tt-plani.opf     = vopccod
                                       tt-plani.serie   = v-ser 
                                       tt-plani.vemi    = fiscal.emite
                                       tt-plani.vdata   = fiscal.plarec
                                       tt-plani.tot_pla = fiscal.platot 
                                       tt-plani.val_con = val_contabil 
                                       tt-plani.bas_icm = fiscal.platot 
                                       tt-plani.val_icm = fiscal.icms.
                            end. 
                        end.
                        end.
                    end.
                end.
                else do: 

                    tot_pro = fiscal.platot.
                    vcodfis = "".
                    vsittri = "".
                    
                    
                    base_subs  = 0.
                    valor_subs = 0.
                    
                    
                    base_ipi = 0.
                    
                    if fiscal.ipi > 0
                    then base_ipi = fiscal.platot.

                    base_icms = (fiscal.bicms / fiscal.platot) * 
                                (fiscal.platot).
                                
                                                       
                    vdes = 0.
                  
                    vipi  = 0.
                    
                    vicms = base_icms * (fiscal.alicms / 100). 
                    
                    
                    val_contabil = fiscal.platot + vipi.
 
                    visenta = val_contabil - (fiscal.platot) 
                              - vipi.
                    if visenta < 0
                    then visenta.

                    voutras = val_contabil - (fiscal.platot) 
                              - vipi - visenta.

                    if voutras < 0
                    then voutras = 0.

                    vnumero = fiscal.numero. 
                    if vnumero >= 1000000
                    then vnumero = int(substring(string(vnumero),2,6)).
                                                       
                    if fiscal.opfcod = 1124 or
                       fiscal.opfcod = 2124 or
                       fiscal.opfcod = 2902
                    then do:
                       
                        val_contabil = val_contabil + fiscal.ipi.
               
                        run trata_cfop.p (input vopccod, 
                                          input 0,
                                          input fiscal.platot, 
                                          input fiscal.alicms,    
                                          input fiscal.icms,     
                                          input 0,      
                                          output base_icms,   
                                          output visenta,   
                                          output voutras,   
                                          output vsittri, 
                                          output valicm).
                                          
                    end.
                    
                    if fiscal.opfcod = 1902 or  
                       fiscal.opfcod = 1915 or 
                       fiscal.opfcod = 2915 
                    then voutras = val_contabil.
                    
                                  
                    if vopccod = "1949" or 
                       vopccod = "2949" or
                       vopccod = "1253"
                    then do:   
                
                        if fiscal.bicms > 0
                        then assign base_icms = val_contabil
                                    voutras   = 0.
                        else assign base_icms = 0
                                    voutras   = val_contabil.    
                    end.

 
                    vobs[1] = fiscal.plaobs[1].
                    vobs[2] = fiscal.plaobs[2].
                        
                    if vobs[1] = "" and 
                       fiscal.ipi > 0
                    then vobs[1] = "VALOR IPI: " + 
                                   string(fiscal.ipi,">>,>>9.99").

                    
                    tip-doc = "NF".
                    if v-mod = "08"
                    then assign tip-doc = "CTRC"
                                v-ser   = "U".
                    if arq_tot
                    then do:
                    find first tt-fiscal where  
                               tt-fiscal.etbcod  = estab.etbcod and
                               tt-fiscal.opfcod  = vopccod and
                               tt-fiscal.alicota = fiscal.alicms
                                            no-error.
                    if not avail tt-fiscal 
                    then do:
                
                        create tt-fiscal.
                        assign tt-fiscal.etbcod  = estab.etbcod
                               tt-fiscal.opfcod  = vopccod
                               tt-fiscal.alicota = fiscal.alicms.
                           
                    end.

                          
                    assign tt-fiscal.totsai  = tt-fiscal.totsai + 
                                               fiscal.platot
                           tt-fiscal.base    = tt-fiscal.base  + 
                                               base_icms
                           tt-fiscal.icms    = tt-fiscal.icms  + vicms
                           tt-fiscal.ipi     = tt-fiscal.ipi   + vipi
                           tt-fiscal.valcon  = tt-fiscal.valcon + 
                                               val_contabil
                           tt-fiscal.outras  = tt-fiscal.outras + voutras
                           tt-fiscal.isentas = tt-fiscal.isenta + visenta.
                    end.
                    else do:

                    
                    if vop = vopccod   
                    then do:   
                        find first tt-plani where 
                                   tt-plani.rec  = recid(fiscal) and
                                   tt-plani.tipo = "E" no-error.
                        if not avail tt-plani   
                        then do:   
                            create tt-plani. 
                            assign tt-plani.rec     = recid(fiscal)
                                   tt-plani.numero  = vnumero 
                                   tt-plani.tipo    = "E"
                                   tt-plani.opf     = vopccod
                                   tt-plani.serie   = v-ser 
                                   tt-plani.vemi    = fiscal.emite
                                   tt-plani.vdata   = fiscal.plarec
                                   tt-plani.tot_pla = fiscal.platot 
                                   tt-plani.val_con = val_contabil 
                                   tt-plani.bas_icm = base_icms
                                   tt-plani.val_icm = fiscal.icms.
                        end. 
                    end.
                    end.
                end.
            end.                                 
                         
            
        end.
        
    end.
    

    
    for each estab where if vetbcod = 0 
                         then true  
                         else estab.etbcod = vetbcod no-lock:
        for each tipmov where tipmov.movtdc = 6 or 
                              tipmov.movtdc = 9 or
                              tipmov.movtdc = 22 no-lock,  
            each plani where plani.movtdc = tipmov.movtdc and 
                             plani.desti  = estab.etbcod  and 
                             plani.datexp >= vdti         and
                             plani.datexp <= vdtf  no-lock:
                                 
            if plani.platot = 0 or
               plani.protot = 0
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
        
            totpla = totpla + plani.platot.

            
            vemi = plani.emite.
            if vemi = 998
            then vemi = 995.
            
            vdesti = plani.desti.
            if vdesti = 998
            then vdesti = 995.



            vopccod = "1152". 
            vcod = "E" + string(vemi,"9999999") + "          ". 


            if plani.bicms > 0  
            then vali = int((plani.icms * 100) / plani.bicms). 
            else vali = 0.

    
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
                  
                frete_item = 0. 
                if movim.movdev > 0 
                then frete_item = movim.movdev.
                        
                if movim.movpc = 0 or
                   movim.movqtm = 0
                then next.       
 
                tot_pro = movim.movqtm * movim.movpc. 
                vcodfis = "". 
                vsittri = "".
                    
                find produ where produ.procod = movim.procod no-lock no-error.
                                        
                if not avail produ 
                then next.
                    
                if produ.codfis > 0
                then vcodfis = substring(string(produ.codfis),1,4) + 
                                   "." +   
                               substring(string(produ.codfis),5,2) +  
                                   "." +  
                               substring(string(produ.codfis),7,2).
                if produ.codori > 0
                then vsittri = string(produ.codori) + string(produ.codtri).
                    
                base_subs  = 0. 
                valor_subs = 0.
                    
                    
                base_ipi = 0.
                    
                if plani.ipi > 0 
                then base_ipi = (movim.movpc * movim.movqtm).

                base_icms = (plani.bicms / plani.protot) * 
                            (movim.movpc * movim.movqtm).
     
 
                vdes = (plani.descprod / plani.platot) * 
                       (movim.movpc * movim.movqtm).
                           
                  
                vipi  = base_ipi  * (movim.movalipi / 100).
                vicms = base_icms * (movim.movalicms / 100). 
                    
                    
                val_contabil = (movim.movpc * movim.movqtm) + vipi.
                
                visenta = val_contabil - (movim.movpc * movim.movqtm) 
                              - vipi.
                if visenta < 0
                then visenta = 0.
                           
                voutras = val_contabil.
                
                if arq_tot
                then do:  
                find first tt-fiscal where 
                           tt-fiscal.etbcod  = vdesti and
                           tt-fiscal.opfcod  = vopccod and
                           tt-fiscal.alicota = movim.movalicms
                                            no-error.
                if not avail tt-fiscal 
                then do:
                
                    create tt-fiscal.
                    assign tt-fiscal.etbcod  = vdesti
                           tt-fiscal.opfcod  = vopccod
                           tt-fiscal.alicota = movim.movalicms.
                           
                end.

                          
                assign tt-fiscal.totsai  = tt-fiscal.totsai + 
                                           (movim.movpc * movim.movqtm)
                       tt-fiscal.base    = tt-fiscal.base  + base_icms
                       tt-fiscal.icms    = tt-fiscal.icms  + 
                                           ( ((movim.movpc * movim.movqtm) * 
                                             (movim.movalicms / 100)) ) 
                       tt-fiscal.ipi     = tt-fiscal.ipi   + vipi
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
                               tt-plani.vemi    = vemi
                               tt-plani.vdata   = plani.datexp
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
                 
                
                
                tot_pro = plani.platot.
                vcodfis = "". 
                vsittri = "".
                    
                base_subs  = 0. 

                valor_subs = 0.
                    
                    
                base_ipi = 0.
                    
                if plani.ipi > 0 
                then base_ipi = plani.platot.

                base_icms = (plani.bicms / plani.protot) * 
                            plani.platot.
     
 
                vdes = (plani.descprod / plani.platot) * 
                       plani.platot.
                           
                  
                vipi  = base_ipi  * (plani.alipi / 100).
                vicms = base_icms * (plani.alicms / 100). 
                    
                    
                val_contabil = plani.platot + vipi.
                visenta = val_contabil - plani.platot - vipi.
                
                if visenta < 0
                then visenta = 0.

                voutras = val_contabil.
                
                
                if arq_tot
                then do:  
                find first tt-fiscal where 
                           tt-fiscal.etbcod  = vdesti  and
                           tt-fiscal.opfcod  = vopccod and
                           tt-fiscal.alicota = plani.alicms no-error.
                if not avail tt-fiscal 
                then do:
                
                    create tt-fiscal.
                    assign tt-fiscal.etbcod  = vdesti
                           tt-fiscal.opfcod  = vopccod
                           tt-fiscal.alicota = plani.alicms.
                           
                end.

                          
                assign tt-fiscal.totsai  = tt-fiscal.totsai + plani.platot
                       tt-fiscal.base    = tt-fiscal.base  + base_icms
                       tt-fiscal.icms    = tt-fiscal.icms  + 
                                          (plani.platot * (plani.alicms / 100)) 
                       tt-fiscal.ipi     = tt-fiscal.ipi   + vipi
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
                               tt-plani.vemi    = vemi
                               tt-plani.vdata   = plani.datexp
                               tt-plani.tot_pla = plani.platot 
                               tt-plani.val_con = val_contabil 
                               tt-plani.bas_icm = base_icms
                               tt-plani.val_icm = plani.icms.
                    end. 
                end.
                end.
           end.   
        end.  
    end.            
    
    
    /**************** energia eletrica ********************/
                
    
    for each estab where if vetbcod = 0 
                         then true  
                         else estab.etbcod = vetbcod no-lock:
                         
        for each plani where plani.movtdc = 11            and 
                             plani.desti  = estab.etbcod  and 
                             plani.datexp >= vdti         and
                             plani.datexp <= vdtf  no-lock:
                                 
        
            nome_produto = "Credito 50% Energia Eletrica - Ref. Mes " +
                           string(month(plani.datexp),"99").

            totpla = totpla + plani.platot.

            
            vemi = plani.emite.
            if vemi = 998
            then vemi = 995.
            
            vdesti = plani.desti.
            if vdesti = 998
            then vdesti = 995.



            vopccod = "1949". 
            vcod = "E" + string(vemi,"9999999") + "          ". 


            if plani.bicms > 0  
            then vali = int((plani.icms * 100) / plani.bicms). 
            else vali = 0.

               
                
            tot_pro = plani.platot. 
            vcodfis = "".  
            vsittri = "".
                    
            base_subs  = 0. 

            valor_subs = 0.
                    
                    
            base_ipi = 0.
                   
            if plani.ipi > 0  
            then base_ipi = plani.platot.

            base_icms = plani.bicms.
     
 
                  
            vipi  = base_ipi  * (plani.alipi / 100). 
            vicms = base_icms * (plani.alicms / 100). 
                    
                    
            val_contabil = plani.platot + vipi.
            visenta = val_contabil - plani.platot - vipi.
                
            if visenta < 0
            then visenta = 0.

            voutras = val_contabil.
            
            find first bmovim where bmovim.etbcod = plani.etbcod and
                                    bmovim.placod = plani.placod and
                                    bmovim.movtdc = plani.movtdc and
                                    bmovim.movdat = plani.pladat 
                                                no-lock no-error.
            if avail bmovim  
            then do: 

                vcod = "F" + string(vemi,"9999999") + "          ". 


                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat no-lock:
                   
                    frete_item = 0. 
                    if movim.movdev > 0 
                    then frete_item = movim.movdev.
                        
                    if movim.movpc = 0 or
                       movim.movqtm = 0
                    then next.       
 
                    tot_pro = movim.movqtm * movim.movpc. 
                    vcodfis = "". 
                    vsittri = "".
                    
                    find produ where produ.procod = movim.procod 
                            no-lock no-error.
                                        
                    if not avail produ 
                    then next.
                    
                    if produ.codfis > 0
                    then vcodfis = substring(string(produ.codfis),1,4) + 
                                   "." +   
                                   substring(string(produ.codfis),5,2) +  
                                   "." +  
                                   substring(string(produ.codfis),7,2).
                    if produ.codori > 0
                    then vsittri = string(produ.codori) + string(produ.codtri).
                    
                    base_subs  = 0. 
                    valor_subs = 0.
                    
                    
                    base_ipi = 0.
                    
                    if plani.ipi > 0 
                    then base_ipi = (movim.movpc * movim.movqtm).

                    base_icms = (plani.bicms / plani.protot) * 
                                (movim.movpc * movim.movqtm).
     
 
                    vdes = (plani.descprod / plani.platot) * 
                           (movim.movpc * movim.movqtm).
                           
                  
                    vipi  = base_ipi  * (movim.movalipi / 100).
                    vicms = base_icms * (movim.movalicms / 100). 
                    
                    
                    val_contabil = (movim.movpc * movim.movqtm) + vipi. 
                    visenta = val_contabil - (movim.movpc * movim.movqtm) 
                              - vipi.
                    
                    if visenta < 0
                    then visenta = 0.
                    voutras = val_contabil.
                    
                    
                    if plani.bicms > 0
                    then assign base_icms = val_contabil
                                voutras   = 0.
                    else assign base_icms = 0
                                voutras   = val_contabil.    
                        
                      
                    if arq_tot
                    then do:
                    find first tt-fiscal where 
                               tt-fiscal.etbcod  = vdesti  and
                               tt-fiscal.opfcod  = vopccod and
                               tt-fiscal.alicota = movim.movalicms no-error.
                    if not avail tt-fiscal 
                    then do:
                
                        create tt-fiscal.
                        assign tt-fiscal.etbcod  = vdesti
                               tt-fiscal.opfcod  = vopccod
                               tt-fiscal.alicota = movim.movalicms.
                               
                    end.
        
                          
                    assign tt-fiscal.totsai  = tt-fiscal.totsai + 
                                               (movim.movpc * movim.movqtm)
                           tt-fiscal.base    = tt-fiscal.base  + base_icms
                           tt-fiscal.icms    = tt-fiscal.icms  + 
                                               (((movim.movpc * movim.movqtm) * 
                                                (movim.movalicms / 100))) 
                           tt-fiscal.ipi     = tt-fiscal.ipi   + vipi
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
                                   tt-plani.vemi    = vemi
                                   tt-plani.vdata   = plani.datexp
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
            
                if arq_tot
                then do:
                find first tt-fiscal where 
                           tt-fiscal.etbcod  = vdesti  and
                           tt-fiscal.opfcod  = vopccod and
                           tt-fiscal.alicota = plani.alicms no-error.
                if not avail tt-fiscal 
                then do:
                    
                    create tt-fiscal.
                    assign tt-fiscal.etbcod  = vdesti
                           tt-fiscal.opfcod  = vopccod
                           tt-fiscal.alicota = plani.alicms.
                             
                end.
        
                          
                assign tt-fiscal.totsai  = tt-fiscal.totsai + plani.platot
                       tt-fiscal.base    = tt-fiscal.base  + base_icms
                       tt-fiscal.icms    = tt-fiscal.icms  + plani.icms
                       tt-fiscal.ipi     = tt-fiscal.ipi   + vipi
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
                               tt-plani.vemi    = vemi
                               tt-plani.vdata   = plani.datexp
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
    
