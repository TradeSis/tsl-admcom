def var total_inicial like plani.platot.
def var vdup as char format "x(15)".
def buffer bmapctb for mapctb.
def var redz    like mapctb.nrored.
def var v-caixa as char.
def var varq as char.
def input parameter vetbcod like estab.etbcod.
def input parameter vdti like plani.pladat.
def input parameter vdtf like plani.pladat.
def var vopccod as char.
def var vali    as int.
def var tot-valor like plani.platot.
def var tot-base  like plani.platot.
def var tot-icms  like plani.platot.
def var total_base  as dec.
def var total_17    as dec.
def var total_07    as dec.
def var total_12    as dec.
def var total_sub   as dec.
def var total_icms  as dec.
def var vser as char format "x(20)".


    varq = "/admcom/audit/map" + string(vetbcod,"99") + "_" +
           string(day(vdti),"99") + 
           string(month(vdti),"99") + 
           string(year(vdti),"9999") + "_" + 
          
           string(day(vdtf),"99") + 
           string(month(vdtf),"99") + 
           string(year(vdtf),"9999") + ".txt".

 
    output to value(varq).

    for each estab where if vetbcod = 0 
                         then true  
                         else estab.etbcod = vetbcod no-lock:

        for each mapctb where mapctb.etbcod = estab.etbcod and
                              mapctb.datmov >= vdti        and
                              mapctb.datmov <= vdtf  no-lock:
                              
            
            vser = mapctb.ch1.
            if vser = ""
            then do: 
                
                vdup = "".
                find first tabecf where 
                           tabecf.etbcod   = mapctb.etbcod and
                           tabecf.equipa   = mapctb.cxacod no-lock no-error.
                /*
                find first tabecf where 
                           tabecf.etbcod   = mapctb.etbcod and
                           int(tabecf.de1) = int(mapctb.de1)
                                                no-lock no-error.
                */
                if avail tabecf 
                then do:
                    assign vser = tabecf.serie.
                    for each bmapctb where bmapctb.etbcod = estab.etbcod and
                                           bmapctb.datmov >= vdti and
                                           bmapctb.datmov <= vdtf no-lock:
                        if bmapctb.ch1 = vser
                        then vdup = "DUPLICADO".
                                                               
                    end.   

                end.    
            end.      
            
  
            if int(mapctb.nrofab) > 0  
            then redz = mapctb.nrored + 1.  
            else redz = mapctb.nrored.

            find last bmapctb use-index ind-2
                      where bmapctb.etbcod = mapctb.etbcod and
                            bmapctb.cxacod = mapctb.cxacod and
                            bmapctb.datmov < mapctb.datmov
                                        no-lock no-error.
                                        
            if avail bmapctb
            then total_inicial = bmapctb.gtotal.
            else total_inicial = mapctb.gtotal -
                                 mapctb.t01 - 
                                 mapctb.t02 -
                                 mapctb.t03 -
                                 mapctb.vlsub -
                                 mapctb.vlcan + 
                                 mapctb.vlacr.

             
            assign tot-valor = (mapctb.t01 + 
                                mapctb.t02 +
                                mapctb.t03 +
                                mapctb.vlsub)
                                
                                
                   tot-base  = (mapctb.t01 +  
                                mapctb.t02 + 
                                mapctb.t03 +
                                mapctb.vlsub)
                               
                   tot-icms  = (mapctb.t01 * 0.17) + 
                               (mapctb.t03 * 0.07) +
                               ((mapctb.t02 * 0.705889) * 0.17).
               
            total_base = total_base + tot-base.
            total_17 = total_17 + mapctb.t01.
            total_07 = total_07 + mapctb.t03.
            total_12 = total_12 + mapctb.t02.
            total_sub = total_sub + mapctb.vlsub.
            total_icms = total_icms + tot-icms.
        
            v-caixa = "CAIXA:" + string(mapctb.de1,"999") +
                      vdup.
            
            put unformatted
/* 001-003 */               string(mapctb.etbcod,">>9")
/* 004-006 */               string(mapctb.cxacod,">>9")
/* 007-026 */               vser format "x(20)"
/* 027-028 */               "1" format "x(02)"
/* 029-034 */               " " format "x(06)" 
/* 035-038 */               string(year(mapctb.datmov),"9999")  
/* 039-040 */               string(month(mapctb.datmov),"99") 
/* 041-042 */               string(day(mapctb.datmov),"99")
/* 043-049 */               mapctb.cooini format "9999999"
/* 050-056 */               mapctb.coofin format "9999999"
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
/* 208-223 */               mapctb.t01 format "9999999999999.99"           
/* 224-239 */               mapctb.t02 format "9999999999999.99"          
/* 240-255 */               mapctb.t03 format "9999999999999.99"          
/* 256-271 */               mapctb.t04 format "9999999999999.99"          
/* 272-287 */               mapctb.vlsub format "9999999999999.99"          
/* 288-303 */               mapctb.t06 format "9999999999999.99"          
/* 304-319 */               mapctb.t07 format "9999999999999.99"          
/* 320-335 */               mapctb.t08 format "9999999999999.99"          
/* 336-351 */               mapctb.t09 format "9999999999999.99"          
/* 352-367 */               mapctb.t10 format "9999999999999.99"          
/* 368-383 */               mapctb.t11 format "9999999999999.99"          
/* 384-399 */               mapctb.t12 format "9999999999999.99"          
/* 400-415 */               mapctb.t13 format "9999999999999.99"          
/* 416-431 */               mapctb.t14 format "9999999999999.99"          
/* 432-447 */               mapctb.t15 format "9999999999999.99"           
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
/* 647-746 */               v-caixa format "x(100)" skip.
    
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

    
    
        
