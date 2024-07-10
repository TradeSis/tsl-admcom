{admcab.i }
def var total_base  as dec.
def var total_17    as dec.
def var total_07    as dec.
def var total_12    as dec.
def var total_sub   as dec.
def var total_icms  as dec.
def var vser as char.
def stream stela.
def var varq as char. 
def var vnum like caixa.cxacod.

def var vicms17 like serial.icm17.
def var vequ as char format "x(20)".

def var v-caixa as char.
def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var vativo  as log.

    
def var vprocod like produ.procod.
def var vfil      like estab.etbcod.
def var tot-valor like plani.platot.
def var tot-base  like plani.platot.
def var tot-icms  like plani.platot.
def buffer bestab for estab.

def temp-table tt-ecf
    field etbcod like estab.etbcod
    field cxacod like caixa.cxacod
    field codecf as int format "99999"
        index ind-1 etbcod
                    cxacod.



def var v-ecf as int format ">>>>>>>>>>>>>99".
def var vcgc as char format "x(14)".
def var ii as int.
def var valor-contabil like plani.platot.
    

def temp-table tt-icms
    field procod like produ.procod
    field dtini  like plani.pladat
    field dtfin  like plani.pladat
    field ativo  as log
        index ind-1 procod.




def temp-table tt-07
    field etbcod like estab.etbcod
    field cxacod like plani.cxacod
    field data   like plani.pladat
    field valor  like plani.platot.
    

def var val07 as dec.

def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vopccod as char.
def var vali    as int.



repeat:
    
    

    
    
    input from l:\progr\tt-ecf.txt.
    repeat:
        create tt-ecf.
        import tt-ecf.
    end.
    input close.
    
    
    for each tt-ecf where tt-ecf.etbcod = 0.
        delete tt-ecf.
    end.

    
    for each tt-07. 
        delete tt-07. 
    end.
    
    for each tt-icms:
        delete tt-icms.
    end.
    
   
    
    update vetbcod with frame f1.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom with frame f1.
    else do:
    
        find estab where estab.etbcod = vetbcod no-lock.

        display estab.etbnom no-label with frame f1.
        
    end.
    

    
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1 side-label width 80.

 


    
    input from ..\progr\icms.txt.
    repeat:
        import vprocod
               vdtini
               vdtfin
               vativo.
        find first tt-icms where tt-icms.procod = vprocod no-error.
        if not avail tt-icms
        then do:
               
        
            create tt-icms.
            assign tt-icms.procod = vprocod
                   tt-icms.dtini  = vdtini
                   tt-icms.dtfin  = vdtfin
                   tt-icms.ativo  = vativo.
                   
                   
            
        end.
        
    end.
    input close.
    
    for each tt-icms.

        find produ where produ.procod = tt-icms.procod no-lock no-error.
        if not avail produ
        then do:
            delete tt-icms.
            next.
        end.
    
    end.    
     
    assign tot-valor = 0 
           tot-base  = 0 
           tot-icms  = 0.

    
    
    for each tt-icms where tt-icms.dtini <= vdti and
                           tt-icms.dtfin >= vdtf:   

  
        for each estab where if vetbcod = 0
                             then true
                             else estab.etbcod = vetbcod no-lock,
            each movim where movim.etbcod = estab.etbcod and
                             movim.movtdc = 5            and
                             movim.movdat >= vdti        and
                             movim.movdat <= vdtf        and
                             movim.procod = tt-icms.procod no-lock.
  
            
            if movim.movdat >= 07/01/2004 and
               movim.movdat <= 07/31/2004
            then do: 
                if movim.procod = 401599 or
                   movim.procod = 402474 or
                   movim.procod = 401599 or
                   movim.procod = 401598
                then next.
            end.

                             
            /*
            if movim.movdat >= 12/22/2004 and
               movim.movdat <= 12/31/2004
            then do:
               
                if movim.procod = 401788 or 
                   movim.procod = 401873 or  
                   movim.procod = 402357
                then next.
                
            end.
            else do:
    
                if movim.procod = 401788 or 
                   movim.procod = 401873 or  
                   movim.procod = 402357 or  
                   movim.procod = 403352   
                then next.

            end.
            */
            
            
            find first plani where plani.etbcod = movim.etbcod and
                             plani.placod = movim.placod and
                             plani.movtdc = movim.movtdc and
                             plani.pladat = movim.movdat no-lock no-error.
        
            if not avail plani
            then next.
                
            
            find first tt-07 where tt-07.etbcod = plani.etbcod and
                                   tt-07.cxacod = plani.cxacod and
                                   tt-07.data   = plani.pladat no-error.
            if not avail tt-07
            then do:
                create tt-07.
                assign tt-07.etbcod = plani.etbcod
                       tt-07.cxacod = plani.cxacod
                       tt-07.data   = plani.pladat.
            end.
            tt-07.valor = tt-07.valor + (movim.movpc * movim.movqtm).
    
            
            /*
            if movim.procod = 402980 or
               movim.procod = 401408 
            then tt-07.valor = tt-07.valor + 
                               ( (movim.movpc * movim.movqtm) * 2).
            
            if movim.procod = 402982 or
               movim.procod = 402880 or
               movim.procod = 402881 or
               movim.procod = 402984 or
               movim.procod = 403094 or
               movim.procod = 402512 or
               movim.procod = 402405 or
               movim.procod = 402409 or
               movim.procod = 402885 or
               movim.procod = 402652 or
               movim.procod = 402651 or
               movim.procod = 402972 or
               movim.procod = 402934 or
               movim.procod = 402656 or
               movim.procod = 402647 or
               movim.procod = 403032 or
               movim.procod = 402832 or
               movim.procod = 402069 or
               movim.procod = 402178
            then tt-07.valor = tt-07.valor + (movim.movpc * movim.movqtm).
            */
                         
            
             
        end.
    
    end.        

 
    varq = "l:\audit\map" + string(vetbcod,">>9") + "_" +
           string(day(vdti),"99") + 
           string(month(vdti),"99") + 
           string(year(vdti),"9999") + "_" + 
          
           string(day(vdtf),"99") + 
           string(month(vdtf),"99") + 
           string(year(vdtf),"9999") + ".txt".

 
    output to value(varq).
    output stream stela to terminal.

      
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each serial where serial.etbcod = estab.etbcod and
                          serial.serdat >= vdti and 
                          serial.serdat <= vdtf no-lock:
    
        
        find first tabecf where tabecf.etbcod   = serial.etbcod and
                                int(tabecf.de1) = serial.cxacod no-lock
                                        no-error.
        if avail tabecf 
        then assign vnum = tabecf.equipa 
                    vser = tabecf.serie.
        else assign vnum = serial.cxacod
                    vser = "".
                                        
                                
        
        find first tt-07 where tt-07.etbcod = serial.etbcod and
                               tt-07.cxacod = serial.cxacod and
                               tt-07.data   = serial.serdat no-error.
        if avail tt-07
        then val07 = tt-07.valor.
        else val07 = 0.
    
        v-ecf = 0.
        find first tt-ecf where tt-ecf.etbcod = serial.etbcod and
                                tt-ecf.cxacod = serial.cxacod no-error.
        if avail tt-ecf
        then v-ecf = tt-ecf.codecf.
                                

        vicms17 = 0.
        
        
        if serial.icm17 > val07
        then do:
        
            assign tot-valor = (serial.icm17 + serial.sersub + serial.icm12)  
                   tot-base  = ((serial.icm17 - val07) + 
                                (val07 * 0.41177)) +  
                                (serial.icm12 * 0.705889) 
                   tot-icms  = ( ((serial.icm17 - val07) * 0.17) 
                               + (val07 * 0.07) ) +
                               ((serial.icm12 * 0.705889) * 0.17)
                   vicms17   = serial.icm17 - val07.
        end.
        else do:
            if serial.icm17 = 0 and
               val07 > 0
            then do:
                
                assign tot-valor = (val07 + serial.sersub + 
                                    serial.icm12)  
                       tot-base  = (val07 * 0.41177) +  
                                   (serial.icm12 * 0.705889) 
                       tot-icms  = (val07 * 0.07) +
                                   ((serial.icm12 * 0.705889) * 0.17).
            end.   
        
        end.
        if serial.icm17 < val07 and
           serial.icm12 = 0     and
           serial.sersub = 0
        then next.
        if serial.icm17 < val07 and
           serial.icm12 > 0  
        then do:
            assign val07 = 0
                   vicms17 = 0 
                   tot-valor = (val07 + serial.sersub + 
                                    serial.icm12)  
                   tot-base  = (val07 * 0.41177) +  
                                   (serial.icm12 * 0.705889) 
                   tot-icms  = (val07 * 0.07) +
                                   ((serial.icm12 * 0.705889) * 0.17).
        end.
        
           
           

        
        tot-base = vicms17 + serial.icm12 + val07 + serial.sersub.

        tot-icms = (vicms17 * 0.17) + 
                   (val07 * 0.07) +
                   (serial.icm12 * 0.12).

        
           
        total_base = total_base + tot-base.
        total_17 = total_17 + vicms17.
        total_07 = total_07 + val07.
        total_12 = total_12 + serial.icm12.
        total_sub = total_sub + serial.sersub.
        total_icms = total_icms + tot-icms.
        
        v-caixa = "CAIXA:" + string(serial.cxacod,"999").
        
        put unformatted
/* 001-003 */               string(serial.etbcod,">>9")
/* 004-006 */               string(vnum,">>9")
/* 007-026 */               vser format "x(20)"
/* 027-028 */               "1" format "x(02)"
/* 029-034 */               " " format "x(06)" 
/* 035-038 */               string(year(serial.serdat),"9999")  
/* 039-040 */               string(month(serial.serdat),"99") 
/* 041-042 */               string(day(serial.serdat),"99")
/* 043-049 */               "0000000"
/* 050-056 */               "0000000"
/* 057-063 */               serial.redcod format "9999999"
/* 064-079 */               "0000000000000.00"
/* 080-095 */               tot-valor format "9999999999999.99"
/* 096-111 */               "0000000000000.00"
/* 112-127 */               "0000000000000.00"
/* 128-143 */               tot-base format "9999999999999.99"
/* 144-159 */               "0000000000000.00"
/* 160-175 */               "0000000000000.00"
/* 176-191 */               "0000000000000.00"
/* 192-207 */               tot-icms format "9999999999999.99" 
/* 208-223 */               vicms17   format "9999999999999.99"
/* 224-239 */               serial.icm12 format "9999999999999.99"          
/* 240-255 */               val07        format "9999999999999.99"          
/* 256-271 */               "0000000000000.00"          
/* 272-287 */               serial.sersub format "9999999999999.99"          
/* 288-303 */               "0000000000000.00"          
/* 304-319 */               "0000000000000.00"          
/* 320-335 */               "0000000000000.00"          
/* 336-351 */               "0000000000000.00"          
/* 352-367 */               "0000000000000.00"          
/* 368-383 */               "0000000000000.00"          
/* 384-399 */               "0000000000000.00"          
/* 400-415 */               "0000000000000.00"          
/* 416-431 */               "0000000000000.00"          
/* 432-447 */               "0000000000000.00"           
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
/* 624-627 */               string(year(serial.serdat),"9999")  
/* 628-629 */               string(month(serial.serdat),"99") 
/* 630-631 */               string(day(serial.serdat),"99")
/* 632-639 */               " " format "x(08)"
/* 640-646 */               "0000000" format "x(07)"
/* 647-746 */               v-caixa format "x(100)" skip.
    
    
    
    
    end.
    output close.
    output stream stela close.


    
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

