{admcab.i}
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
def stream stela.
def var base_icms like plani.platot.
def var base_ipi  like plani.platot.
def var vdes      like plani.platot. 
def var vipi      like plani.platot.
def var vicms     like plani.platot.
def var visenta   like plani.isenta.
def var voutras   like plani.platot.
def var val_contabil like plani.platot.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vopccod as char.
def var vali    as int.
def var vcod as char format "x(18)".
def var ali_icms like movim.movalipi.
def var ali_ipi  like movim.movalicms.
repeat:

    update vetbcod with frame f1.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom with frame f1.
    else do:
    
        find estab where estab.etbcod = vetbcod no-lock.

        display estab.etbnom no-label with frame f1.
        
    end.
    
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1 side-label width 80.

 

    varq = "l:\audit\rem" + string(vetbcod,">>9") + "_" +
           string(day(vdti),"99") + 
           string(month(vdti),"99") + 
           string(year(vdti),"9999") + "_" + 
          
           string(day(vdtf),"99") + 
           string(month(vdtf),"99") + 
           string(year(vdtf),"9999") + ".txt".

                
                                                               
    output to value(varq).
                                                               
    output stream stela to terminal.
    for each tipmov where tipmov.movtdc = 4 or
                          tipmov.movtdc = 12 no-lock:
                          
        
        for each estab where if vetbcod = 0
                             then true 
                             else estab.etbcod = vetbcod no-lock:
         
            for each fiscal where fiscal.movtdc = tipmov.movtdc and
                                  fiscal.desti  = estab.etbcod  and
                                  fiscal.plarec >= vdti         and
                                  fiscal.plarec <= vdtf no-lock:

                vcod = "".
                recpla = ?.
                if fiscal.opfcod  = 1915 or
                   fiscal.opfcod  = 2915
                then.
                else next.
                

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
                                           "          ".              
                                    recpla = recid(plani).

                    end.
                    else do:
                        assign vcod = "E" + string(fiscal.emite,"9999999") + 
                                      "          ".              
                                      recpla = recid(plani).

                    
                    end.
                end. 

                if (estab.etbcod > 900 or
                    {conv_igual.i estab.etbcod} or
                    estab.etbcod = 22) and
                    fiscal.movtdc = 4
                then do:
                    find forne where forne.forcod = fiscal.emite 
                                no-lock no-error.  
                    if not avail forne  
                    then next.
                    vcod = "F" + string(forne.forcod,"9999999") + "          ". 
                end.
                else assign vcod = "E" + string(fiscal.emite,"9999999") + 
                                    "          ".  
                                                   

                vopccod = string(fiscal.opfcod). 
                


                if fiscal.bicms > 0 
                then vali = int((fiscal.icms * 100) / fiscal.bicms). 
                else vali = 0.
                
                if recpla <> ?
                then find plani where recid(plani) = recpla 
                                no-lock no-error. 
                    
                if avail plani
                then do:

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
                        then base_ipi = (movim.movpc * movim.movqtm).

                        base_icms = (fiscal.bicms / plani.protot) * 
                                    (movim.movpc * movim.movqtm).
     
 
                        vdes = (plani.descprod / fiscal.platot) * 
                               (movim.movpc * movim.movqtm).
                           
                  
                        vipi  = base_ipi  * (movim.movalipi / 100).
                        vicms = base_icms * (movim.movalicms / 100). 
                    
                    
                        
                        
                        /*
                        display stream stela 
                                    plani.platot column-label "Tot Nota"
                                    plani.bicms  column-label "Base icms" 
                                    plani.protot column-label "Tot Prod"
                                    base_icms column-label "Base Calc"
                                    vicms     column-label "Valor Icms"
                                    base_subs column-label "Base Subs"
                                    valor_subs column-label "Valor Subs" 
                                        with frame ff down.
                        */       
                    
                        
                    
                        val_contabil = (movim.movpc * movim.movqtm) + vipi.
 
                        visenta = val_contabil - (movim.movpc * movim.movqtm) 
                                  - vipi.

                        voutras = val_contabil - (movim.movpc * movim.movqtm) 
                                  - vipi - visenta.
 
                   
                        put unformatted 
        /* 001-003 */   string(plani.etbcod,">>9")    
        /* 004-004 */   "T"  format "x(1)"                            
        /* 005-006 */   "01" format "x(2)"  
        /* 007-011 */   "NF" format "x(05)"            
        /* 012-016 */   "01"  format "x(05)"           
        /* 017-028 */   string(plani.numero,">>>>>>999999") 
        /* 029-036 */   string(year(plani.pladat),"9999")  
        /* 029-036 */   string(month(plani.pladat),"99") 
        /* 029-036 */   string(day(plani.pladat),"99") 
        /* 037-044 */   string(year(fiscal.plarec),"9999") 
        /* 037-044 */   string(month(fiscal.plarec),"99") 
        /* 037-044 */   string(day(fiscal.plarec),"99") 
        /* 045-062 */   vcod format "x(18)" 
        /* 063-063 */   " " format "x(1)" 
        /* 064-064 */   "V" format "x(1)" 
        /* 065-080 */   fiscal.platot   format "9999999999999.99" 
        /* 081-096 */   plani.descprod format "9999999999999.99" 
        /* 097-112 */   plani.protot   format "9999999999999.99" 
        /* 113-128 */   fiscal.icms     format "9999999999999.99" 
        /* 129-144 */   fiscal.ipi      format "9999999999999.99" 
        /* 145-160 */   plani.icmssubst format "9999999999999.99"  
        /* 161-180 */   " " format "x(20)" 
        /* 181-196 */   plani.frete    format "9999999999999.99" 
        /* 197-212 */   plani.seguro   format "9999999999999.99" 
        /* 213-228 */   "0000000000000.00"  
        /* 229-243 */   "RODOVIARIO"   format "x(15)" 
        /* 244-246 */   "CIF"          format "x(3)"  
        /* 247-264 */   "0" format "x(18)" 
        /* 265-280 */   "0000000000000.00" 
        /* 281-290 */   "UNIDADE" format "x(10)"  
        /* 291-306 */   "000000000000.000" 
        /* 307-322 */   "000000000000.000" 
        /* 323-339 */   " " format "x(17)" 
        /* 340-355 */   plani.vlserv format "9999999999999.99" 
        /* 356-362 */   "0000.00" 
        /* 363-378 */   "0000000000000.00" 
        /* 379-394 */   "0000000000000.00"  
        /* 395-410 */   "0000000000000.00"  
        /* 411-426 */   "0000000000000.00"  
        /* 427-442 */   "0000000000000.00"  
        /* 443-458 */   "0000000000000.00"  
        /* 459-474 */   "0000000000000.00"  
        /* 475-490 */   "0000000000000.00"  
        /* 491-506 */   "0000000000000.00"  
        /* 507-522 */   "0000000000000.00"  
        /* 523-538 */   "0000000000000.00"  
        /* 539-554 */   "0000000000000.00"  
        /* 555-570 */   "0000000000000.00"  
        /* 571-670 */   plani.notobs[1] format "x(50)" 
        /* 571-670 */   plani.notobs[2] format "x(50)" 
        /* 671-700 */   " " format "x(30)"
        /* 701-701 */   " " format "x(1)"  
        /* 702-721 */   string(movim.procod) format "x(20)" 
        /* 722-766 */   " " format "x(45)" 
        /* 767-772 */   vopccod format "x(6)" 
        /* 773-778 */   " " format "x(6)" 
        /* 779-788 */   vcodfis format "x(10)" 
        /* 789-791 */   vsittri format "x(3)"  
        /* 792-807 */   movim.movqtm   format "99999999999.9999"
        /* 808-810 */   "UN" format "x(3)" 
        /* 811-826 */   movim.movpc format "99999999999.9999" 
        /* 827-842 */   (movim.movpc * movim.movqtm) format "9999999999999.99" 
        /* 843-858 */   vdes format "9999999999999.99"  
        /* 859-859 */   " " format "x(1)"
        /* 860-875 */   base_icms       format "9999999999999.99" 
        /* 876-882 */   movim.movalicms format "9999.99"       
        /* 883-898 */   ((movim.movpc * movim.movqtm) * 
                         (movim.movalicms / 100)) format "9999999999999.99" 
        /* 899-914 */   visenta      format "9999999999999.99" 
        /* 915-930 */   voutras      format "9999999999999.99" 
        /* 931-946 */   base_subs    format "9999999999999.99" 
        /* 947-962 */   valor_subs   format "9999999999999.99" 
        /* 963-963 */   " " format "x(1)"  
        /* 964-979 */   base_ipi format "9999999999999.99" 
        /* 980-986 */   movim.movalipi format "9999.99" 
        /* 987-1002 */  vipi format "9999999999999.99" 
        /* 1003-1018 */ "0000000000000.00" 
        /* 1019-1034 */ "0000000000000.00" 
        /* 1035-1050 */ "0000000000000.00" 
        /* 1051-1066 */ "0000000000000.00" 
        /* 1067-1073 */ "0000.00"    
        /* 1074-1089 */ "0000000000000.00"  
        /* 1090-1105 */ "0000000000000.00"
        /* 1106-1112 */ "0000.00"  
        /* 1113-1128 */ "0000000000000.00" 
        /* 1129-1144 */ "0000000000000.00" 
        /* 1145-1151 */ "0000.00"  
        /* 1152-1167 */ "0000000000000.00" 
        /* 1168-1183 */ "0000000000000.00"
        /* 1184-1190 */ "0000.00"
        /* 1191-1206 */ "0000000000000.00"
        /* 1207-1220 */ " " format "x(14)"
        /* 1221-1236 */ "0000000000000.00" 
        /* 1237-1243 */ "0000.00"  
        /* 1244-1259 */ "0000000000000.00"  
        /* 1260-1275 */ "0000000000000.00"  
        /* 1276-1282 */ "0000.00"  
        /* 1283-1298 */ "0000000000000.00"  
        /* 1299-1314 */ val_contabil format "9999999999999.99" 
        /* 1315-1400 */ " " format "x(86)" skip.
                        end.
                    end.
                    else do:
                       if vopccod = "1102"
                       then vcod = "F" + "0100725" + "          ".  
 
 
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
                    
                    
                    
                        val_contabil = (fiscal.platot) + vipi.
 
                        visenta = val_contabil - (fiscal.platot) 
                                  - vipi.

                        voutras = val_contabil - (fiscal.platot) 
                                  - vipi - visenta.
 
                   
                        put unformatted 
            /* 001-003 */   string(estab.etbcod,">>9")    
            /* 004-004 */   "T"  format "x(1)"                            
            /* 005-006 */   "01" format "x(2)"  
            /* 007-011 */   "NF" format "x(05)"            
            /* 012-016 */   "01"  format "x(05)"           
            /* 017-028 */   string(fiscal.numero,">>>>>>999999") 
            /* 029-036 */   string(year(fiscal.plaemi),"9999")  
            /* 029-036 */   string(month(fiscal.plaemi),"99") 
            /* 029-036 */   string(day(fiscal.plaemi),"99") 
            /* 037-044 */   string(year(fiscal.plarec),"9999") 
            /* 037-044 */   string(month(fiscal.plarec),"99") 
            /* 037-044 */   string(day(fiscal.plarec),"99") 
            /* 045-062 */   vcod format "x(18)" 
            /* 063-063 */   " " format "x(1)"        
            /* 064-064 */   "V" format "x(1)" 
            /* 065-080 */   fiscal.platot   format "9999999999999.99" 
            /* 081-096 */   "0000000000000.00" 
            /* 097-112 */   fiscal.platot  format "9999999999999.99" 
            /* 113-128 */   fiscal.icms     format "9999999999999.99" 
            /* 129-144 */   fiscal.ipi      format "9999999999999.99" 
            /* 145-160 */   "0000000000000.00"  
            /* 161-180 */   " " format "x(20)" 
            /* 181-196 */   "0000000000000.00" 
            /* 197-212 */   "0000000000000.00" 
            /* 213-228 */   "0000000000000.00"  
            /* 229-243 */   "RODOVIARIO"   format "x(15)" 
            /* 244-246 */   "CIF"          format "x(3)"  
            /* 247-264 */   "0" format "x(18)" 
            /* 265-280 */   "0000000000000.00" 
            /* 281-290 */   "UNIDADE" format "x(10)"  
            /* 291-306 */   "000000000000.000" 
            /* 307-322 */   "000000000000.000" 
            /* 323-339 */   " " format "x(17)" 
            /* 340-355 */   "0000000000000.00" 
            /* 356-362 */   "0000.00" 
            /* 363-378 */   "0000000000000.00" 
            /* 379-394 */   "0000000000000.00"  
            /* 395-410 */   "0000000000000.00"  
            /* 411-426 */   "0000000000000.00"  
            /* 427-442 */   "0000000000000.00"  
            /* 443-458 */   "0000000000000.00"  
            /* 459-474 */   "0000000000000.00"  
            /* 475-490 */   "0000000000000.00"  
            /* 491-506 */   "0000000000000.00"  
            /* 507-522 */   "0000000000000.00"  
            /* 523-538 */   "0000000000000.00"  
            /* 539-554 */   "0000000000000.00"  
            /* 555-570 */   "0000000000000.00"  
            /* 571-670 */   fiscal.plaobs[1] format "x(50)" 
            /* 571-670 */   fiscal.plaobs[2] format "x(50)" 
            /* 671-700 */   " " format "x(30)"
            /* 701-701 */   " " format "x(1)"  
            /* 702-721 */   " " format "x(20)" 
            /* 722-766 */   " " format "x(45)" 
            /* 767-772 */   vopccod format "x(6)" 
            /* 773-778 */   " " format "x(6)" 
            /* 779-788 */   vcodfis format "x(10)" 
            /* 789-791 */   vsittri format "x(3)"  
            /* 792-807 */   "00000000001.0000"
            /* 808-810 */   "UN" format "x(3)" 
            /* 811-826 */   fiscal.platot   format "9999999999999.99" 
            /* 827-842 */   fiscal.platot   format "9999999999999.99" 
            /* 843-858 */   vdes format "9999999999999.99"  
            /* 859-859 */   " " format "x(1)"
            /* 860-875 */   base_icms       format "9999999999999.99" 
            /* 876-882 */   fiscal.alicms format "9999.99"       
            /* 883-898 */   (fiscal.platot * 
                        (fiscal.alicms / 100)) format "9999999999999.99" 
            /* 899-914 */   visenta      format "9999999999999.99" 
            /* 915-930 */   voutras      format "9999999999999.99" 
            /* 931-946 */   base_subs    format "9999999999999.99" 
            /* 947-962 */   valor_subs   format "9999999999999.99" 
            /* 963-963 */   " " format "x(1)"  
            /* 964-979 */   base_ipi format "9999999999999.99" 
            /* 980-986 */   "0000.00" 
            /* 987-1002 */  vipi format "9999999999999.99" 
            /* 1003-1018 */ "0000000000000.00" 
            /* 1019-1034 */ "0000000000000.00" 
            /* 1035-1050 */ "0000000000000.00" 
            /* 1051-1066 */ "0000000000000.00" 
            /* 1067-1073 */ "0000.00"    
            /* 1074-1089 */ "0000000000000.00"  
            /* 1090-1105 */ "0000000000000.00"
            /* 1106-1112 */ "0000.00"  
            /* 1113-1128 */ "0000000000000.00" 
            /* 1129-1144 */ "0000000000000.00" 
            /* 1145-1151 */ "0000.00"  
            /* 1152-1167 */ "0000000000000.00" 
            /* 1168-1183 */ "0000000000000.00"
            /* 1184-1190 */ "0000.00"
            /* 1191-1206 */ "0000000000000.00"
            /* 1207-1220 */ " " format "x(14)"
            /* 1221-1236 */ "0000000000000.00" 
            /* 1237-1243 */ "0000.00"  
            /* 1244-1259 */ "0000000000000.00"  
            /* 1260-1275 */ "0000000000000.00"  
            /* 1276-1282 */ "0000.00"  
            /* 1283-1298 */ "0000000000000.00"  
            /* 1299-1314 */ val_contabil format "9999999999999.99" 
            /* 1315-1400 */ " " format "x(86)" skip.
                    
 
                    
                    end.
                end.
                else do: 

                     
                    /*
                    display stream stela fiscal
                                        with frame fff down.
                               
                    */

                    if vopccod = "1102"
                    then
                    vcod = "F" + "0100725" + "          ".  
 
 
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
                    
                    
                    
                    val_contabil = (fiscal.platot) + vipi.
 
                    visenta = val_contabil - (fiscal.platot) 
                              - vipi.

                    voutras = val_contabil - (fiscal.platot) 
                              - vipi - visenta.
 
                   
                    put unformatted 
        /* 001-003 */   string(estab.etbcod,">>9")    
        /* 004-004 */   "T"  format "x(1)"                            
        /* 005-006 */   "01" format "x(2)"  
        /* 007-011 */   "NF" format "x(05)"            
        /* 012-016 */   "01"  format "x(05)"           
        /* 017-028 */   string(fiscal.numero,">>>>>>999999") 
        /* 029-036 */   string(year(fiscal.plaemi),"9999")  
        /* 029-036 */   string(month(fiscal.plaemi),"99") 
        /* 029-036 */   string(day(fiscal.plaemi),"99") 
        /* 037-044 */   string(year(fiscal.plarec),"9999") 
        /* 037-044 */   string(month(fiscal.plarec),"99") 
        /* 037-044 */   string(day(fiscal.plarec),"99") 
        /* 045-062 */   vcod format "x(18)" 
        /* 063-063 */   " " format "x(1)"        
        /* 064-064 */   "V" format "x(1)" 
        /* 065-080 */   fiscal.platot   format "9999999999999.99" 
        /* 081-096 */   "0000000000000.00" 
        /* 097-112 */   fiscal.platot  format "9999999999999.99" 
        /* 113-128 */   fiscal.icms     format "9999999999999.99" 
        /* 129-144 */   fiscal.ipi      format "9999999999999.99" 
        /* 145-160 */   "0000000000000.00"  
        /* 161-180 */   " " format "x(20)" 
        /* 181-196 */   "0000000000000.00" 
        /* 197-212 */   "0000000000000.00" 
        /* 213-228 */   "0000000000000.00"  
        /* 229-243 */   "RODOVIARIO"   format "x(15)" 
        /* 244-246 */   "CIF"          format "x(3)"  
        /* 247-264 */   "0" format "x(18)" 
        /* 265-280 */   "0000000000000.00" 
        /* 281-290 */   "UNIDADE" format "x(10)"  
        /* 291-306 */   "000000000000.000" 
        /* 307-322 */   "000000000000.000" 
        /* 323-339 */   " " format "x(17)" 
        /* 340-355 */   "0000000000000.00" 
        /* 356-362 */   "0000.00" 
        /* 363-378 */   "0000000000000.00" 
        /* 379-394 */   "0000000000000.00"  
        /* 395-410 */   "0000000000000.00"  
        /* 411-426 */   "0000000000000.00"  
        /* 427-442 */   "0000000000000.00"  
        /* 443-458 */   "0000000000000.00"  
        /* 459-474 */   "0000000000000.00"  
        /* 475-490 */   "0000000000000.00"  
        /* 491-506 */   "0000000000000.00"  
        /* 507-522 */   "0000000000000.00"  
        /* 523-538 */   "0000000000000.00"  
        /* 539-554 */   "0000000000000.00"  
        /* 555-570 */   "0000000000000.00"  
        /* 571-670 */   fiscal.plaobs[1] format "x(50)" 
        /* 571-670 */   fiscal.plaobs[2] format "x(50)" 
        /* 671-700 */   " " format "x(30)"
        /* 701-701 */   " " format "x(1)"  
        /* 702-721 */   " " format "x(20)" 
        /* 722-766 */   " " format "x(45)" 
        /* 767-772 */   vopccod format "x(6)" 
        /* 773-778 */   " " format "x(6)" 
        /* 779-788 */   vcodfis format "x(10)" 
        /* 789-791 */   vsittri format "x(3)"  
        /* 792-807 */   "00000000001.0000"
        /* 808-810 */   "UN" format "x(3)" 
        /* 811-826 */   fiscal.platot   format "9999999999999.99" 
        /* 827-842 */   fiscal.platot   format "9999999999999.99" 
        /* 843-858 */   vdes format "9999999999999.99"  
        /* 859-859 */   " " format "x(1)"
        /* 860-875 */   base_icms       format "9999999999999.99" 
        /* 876-882 */   fiscal.alicms format "9999.99"       
        /* 883-898 */   (fiscal.platot * 
                        (fiscal.alicms / 100)) format "9999999999999.99" 
        /* 899-914 */   visenta      format "9999999999999.99" 
        /* 915-930 */   voutras      format "9999999999999.99" 
        /* 931-946 */   base_subs    format "9999999999999.99" 
        /* 947-962 */   valor_subs   format "9999999999999.99" 
        /* 963-963 */   " " format "x(1)"  
        /* 964-979 */   base_ipi format "9999999999999.99" 
        /* 980-986 */   "0000.00" 
        /* 987-1002 */  vipi format "9999999999999.99" 
        /* 1003-1018 */ "0000000000000.00" 
        /* 1019-1034 */ "0000000000000.00" 
        /* 1035-1050 */ "0000000000000.00" 
        /* 1051-1066 */ "0000000000000.00" 
        /* 1067-1073 */ "0000.00"    
        /* 1074-1089 */ "0000000000000.00"  
        /* 1090-1105 */ "0000000000000.00"
        /* 1106-1112 */ "0000.00"  
        /* 1113-1128 */ "0000000000000.00" 
        /* 1129-1144 */ "0000000000000.00" 
        /* 1145-1151 */ "0000.00"  
        /* 1152-1167 */ "0000000000000.00" 
        /* 1168-1183 */ "0000000000000.00"
        /* 1184-1190 */ "0000.00"
        /* 1191-1206 */ "0000000000000.00"
        /* 1207-1220 */ " " format "x(14)"
        /* 1221-1236 */ "0000000000000.00" 
        /* 1237-1243 */ "0000.00"  
        /* 1244-1259 */ "0000000000000.00"  
        /* 1260-1275 */ "0000000000000.00"  
        /* 1276-1282 */ "0000.00"  
        /* 1283-1298 */ "0000000000000.00"  
        /* 1299-1314 */ val_contabil format "9999999999999.99" 
        /* 1315-1400 */ " " format "x(86)" skip.
                
                
                end.
            end.                                 
                         
            
        end.
        
    end.
    
            

    
    
    output close. 
    output stream stela close.
    display totpla format ">>>,>>>,>>9.99".
    
end.    
