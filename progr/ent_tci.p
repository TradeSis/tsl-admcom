/* {admcab.i} */

def var nf-modelo as char.
def var nf-serie as char.

def var basepis-capa as dec.
def var valpis-capa as dec.
def var valcofins-capa as dec.
def var vcodsit as char.
def var base-pis as dec.
def var per-cofins as dec.
def var val-cofins as dec.

def var frete_item like movim.movpc.
def var valicm  as dec.
def var tip-doc as char.
def var ie_subst_trib as char.
def var per_desc like plani.platot.
def var valor_item as dec decimals 4 format "->>>,>>9.9999".
def var protot_capa like plani.platot.
def var desc_capa like plani.platot.
def var valor_ipi as dec.
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
def var vmovpc as dec decimals 4 format "->>>,>>9.9999".
def var vdatexp like plani.datexp.
def var vetb as char.

/***/
def var vmovseq like movim.movseq.
def var tot-bicmscapa as dec.
def var ind-complementar as char.
def var ind-tiponota as char.
def var obs-complementar as char.
def var cod-observacao as char.
def var cod-obsfiscal  as char.
def var tot-basesubst  as dec.
def var ind-movestoque as char.
def var chave-nfe as char.


def var vtotprodu like plani.protot.
def var codigo-bc as char.
def var conta-pis as char.
def var conta-cofins as char.
def var cst-piscofins as char.
def var tipo-credito as char.
def var ipi_retido as dec.
def var cof_retido as dec.
def var dat_conclu as char.
def var nat_frete as char.
def var tipo_cte as char.
def var dat_contingencia as char.
def var hor_contingencia as char.
def var mot_contingencia as char.
def var ccc_fiscal as char.
def var ipi_capa  like plani.platot.
def var ipi_item  like plani.platot.
def var vmovalipi like movim.movalipi.
/***/

def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
 
repeat:
    if opsys = "unix" and sparam <> "AniTA"
    then do:
        
        input from /admcom/audit/param_etci.
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
    
    if vetbcod = 0
    then vetb = "".
    else vetb = string(vetbcod,"999").
    if opsys = "unix"
    then varq = "/admcom/audit/enttcred_" + trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
    else varq = "l:\audit\enttcred_" + trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") + 
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
                
                                                               
    output to value(varq).
         
    
    def var vtotalmov as dec.
    for each estab where if vetbcod = 0 
                         then true  
                         else estab.etbcod = vetbcod no-lock:
        for each tipmov where tipmov.movtdc = 24 no-lock,
            each plani where plani.movtdc = tipmov.movtdc and 
                             plani.desti  = estab.etbcod  and 
                             plani.pladat >= vdti         and
                             plani.pladat <= vdtf  exclusive-lock:
            if plani.numero = 0
            then next.
                                 
            if plani.serie = "U" or
               plani.serie = "U1" or
               plani.serie = "1"
            then.
            else next.
            if (plani.movtdc = 6 or plani.movtdc = 16) and 
                month(vdti) = 12 and
                plani.emite = 998
            then do:    
                find fiscal where fiscal.emite  = plani.emite  and
                              fiscal.desti  = plani.desti  and
                              fiscal.movtdc = plani.movtdc  and
                              fiscal.numero = plani.numero  and
                              fiscal.serie  = plani.serie no-error.
                if not avail fiscal then next.
            end.

            if plani.emite = 993 /*95*/ and
               plani.desti = 998 
            then next.
            if plani.emite = 998 and
               plani.desti = 993 /*95*/
            then next.   
        
            totpla = totpla + plani.platot.

            
            vemi = plani.emite.
            if vemi = 998
            then vemi = 993 /*95*/.
            
            vdesti = plani.desti.
            if vdesti = 998
            then vdesti = 993 /*95*/.

            vopccod = "1602". 
            vcod = "E" + string(vemi,"9999999") + "          ". 

            if plani.bicms > 0  
            then vali = int((plani.icms * 100) / plani.bicms). 
            else vali = 0.

            do:
                tot_pro = plani.platot.
                vcodfis = "". 
                vsittri = "090".
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
                vdatexp = plani.pladat.
               /*if day(vdatexp) < 15
                then vdatexp = date(month(vdatexp),01,year(vdatexp)) - 1.
                 */ 
        find A01_InfNFe where
                         A01_InfNFe.etbcod = plani.etbcod and
                         A01_InfNFe.placod = plani.placod
                         no-lock no-error.
        if plani.serie = "55" or
           plani.serie = "1"
        then nf-modelo = "55".
        else nf-modelo = "01".
        nf-serie = string(plani.serie,"99").
 
        cst-piscofins = "9898".
        
        {nf-situacao.i}
        
        if ind-situacao = "00"
        then do:
        find first movim where movim.etbcod = plani.etbcod and
                                movim.placod = plani.placod and
                                movim.movtdc = plani.movtdc
                                no-lock.
 
        if vcodfis = "99999999"
        then vcodfis = "00000000".
        
                 put unformatted 
        /* 001-003 */   string(vdesti,">>9")    
        /* 004-004 */   "T"  format "x(1)"                            
        /* 005-006 */   nf-modelo format "x(2)"  
        /* 007-011 */   "NF" format "x(05)"            
        /* 012-016 */   nf-serie  format "x(05)"           
        /* 017-028 */   string(plani.numero,">>>>>>999999") 
        /* 029-036 */   string(year(vdatexp),"9999")  
        /* 029-036 */   string(month(vdatexp),"99") 
        /* 029-036 */   string(day(vdatexp),"99") 
        /* 037-044 */   string(year(vdatexp),"9999") 
        /* 037-044 */   string(month(vdatexp),"99") 
        /* 037-044 */   string(day(vdatexp),"99") 
        /* 045-062 */   vcod format "x(18)" 
        /* 063-063 */   " " format "x(1)" 
        /* 064-064 */   "V" format "x(1)" 
        /* 065-080 */   "0000000000000.00" 
        /* 081-096 */   "0000000000000.00" 
        /* 097-112 */   "0000000000000.00" 
        /* 113-128 */   0                  format "9999999999999.99" 
        /* 129-144 */   "0000000000000.00" 
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
        /* 571-670 */   plani.notobs[1] format "x(50)" 
        /* 571-670 */   plani.notobs[2] format "x(50)" 
        /* 671-700 */   " " format "x(30)"
        /* 701-701 */   " " format "x(1)"  
        /* 702-721 */   string(movim.procod) format "x(20)" 
        /* 722-766 */   " " format "x(45)" 
        /* 767-772 */   vopccod format "x(6)" 
        /* 773-778 */   " " format "x(6)" 
        /* 779-788 */   vcodfis format "x(10)" /*NCM*/
        /* 789-791 */   vsittri format "x(3)" /*cst icms*/ 
        /* 792-807 */   "00000000001.0000"  /*movqtm*/
        /* 808-810 */   "UN" format "x(3)" 
        /* 811-826 */   "00000000000.0000" 
        /* 827-842 */   "0000000000000.00" 
        /* 843-858 */   "0000000000000.00" 
        /* 859-859 */   " " format "x(1)"
        /* 860-875 */   "0000000000000.00" 
        /* 876-882 */   "0000.00"  /*%icms*/
        /* 883-898 */   0 format "9999999999999.99" 
        /* 899-914 */   "0000000000000.00" 
        /* 915-930 */   plani.icms format "9999999999999.99" 
        /* 931-946 */   "0000000000000.00" 
        /* 947-962 */   "0000000000000.00" 
        /* 963-963 */   " " format "x(1)"  
        /* 964-979 */   "0000000000000.00" 
        /* 980-986 */   "0000.00" 
        /* 987-1002 */  "0000000000000.00" 
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
        /* 1299-1314 */ "0000000000000.00" 
        /* 1315-1330 */ "0000000000000.00"  
        /* 1331      */ /*vcodsit*/ cst-piscofins format "x(4)" 
        /* 1335      */ tot-bicmscapa format "9999999999999.99"
        /* 1351      */ "" format "x"
        /* 1352      */ "" format "xx"
        /* 1354      */ ind-complementar format "x"
        /* 1355      */ ind-situacao        format "xx"
        /* 1357      */ "" format "x"
        /* 1358      */ ind-tiponota format "x"
        /* 1359      */ obs-complementar format "x(254)"
        /* 1613      */ cod-observacao   format "x(6)"
        /* 1619      */ cod-obsfiscal    format "x(6)"
        /* 1625      */ tot-basesubst    format "9999999999999.99"
        /* 1641      */ ind-movestoque   format "x".
        /* 1642      */  if avail A01_InfNFe
                then put A01_InfNFe.id format "x(44)".
                else put " " format "x(44)".
        /* 1686      */ put " " format "x(28)" .
        /* 1714      */ put ipi_capa format "99999999999999.99"
        /* 1731      */     ipi_item format "99999999999999.99"
        /* 1748      */     ipi_retido format "9999.99"
        /* 1755      */     cof_retido format "9999.99"
        /* 1762      */     dat_conclu format "x(8)"
        /* 1770      */     nat_frete format "x"
        /* 1771      */     tipo_cte format "x"
        /* 1772      */     dat_contingencia format "x(8)"
        /* 1780      */     hor_contingencia format "x(10)"
        /* 1790      */     mot_contingencia format "x(254)"
        /* 2044      */     ccc_fiscal format "x(2)"
        /* 2046      */     "0"
        /* 2047      */     "0"
        /* 2048      */     " " format "x(28)"
        /* 2076      */     " " format "x(6)"
        /* 2082      */     " " format "x(6)"
        /* 2088      */     tipo-credito format "x(3)"
        /* 2091      */     codigo-bc format "x(2)"
        /* 2093      */     conta-pis     format "x(28)"
        /* 2121      */     conta-cofins  format "x(28)"
        /* 2149      */     " " format "x(2)"
        /* 2151      */     string(vmovseq,">>>9") format "x(4)"
                            .
        put skip.
        end.
        
        assign
            tot-bicmscapa = 0
            ind-complementar = ""
            ind-situacao = ""
            ind-tiponota = ""
            obs-complementar = ""
            cod-observacao = ""
            cod-obsfiscal = ""
            tot-basesubst = 0
            ind-movestoque = ""
            ipi_capa = 0
            ipi_item = 0
            ipi_retido = 0
            cof_retido = 0
            dat_conclu = ""
            nat_frete = ""
            tipo_cte = ""
            dat_contingencia = ""
            hor_contingencia = ""
            mot_contingencia = ""
            ccc_fiscal = ""
            basepis-capa = 0
            valpis-capa = 0
            basepis-capa = 0
            valcofins-capa = 0
            vcodsit = ""
            cst-piscofins = ""
            tipo-credito = ""
            codigo-bc = ""
            conta-pis = ""
            conta-cofins = ""
            base-pis = 0
            per-cofins = 0
            val-cofins = 0
            .

            end.   
        end.  
    end. 

    output close. 
    
    /* display totpla format ">>>,>>>,>>9.99". */
    
    if opsys = "unix"
    then return.
    
end.