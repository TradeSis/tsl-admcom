/* {admcab.i} */

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
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vopccod as char.
def var vali    as int.
def var vcod as char format "x(18)".
def var ali_icms like movim.movalipi.
def var ali_ipi  like movim.movalicms.
def var vobs     like plani.notobs.

repeat:
    if opsys = "unix"
    then do:
        input from /admcom/audit/param_nfe.
        repeat:
            import varq.
            vetbcod = int(substring(varq,1,2)).
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
        update vetbcod with frame f1.
        if vetbcod = 0
        then display "GERAL" @ estab.etbnom with frame f1.
        else do:
            find estab where estab.etbcod = vetbcod no-lock.
            display estab.etbnom no-label with frame f1.
        end.
    
        update vdti label "Data Inicial" colon 16
               vdtf label "Data Final" with frame f1 side-label width 80.
    end.
    
    if opsys = "unix"
    then varq = "/admcom/audit/ent" + string(vetbcod,"99") + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
    else varq = "l:\audit\ent" + string(vetbcod,"99") + "_" +
                string(day(vdti),"99") + 
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".                
                                                               
    output to value(varq).
    for each tipmov where tipmov.movtdc = 4 or
                          tipmov.movtdc = 12 no-lock:

        for each estab where if vetbcod = 0
                             then true 
                             else estab.etbcod = vetbcod no-lock:

            for each fiscal where fiscal.movtdc = tipmov.movtdc and
                                  fiscal.desti  = estab.etbcod  and
                                  fiscal.plarec >= vdti         and
                                  fiscal.plarec <= vdtf
                            no-lock:

                v-mod = "01".
                v-ser = "01".
                vcod  = "".
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
                        else do:
                            find plani where plani.etbcod = estab.etbcod 
                                     and plani.emite  = fiscal.emite 
                                     and plani.movtdc = 23 
                                     and plani.serie  = fiscal.serie 
                                     and plani.numero = fiscal.numero 
                                             no-lock no-error.
                            if avail plani
                            then recpla = recid(plani).
                        end.
                    end.
                    else recpla = recid(plani).
                end.     
                else do:
                    /**
                    find first plani where plani.etbcod = estab.etbcod 
                                and plani.emite  = fiscal.emite 
                                and plani.movtdc = 12 
                                and plani.serie  = fiscal.serie 
                                and plani.nottran = fiscal.numero 
                                and plani.pladat >= vdti
                                            no-lock no-error.
                    if not avail plani
                    then do:
                        **/
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

                    /*end.
                    else do:
                        assign vcod = "E" + string(fiscal.emite,"9999999") + 
                                      "          "              
                                      recpla = recid(plani)
                                      v-tipo = "P".
                    end.*/
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

                    if tipmov.movtnota = no /* Digita */ and
                       plani.notpis = 0
                    then run piscofins2.p (recid(plani)).

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
                        
                        valor_item  = movim.movpc.
                        protot_capa = plani.protot.
                        desc_capa   = plani.descprod.
                        per_desc    = plani.descprod / plani.protot.
                                   
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
                           vopccod = "1202" /*
                           vopccod = "1910" or
                           vopccod = "2910" or
                           vopccod = "2102" or
                           vopccod = "1949" or
                           vopccod = "2949" or
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

                        
 
                   
                        put unformatted 
        /* 001-003 */   string(plani.etbcod,">>9")    
        /* 004-004 */   v-tipo  format "x(1)"                            
        /* 005-006 */   v-mod  format "x(2)"  
        /* 007-011 */   "NF" format "x(05)"            
        /* 012-016 */   v-ser  format "x(05)"           
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
        /* 081-096 */   desc_capa format "9999999999999.99" 
        /* 097-112 */   protot_capa     format "9999999999999.99" 
        /* 113-128 */   fiscal.icms     format "9999999999999.99" 
        /* 129-144 */   fiscal.ipi      format "9999999999999.99" 
        /* 145-160 */   plani.icmssubst format "9999999999999.99"  
        /* 161-180 */   ie_subst_trib   format "x(20)" 
        /* 181-196 */   plani.frete    format "9999999999999.99" 
        /* 197-212 */   plani.seguro   format "9999999999999.99" 
        /* 213-228 */   plani.desacess format "9999999999999.99"  
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
        /* 571-670 */   vobs[1] format "x(50)" 
        /* 571-670 */   vobs[2] format "x(50)" 
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
        /* 811-826 */   round(valor_item,4) format "99999999999.9999" 
        /* 827-842 */   round((valor_item * movim.movqtm),2) 
                                            format "9999999999999.99" 
        /* 843-858 */   round((movim.movdes * movim.movqtm),2)
                                            format "9999999999999.99"  
        /* 859-859 */   " " format "x(1)"
        /* 860-875 */   round(base_icms,2)  format "9999999999999.99" 
        /* 876-882 */   movim.movalicms format "9999.99"       
        /* 883-898 */   round(valicm,2) format "9999999999999.99" 
        /* 899-914 */   round(visenta,2) format "9999999999999.99" 
        /* 915-930 */   round(voutras,2) format "9999999999999.99" 
        /* 931-946 */   round(base_subs,2)    format "9999999999999.99" 
        /* 947-962 */   round(valor_subs,2)   format "9999999999999.99" 
        /* 963-963 */   " " format "x(1)"  
        /* 964-979 */   round(base_ipi,2) format "9999999999999.99" 
        /* 980-986 */   movim.movalipi format "9999.99" 
        /* 987-1002 */  round(vipi,2) format "9999999999999.99" 
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
        /* 1299-1314 */ round(val_contabil,2)  format "9999999999999.99" 
        /* 1315-1330 */ round((frete_item * movim.movqtm),2)  
                                               format "9999999999999.99"
        /* 1331-1400 */ " " format "x(70)" skip.
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

                        visenta = val_contabil - (fiscal.platot) - vipi.
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

 
                        
                        put unformatted 
            /* 001-003 */   string(estab.etbcod,">>9")    
            /* 004-004 */   "T"  format "x(1)"                            
            /* 005-006 */   v-mod format "x(2)"  
            /* 007-011 */   "NF" format "x(05)"            
            /* 012-016 */   v-ser  format "x(05)"           
            /* 017-028 */   string(vnumero,">>>>>>999999") 
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
            /* 161-180 */   ie_subst_trib format "x(20)" 
            /* 181-196 */   "0000000000000.00" 
            /* 197-212 */   "0000000000000.00" 
            /* 213-228 */   plani.desacess format "9999999999999.99"  
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
            /* 571-670 */   vobs[1] format "x(50)" 
            /* 571-670 */   vobs[2] format "x(50)" 
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
            /* 883-898 */   vicms format "9999999999999.99" 
            /* 899-914 */   visenta      format "9999999999999.99" 
            /* 915-930 */   voutras      format "9999999999999.99" 
            /* 931-946 */   base_subs    format "9999999999999.99" 
            /* 947-962 */   valor_subs   format "9999999999999.99" 
            /* 963-963 */   " " format "x(1)"  
            /* 964-979 */   base_ipi format "9999999999999.99" 
            /* 980-986 */   round(((vipi / base_ipi) * 100),0) format "9999.99" 
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
                        if (fiscal.platot * (fiscal.alicms / 100)) = 0
                        then base_icms = 0.
                        else base_icms = fiscal.platot.
                        val_contabil = val_contabil + fiscal.ipi.
                        voutras = fiscal.platot - base_icms.
                        if voutras < 0
                        then voutras = 0.
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
                                
 
                   
                    put unformatted 
        /* 001-003 */   string(estab.etbcod,">>9")    
        /* 004-004 */   v-tipo  format "x(1)"                            
        /* 005-006 */   v-mod format "x(2)"  
        /* 007-011 */   tip-doc format "x(05)"            
        /* 012-016 */   v-ser  format "x(05)"           
        /* 017-028 */   string(vnumero,">>>>>>999999") 
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
        /* 571-670 */   vobs[1] format "x(50)" 
        /* 571-670 */   vobs[2] format "x(50)" 
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
        /* 883-898 */   vicms format "9999999999999.99" 
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

                 
                
                   
                put unformatted 
        /* 001-003 */   string(vdesti,">>9")    
        /* 004-004 */   "T"  format "x(1)"                            
        /* 005-006 */   "01" format "x(2)"  
        /* 007-011 */   "NF" format "x(05)"            
        /* 012-016 */   "01"  format "x(05)"           
        /* 017-028 */   string(plani.numero,">>>>>>999999") 
        /* 029-036 */   string(year(plani.datexp),"9999")  
        /* 029-036 */   string(month(plani.datexp),"99") 
        /* 029-036 */   string(day(plani.datexp),"99") 
        /* 037-044 */   string(year(plani.datexp),"9999") 
        /* 037-044 */   string(month(plani.datexp),"99") 
        /* 037-044 */   string(day(plani.datexp),"99") 
        /* 045-062 */   vcod format "x(18)" 
        /* 063-063 */   " " format "x(1)" 
        /* 064-064 */   "V" format "x(1)" 
        /* 065-080 */   plani.platot   format "9999999999999.99" 
        /* 081-096 */   plani.descprod format "9999999999999.99" 
        /* 097-112 */   plani.protot   format "9999999999999.99" 
        /* 113-128 */   plani.icms     format "9999999999999.99" 
        /* 129-144 */   plani.ipi      format "9999999999999.99" 
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

 
 
 
                   
                put unformatted 
        /* 001-003 */   string(vdesti,">>9")    
        /* 004-004 */   "T"  format "x(1)"                            
        /* 005-006 */   "01" format "x(2)"  
        /* 007-011 */   "NF" format "x(05)"            
        /* 012-016 */   "01"  format "x(05)"           
        /* 017-028 */   string(plani.numero,">>>>>>999999") 
        /* 029-036 */   string(year(plani.datexp),"9999")  
        /* 029-036 */   string(month(plani.datexp),"99") 
        /* 029-036 */   string(day(plani.datexp),"99") 
        /* 037-044 */   string(year(plani.datexp),"9999") 
        /* 037-044 */   string(month(plani.datexp),"99") 
        /* 037-044 */   string(day(plani.datexp),"99") 
        /* 045-062 */   vcod format "x(18)" 
        /* 063-063 */   " " format "x(1)" 
        /* 064-064 */   "V" format "x(1)" 
        /* 065-080 */   plani.platot   format "9999999999999.99" 
        /* 081-096 */   plani.descprod format "9999999999999.99" 
        /* 097-112 */   plani.protot   format "9999999999999.99" 
        /* 113-128 */   plani.icms     format "9999999999999.99" 
        /* 129-144 */   plani.ipi      format "9999999999999.99" 
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
        /* 702-721 */   " " format "x(20)" 
        /* 722-766 */   " " format "x(45)" 
        /* 767-772 */   vopccod format "x(6)" 
        /* 773-778 */   " " format "x(6)" 
        /* 779-788 */   vcodfis format "x(10)" 
        /* 789-791 */   vsittri format "x(3)"  
        /* 792-807 */   "00000000001.0000"
        /* 808-810 */   "UN" format "x(3)" 
        /* 811-826 */   plani.platot format "99999999999.9999" 
        /* 827-842 */   plani.platot format "9999999999999.99" 
        /* 843-858 */   vdes format "9999999999999.99"  
        /* 859-859 */   " " format "x(1)"
        /* 860-875 */   base_icms       format "9999999999999.99" 
        /* 876-882 */   plani.alicms format "9999.99"       
        /* 883-898 */   (plani.platot * 
                        (plani.alicms / 100)) format "9999999999999.99" 
        /* 899-914 */   visenta      format "9999999999999.99" 
        /* 915-930 */   voutras      format "9999999999999.99" 
        /* 931-946 */   base_subs    format "9999999999999.99" 
        /* 947-962 */   valor_subs   format "9999999999999.99" 
        /* 963-963 */   " " format "x(1)"  
        /* 964-979 */   base_ipi format "9999999999999.99" 
        /* 980-986 */   plani.alipi format "9999.99" 
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
                
 
 
                   
                    put unformatted 
        /* 001-003 */   string(vdesti,">>9")    
        /* 004-004 */   "T"  format "x(1)"                            
        /* 005-006 */   "01" format "x(2)"  
        /* 007-011 */   "NF" format "x(05)"            
        /* 012-016 */   "01"  format "x(05)"           
        /* 017-028 */   string(plani.numero,">>>>>>999999") 
        /* 029-036 */   string(year(plani.datexp),"9999")  
        /* 029-036 */   string(month(plani.datexp),"99") 
        /* 029-036 */   string(day(plani.datexp),"99") 
        /* 037-044 */   string(year(plani.datexp),"9999") 
        /* 037-044 */   string(month(plani.datexp),"99") 
        /* 037-044 */   string(day(plani.datexp),"99") 
        /* 045-062 */   vcod format "x(18)" 
        /* 063-063 */   " " format "x(1)" 
        /* 064-064 */   "V" format "x(1)" 
        /* 065-080 */   plani.platot   format "9999999999999.99" 
        /* 081-096 */   plani.descprod format "9999999999999.99" 
        /* 097-112 */   plani.protot   format "9999999999999.99" 
        /* 113-128 */   plani.icms     format "9999999999999.99" 
        /* 129-144 */   plani.ipi      format "9999999999999.99" 
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
                   
            put unformatted 
        /* 001-003 */   string(vdesti,">>9")    
        /* 004-004 */   "P"  format "x(1)"                            
        /* 005-006 */   "01" format "x(2)"  
        /* 007-011 */   "NF" format "x(05)"            
        /* 012-016 */   "01"  format "x(05)"           
        /* 017-028 */   string(plani.numero,">>>>>>999999") 
        /* 029-036 */   string(year(plani.datexp),"9999")  
        /* 029-036 */   string(month(plani.datexp),"99") 
        /* 029-036 */   string(day(plani.datexp),"99") 
        /* 037-044 */   string(year(plani.datexp),"9999") 
        /* 037-044 */   string(month(plani.datexp),"99") 
        /* 037-044 */   string(day(plani.datexp),"99") 
        /* 045-062 */   vcod format "x(18)" 
        /* 063-063 */   " " format "x(1)" 
        /* 064-064 */   "V" format "x(1)" 
        /* 065-080 */   plani.platot   format "9999999999999.99" 
        /* 081-096 */   plani.descprod format "9999999999999.99" 
        /* 097-112 */   plani.protot   format "9999999999999.99" 
        /* 113-128 */   plani.icms     format "9999999999999.99" 
        /* 129-144 */   plani.ipi      format "9999999999999.99" 
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
        /* 702-721 */   "GENERICO" format "x(20)" 
        /* 722-766 */   nome_produto format "x(45)" 
        /* 767-772 */   vopccod format "x(6)" 
        /* 773-778 */   " " format "x(6)" 
        /* 779-788 */   vcodfis format "x(10)" 
        /* 789-791 */   vsittri format "x(3)"  
        /* 792-807 */   "00000000001.0000"
        /* 808-810 */   "UN" format "x(3)" 
        /* 811-826 */   plani.platot format "99999999999.9999" 
        /* 827-842 */   plani.platot format "9999999999999.99" 
        /* 843-858 */   plani.descprod format "9999999999999.99"  
        /* 859-859 */   " " format "x(1)"
        /* 860-875 */   base_icms       format "9999999999999.99" 
        /* 876-882 */   plani.alicms format "9999.99"       
        /* 883-898 */   plani.icms format "9999999999999.99" 
        /* 899-914 */   visenta      format "9999999999999.99" 
        /* 915-930 */   voutras      format "9999999999999.99" 
        /* 931-946 */   base_subs    format "9999999999999.99" 
        /* 947-962 */   valor_subs   format "9999999999999.99" 
        /* 963-963 */   " " format "x(1)"  
        /* 964-979 */   base_ipi format "9999999999999.99" 
        /* 980-986 */   plani.alipi format "9999.99" 
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
    
    output close. 
    
    /* display totpla format ">>>,>>>,>>9.99". */
    
    if opsys = "unix"
    then return.
    
end.    
