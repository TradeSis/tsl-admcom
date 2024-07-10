{admcab.i}
def var total_inicial like plani.platot.
def var vdup as char format "x(15)".
def buffer bmapcxa for mapcxa.
def var redz    like mapcxa.nrored.
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
def var total_17    as dec.
def var total_07    as dec.
def var total_12    as dec.
def var total_sub   as dec.
def var total_icms  as dec.
def var vser as char format "x(20)".

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

    varq = "l:\audit\map" + string(vetbcod,"99") + "_" +
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

        for each mapcxa where mapcxa.etbcod = estab.etbcod and
                              mapcxa.datmov >= vdti        and
                              mapcxa.datmov <= vdtf  no-lock:
                              
            
            vser = mapcxa.ch1.
            if vser = ""
            then do: 
                
                vdup = "".
                find first tabecf where 
                           tabecf.etbcod   = mapcxa.etbcod and
                           int(tabecf.de1) = int(mapcxa.de1)
                                                no-lock no-error.
                if avail tabecf 
                then do:
                    assign vser = tabecf.serie.
                    for each bmapcxa where bmapcxa.etbcod = estab.etbcod and
                                           bmapcxa.datmov >= vdti and
                                           bmapcxa.datmov <= vdtf no-lock:
                        if bmapcxa.ch1 = vser
                        then vdup = "DUPLICADO".
                                                               
                    end.   

                end.    
            end.      
            
  
            if int(mapcxa.nrofab) > 0  
            then redz = mapcxa.nrored + 1.  
            else redz = mapcxa.nrored.

            find last bmapcxa where bmapcxa.etbcod = mapcxa.etbcod and
                                    bmapcxa.cxacod = mapcxa.cxacod and
                                    bmapcxa.datmov < mapcxa.datmov
                                        no-lock no-error.
                                        
            if avail bmapcxa
            then total_inicial = bmapcxa.gtotal.
            else total_inicial = mapcxa.gtotal.
                        
            assign tot-valor = (mapcxa.t01 + 
                                mapcxa.t02 +
                                mapcxa.t03 +
                                mapcxa.vlsub)
                   tot-base  = mapcxa.t01 + 
                               (mapcxa.t03 * 0.41177) +  
                               (mapcxa.t02 * 0.705889) 
                   tot-icms  = (mapcxa.t01 * 0.17) + 
                               (mapcxa.t03 * 0.07) +
                               ((mapcxa.t02 * 0.705889) * 0.17).
               
            total_base = total_base + tot-base.
            total_17 = total_17 + mapcxa.t01.
            total_07 = total_07 + mapcxa.t03.
            total_12 = total_12 + mapcxa.t02.
            total_sub = total_sub + mapcxa.vlsub.
            total_icms = total_icms + tot-icms.
        
            v-caixa = "CAIXA:" + string(mapcxa.de1,"999") +
                      vdup.
            
            put unformatted
/* 001-003 */               string(mapcxa.etbcod,">>9")
/* 004-006 */               string(mapcxa.cxacod,">>9")
/* 007-026 */               vser format "x(20)"
/* 027-028 */               "1" format "x(02)"
/* 029-034 */               " " format "x(06)" 
/* 035-038 */               string(year(mapcxa.datmov),"9999")  
/* 039-040 */               string(month(mapcxa.datmov),"99") 
/* 041-042 */               string(day(mapcxa.datmov),"99")
/* 043-049 */               mapcxa.cooini format "9999999"
/* 050-056 */               mapcxa.coofin format "9999999"
/* 057-063 */               redz format "9999999"
/* 064-079 */               "0000000000000.00"
/* 080-095 */               tot-valor format "9999999999999.99"
/* 096-111 */               total_inicial format "9999999999999.99"
/* 112-127 */               mapcxa.gtotal format "9999999999999.99"
/* 128-143 */               tot-base format "9999999999999.99"
/* 144-159 */               mapcxa.vlcan format "9999999999999.99"
/* 160-175 */               mapcxa.vldes format "9999999999999.99"
/* 176-191 */               mapcxa.vlacr format "9999999999999.99"
/* 192-207 */               tot-icms format "9999999999999.99" 
/* 208-223 */               mapcxa.t01 format "9999999999999.99"           
/* 224-239 */               mapcxa.t02 format "9999999999999.99"          
/* 240-255 */               mapcxa.t03 format "9999999999999.99"          
/* 256-271 */               mapcxa.t04 format "9999999999999.99"          
/* 272-287 */               mapcxa.vlsub format "9999999999999.99"          
/* 288-303 */               mapcxa.t06 format "9999999999999.99"          
/* 304-319 */               mapcxa.t07 format "9999999999999.99"          
/* 320-335 */               mapcxa.t08 format "9999999999999.99"          
/* 336-351 */               mapcxa.t09 format "9999999999999.99"          
/* 352-367 */               mapcxa.t10 format "9999999999999.99"          
/* 368-383 */               mapcxa.t11 format "9999999999999.99"          
/* 384-399 */               mapcxa.t12 format "9999999999999.99"          
/* 400-415 */               mapcxa.t13 format "9999999999999.99"          
/* 416-431 */               mapcxa.t14 format "9999999999999.99"          
/* 432-447 */               mapcxa.t15 format "9999999999999.99"           
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
/* 624-627 */               string(year(mapcxa.datred),"9999")  
/* 628-629 */               string(month(mapcxa.datred),"99") 
/* 630-631 */               string(day(mapcxa.datred),"99")
/* 632-639 */               " " format "x(08)"
/* 640-646 */               "0000000" format "x(07)"
/* 647-746 */               v-caixa format "x(100)" skip.
    
        end.
    end.

    output close.

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


    
end.
    
        
