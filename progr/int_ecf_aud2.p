/* {admcab.i} */
def var total_inicial like plani.platot.
def var vdup as char format "x(15)".
def buffer bmapctb for mapctb.
def var redz    like mapctb.nrored.
def var v-caixa as char.
def var varq as char.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vopccod as char.
def var vali    as int.
def var tot-valor like plani.platot.
def var tot-base  like plani.platot.
def var tot-icms  like plani.platot.
def var total_base  as dec.
def var total_18    as dec.
def var total_17    as dec.
def var total_07    as dec.
def var total_12    as dec.
def var total_sub   as dec.
def var total_icms  as dec.
def var vser as char format "x(20)".
def var vetb as char.
def var vcooini like mapctb.cooini.
def var vcoofin like mapctb.coofin.

/**
/* gera arquivo cupom fiscal */
  if opsys = "unix" 
  and search("/admcom/progr/ven_aud.p") <> ?
  then run /admcom/progr/ven_aud.p.
**/

def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
 
repeat:

    if opsys = "unix"  and sparam <> "AniTA"
    then do:
        
        input from /file_server/param_map.
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
            then varq = "/file_server/map_" + 
                    trim(string(vetb,"x(3)")) + "_" + 
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".txt".
            else varq = "/file_server/map_" + 
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
    then do:
        if vetbcod = 0
        then varq = "/admcom/decision/map_" + 
                trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") + 
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
        else varq = "/admcom/decision/map_" + 
                trim(string(vetbcod,"999")) + "_" +
                string(day(vdti),"99") + 
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
                
    end.
    output to value(varq).

    for each estab where if vetbcod = 0 
                         then true  
                         else estab.etbcod = vetbcod no-lock:
        if estab.etbcod = 13 or
           estab.etbcod = 301
        then next.   
        for each mapctb where mapctb.etbcod = estab.etbcod and
                              mapctb.datmov >= vdti        and
                              mapctb.datmov <= vdtf  and
                              mapctb.ch2 <> "E" no-lock:
                              
            if mapctb.ch2 = "E"
            then next.
                
            vser = mapctb.ch1.
            if vser = ""
            then do: 
                
                vdup = "".
                find first tabecf where 
                           tabecf.etbcod   = mapctb.etbcod and
                           tabecf.equipa   = mapctb.cxacod no-lock no-error.
                if avail tabecf 
                then do:
                    assign vser = tabecf.serie.
                    for each bmapctb where bmapctb.etbcod = estab.etbcod and
                                           bmapctb.datmov >= vdti and
                                           bmapctb.datmov <= vdtf and
                                           bmapctb.ch2 <> "E" no-lock:
                        if bmapctb.ch1 = vser
                        then vdup = "DUPLICADO".
                                                               
                    end.   

                end.    
            end.      
            
            /*
            if int(mapctb.nrofab) > 0  
            then redz = mapctb.nrored + 1.  
            else 
            */
            redz = mapctb.nrored.
            
            
            
            if mapctb.ch1 = "" 
            then find last bmapctb use-index ind-2 
                        where bmapctb.etbcod = mapctb.etbcod and
                              bmapctb.cxacod = mapctb.cxacod and
                               bmapctb.ch2 <> "E"            and  
                              bmapctb.datmov < mapctb.datmov
                                        no-lock no-error.
                                        
            else find last bmapctb use-index ind-1 
                            where bmapctb.ch1    = mapctb.ch1 and
                                  bmapctb.ch2 <> "E"          and    
                                  bmapctb.datmov < mapctb.datmov
                                        no-lock no-error.
                     
                                        
            if avail bmapctb
            then total_inicial = bmapctb.gtotal.
            else total_inicial = mapctb.gtotal -
                                 mapctb.t01 - 
                                 mapctb.t02 -
                                 mapctb.t03 -
                                 mapctb.t05 -
                                 mapctb.vlsub -
                                 mapctb.vlcan + 
                                 mapctb.vlacr.

            /* Evita erros de format */
            if total_inicial < 0
            then total_inicial = 0.
            
            assign tot-valor = (mapctb.t01 + 
                                mapctb.t02 +
                                mapctb.t03 +
                                mapctb.t05 +
                                mapctb.vlsub) +
                                mapctb.vlcan +
                                mapctb.vldes
                                .
                                
                   tot-base  = (mapctb.t01 +  
                                mapctb.t02 + 
                                mapctb.t03 +
                                mapctb.t05 +
                                mapctb.vlsub) .
                               
           /*if mapctb.t16 <> 0
           then tot-icms = mapctb.t16.
           else*/
           
           tot-icms  = (mapctb.t01 * 0.17) + 
                               (mapctb.t03 * 0.07) +
                               ((mapctb.t02 * 0.705889) * 0.17)
                               + (mapctb.t05 * .18) .
               
            total_base = total_base + tot-base.
            total_17 = total_17 + mapctb.t01.
            total_07 = total_07 + mapctb.t03.
            total_12 = total_12 + mapctb.t02.
            total_18 = total_18 + mapctb.t05.
            total_sub = total_sub + mapctb.vlsub.
            total_icms = total_icms + tot-icms.
        
            v-caixa = "CAIXA:" + string(mapctb.de1,"9999") +
                      vdup.
            vcooini = mapctb.cooini.
            vcoofin = mapctb.coofin.
            if vcoofin = 0 then vcoofin = mapctb.nroseq.
            
            put unformatted
/* 001-003 */               string(mapctb.etbcod,">>9")
/* 004-006 */               string(mapctb.cxacod,">>9")
/* 007-026 */               vser format "x(20)"
/* 027-028 */               "2D" format "x(02)"
/* 029-034 */               " " format "x(06)" 
/* 035-038 */               string(year(mapctb.datmov),"9999")  
/* 039-040 */               string(month(mapctb.datmov),"99") 
/* 041-042 */               string(day(mapctb.datmov),"99")
/* 043-049 */               vcooini format "9999999"
/* 050-056 */               vcoofin format "9999999"
/* 057-063 */               redz format "9999999"
/* 064-079 */               "0000000000000.00"
/* 080-095 */               tot-valor format "9999999999999.99"
/* 096-111 */               total_inicial format "9999999999999.99"
/* 112-127 */               mapctb.gtotal format "9999999999999.99"
/* 128-143 */               tot-base format "9999999999999.99"
/* 144-159 */               mapctb.vlcan format "9999999999999.99"
/* 160-175 */               mapctb.vldes format "9999999999999.99"
/* 176-191 */               mapctb.vlacr format "9999999999999.99"
/* 192-207 */               tot-icms format "9999999999999.99" 
/* 208-223 */               mapctb.t05 format "9999999999999.99"           
/* 224-239 */               mapctb.t02 format "9999999999999.99"          
/* 240-255 */               mapctb.t03 format "9999999999999.99"          
/* 256-271 */               mapctb.t04 format "9999999999999.99"          
/* 272-287 */               mapctb.vlsub format "9999999999999.99"          
/* 288-303 */               mapctb.t06 format "9999999999999.99"          
/* 304-319 */               mapctb.t07 format "9999999999999.99"          
/* 320-335 */               mapctb.t08 format "9999999999999.99"          
/* 336-351 */               mapctb.t01 format "9999999999999.99"          
/* 352-367 */               mapctb.t10 format "9999999999999.99"          
/* 368-383 */               "0000000000000.00"
                    /*mapctb.t05 format "9999999999999.99"*/          
/* 384-399 */               "0000000000000.00" /*mapctb.t12 format "9999999999999.99"*/          
/* 400-415 */               "0000000000000.00" /*mapctb.t13 format "9999999999999.99"*/          
/* 416-431 */               "0000000000000.00" /*mapctb.t14 format "9999999999999.99"*/          
/* 432-447 */               "0000000000000.00" /*mapctb.t15 format "9999999999999.99"*/           
/* 448-463 */               "0000000000000.00"  
/* 464-479 */               "0000000000000.00"  
/* 480-495 */               "0000000000000.00"  
/* 496-511 */               "0000000000000.00"  
/* 512-527 */               "0000000000000.00"  
/* 528-543 */               "0000000000000.00"  
/* 544-559 */               "0000000000000.00"  
/* 560-575 */               "0000000000000.00"  
/* 576-591 */               "0000000000000.00"  
/* 592-607 */               "0000000000000.00"
/* 608-615 */               " " format "x(08)"
/* 616-623 */               " " format "x(08)"
/* 624-627 */               string(year(mapctb.datred),"9999")  
/* 628-629 */               string(month(mapctb.datred),"99") 
/* 630-631 */               string(day(mapctb.datred),"99")
/* 632-639 */               " " format "x(08)"
/* 640-646 */               "0000000" format "x(07)"
/**** /* 647-746 */               v-caixa format  "x(100)" skip. */
/* 647-674 */               v-caixa format  "x(28)"
/* 675-691 */               mapctb.t13 format "99999999999999.99"
/* 692-708 */               mapctb.t12 format "99999999999999.99"
/* 709-748 */ " "  format "x(40)"
.

/* 749     */ put (mapctb.t05 * 0.18) /*(mapctb.t01 * 0.17)*/
                    format "99999999999999.99"
/* 765     */     ((mapctb.t02 * 0.705889) * 0.17) format "99999999999999.99"
/* 781     */     (mapctb.t03 * 0.07) format "99999999999999.99"
/* 797     */     "0000000000000.00"
/* 813     */     "0000000000000.00"
/* 829     */     "0000000000000.00"
/* 845     */     "0000000000000.00"
/* 861     */     "0000000000000.00"
/* 877     */     "0000000000000.00"
/* 893     */     "0000000000000.00"
/* 909     */     "0000000000000.00"
/* 925     */     "0000000000000.00"
/* 941     */     "0000000000000.00"
/* 957     */     "0000000000000.00"
/* 973     */     "0000000000000.00"
.
                  put skip.

        total_inicial = 0.
    
        end.
    end.

    output close.

    /*
    display total_base format ">>>,>>>,>>9.99" 
            total_17   format ">>>,>>>,>>9.99"
            total_12   format ">>>,>>>,>>9.99"
            total_07   format ">>>,>>>,>>9.99" 
            total_sub  format ">>>,>>>,>>9.99"
            (total_17 + 
            total_12 + 
            total_07 + 
            total_sub) - total_base format "->>>,>>>,>>9.99"
                                    label "Diferenca"
            total_icms format ">>>,>>>,>>9.99"
                with frame f-tot 1 column. 
            pause.
     */
     
     if opsys = "unix"
     then return.

    
end.
    
        
