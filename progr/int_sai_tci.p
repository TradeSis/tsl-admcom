/* {admcab.i} */

def var nf-modelo as char.
def var nf-serie as char.
 
def var vmovseq as dec.
def var frete-item as dec.
def var icms_item like movim.movicms.
def var vobs like plani.notobs.

def var desaces-capa as dec.
def var desaces-item as dec.

def var ipi_capa  like plani.platot.
def var ipi_item  like plani.platot.
def var base_icms like plani.platot.
def var vdatexp like plani.datexp.
def var vcod as char format "x(18)".
def var vemite like plani.emite.
def var vdesti like plani.desti.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vopccod as char.
def var vali    as int.
def var varq    as char. 
def var val_contabil like plani.platot.
def var visenta like plani.platot.
def var voutras like plani.platot.
def buffer bmovim for movim.
 
def var vetb as char.
def var val-pis    as dec.
def var val-cofins as dec.
def var per-pis    as dec.
def var per-cofins as dec.
def var base-pis   as dec.
def var vcodsit    as char.
def var valpis-capa as dec.
def var basepis-capa as dec.
def var valcofins-capa as dec.
def var aliquota_pis as dec.
def var aliquota_cofins as dec.
def var data_contingencia as char.
def var hora_contingencia as char.
def var motivo_contingencia as char.
def var ccc_fiscal as char.
def var st_ipi as char.
def var icms_naodebitado as dec.
def var vforcod like forne.forcod.
def var vufecod like forne.ufecod. 

def var conta-pis as char.
def var conta-cofins as char.
def var cst-piscofins as char init "4949".
 
def var aux-uf as char init "". 

def var tot-bicmscapa as dec.
def var ind-complementar as char.
def var ind-tiponota as char.
def var obs-complementar as char.
def var cod-observacao as char.
def var cod-obsfiscal  as char.
def var tot-basesubst  as dec.
def var ind-movestoque as char.
def var chave-nfe as char.
def var vnf-cancelada as char.

def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
 
repeat:

    if opsys = "unix" and sparam <> "AniTA"
    then do:
        
        input from /file_server/param_stci.
        repeat:                         
            import varq.
            vetbcod = int(substring(varq,1,3)).
            vdti    = date(int(substring(varq,6,2)),
                           int(substring(varq,4,2)),
                           int(substring(varq,8,4))).
            vdtf    = date(int(substring(varq,14,2)),
                           int(substring(varq,12,2)),
                           int(substring(varq,16,4))).                       
        
            if vetbcod = 0
            then varq = "/file_server/stci_" + 
                    trim(string(vetb,"x(3)")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".txt".
            else varq = "/file_server/stci_" + 
                    trim(string(vetbcod,"999")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".txt".

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
    if opsys = "unix" and sparam = "AniTA"
    then varq = "/admcom/decision/stci_" + 
                trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".

    output to value(varq).
    for each tipmov where tipmov.movtdc = 24 no-lock:

        for each estab where if vetbcod = 0
                             then true 
                             else estab.etbcod = vetbcod no-lock:
            for each plani where plani.etbcod = estab.etbcod  and
                                 plani.movtdc = tipmov.movtdc and
                                 plani.pladat >= vdti         and
                                 plani.pladat <= vdtf no-lock:
               
                ipi_item = 0.
                ipi_capa = 0.
                
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
                
                vdatexp = plani.pladat.
                /*
                if plani.movtdc = 13 and
                   plani.datexp >= 01/01/2005 and
                   plani.datexp <= 05/31/2005
                then vdatexp = date(07,
                                    day(plani.datexp),
                                    year(plani.datexp)).
                */             

                vemite = plani.emite.  
                if vemite = 998  
                then vemite = 993 /*95*/.
            
                vdesti = plani.desti.  
                if vdesti = 998  
                then vdesti = 993 /*95*/.
               
               
                assign visenta      = 0 
                       voutras      = 0.

                vopccod = "5602".
                 
                if plani.movtdc = 6 or
                   plani.movtdc = 9 or
                   plani.movtdc = 22 or
                   plani.movtdc = 24
                then do:   
                    if plani.movtdc <> 24
                    then vopccod = "5152". 
                    vcod = "E" + string(vdesti,"9999999999") + "       ". 
                end.    
                else do: 
                    find forne where forne.forcod = vdesti no-lock no-error.
                    if not avail forne 
                    then next.

                    vcod = "F" + string(forne.forcod,"9999999999") + 
                            "       ". 
                
                    if forne.ufecod = "RS"
                    then find first opcom where 
                                    opcom.movtdc = plani.movtdc no-lock.
                    else find last opcom where 
                                   opcom.movtdc = plani.movtdc no-lock.
                
                    vopccod = string(opcom.opccod). 
                    if plani.opccod = 5910 or
                       plani.opccod = 5949
                    then vopccod = string(plani.opccod).
                
                end.


                if plani.bicms > 0
                then vali = int((plani.icms * 100) / plani.bicms).
                else vali = 0. 
             
                base_icms = 0.

                do:
                    base_icms = 0.
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
                                val_contabil = val_contabil + plani.ipi.
                  
                    vobs[1] = plani.notobs[1]. 
                    vobs[2] = plani.notobs[2].
                        
                    if vobs[1] = "" and 
                       plani.ipi > 0
                    then vobs[1] = "VALOR IPI: " + 
                                   string(plani.ipi,">>,>>9.99").
                
                    /*
                    if day(vdatexp) < 15
                    then vdatexp = date(month(vdatexp),01,year(vdatexp))
                                    - 1.
                    */

                    assign vnf-cancelada = "".
                    
                    find A01_InfNFe where
                         A01_InfNFe.etbcod = plani.etbcod and
                         A01_InfNFe.placod = plani.placod
                         no-lock no-error.
                    if avail A01_InfNFe
                    then do:
                        
                        assign nf-modelo = "55".
                       
                        if A01_InfNFe.situacao = "cancelada"
                        then assign vnf-cancelada = "S".
                        
                    end.
                    else do:
                        
                        if plani.modcod = "can"
                        then assign vnf-cancelada = "S".
                        
                        assign nf-modelo = "01".
                        
                    end.
                    
                    nf-serie = string(plani.serie,"99").

                    cst-piscofins = "4949".
                    
                    {nf-situacao.i}
                    
                    find first movim where movim.etbcod = plani.etbcod and
                                movim.placod = plani.placod and
                                movim.movtdc = plani.movtdc
                                no-lock.
           
                     vmovseq = 1.           
                     put unformatted 
                        string(vemite,">>9")    
                        "P"  format "x(1)"                           
                        nf-modelo format "x(02)"  
                        "NF" format "x(05)"            
                        nf-serie format "x(05)" 
                        string(plani.numero,">>>>>>999999")  
                        string(year(vdatexp),"9999") 
                        string(month(vdatexp),"99") 
                        string(day(vdatexp),"99") 
                        string(year(vdatexp),"9999")
                        string(month(vdatexp),"99") 
                        string(day(vdatexp),"99") 
                        vcod  format "x(18)" 
                        vnf-cancelada  format "x(1)" 
                        "V" format "x(1)" 
                        "0000000000000.00" 
                        "0000000000000.00"
                        "0000000000000.00"  
     /* 113-128 */      0              format "9999999999999.99" 
                        "0000000000000.00" 
                        "0000000000000.00" 
                        " " format "x(20)" 
                        "0000000000000.00" 
                        "0000000000000.00" 
                        desaces-capa format "9999999999999.99"
                        "RODOVIARIO"   format "x(15)" 
                        "CIF"          format "x(3)"  
                        " " format "x(18)" 
                        "0000000000000.00" 
                        "UNIDADE" format "x(10)"  
                        "000000000000.000" 
                        "000000000000.000" 
                        " " format "x(17)" 
                        "0000000000000.00" 
                        "0000.00" 
                        "0000000000000.00" 
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        vobs[1] format "x(50)" 
                        vobs[2] format "x(50)" 
                        " " format "x(30)" 
                        " " format "x(1)"  
                        string(movim.procod) format "x(20)"
                        " " format "x(45)" 
                        vopccod format "x(6)" 
                        " " format "x(6)" 
                        " " format "x(10)" 
                        "090" format "x(3)"   /* 789-791 */
                        movim.movqtm  format "99999999999.9999" /* 792-807 */
                        "UN" format "x(3)"
                        "00000000000.0000" 
                        "0000000000000.00"
                        "0000000000000.00"  
                        " " format "x(1)"
     /*860-875 */       "0000000000000.00" 
     /* 876-882 */      "0000.00"       
     /* 883-898 */      0          format "9999999999999.99" 
     /* 899-914 */      "0000000000000.00" 
     /* 915-930 */      plani.icms format "9999999999999.99"
                        "0000000000000.00" 
                        "0000000000000.00" 
                        " " format "x(1)"  
                        "0000000000000.00" 
     /* 980-986  */     "0000.00" 
     /* 987-1002 */     "0000000000000.00" 
                        "0000000000000.00" 
                        "0000000000000.00" 
                        "0000000000000.00" 
                        "0000000000000.00" 
     /* 1067-1073 */    "0000.00"    
                        "0000000000000.00"  
                        "0000000000000.00"
     /* 1106-1112 */    "0000.00"  
                        "0000000000000.00" 
                        "0000000000000.00" 
     /* 1145-1151 */    "0000.00"  
                        "0000000000000.00" 
                        "0000000000000.00"
    /*  1184-1190 */    "0000.00"
                        "0000000000000.00"
                        " " format "x(14)"
        /* 1221-1236 */ base-pis format "9999999999999.99" 
        /* 1237-1243 */ per-pis format "9999.99"  
        /* 1244-1259 */ val-pis format "9999999999999.99"  
        /* 1260-1275 */ base-pis format "9999999999999.99"  
        /* 1276-1282 */ per-cofins format "9999.99"  
        /* 1283-1298 */ val-cofins format "9999999999999.99"  
        /* 1299-1314 */ val_contabil format "9999999999999.99" 
        /* 1315-1330 */ " " format "x(16)"
        /* 1331-1334 */ cst-piscofins /*vcodsit*/ format "x(4)"
        /* 1335-     */ tot-bicmscapa format "9999999999999.99"
        /* 1351-     */ ind-complementar format "x"
        /* 1352-     */ ind-situacao format "x(2)"
        /* 1354-     */ ind-tiponota format "x"
        /* 1355-     */ obs-complementar format "x(254)"
        /* 1609-     */ cod-observacao format "x(6)"
        /* 1615-     */ cod-obsfiscal  format "x(6)"
        /* 1621-     */ tot-basesubst  format "9999999999999.99"
        /* 1637-     */ ind-movestoque format "x" .
        /* 1638-     */ if avail A01_InfNFe
                       then put A01_InfNFe.id format "x(44)".
                       else put " " format "x(44)".
        /* 1682      */ put " " format "x(28)" .
        /* 1710      */ put ipi_capa format "99999999999999.99"
        /* 1727      */     ipi_item format "99999999999999.99" .
        /* 1744      */ put plani.bicms format "99999999999999.99"
        /* 1761      */     aliquota_pis format "9999.99"
        /* 1768      */     aliquota_cofins format "9999.99"
        /* 1775      */     data_contingencia format "x(8)"
        /* 1783      */     hora_contingencia format "x(10)"
        /* 1793      */     motivo_contingencia format "x(254)"
        /* 2047      */     ccc_fiscal format "x(2)"
        /* 2049      */     st_ipi format "x(3)"
        /* 2052      */     icms_naodebitado format "99999999999999.99"
        /* 2069      */     aliquota_pis format "9999.99"
        /* 2076      */     aliquota_cofins format "9999.99"
        /* 2083      */     "0" format "x"
        /* 2084      */     "0" format "x"
        /* 2085      */     " " format "x(28)"
        /* 2113      */     " " format "x(6)"
        /* 2119      */     " " format "x(6)"
        /* 2125      */     " " format "x(3)"
        /* 2128      */     " " format "x(2)"
        /* 2130      */     conta-pis    format "x(28)"
        /* 2158      */     conta-cofins format "x(28)"
        /* 2186      */     string(vmovseq,">>>9") format "x(4)"
        /* 2190      */     frete-item format "9999999999999.99"
        /* 2206      */  " " format "x(44)"
        /* 2250      */  " " format "x(3)"
                         " " format "x(48)"
        /* 2301      */ desaces-item format "9999999999999.99"
        /*2317*/  " " format "x" 
        /*2318*/  0 format "9999999999999.99"
        /*2334*/  0 format "9999999999999.99"
        /*2350*/  0 format "999.99"
        /*2356*/  " " format "x(10)"
        /*2366*/  0 format "9999999999999.99"
        /*2382*/  0 format "9999999999999.99"
        /*2398*/  0 format "9999999999999.99"
        /*2414*/  " " format "x(10)"
         .
                             
        put skip.
        
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
            aliquota_pis = 0
            aliquota_cofins = 0
            data_contingencia = ""
            hora_contingencia = ""
            motivo_contingencia = ""
            ccc_fiscal = ""
            st_ipi = ""
            icms_naodebitado = 0
            conta-pis = ""
            conta-cofins = ""
            cst-piscofins = ""
            frete-item = 0
             .

                
                end.
            end.                                 
        end.
    end.
    output close.
    if opsys = "unix"
    then return.
end.    

